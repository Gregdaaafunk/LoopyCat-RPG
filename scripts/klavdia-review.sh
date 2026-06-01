#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

report_path="${CLAUDE_REVIEW_REPORT:-CLAUDE_REVIEW.md}"
review_timeout_seconds="${CLAUDE_REVIEW_OUTER_TIMEOUT_SECONDS:-2100}"
inner_review_timeout_seconds="${CLAUDE_REVIEW_TIMEOUT_SECONDS:-1800}"
inner_review_retries="${CLAUDE_REVIEW_RETRIES:-1}"
if [ -z "${CLAUDE_REVIEW_OUTER_TIMEOUT_SECONDS:-}" ]; then
  minimum_outer_timeout=$((inner_review_timeout_seconds * (inner_review_retries + 1) + 120))
  if [ "$review_timeout_seconds" -lt "$minimum_outer_timeout" ]; then
    review_timeout_seconds="$minimum_outer_timeout"
  fi
fi
review_heartbeat_seconds="${CLAUDE_REVIEW_HEARTBEAT_SECONDS:-30}"
tmp_output="$(mktemp)"
duplicate_report=""
heartbeat_pid=""
cleanup() {
  if [ -n "$heartbeat_pid" ]; then
    kill "$heartbeat_pid" 2>/dev/null || true
    wait "$heartbeat_pid" 2>/dev/null || true
  fi
  rm -f "$tmp_output"
  if [ -n "$duplicate_report" ]; then
    rm -f "$duplicate_report"
  fi
}
trap cleanup EXIT
review_started_epoch="$(date +%s)"
blockers=()

ts() {
  date -u '+%Y-%m-%dT%H:%M:%SZ'
}

elapsed() {
  local now
  now="$(date +%s)"
  printf '%ss' "$((now - review_started_epoch))"
}

log_line() {
  printf '[%s +%s] %s\n' "$(ts)" "$(elapsed)" "$*"
}

add_blocker() {
  blockers+=("$*")
}

print_final_report() {
  local status="$1"
  local next_action="$2"
  echo
  echo "STATUS:"
  echo "$status"
  echo
  echo "BLOCKERS:"
  if [ "${#blockers[@]}" -eq 0 ]; then
    echo "- None"
  else
    printf '%s\n' "${blockers[@]}" | sed 's/^/- /'
  fi
  echo
  echo "NEXT ACTION:"
  echo "$next_action"
}

redact_secrets() {
  sed -E \
    -e 's/(ANTHROPIC_AUTH_TOKEN=)"[^"]+"/\1"REDACTED"/g' \
    -e 's/(ANTHROPIC_API_KEY=)"[^"]+"/\1"REDACTED"/g' \
    -e 's/(Authorization:[[:space:]]*Bearer[[:space:]]+)[A-Za-z0-9._~+\/=-]+/\1REDACTED/Ig' \
    -e 's/(x-api-key:[[:space:]]*)[A-Za-z0-9._~+\/=-]+/\1REDACTED/Ig' \
    -e 's/sk-[A-Za-z0-9._~+\/=-]{12,}/sk-REDACTED/g'
}

changed_files="$(git status --porcelain=v1)"
changed_count="$(printf '%s\n' "$changed_files" | sed '/^$/d' | wc -l | tr -d ' ')"
branch="$(git branch --show-current 2>/dev/null || git rev-parse --short HEAD)"
staged_count="$(git diff --cached --name-only --diff-filter=ACMRD -- . | sort -u | wc -l | tr -d ' ')"
unstaged_count="$(git diff --name-only --diff-filter=ACMRD -- . | sort -u | wc -l | tr -d ' ')"
untracked_count="$(git ls-files --others --exclude-standard | sort -u | wc -l | tr -d ' ')"

git_writable=1
if ! touch .git/.klavdia-write-test 2>/dev/null; then
  git_writable=0
  add_blocker ".git is read-only; cannot create .git/.klavdia-write-test"
