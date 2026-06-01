#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

report_path="${CLAUDE_REVIEW_REPORT:-CLAUDE_REVIEW.md}"

report_pathspec() {
  case "$report_path" in
    "$repo_root"/*)
      printf '%s\n' "${report_path#"$repo_root"/}"
      ;;
    /*)
      return 1
      ;;
    ./*)
      printf '%s\n' "${report_path#./}"
      ;;
    *)
      printf '%s\n' "$report_path"
      ;;
  esac
}

hash_stream() {
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 | awk '{print $1}'
  else
    sha256sum | awk '{print $1}'
  fi
}

changed_files() {
  local report_file
  report_file="$(report_pathspec || true)"
  {
    git diff --name-only --diff-filter=ACMRD -- .
    git diff --cached --name-only --diff-filter=ACMRD -- .
    git ls-files --others --exclude-standard
  } | sort -u | grep -Fvx "$report_file" || true
}

content_files() {
  local report_file
  report_file="$(report_pathspec || true)"
  git ls-files --cached --others --exclude-standard | sort -u | grep -Fvx "$report_file" || true
}

worktree_mode() {
  local file="$1"
  if [ -L "$file" ]; then
    printf '120000'
  elif [ -x "$file" ]; then
    printf '100755'
  else
    printf '100644'
  fi
}

current_content_id() {
  {
    content_files | while IFS= read -r file; do
      [ -n "$file" ] || continue
      if git ls-files --error-unmatch -- "$file" >/dev/null 2>&1; then
        git ls-files -s -- "$file" | while read -r mode object stage indexed_file; do
          [ -n "$indexed_file" ] || continue
          printf 'F %s %s %s\n' "$mode" "$object" "$indexed_file"
        done
      elif [ -e "$file" ]; then
        printf 'F %s %s %s\n' "$(worktree_mode "$file")" "$(git hash-object --no-filters -- "$file")" "$file"
      fi
    done
  } | hash_stream
}

staged_content_id() {
  {
    content_files | while IFS= read -r file; do
      [ -n "$file" ] || continue
      git ls-files -s -- "$file" | while read -r mode object stage indexed_file; do
        [ -n "$indexed_file" ] || continue
        printf 'F %s %s %s\n' "$mode" "$object" "$indexed_file"
      done
    done
  } | hash_stream
}

state_id() {
  {
    printf 'CONTENT_TREE %s\n' "$(current_content_id)"
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
