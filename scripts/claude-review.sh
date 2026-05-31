#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

claude_bin="${CLAUDE_BIN:-claude}"
model="${CLAUDE_REVIEW_MODEL:-sonnet}"
max_diff_bytes="${CLAUDE_REVIEW_MAX_DIFF_BYTES:-220000}"
report_path="${CLAUDE_REVIEW_REPORT:-CLAUDE_REVIEW.md}"
local_env="${CLAUDE_REVIEW_ENV:-$HOME/.config/claude-review/env}"

if [ -f "$local_env" ]; then
  # shellcheck disable=SC1090
  source "$local_env"
fi

if ! command -v "$claude_bin" >/dev/null 2>&1; then
  if [ -x "/home/gregdafunk/.npm-global/bin/claude" ]; then
    claude_bin="/home/gregdafunk/.npm-global/bin/claude"
  else
    echo "Claude Code is not installed or not on PATH." >&2
    exit 2
  fi
fi

if [ -z "${ANTHROPIC_AUTH_TOKEN:-}" ] && [ -z "${ANTHROPIC_API_KEY:-}" ]; then
  echo "Missing ANTHROPIC_AUTH_TOKEN or ANTHROPIC_API_KEY." >&2
  echo "Redeem the provider code in the New API console, generate an sk token, then export it locally." >&2
  exit 2
fi

if [ -z "${ANTHROPIC_BASE_URL:-}" ]; then
  echo "Missing ANTHROPIC_BASE_URL. For the purchased service, use https://cc.580ai.net after token redemption." >&2
  exit 2
fi

if git diff --quiet --ignore-submodules -- && git diff --cached --quiet --ignore-submodules -- && [ -z "$(git ls-files --others --exclude-standard)" ]; then
  echo "No local changes to review."
  exit 0
fi

changed_files="$(git status --porcelain=v1 | sed 's/^...//')"
blocked_patterns='(^|/)(\.env|secrets?|private|credentials?|certs?)(\.|/|$)|\.(p8|p12|pem|key|mobileprovision|cer|cert)$|AppStoreConnect|ASC_KEY|MATCH_PASSWORD|FASTLANE_PASSWORD'
if printf '%s\n' "$changed_files" | grep -Eiq "$blocked_patterns"; then
  echo "Refusing to send potentially sensitive file changes to Claude." >&2
  printf '%s\n' "$changed_files" | grep -Ei "$blocked_patterns" >&2
  exit 3
fi

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT
prompt_file="$tmp_dir/claude-review-prompt.md"
diff_file="$tmp_dir/diff.txt"
untracked_file="$tmp_dir/untracked.txt"
mcp_config="$tmp_dir/mcp-empty.json"
settings_file="$tmp_dir/settings.json"

cat > "$mcp_config" <<'JSON'
{
  "mcpServers": {}
}
JSON

cat > "$settings_file" <<'JSON'
{
  "permissions": {
    "allow": [],
    "deny": [
      "Bash",
      "Edit",
      "MultiEdit",
      "Write",
      "NotebookEdit",
      "WebFetch",
      "WebSearch"
    ]
  },
  "env": {
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1",
    "API_TIMEOUT_MS": "60000"
  }
}
JSON

{
  git diff --cached --no-ext-diff --minimal -- .
  git diff --no-ext-diff --minimal -- .
} > "$diff_file"

diff_bytes="$(wc -c < "$diff_file" | tr -d ' ')"
if [ "$diff_bytes" -gt "$max_diff_bytes" ]; then
  echo "Diff is ${diff_bytes} bytes, above CLAUDE_REVIEW_MAX_DIFF_BYTES=${max_diff_bytes}." >&2
  echo "Split the change or raise the limit deliberately." >&2
  exit 4
fi

while IFS= read -r file; do
  [ -z "$file" ] && continue
  if printf '%s\n' "$file" | grep -Eiq "$blocked_patterns"; then
    echo "Refusing to send potentially sensitive untracked file: $file" >&2
    exit 3
  fi
  if [ -f "$file" ] && file "$file" | grep -Eiq 'text|json|xml|source|script|markdown|yaml|plist'; then
    {
      printf '\n--- BEGIN UNTRACKED FILE: %s ---\n' "$file"
      sed -n '1,240p' "$file"
      printf '\n--- END UNTRACKED FILE: %s ---\n' "$file"
    } >> "$untracked_file"
  fi
done < <(git ls-files --others --exclude-standard)

cat > "$prompt_file" <<'PROMPT'
You are Claude Code acting only as a read-only reviewer and architect for LoopyCat-RPG.

Return exactly one of these status labels as the first line:
APPROVED
NEEDS_FIXES
REJECTED

Review the provided git status, diff, and untracked file excerpts. Do not ask to deploy, push, commit, access secrets, or run release tasks. You are not the implementer. Identify concrete defects and architectural risks only.

Focus on:
- Swift and SwiftUI correctness, lifecycle, state management, async behavior, and rendering pitfalls.
- Local storage, photo/camera permissions, asset handling, data loss, and privacy risks.
- Build, signing, Fastlane, GitHub Actions, and TestFlight deployment risks.
- Unnecessary or risky file modifications.
- Missing tests or verification that materially affect this change.
- Any accidental credential or secret exposure.

Use this response shape:
STATUS

Findings:
- severity: file:line or file: issue and fix

Required Fixes:
- concrete required fix, or "None"

Notes:
- optional non-blocking observations

Approve only when the change is ready for commit/push/deployment gate.
PROMPT

{
  printf '\nRepository status:\n\n```text\n'
  git status --short --branch
  printf '```\n\nDiff stat:\n\n```text\n'
  git diff --stat --cached -- .
  git diff --stat -- .
  printf '```\n\nDiff:\n\n```diff\n'
  cat "$diff_file"
  printf '\n```\n'
  if [ -s "$untracked_file" ]; then
    printf '\nUntracked file excerpts:\n\n```text\n'
    cat "$untracked_file"
    printf '\n```\n'
  fi
} >> "$prompt_file"

"$claude_bin" \
  --print \
  --model "$model" \
  --permission-mode dontAsk \
  --tools "" \
  --disable-slash-commands \
  --strict-mcp-config \
  --mcp-config "$mcp_config" \
  --settings "$settings_file" \
  --no-session-persistence \
  --output-format text < "$prompt_file" | tee "$report_path"

status="$(sed -n '1p' "$report_path" | tr -d '\r')"
case "$status" in
  APPROVED)
    echo "Claude review approved."
    ;;
  NEEDS_FIXES|REJECTED)
    echo "Claude review returned $status. Fixes are required before commit/push/deploy." >&2
    exit 1
    ;;
  *)
    echo "Claude review returned an invalid status: $status" >&2
    exit 5
    ;;
esac
