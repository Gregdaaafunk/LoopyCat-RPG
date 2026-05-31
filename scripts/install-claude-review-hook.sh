#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

hook_source="$repo_root/scripts/claude-review-pre-commit"
hook_target="$repo_root/.git/hooks/pre-commit"

if [ ! -x "$hook_source" ]; then
  chmod +x "$hook_source"
fi

if [ -e "$hook_target" ] && ! cmp -s "$hook_source" "$hook_target"; then
  backup="$hook_target.backup.$(date +%Y%m%d%H%M%S)"
  cp "$hook_target" "$backup"
  echo "Backed up existing pre-commit hook to $backup"
fi

cp "$hook_source" "$hook_target"
chmod +x "$hook_target"
echo "Installed Claude review pre-commit hook at $hook_target"
