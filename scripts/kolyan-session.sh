#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

implementation_model="gpt-5.5"

printf '%s\n' "Kolyan Session"
printf '%s\n' "=============="
printf '\n'
printf '%s\n' "Project root: $repo_root"
printf '%s\n' "Current working directory: $(pwd)"
printf '\n'
printf '%s\n' "Loading primary context:"
printf '%s\n' "  - AI_TEAM.md"
printf '%s\n' "  - CODEX.md"
printf '%s\n' "  - CLAUDE.md"
printf '%s\n' "  - PROJECT_CONTEXT.md"
printf '\n'
printf '%s\n' "Default implementation model: $implementation_model"
printf '%s\n' "Sandbox: danger-full-access"
printf '%s\n' "Security audit: this grants full local filesystem access, not just workspace access."
printf '%s\n' "Minimum permission check: workspace-write was tested and mounted .git read-only; danger-full-access is the narrowest Codex mode available here that allows .git writes."
printf '%s\n' "Required local operations: touch .git/.write-test, git add, git commit, and scripts/claude-review-state.sh gate hashes."
printf '%s\n' "Release boundary: push, GitHub Actions, and TestFlight still require explicit owner approval and fresh Klavdia APPROVED."
printf '\n'
printf '%s\n' "Starting Codex..."

exec codex \
  --model "$implementation_model" \
  --cd "$repo_root" \
  --sandbox danger-full-access \
  --ask-for-approval never \
  --no-alt-screen \
  "Read AI_TEAM.md, CODEX.md, CLAUDE.md, and PROJECT_CONTEXT.md first. Treat them as primary operating context. You are Kolyan, the implementation engineer. Proceed autonomously on normal development work, keep Klavdia approval current, and do not push or deploy."
