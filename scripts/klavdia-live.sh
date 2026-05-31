#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

printf '%s\n' "Klavdia Live"
printf '%s\n' "============="
printf '\n'
printf '%s\n' "Watching repository..."
printf '%s\n' "Reading AI_TEAM.md, CODEX.md, CLAUDE.md, and PROJECT_CONTEXT.md as review context."
printf '\n'

exec scripts/klavdia-review.sh
