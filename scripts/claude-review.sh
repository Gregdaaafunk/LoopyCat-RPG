#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

claude_bin="${CLAUDE_BIN:-claude}"
model="${CLAUDE_REVIEW_MODEL:-sonnet}"
max_diff_bytes="${CLAUDE_REVIEW_MAX_DIFF_BYTES:-220000}"
review_timeout_seconds="${CLAUDE_REVIEW_TIMEOUT_SECONDS:-1800}"
review_retries="${CLAUDE_REVIEW_RETRIES:-1}"
review_heartbeat_seconds="${CLAUDE_REVIEW_HEARTBEAT_SECONDS:-30}"
report_path="${CLAUDE_REVIEW_REPORT:-CLAUDE_REVIEW.md}"
local_env="${CLAUDE_REVIEW_ENV:-$HOME/.config/claude-review/env}"
review_id="$(date -u '+%Y%m%dT%H%M%SZ')-$(git rev-parse --short HEAD)"
review_timestamp="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
state_script="$repo_root/scripts/claude-review-state.sh"
review_started_epoch="$(date +%s)"
blockers=()
failure_category="Review logic"

ts() {
  date -u '+%Y-%m-%dT%H:%M:%SZ'
}

elapsed() {
  local now
  now="$(date +%s)"
  printf '%ss' "$((now - review_started_epoch))"
}

log_line() {
  printf '[%s +%s] %s\n' "$(ts)" "$(elapsed)" "$*" >&2
}

add_blocker() {
  blockers+=("$*")
}

print_final_report() {
  local final_status="$1"
  local next_action="$2"
  {
    printf '\nSTATUS:\n%s\n\n' "$final_status"
    printf 'BLOCKERS:\n'
    if [ "${#blockers[@]}" -eq 0 ]; then
      printf -- '- None\n'
    else
      printf '%s\n' "${blockers[@]}" | sed 's/^/- /'
    fi
    printf '\nNEXT ACTION:\n%s\n' "$next_action"
  } >&2
}