else
  rm -f .git/.klavdia-write-test
fi

echo "Klavdia Visible Review"
echo "======================"
echo
echo "Reviewer: Klavdia (Claude Code)"
echo "Mode: reviewer and architecture auditor only"
echo "Authority: no push, no deploy, no secrets, no tool access"
echo "Live mode: enabled"
echo
log_line "Review started"
echo
echo "Repository diagnostics:"
echo "  branch: ${branch:-DETACHED}"
echo "  changed file entries: $changed_count"
echo "  staged file count: $staged_count"
echo "  unstaged file count: $unstaged_count"
echo "  untracked file count: $untracked_count"
echo "  .git writable: $([ "$git_writable" -eq 1 ] && echo YES || echo NO)"
echo
echo "Duplicate diagnostics:"
duplicate_report="$(mktemp)"
{
  find 03_AR/ARC Asset 04_Content -type f ! -name '.gitkeep' 2>/dev/null | while IFS= read -r file; do
    if command -v shasum >/dev/null 2>&1; then
      printf '%s  %s\n' "$(shasum -a 256 "$file" | awk '{print $1}')" "$file"
    else
      printf '%s  %s\n' "$(sha256sum "$file" | awk '{print $1}')" "$file"
    fi
  done | sort | awk '
    BEGIN { last=""; group="" }
    {
      hash=$1
      file=$0
      sub(/^[^ ]+  /, "", file)
      if (hash != last && group_count > 1) {
        print "duplicate content group: " group
      }
      if (hash != last) {
        group=file
        group_count=1
        last=hash
      } else {
        group=group ", " file
        group_count++
      }
    }
    END {
      if (group_count > 1) {
        print "duplicate content group: " group
      }
    }
  '
} > "$duplicate_report"
if [ -s "$duplicate_report" ]; then
  sed 's/^/  - /' "$duplicate_report"
else
  echo "  none"
fi
echo

if [ "$git_writable" -eq 0 ]; then
  {
    printf 'ERROR\n\n'
    printf 'Review ID: unavailable\n'
    printf 'Timestamp: %s\n' "$(ts)"
    printf 'Repository State ID: unavailable\n'
    printf 'Approved Tree ID: unavailable\n'
    printf 'Claude Exit Code: not_started\n'
    printf 'Changed Files:\n'
    printf '%s\n' "$changed_files" | sed 's/^/- /'
    printf '\nError Category: Git\n'
    printf 'Error: .git is mounted read-only; review skipped because commit/push gates cannot be updated safely.\n'
  } > "$report_path"
  log_line "Fail fast: .git is read-only"
  print_final_report "ERROR" "Fix the .git mount, then run: scripts/klavdia-review.sh"
  exit 2
fi

echo "Changed files (${changed_count}):"
if [ "$changed_count" = "0" ]; then
  echo "  none"
else
  printf '%s\n' "$changed_files" | sed 's/^/  /'
fi
echo
echo "Review scope:"
echo "  - git status"
echo "  - staged and unstaged diffs"
echo "  - safe text excerpts from untracked files"
echo "  - SwiftUI, storage, deployment risk, architecture, and quality-gate issues"
if [ -x scripts/claude-review-state.sh ]; then
  echo "  - repository state id: $(scripts/claude-review-state.sh state-id)"
  echo "  - approved tree id candidate: $(scripts/claude-review-state.sh approved-tree-id)"
fi
echo
echo "Claude output:"
echo "--------------"
log_line "Klavdia reviewing..."
log_line "Reading changed files..."
sleep 0.15
log_line "Checking SwiftUI layout..."
sleep 0.15
log_line "Checking architecture..."
sleep 0.15
log_line "Checking diagnostics..."
sleep 0.15
log_line "Checking deployment risks..."
sleep 0.15
log_line "Generating findings..."
sleep 0.15
log_line "Generating final report..."
log_line "Claude request start"

