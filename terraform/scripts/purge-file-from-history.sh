#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf 'Usage: %s <repository-relative-file-path>\n' "$0" >&2
  exit 2
}

[[ "$#" -eq 1 && -n "$1" ]] || usage

file_path="$1"
case "$file_path" in
  /*|.|./|./*|..|../*|*/../*|*/..|.git|.git/*)
    printf 'Error: provide a file path inside the repository, without "." or ".." components.\n' >&2
    exit 2
    ;;
esac

command -v git-filter-repo >/dev/null 2>&1 || {
  printf 'Error: git-filter-repo is required but was not found in PATH.\n' >&2
  exit 1
}

repo_root="$(git rev-parse --show-toplevel 2>/dev/null)" || {
  printf 'Error: run this command from inside a Git repository.\n' >&2
  exit 1
}
cd "$repo_root"

if [[ -n "$(git status --porcelain --untracked-files=all)" ]]; then
  printf 'Error: commit, stash, or remove local changes before rewriting history.\n' >&2
  exit 1
fi

remote_url="$(git remote get-url origin 2>/dev/null)" || {
  printf 'Error: an origin remote is required to push the rewritten history.\n' >&2
  exit 1
}

git fetch origin --prune --tags '+refs/heads/*:refs/remotes/origin/*'

remote_listing="$(git ls-remote --heads --tags origin)"
declare -A remote_refs=()
while IFS=$'\t' read -r object_id ref_name; do
  [[ -n "$ref_name" && "$ref_name" != *'^{}' ]] || continue
  case "$ref_name" in
    refs/heads/*|refs/tags/*) remote_refs["$ref_name"]="$object_id" ;;
  esac
done <<< "$remote_listing"

if [[ "${#remote_refs[@]}" -eq 0 ]]; then
  printf 'Error: origin has no branches or tags to update.\n' >&2
  exit 1
fi

if [[ -z "$(git log --all -1 --format='%H' -- ":(literal)$file_path")" ]]; then
  printf 'Error: %s was not found in the history of any local ref.\n' "$file_path" >&2
  exit 1
fi

printf 'This will remove "%s" from all local branches and tags, rewrite their history,\n' "$file_path"
printf 'and force-push the rewritten branches and tags to origin using leases.\n'
printf 'Collaborators will need to re-sync their clones. Rotate/revoke any exposed secrets.\n'
printf '\n'
read -r -p 'Type PURGE AND PUSH to continue: ' confirmation
if [[ "$confirmation" != "PURGE AND PUSH" ]]; then
  printf 'Cancelled; no history was changed.\n'
  exit 1
fi

for ref_name in "${!remote_refs[@]}"; do
  case "$ref_name" in
    refs/heads/*)
      branch_name="${ref_name#refs/heads/}"
      local_ref="refs/heads/$branch_name"
      remote_tracking_ref="refs/remotes/origin/$branch_name"
      if git show-ref --verify --quiet "$local_ref"; then
        local_object_id="$(git rev-parse "$local_ref")"
        if [[ "$local_object_id" != "${remote_refs[$ref_name]}" ]]; then
          printf 'Error: local branch %s differs from origin; synchronize it before rewriting.\n' "$branch_name" >&2
          exit 1
        fi
      elif git show-ref --verify --quiet "$remote_tracking_ref"; then
        git branch "$branch_name" "$remote_tracking_ref"
      else
        printf 'Error: could not find local ref for remote branch %s.\n' "$branch_name" >&2
        exit 1
      fi
      ;;
    refs/tags/*)
      tag_name="${ref_name#refs/tags/}"
      local_ref="refs/tags/$tag_name"
      if ! git show-ref --verify --quiet "$local_ref"; then
        printf 'Error: remote tag %s was not fetched locally.\n' "$tag_name" >&2
        exit 1
      fi
      local_object_id="$(git rev-parse "$local_ref")"
      if [[ "$local_object_id" != "${remote_refs[$ref_name]}" ]]; then
        printf 'Error: local tag %s differs from origin; synchronize it before rewriting.\n' "$tag_name" >&2
        exit 1
      fi
      ;;
  esac
done

git filter-repo --force --path "$file_path" --invert-paths --prune-empty never

if git remote get-url origin >/dev/null 2>&1; then
  git remote set-url origin "$remote_url"
else
  git remote add origin "$remote_url"
fi

push_args=()
for ref_name in "${!remote_refs[@]}"; do
  push_args+=("--force-with-lease=$ref_name:${remote_refs[$ref_name]}" "$ref_name:$ref_name")
done

git push origin "${push_args[@]}"
printf 'Removed "%s" from rewritten history and pushed the updated refs.\n' "$file_path"
