#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

report_path="${CLAUDE_REVIEW_REPORT:-CLAUDE_REVIEW.md}"

hash_stream() {
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 | awk '{print $1}'
  else
    sha256sum | awk '{print $1}'
  fi
}

changed_files() {
  {
    git diff --name-only --diff-filter=ACMRD -- .
    git diff --cached --name-only --diff-filter=ACMRD -- .
    git ls-files --others --exclude-standard
  } | sort -u | grep -v -x "$report_path" || true
}

file_mode() {
  local file="$1"
  local tracked_mode
  tracked_mode="$(git ls-files -s -- "$file" | awk '{print $1}' | sed -n '1p')"
  if [ -n "$tracked_mode" ]; then
    printf '%s' "$tracked_mode"
  elif [ -x "$file" ]; then
    printf '100755'
  else
    printf '100644'
  fi
}

current_content_id() {
  {
    printf 'HEAD %s\n' "$(git rev-parse HEAD)"
    changed_files | while IFS= read -r file; do
      [ -z "$file" ] && continue
      if [ -e "$file" ]; then
        printf 'F %s %s %s\n' "$(file_mode "$file")" "$(git hash-object --no-filters -- "$file")" "$file"
      else
        printf 'D %s\n' "$file"
      fi
    done
  } | hash_stream
}

staged_content_id() {
  {
    printf 'HEAD %s\n' "$(git rev-parse HEAD)"
    git diff --cached --name-only --diff-filter=ACMRD -- . | sort -u | grep -v -x "$report_path" | while IFS= read -r file; do
      [ -z "$file" ] && continue
      if git diff --cached --name-only --diff-filter=D -- "$file" | grep -qx "$file"; then
        printf 'D %s\n' "$file"
      else
        git ls-files -s -- "$file" | awk -v path="$file" '{print "F " $1 " " $2 " " path}' | sed -n '1p'
      fi
    done
  } | hash_stream
}

state_id() {
  {
    printf 'HEAD %s\n' "$(git rev-parse HEAD)"
    printf 'APPROVED_CONTENT %s\n' "$(current_content_id)"
    changed_files | while IFS= read -r file; do
      [ -n "$file" ] && printf 'CHANGED %s\n' "$file"
    done
  } | hash_stream
}

case "${1:-state-id}" in
  state-id)
    state_id
    ;;
  approved-tree-id)
    current_content_id
    ;;
  staged-tree-id)
    staged_content_id
    ;;
  changed-files)
    changed_files
    ;;
  *)
    echo "Usage: $0 [state-id|approved-tree-id|staged-tree-id|changed-files]" >&2
    exit 2
    ;;
esac
