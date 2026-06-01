#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

refresh_seconds="${LOOPYCAT_HQ_REFRESH_SECONDS:-15}"
implementation_model="${LOOPYCAT_KOLYAN_MODEL:-gpt-5.5}"

status_line() {
  printf '* %s\n' "$1"
}

command_ok() {
  "$@" >/dev/null 2>&1
}

git_writable_status() {
  if touch .git/.hq-write-test 2>/dev/null; then
    rm -f .git/.hq-write-test
    printf 'WRITABLE'
  else
    printf 'READ ONLY'
  fi
}

repository_status() {
  if command_ok git rev-parse --show-toplevel; then
    printf 'VALID'
  else
    printf 'INVALID'
  fi
}

git_status_label() {
  if [ -z "$(git status --porcelain=v1 2>/dev/null)" ]; then
    printf 'CLEAN'
  else
    printf 'CHANGES DETECTED'
  fi
}

pending_change_count() {
  git status --porcelain=v1 2>/dev/null | sed '/^$/d' | wc -l | tr -d ' '
}

github_status() {
  if timeout 8s git ls-remote --exit-code origin HEAD >/dev/null 2>&1; then
    printf 'CONNECTED'
  else
    printf 'ERROR'
  fi
}

internet_status() {
  if command -v curl >/dev/null 2>&1 && timeout 8s curl -Is https://github.com >/dev/null 2>&1; then
    printf 'OK'
  elif command -v ping >/dev/null 2>&1 && timeout 8s ping -c 1 1.1.1.1 >/dev/null 2>&1; then
    printf 'OK'
  else
    printf 'ERROR'
  fi
}

kolyan_status() {
  if ! command -v codex >/dev/null 2>&1; then
    printf 'ERROR'
  elif pgrep -af "codex .*LoopyCat-RPG|scripts/kolyan-session.sh" >/dev/null 2>&1; then
    printf 'WORKING'
  else
    printf 'IDLE'
  fi
}

klavdia_status() {
  if pgrep -af "scripts/klavdia-review.sh|scripts/claude-review.sh" >/dev/null 2>&1; then
    printf 'WORKING'
  elif [ -f CLAUDE_REVIEW.md ] && [ "$(sed -n '1p' CLAUDE_REVIEW.md | tr -d '\r')" = "ERROR" ]; then
    printf 'ERROR'
  else
    printf 'WAITING'
  fi
}

review_status() {
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

launcher_status() {
  if [ -x ./loopycatrpg ] && [ -x scripts/loopycatrpg.sh ] && [ -x scripts/kolyan-session.sh ] && [ -x scripts/klavdia-live.sh ] && [ -x scripts/hq-dashboard.sh ]; then
    printf 'OK'
  else
    printf 'ERROR'
  fi
}

review_pipeline_status() {
  if bash -n scripts/klavdia-review.sh scripts/claude-review.sh scripts/claude-review-state.sh scripts/claude-review-verify.sh >/dev/null 2>&1; then
    printf 'OK'
  else
    printf 'ERROR'
  fi
}

last_commit() {
  git rev-parse --short HEAD 2>/dev/null || printf 'UNKNOWN'
}

current_branch() {
  git branch --show-current 2>/dev/null || git rev-parse --short HEAD 2>/dev/null || printf 'UNKNOWN'
}

draw() {
  clear
  printf '%s\n' "========================"
  printf '%s\n' "LOOPYCAT RPG HQ"
  printf '\n'
  printf '%s\n' "Kolyan:"
  status_line "$(kolyan_status)"
  printf '\n'
  printf '%s\n' "Model:"
  status_line "$implementation_model"
  printf '\n'
  printf '%s\n' "Klavdia:"
  status_line "$(klavdia_status)"
  printf '\n'
  printf '%s\n' "Current Review:"
  status_line "$(review_status)"
  printf '\n'
  printf '%s\n' "Git:"
  status_line "$(git_status_label)"
  printf '\n'
  printf '%s\n' "GitHub:"
  status_line "$(github_status)"
  printf '\n'
  printf '%s\n' "Internet:"
  status_line "$(internet_status)"
  printf '\n'
  printf '%s\n' "Repository:"
  status_line "$(repository_status)"
  printf '\n'
  printf '%s\n' ".git:"
  status_line "$(git_writable_status)"
  printf '\n'
  printf '%s\n' "Last Commit:"
  status_line "$(last_commit)"
  printf '\n'
  printf '%s\n' "Current Branch:"
  status_line "$(current_branch)"
  printf '\n'
  printf '%s\n' "Pending Changes:"
  status_line "$(pending_change_count)"
  printf '\n'
  printf '%s\n' "Launcher:"
  status_line "$(launcher_status)"
  printf '\n'
  printf '%s\n' "Review Pipeline:"
  status_line "$(review_pipeline_status)"
  printf '\n'
  printf '%s\n' "Time:"
  status_line "$(date '+%Y-%m-%d %H:%M:%S %Z')"
  printf '\n'
  printf '%s\n' "Refresh:"
  status_line "${refresh_seconds}s"
  printf '%s\n' "========================"
}

while true; do
  draw
  sleep "$refresh_seconds"
done
