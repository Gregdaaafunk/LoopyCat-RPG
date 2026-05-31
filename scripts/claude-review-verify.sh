#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

report_path="${CLAUDE_REVIEW_REPORT:-CLAUDE_REVIEW.md}"
state_script="$repo_root/scripts/claude-review-state.sh"

if ! command -v python3 >/dev/null 2>&1; then
  echo "Claude review verification failed: python3 is required for approval timestamp checks." >&2
  exit 1
fi

if [ ! -f "$report_path" ]; then
  echo "Claude review verification failed: missing $report_path." >&2
  exit 1
fi

status="$(sed -n '1p' "$report_path" | tr -d '\r')"
if [ "$status" != "APPROVED" ]; then
  echo "Claude review verification failed: $report_path status is '$status', not APPROVED." >&2
  exit 1
fi

approved_tree="$(sed -n 's/^Approved Tree ID: //p' "$report_path" | tr -d '\r' | sed -n '1p')"
approved_state="$(sed -n 's/^Repository State ID: //p' "$report_path" | tr -d '\r' | sed -n '1p')"
approved_timestamp="$(sed -n 's/^Timestamp: //p' "$report_path" | tr -d '\r' | sed -n '1p')"

if [ -z "$approved_tree" ] || [ -z "$approved_state" ] || [ -z "$approved_timestamp" ]; then
  echo "Claude review verification failed: $report_path is missing repository state metadata." >&2
  exit 1
fi

current_tree="$("$state_script" approved-tree-id)"
current_state="$("$state_script" state-id)"
staged_tree="$("$state_script" staged-tree-id)"

if [ "$current_state" != "$approved_state" ]; then
  echo "Claude review verification failed: repository state changed after Klavdia APPROVED." >&2
  echo "Approved state: $approved_state" >&2
  echo "Current state:  $current_state" >&2
  exit 1
fi

if [ "$staged_tree" != "$approved_tree" ]; then
  echo "Claude review verification failed: staged commit does not match the APPROVED content." >&2
  echo "Stage every file reviewed by Klavdia, including added/deleted files, and do not stage unrelated files." >&2
  echo "Approved content: $approved_tree" >&2
  echo "Staged content:   $staged_tree" >&2
  exit 1
fi

approved_epoch="$(python3 -c 'import datetime, sys
ts = sys.argv[1]
try:
    dt = datetime.datetime.strptime(ts, "%Y-%m-%dT%H:%M:%SZ").replace(tzinfo=datetime.timezone.utc)
except ValueError:
    raise SystemExit(1)
print(int(dt.timestamp()))' "$approved_timestamp" 2>/dev/null || true)"
if [ -z "$approved_epoch" ]; then
  echo "Claude review verification failed: invalid review timestamp '$approved_timestamp'." >&2
  exit 1
fi

newest_change_epoch="$(
  {
    git diff --cached --name-only --diff-filter=ACMRD -- .
    git diff --name-only --diff-filter=ACMRD -- .
    git ls-files --others --exclude-standard
  } | while IFS= read -r file; do
    [ -n "$file" ] || continue
    [ "$file" = "$report_path" ] && continue
    [ -e "$file" ] && python3 -c 'import os, sys
print(int(os.path.getmtime(sys.argv[1])))' "$file"
  done | sort -nr | sed -n '1p'
)"

if [ -n "$newest_change_epoch" ] && [ "$approved_epoch" -lt "$newest_change_epoch" ]; then
  echo "Claude review verification failed: review timestamp is older than local changes." >&2
  echo "Re-run scripts/claude-review.sh after your latest edits." >&2
  exit 1
fi

echo "Claude review verification: APPROVED."
