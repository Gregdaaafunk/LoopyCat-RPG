#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

report_path="${CLAUDE_REVIEW_REPORT:-CLAUDE_REVIEW.md}"
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
echo
echo "Claude output:"
echo "--------------"

set +e
scripts/claude-review.sh 2>&1 | tee "$tmp_output" | redact_secrets
review_exit="${PIPESTATUS[0]}"
set -e

status="UNKNOWN"
if [ -f "$report_path" ]; then
  status="$(sed -n '1p' "$report_path" | tr -d '\r')"
else
  first_line="$(sed -n '1p' "$tmp_output" | tr -d '\r')"
  case "$first_line" in
    APPROVED|NEEDS_FIXES|REJECTED) status="$first_line" ;;
  esac
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
  *)
    exit "$review_exit"
    ;;
esac
