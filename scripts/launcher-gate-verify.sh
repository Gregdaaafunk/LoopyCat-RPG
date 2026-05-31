#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

state_script="$repo_root/scripts/claude-review-state.sh"
verify_script="$repo_root/scripts/claude-review-verify.sh"
pre_push_script="$repo_root/scripts/claude-review-pre-push"
tmp_dir="$(mktemp -d)"
tmp_index="$tmp_dir/index"
trap 'rm -rf "$tmp_dir"' EXIT

cp "$repo_root/.git/index" "$tmp_index"
export GIT_INDEX_FILE="$tmp_index"

run_gate() {
  local label="$1"
  local expected_exit="$2"
  local report_status="$3"
  local gate_command="$4"
  local report_path="$tmp_dir/${label}.md"
  local output_path="$tmp_dir/${label}.out"

  git add -A

  {
    printf '%s\n\n' "$report_status"
    printf 'Review ID: launcher-gate-verify-%s\n' "$label"
    printf 'Timestamp: %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
    printf 'Repository State ID: %s\n' "$("$state_script" state-id)"
    printf 'Approved Tree ID: %s\n' "$("$state_script" approved-tree-id)"
    printf 'Claude Exit Code: 0\n'
    printf 'Changed Files:\n'
    "$state_script" changed-files | sed 's/^/- /'
  } > "$report_path"

  set +e
  CLAUDE_REVIEW_REPORT="$report_path" "$gate_command" > "$output_path" 2>&1
  local actual_exit="$?"
  set -e

  if [ "$actual_exit" -eq "$expected_exit" ]; then
    printf 'PASS: %s -> expected exit %s\n' "$label" "$expected_exit"
  else
    printf 'FAIL: %s -> expected exit %s, got %s\n' "$label" "$expected_exit" "$actual_exit" >&2
    sed 's/^/  /' "$output_path" >&2
    exit 1
  fi
}

run_gate "verify-needs-fixes" 1 "NEEDS_FIXES" "$verify_script"
run_gate "verify-rejected" 1 "REJECTED" "$verify_script"
run_gate "verify-approved" 0 "APPROVED" "$verify_script"

run_gate "pre-push-needs-fixes" 1 "NEEDS_FIXES" "$pre_push_script"
run_gate "pre-push-rejected" 1 "REJECTED" "$pre_push_script"
run_gate "pre-push-approved" 0 "APPROVED" "$pre_push_script"

printf 'Gate verification complete.\n'
