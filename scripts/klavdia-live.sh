#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

refresh_seconds="${LOOPYCAT_KLAVDIA_REFRESH_SECONDS:-10}"
last_review_result="UNKNOWN"
last_review_duration="NONE"
last_review_state="NONE"
last_review_finished_at="NEVER"
current_state="IDLE"
current_phase="Starting"

timestamp() {
  date '+%Y-%m-%d %H:%M:%S %Z'
}

clear_screen() {
  if [ -t 1 ]; then
    clear
  fi
}

repo_state_id() {
  scripts/claude-review-state.sh state-id 2>/dev/null || printf 'UNAVAILABLE'
}

pending_change_count() {
  git status --porcelain=v1 2>/dev/null | sed '/^$/d' | wc -l | tr -d ' '
}

git_writable() {
  if touch .git/.klavdia-live-write-test 2>/dev/null; then
    rm -f .git/.klavdia-live-write-test
    printf 'WRITABLE'
  else
    printf 'READ ONLY'
  fi
}

report_status() {
  if [ -f CLAUDE_REVIEW.md ]; then
    case "$(sed -n '1p' CLAUDE_REVIEW.md | tr -d '\r')" in
      APPROVED|NEEDS_FIXES|REJECTED|ERROR)
        sed -n '1p' CLAUDE_REVIEW.md | tr -d '\r'
        ;;
      *)
        printf 'ERROR'
        ;;
    esac
  else
    printf 'ERROR'
  fi
}

render_dashboard() {
  clear_screen
  printf '%s\n' "========================"
  printf '%s\n' "KLAVDIA LIVE"
  printf '\n'
  printf '%s\n' "State:"
  printf '* %s\n' "$current_state"
  printf '\n'
  printf '%s\n' "Current Phase:"
  printf '* %s\n' "$current_phase"
  printf '\n'
  printf '%s\n' "Last Review Result:"
  printf '* %s\n' "$last_review_result"
  printf '\n'
  printf '%s\n' "Last Review Duration:"
  printf '* %s\n' "$last_review_duration"
  printf '\n'
  printf '%s\n' "Last Review Finished:"
  printf '* %s\n' "$last_review_finished_at"
  printf '\n'
  printf '%s\n' "Current Repository State:"
  printf '* %s\n' "$(repo_state_id)"
  printf '\n'
  printf '%s\n' "Last Reviewed State:"
  printf '* %s\n' "$last_review_state"
  printf '\n'
  printf '%s\n' "Pending Changes:"
  printf '* %s\n' "$(pending_change_count)"
  printf '\n'
  printf '%s\n' ".git:"
  printf '* %s\n' "$(git_writable)"
  printf '\n'
  printf '%s\n' "Current Review Report:"
  printf '* %s\n' "$(report_status)"
  printf '\n'
  printf '%s\n' "Alive:"
  printf '* %s\n' "$(timestamp)"
  printf '\n'
  printf '%s\n' "Refresh:"
  printf '* %ss\n' "$refresh_seconds"
  printf '%s\n' "========================"
}

phase_from_line() {
  local line="$1"
  case "$line" in
    *"Reading changed files"*|*"Reading files"*)
      printf 'Reading files...'
      ;;
    *"Checking architecture"*)
      printf 'Checking architecture...'
      ;;
    *"Checking SwiftUI"*)
      printf 'Checking SwiftUI...'
      ;;
    *"Checking diagnostics"*)
      printf 'Checking diagnostics...'
      ;;
    *"Claude request start"*|*"Sending Claude request"*)
      printf 'Sending Claude request...'
      ;;
    *"Heartbeat: waiting for Claude response"*|*"Waiting for Claude"*)
      printf 'Waiting for Claude...'
      ;;
    *"Claude response received"*)
      printf 'Parsing response...'
      ;;
    *"Generating final report"*)
      printf 'Generating report...'
      ;;
    *"Final status:"*|*"STATUS:"*)
      printf 'Finished review.'
      ;;
    *)
      printf ''
      ;;
  esac
}

state_from_phase() {
  local phase="$1"
  case "$phase" in
    "Waiting for Claude..."|"Sending Claude request...")
      printf 'WAITING_FOR_CLAUDE'
      ;;
    "Finished review.")
      printf 'REVIEWING'
      ;;
    *)
      printf 'REVIEWING'
      ;;
  esac
}

run_review() {
  local started_epoch ended_epoch review_exit line phase next_state result
  started_epoch="$(date +%s)"
  current_state="REVIEWING"
  current_phase="Reading files..."
  render_dashboard
  printf '\n%s\n' "Live review progress:"
  printf '%s\n' "---------------------"

  set +e
  scripts/klavdia-review.sh 2>&1 | while IFS= read -r line; do
    phase="$(phase_from_line "$line")"
    if [ -n "$phase" ]; then
      current_phase="$phase"
      next_state="$(state_from_phase "$phase")"
      current_state="$next_state"
      printf '[%s] %s | %s\n' "$(timestamp)" "$current_state" "$current_phase"
    fi
    printf '%s\n' "$line"
  done
  review_exit="${PIPESTATUS[0]}"
  set -e

  ended_epoch="$(date +%s)"
  last_review_duration="$((ended_epoch - started_epoch))s"
  last_review_finished_at="$(timestamp)"
  last_review_state="$(repo_state_id)"
  result="$(report_status)"
  last_review_result="$result"

  case "$result" in
    APPROVED|NEEDS_FIXES|REJECTED|ERROR)
      current_state="$result"
      ;;
    *)
      current_state="ERROR"
      ;;
  esac
  if [ "$review_exit" -ne 0 ] && [ "$current_state" = "APPROVED" ]; then
    current_state="ERROR"
    last_review_result="ERROR"
  fi
  current_phase="Finished review."
  render_dashboard
  printf '\n%s\n' "Review finished with state: $current_state"
  printf '%s\n' "Klavdia remains alive and will continue watching."
  sleep "$refresh_seconds"
}

printf '%s\n' "Klavdia Live"
printf '%s\n' "============="
printf '\n'
printf '%s\n' "Permanent session started."
printf '%s\n' "Reading AI_TEAM.md, CODEX.md, CLAUDE.md, and PROJECT_CONTEXT.md as review context."
printf '%s\n' "Review engine: scripts/klavdia-review.sh"
printf '\n'
sleep 1

while true; do
  current_repo_state="$(repo_state_id)"
  change_count="$(pending_change_count)"

  if [ "$change_count" -gt 0 ] && [ "$current_repo_state" != "$last_review_state" ]; then
    run_review
  else
    current_state="IDLE"
    current_phase="Waiting for repository changes..."
    render_dashboard
    sleep "$refresh_seconds"
  fi
done
