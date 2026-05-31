#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

report_path="${CLAUDE_REVIEW_REPORT:-CLAUDE_REVIEW.md}"
review_timeout_seconds="${CLAUDE_REVIEW_OUTER_TIMEOUT_SECONDS:-2100}"
tmp_output="$(mktemp)"
trap 'rm -f "$tmp_output"' EXIT

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

echo "Klavdia Visible Review"
echo "======================"
echo
echo "Reviewer: Klavdia (Claude Code)"
echo "Mode: reviewer and architecture auditor only"
echo "Authority: no push, no deploy, no secrets, no tool access"
echo "Live mode: enabled"
echo
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
printf '%s\n' "Klavdia reviewing..."
printf '%s\n' "Reading changed files..."
sleep 0.15
printf '%s\n' "Checking SwiftUI layout..."
sleep 0.15
printf '%s\n' "Checking architecture..."
sleep 0.15
printf '%s\n' "Checking diagnostics..."
sleep 0.15
printf '%s\n' "Checking deployment risks..."
sleep 0.15
printf '%s\n' "Generating findings..."
sleep 0.15
printf '%s\n' "Generating final report..."

set +e
timeout --foreground --kill-after=10s "$review_timeout_seconds" scripts/claude-review.sh 2>&1 | tee "$tmp_output" | redact_secrets
pipeline_status=("${PIPESTATUS[@]}")
review_exit="${pipeline_status[0]}"
set -e

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

if [ "$report_needs_fallback" -eq 1 ]; then
  {
    printf 'ERROR\n\n'
    printf 'Review ID: unavailable\n'
    printf 'Timestamp: unavailable\n'
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
echo "Final status: $status"

case "$status" in
  APPROVED)
    exit 0
    ;;
  NEEDS_FIXES|REJECTED)
    exit 1
    ;;
  ERROR)
    exit 2
    ;;
  *)
    exit 2
    ;;
esac
