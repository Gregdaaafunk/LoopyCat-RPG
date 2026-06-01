#!/usr/bin/env bash
set -euo pipefail

repo_root="/home/gregdafunk/Downloads/LoopyCat-RPG"
implementation_model="gpt-5.5"

context_files=(
  "AI_TEAM.md"
  "CODEX.md"
  "CLAUDE.md"
  "PROJECT_CONTEXT.md"
)

fail() {
  printf 'ERROR: %s\n' "$1" >&2
  exit 1
}

run_step() {
  local label="$1"
  shift

  printf '\n%s\n' "$label"
  printf '%s\n' "----------------------------------------"
  "$@"
}

verify_repository() {
  [ -d "$repo_root" ] || fail "Repository directory does not exist: $repo_root"
  [ -d "$repo_root/.git" ] || fail ".git directory does not exist: $repo_root/.git"

  local actual_root
  actual_root="$(git -C "$repo_root" rev-parse --show-toplevel 2>/dev/null)" || fail "Not a git work tree: $repo_root"
  [ "$actual_root" = "$repo_root" ] || fail "Unexpected git root: $actual_root"
}

verify_context_files() {
  local file
  for file in "${context_files[@]}"; do
    [ -f "$repo_root/$file" ] || fail "Missing required context file: $file"
  done
}

verify_github_connectivity() {
  git -C "$repo_root" remote get-url origin >/dev/null 2>&1 || {
    printf '%s\n' "WARNING: Missing git remote named origin"
    return 0
  }
  git -C "$repo_root" ls-remote --exit-code origin HEAD >/dev/null 2>&1 || {
    printf '%s\n' "WARNING: GitHub origin is not reachable; HQ will show GitHub: ERROR"
    return 0
  }
  printf '%s\n' "GitHub origin reachable."
}

verify_terminal_available() {
  if [ "${LOOPYCATRPG_NO_TERMINALS:-}" = "1" ]; then
    return
  fi

  command -v xfce4-terminal >/dev/null 2>&1 && return
  command -v x-terminal-emulator >/dev/null 2>&1 && return
  fail "A visible terminal emulator is required for Kolyan, Klavdia, and HQ"
}

verify_codex_available() {
  command -v codex >/dev/null 2>&1 || fail "Codex CLI is not on PATH"
}

verify_repository
cd "$repo_root"
verify_context_files
verify_terminal_available
verify_codex_available

print_context() {
  printf '%s\n' "loopycatrpg"
  printf '%s\n' "=============="
  printf '\n'
  printf '%s\n' "Repository root: $repo_root"
  printf '%s\n' "Current working directory: $(pwd)"
  printf '\n'
  printf '%s\n' "Official startup command: loopycatrpg"
  printf '%s\n' "Default implementation model: $implementation_model"
  printf '\n'
  printf '%s\n' "Loaded required context files:"
  for file in "${context_files[@]}"; do
    printf '%s\n' "  - $file"
  done
  printf '\n'
  printf '%s\n' "Team roles restored:"
  printf '%s\n' "  Greg: Product Owner, vision, testing, product decisions"
  printf '%s\n' "  Matroskin: Strategy, architecture, systems design, product direction"
  printf '%s\n' "  Kolyan: Implementation engineer, coding, debugging, maintenance, GitHub operations, TestFlight deployment"
  printf '%s\n' "  Klavdia: Reviewer, architecture auditor, SwiftUI auditor, quality gate, risk auditor"
  printf '%s\n' "  HQ: Operations dashboard, live project health, launcher/review/git/network visibility"
  printf '%s\n' "  Klavdia permissions: no push, no deploy, no GitHub write, no secrets"
  printf '\n'
  printf '%s\n' "Workflow: Kolyan implements, Klavdia reviews, fixes repeat until APPROVED."
  printf '%s\n' "Gate: push, GitHub Actions, and TestFlight require APPROVED for the current repository state."
}

open_terminal() {
  local title="$1"
  local command="$2"

  if command -v xfce4-terminal >/dev/null 2>&1; then
    xfce4-terminal --title="$title" --working-directory="$repo_root" --hold --command="bash -lc '$command'"
    return
  fi

  if command -v x-terminal-emulator >/dev/null 2>&1; then
    x-terminal-emulator -T "$title" -e bash -lc "$command"
    return
  fi

  printf '%s\n' "ERROR: A terminal emulator is required to launch the live Klavdia session." >&2
  exit 1
}

print_context
run_step "Git status" git status --short --branch
run_step "GitHub connectivity" verify_github_connectivity

if [ "${LOOPYCATRPG_NO_TERMINALS:-}" = "1" ]; then
  printf '\n%s\n' "Terminal launch skipped because LOOPYCATRPG_NO_TERMINALS=1."
  exit 0
fi

open_terminal "Kolyan - LoopyCat-RPG" "exec scripts/kolyan-session.sh"
open_terminal "Klavdia Live" "exec scripts/klavdia-live.sh"
open_terminal "LoopyCat RPG HQ" "exec scripts/hq-dashboard.sh"
