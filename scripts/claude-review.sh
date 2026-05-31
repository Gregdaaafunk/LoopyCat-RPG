#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

claude_bin="${CLAUDE_BIN:-claude}"
model="${CLAUDE_REVIEW_MODEL:-sonnet}"
max_diff_bytes="${CLAUDE_REVIEW_MAX_DIFF_BYTES:-220000}"
review_timeout_seconds="${CLAUDE_REVIEW_TIMEOUT_SECONDS:-1800}"
report_path="${CLAUDE_REVIEW_REPORT:-CLAUDE_REVIEW.md}"
local_env="${CLAUDE_REVIEW_ENV:-$HOME/.config/claude-review/env}"
review_id="$(date -u '+%Y%m%dT%H%M%SZ')-$(git rev-parse --short HEAD)"
review_timestamp="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
state_script="$repo_root/scripts/claude-review-state.sh"

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

repository_state_id="$("$state_script" state-id)"
approved_tree_id="$("$state_script" approved-tree-id)"

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
You are Claude Code acting only as a read-only reviewer, architecture auditor, quality gate, and risk auditor for LoopyCat-RPG.

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

Critical Fixes:
- concrete blocker, or "None"

Improvement Suggestions:
- non-blocking improvement, or "None"

Deployment Risks:
- deployment or future release risk, or "None"

Approve only when the exact repository state is ready for commit/push/deployment gate.
PROMPT

{
  printf '\nReview metadata:\n\n```text\n'
  printf 'review_id: %s\n' "$review_id"
  printf 'timestamp: %s\n' "$review_timestamp"
  printf 'repository_state_id: %s\n' "$repository_state_id"
  printf 'approved_tree_id: %s\n' "$approved_tree_id"
  printf '```\n'
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

claude_output="$tmp_dir/claude-output.txt"
review_exit=0
status_line_number=0
set +e
timeout --foreground --kill-after=10s "$review_timeout_seconds" \
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
  --output-format text < "$prompt_file" | tee "$claude_output"
review_exit="${PIPESTATUS[0]}"
set -e

write_report() {
  local report_status="$1"
  local report_message="${2:-}"

  {
    printf '%s\n\n' "$report_status"
    printf 'Review ID: %s\n' "$review_id"
    printf 'Timestamp: %s\n' "$review_timestamp"
    printf 'Repository State ID: %s\n' "$repository_state_id"
    printf 'Approved Tree ID: %s\n' "$approved_tree_id"
    printf 'Claude Exit Code: %s\n' "$review_exit"
    printf 'Changed Files:\n'
    "$state_script" changed-files | sed 's/^/- /'
    if [ -n "$report_message" ]; then
      printf '\nError: %s\n' "$report_message"
    fi
    if [ -s "$claude_output" ]; then
      printf '\n'
      if [ "$status_line_number" -gt 0 ]; then
        tail -n +"$((status_line_number + 1))" "$claude_output"
      else
        cat "$claude_output"
      fi
    fi
  } > "$report_path"
}

status="ERROR"
report_message=""

if [ "$review_exit" -eq 0 ] && [ -s "$claude_output" ]; then
  status="$(awk 'NF { gsub(/\r$/, ""); print; exit }' "$claude_output")"
  status_line_number="$(awk 'NF { print NR; exit }' "$claude_output")"
  status_line_number="${status_line_number:-0}"
  case "$status" in
    APPROVED|NEEDS_FIXES|REJECTED)
      ;;
    *)
      report_message="Claude returned an invalid status: $status"
      status="ERROR"
      ;;
  esac
else
  case "$review_exit" in
    124)
      report_message="Claude review timed out after ${review_timeout_seconds}s."
      ;;
    *)
      if [ -s "$claude_output" ]; then
        report_message="Claude review failed with exit code ${review_exit}."
      else
        report_message="Claude review produced no output."
      fi
      ;;
  esac
fi

write_report "$status" "$report_message"

case "$status" in
  APPROVED)
    echo "Claude review approved."
    ;;
  NEEDS_FIXES|REJECTED)
    echo "Claude review returned $status. Fixes are required before commit/push/deploy." >&2
    exit 1
    ;;
  ERROR)
    echo "Claude review failed: ${report_message:-unknown error}" >&2
    exit 5
    ;;
esac
