#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

install_hook() {
  local hook_source="$1"
  local hook_target="$2"

  if [ ! -x "$hook_source" ]; then
    chmod +x "$hook_source"
  fi

  if [ -e "$hook_target" ] && ! cmp -s "$hook_source" "$hook_target"; then
    backup="$hook_target.backup.$(date +%Y%m%d%H%M%S)"
    cp "$hook_target" "$backup"
    echo "Backed up existing $(basename "$hook_target") hook to $backup"
  fi

  cp "$hook_source" "$hook_target"
  chmod +x "$hook_target"
  echo "Installed Claude review $(basename "$hook_target") hook at $hook_target"
}

install_hook "$repo_root/scripts/claude-review-pre-commit" "$repo_root/.git/hooks/pre-commit"
install_hook "$repo_root/scripts/claude-review-pre-push" "$repo_root/.git/hooks/pre-push"