(
  trap 'exit 0' TERM INT
  while true; do
    sleep "$review_heartbeat_seconds" &
    wait "$!" || exit 0
    log_line "Heartbeat: waiting for Claude response"
  done
) &
heartbeat_pid="$!"

set +e
timeout --foreground --kill-after=10s "$review_timeout_seconds" scripts/claude-review.sh 2>&1 | tee "$tmp_output" | redact_secrets
pipeline_status=("${PIPESTATUS[@]}")
review_exit="${pipeline_status[0]}"
set -e
kill "$heartbeat_pid" 2>/dev/null || true
wait "$heartbeat_pid" 2>/dev/null || true
log_line "Claude response received with exit code $review_exit"

status="ERROR"
report_needs_fallback=1
if [ -f "$report_path" ]; then
  status="$(sed -n '1p' "$report_path" | tr -d '\r')"
  case "$status" in
    APPROVED|NEEDS_FIXES|REJECTED|ERROR)
      report_needs_fallback=0
      ;;
    *)
      status="ERROR"
      ;;
  esac
fi

if [ "$review_exit" -ne 0 ]; then
  case "$status" in
    NEEDS_FIXES|REJECTED|ERROR)
      ;;
    *)
      status="ERROR"
      report_needs_fallback=1
      add_blocker "Review process exited with code $review_exit and did not produce a current actionable report"
      ;;
  esac
fi

if [ "$report_needs_fallback" -eq 1 ]; then
  add_blocker "Review process did not produce a valid report"
  {
    printf 'ERROR\n\n'
    printf 'Review ID: unavailable\n'
    printf 'Timestamp: %s\n' "$(ts)"
    printf 'Repository State ID: unavailable\n'
    printf 'Approved Tree ID: unavailable\n'
    printf 'Claude Exit Code: %s\n' "$review_exit"
    printf 'Changed Files:\n'
    printf '  unavailable\n'
    if [ -s "$tmp_output" ]; then
      printf '\nError: Review process did not produce a valid report.\n'
      printf '\nCaptured output:\n'
      sed 's/^/  /' "$tmp_output"
    else
      printf '\nError: Review process did not produce any output.\n'
    fi
  } > "$report_path"
fi

echo
if [ "$review_exit" -eq 124 ]; then
  add_blocker "Claude request timed out after ${review_timeout_seconds}s"
elif [ "$review_exit" -ne 0 ] && [ "$status" = "ERROR" ]; then
  add_blocker "Review failed before producing a usable status; inspect $report_path"
fi

case "$status" in
  NEEDS_FIXES|REJECTED)
    add_blocker "Klavdia returned $status; see $report_path Critical Fixes"
    echo
    echo "Blocking details from $report_path:"
    awk '
      BEGIN { in_section=0 }
      /^Critical Fixes:/ { in_section=1; print; next }
      /^Improvement Suggestions:/ { in_section=0 }
      in_section { print }
    ' "$report_path" | sed '/^$/d' | sed 's/^/  /'
    ;;
  ERROR)
    if [ "${#blockers[@]}" -eq 0 ]; then
      add_blocker "Review logic or Claude/API failure; see $report_path"
    fi
    ;;
esac

log_line "Final status: $status"

case "$status" in
  APPROVED)
    print_final_report "$status" "Run: scripts/claude-review-verify.sh"
    exit 0
    ;;
  NEEDS_FIXES|REJECTED)
    print_final_report "$status" "Fix blockers listed in $report_path, then run: scripts/klavdia-review.sh"
    exit 1
    ;;
  ERROR)
    print_final_report "$status" "Fix the reported Git/API/network/review failure, then run: scripts/klavdia-review.sh"
    exit 2
    ;;
  *)
    add_blocker "Unknown status '$status'"
    print_final_report "ERROR" "Inspect $report_path, then run: scripts/klavdia-review.sh"
    exit 2
    ;;
esac