report_pathspec() {
  case "$report_path" in
    "$repo_root"/*)
      printf '%s\n' "${report_path#"$repo_root"/}"
      ;;
    /*)
      return 1
      ;;
    ./*)
      printf '%s\n' "${report_path#./}"
      ;;
    *)
      printf '%s\n' "$report_path"
      ;;
  esac
}

if [ -f "$local_env" ]; then
  # shellcheck disable=SC1090
  source "$local_env"
fi

if ! touch .git/.claude-review-write-test 2>/dev/null; then
  failure_category="Git"
  add_blocker ".git is read-only; cannot create .git/.claude-review-write-test"
  {
    printf 'ERROR\n\n'
    printf 'Review ID: %s\n' "$review_id"
    printf 'Timestamp: %s\n' "$review_timestamp"
    printf 'Repository State ID: unavailable\n'
    printf 'Approved Tree ID: unavailable\n'
    printf 'Claude Exit Code: not_started\n'
    printf 'Changed Files:\n'
    git status --porcelain=v1 | sed 's/^/- /'
    printf '\nError Category: %s\n' "$failure_category"
    printf 'Error: .git is mounted read-only; review skipped because approval state cannot be committed or verified safely.\n'
  } > "$report_path"
  log_line "Git health failure: .git is read-only"
  print_final_report "ERROR" "Fix the .git mount, then run: scripts/klavdia-review.sh"
  exit 5
else
  rm -f .git/.claude-review-write-test
fi

if ! command -v "$claude_bin" >/dev/null 2>&1; then
  if [ -x "/home/gregdafunk/.npm-global/bin/claude" ]; then
    claude_bin="/home/gregdafunk/.npm-global/bin/claude"
  else
    failure_category="Review logic"
    add_blocker "Claude Code is not installed or not on PATH"
    echo "Claude Code is not installed or not on PATH." >&2
    print_final_report "ERROR" "Install Claude Code or set CLAUDE_BIN, then run: scripts/klavdia-review.sh"
    exit 2
  fi
fi

if [ -z "${ANTHROPIC_AUTH_TOKEN:-}" ] && [ -z "${ANTHROPIC_API_KEY:-}" ]; then
  failure_category="Claude API"
  add_blocker "Missing ANTHROPIC_AUTH_TOKEN or ANTHROPIC_API_KEY"
  echo "Missing ANTHROPIC_AUTH_TOKEN or ANTHROPIC_API_KEY." >&2
  echo "Redeem the provider code in the New API console, generate an sk token, then export it locally." >&2
  print_final_report "ERROR" "Configure Claude credentials, then run: scripts/klavdia-review.sh"
  exit 2
fi

if [ -z "${ANTHROPIC_BASE_URL:-}" ]; then
  failure_category="Claude API"
  add_blocker "Missing ANTHROPIC_BASE_URL"
  echo "Missing ANTHROPIC_BASE_URL. For the purchased service, use https://cc.580ai.net after token redemption." >&2
  print_final_report "ERROR" "Set ANTHROPIC_BASE_URL, then run: scripts/klavdia-review.sh"
  exit 2
fi

if git diff --quiet --ignore-submodules -- && git diff --cached --quiet --ignore-submodules -- && [ -z "$(git ls-files --others --exclude-standard)" ]; then
  repository_state_id="$("$state_script" state-id)"
  approved_tree_id="$("$state_script" approved-tree-id)"
  {
    printf 'APPROVED\n\n'
    printf 'Review ID: %s\n' "$review_id"
    printf 'Timestamp: %s\n' "$review_timestamp"
    printf 'Repository State ID: %s\n' "$repository_state_id"
    printf 'Approved Tree ID: %s\n' "$approved_tree_id"
    printf 'Claude Exit Code: not_needed\n'
    printf 'Changed Files:\n'
    printf -- '- none\n'
    printf '\nCritical Fixes:\n- None\n'
    printf '\nImprovement Suggestions:\n- None\n'
    printf '\nDeployment Risks:\n- None\n'
  } > "$report_path"
  echo "No local changes to review."
  print_final_report "APPROVED" "Run: scripts/claude-review-verify.sh"
  exit 0
fi

repository_state_id="$("$state_script" state-id)"
approved_tree_id="$("$state_script" approved-tree-id)"
report_file="$(report_pathspec || true)"
review_pathspecs=(.)
if [ -n "$report_file" ]; then
  review_pathspecs+=(":(exclude)$report_file")
fi

changed_files="$(git status --porcelain=v1 | sed 's/^...//' | grep -Fvx "$report_file" || true)"
blocked_patterns='(^|/)(\.env|secrets?|private|credentials?|certs?)(\.|/|$)|\.(p8|p12|pem|key|mobileprovision|cer|cert)$|AppStoreConnect|ASC_KEY|MATCH_PASSWORD|FASTLANE_PASSWORD'
if printf '%s\n' "$changed_files" | grep -Eiq "$blocked_patterns"; then
  failure_category="Repository state"
  add_blocker "Potentially sensitive file changes detected"
  echo "Refusing to send potentially sensitive file changes to Claude." >&2
  printf '%s\n' "$changed_files" | grep -Ei "$blocked_patterns" >&2
  print_final_report "ERROR" "Remove sensitive files from the diff, then run: scripts/klavdia-review.sh"
  exit 3
fi

tmp_dir="$(mktemp -d)"
heartbeat_pid=""
cleanup() {
  if [ -n "$heartbeat_pid" ]; then
    kill "$heartbeat_pid" 2>/dev/null || true
    wait "$heartbeat_pid" 2>/dev/null || true
  fi
  rm -rf "$tmp_dir"
}
trap cleanup EXIT
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
  git diff --cached --no-ext-diff --minimal -- "${review_pathspecs[@]}"
  git diff --no-ext-diff --minimal -- "${review_pathspecs[@]}"
} > "$diff_file"

diff_bytes="$(wc -c < "$diff_file" | tr -d ' ')"
if [ "$diff_bytes" -gt "$max_diff_bytes" ]; then
  failure_category="Repository state"
  add_blocker "Diff is ${diff_bytes} bytes, above CLAUDE_REVIEW_MAX_DIFF_BYTES=${max_diff_bytes}"
  echo "Diff is ${diff_bytes} bytes, above CLAUDE_REVIEW_MAX_DIFF_BYTES=${max_diff_bytes}." >&2
  echo "Split the change or raise the limit deliberately." >&2
  print_final_report "ERROR" "Split the change or deliberately raise CLAUDE_REVIEW_MAX_DIFF_BYTES, then run: scripts/klavdia-review.sh"
  exit 4
fi

append_untracked_file_summary() {
  local file="$1"
  local file_type
  local file_size

  [ -f "$file" ] || return 0

  file_type="$(file --brief -- "$file")"
  file_size="$(wc -c < "$file" | tr -d ' ')"

  {
    printf '\n--- BEGIN UNTRACKED FILE: %s ---\n' "$file"
    printf 'type: %s\n' "$file_type"
    printf 'bytes: %s\n' "$file_size"
  } >> "$untracked_file"

  if printf '%s\n' "$file_type" | grep -Eiq 'text|json|xml|source|script|markdown|yaml|plist'; then
    sed -n '1,240p' "$file" >> "$untracked_file"
  else
    printf 'content: binary content not sent to reviewer\n' >> "$untracked_file"
  fi

  printf -- '--- END UNTRACKED FILE: %s ---\n' "$file" >> "$untracked_file"
}

while IFS= read -r file; do
  [ -z "$file" ] && continue
  if printf '%s\n' "$file" | grep -Eiq "$blocked_patterns"; then
    failure_category="Repository state"
    add_blocker "Potentially sensitive untracked file: $file"
    echo "Refusing to send potentially sensitive untracked file: $file" >&2
    print_final_report "ERROR" "Remove sensitive files from the working tree, then run: scripts/klavdia-review.sh"
    exit 3
  fi
  append_untracked_file_summary "$file"
done < <(git ls-files --others --exclude-standard -- "${review_pathspecs[@]}")

cat > "$prompt_file" <<'PROMPT'
You are Claude Code acting only as a read-only reviewer, architecture auditor, quality gate, and risk auditor for LoopyCat-RPG.

Return exactly one of these status labels as the first line:
APPROVED
NEEDS_FIXES
REJECTED

Review the provided git status, diff, and untracked file metadata/excerpts. Do not ask to deploy, push, commit, access secrets, or run release tasks. You are not the implementer. Identify concrete defects and architectural risks only.

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
  git status --short --branch -- "${review_pathspecs[@]}"
  printf '```\n\nDiff stat:\n\n```text\n'
  git diff --stat --cached -- "${review_pathspecs[@]}"
  git diff --stat -- "${review_pathspecs[@]}"
  printf '```\n\nDiff:\n\n```diff\n'
  cat "$diff_file"
  printf '\n```\n'
  if [ -s "$untracked_file" ]; then
    printf '\nUntracked file metadata and excerpts:\n\n```text\n'
    cat "$untracked_file"
    printf '\n```\n'
  fi
} >> "$prompt_file"

claude_output="$tmp_dir/claude-output.txt"
review_exit=0
status_line_number=0
attempt=0
max_attempts=$((review_retries + 1))
while [ "$attempt" -lt "$max_attempts" ]; do
  attempt=$((attempt + 1))
  : > "$claude_output"
  log_line "Claude request start (attempt ${attempt}/${max_attempts}, model=$model)"
  (
    trap 'exit 0' TERM INT
    while true; do
      sleep "$review_heartbeat_seconds" &
      wait "$!" || exit 0
      log_line "Heartbeat: waiting for Claude response (attempt ${attempt}/${max_attempts})"
    done
  ) &
  heartbeat_pid="$!"
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
  kill "$heartbeat_pid" 2>/dev/null || true
  wait "$heartbeat_pid" 2>/dev/null || true
  log_line "Claude response received (attempt ${attempt}/${max_attempts}, exit=$review_exit)"
  if [ "$review_exit" -eq 0 ] && [ -s "$claude_output" ]; then
    candidate_status="$(awk 'NF { gsub(/\r$/, ""); print; exit }' "$claude_output")"
    case "$candidate_status" in
      APPROVED|NEEDS_FIXES|REJECTED)
        break
        ;;
      *)
        log_line "Claude response did not include a valid final status: ${candidate_status:-empty}"
        ;;
    esac
  fi
  if [ "$attempt" -lt "$max_attempts" ]; then
    log_line "Retrying Claude request after failed/empty response"
    sleep 2
  fi
done

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
    printf 'Claude Attempts: %s/%s\n' "$attempt" "$max_attempts"
    printf 'Changed Files:\n'
    "$state_script" changed-files | sed 's/^/- /'
    if [ -n "$report_message" ]; then
      printf '\nError: %s\n' "$report_message"
    fi
    printf '\nError Category: %s\n' "$failure_category"
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
        failure_category="Claude API"
        report_message="Claude review failed with exit code ${review_exit}."
      else
        failure_category="Network"
        report_message="Claude review produced no output."
      fi
      ;;
  esac
fi

write_report "$status" "$report_message"

case "$status" in
  APPROVED)
    echo "Claude review approved."
    print_final_report "APPROVED" "Run: scripts/claude-review-verify.sh"
    ;;
  NEEDS_FIXES|REJECTED)
    add_blocker "Klavdia returned $status; see Critical Fixes in $report_path"
    echo "Claude review returned $status. Fixes are required before commit/push/deploy." >&2
    print_final_report "$status" "Fix blockers in $report_path, then run: scripts/klavdia-review.sh"
    exit 1
    ;;
  ERROR)
    add_blocker "${report_message:-unknown error}"
    echo "Claude review failed: ${report_message:-unknown error}" >&2
    print_final_report "ERROR" "Fix ${failure_category} failure, then run: scripts/klavdia-review.sh"
    exit 5
    ;;
esac
