#!/bin/bash
set -euo pipefail

for dependency in git codex; do
  command -v "$dependency" >/dev/null 2>&1 || {
    printf 'Required command not found: %s\n' "$dependency" >&2
    exit 127
  }
done

if [[ "${1:-}" == --help ]]; then
  printf 'Usage: codex --worktree [name] [--] [Codex options or prompt]\n'
  exit 0
fi

name="session-$(date +%Y%m%d-%H%M%S)-$$"
if [[ $# -gt 0 && "$1" != -* ]]; then
  name="$1"
  shift
fi
if [[ ! "$name" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ]]; then
  printf 'Invalid worktree name: %s\n' "$name" >&2
  exit 2
fi
[[ "${1:-}" != -- ]] || shift
for arg in "$@"; do
  case "$arg" in
  -C* | --cd | --cd=* | --remote | --remote=*)
    printf 'Worktree mode cannot be combined with %s\n' "$arg" >&2
    exit 2
    ;;
  esac
done

root="$(git rev-parse --show-toplevel)"
branch="codex/$name"
worktree="$root/.worktrees/$name"
if [[ -e "$worktree" || -L "$worktree" ]] || git show-ref --verify --quiet "refs/heads/$branch"; then
  printf 'Worktree or branch already exists: %s\n' "$name" >&2
  exit 1
fi

# Keep worktrees out of status without changing the project's tracked files.
if ! git -C "$root" check-ignore -q .worktrees/probe; then
  exclude="$(git -C "$root" rev-parse --git-path info/exclude)"
  [[ "$exclude" == /* ]] || exclude="$root/$exclude"
  mkdir -p "${exclude%/*}"
  printf '\n/.worktrees/\n' >>"$exclude"
fi
git -C "$root" worktree add -b "$branch" "$worktree" HEAD

keep() {
  printf '\nKept worktree: %s\nBranch: %s\nResume: codex -C %q resume\n' "$worktree" "$branch" "$worktree"
}
trap 'keep; exit 129' HUP
trap 'keep; exit 143' TERM
# Let the foreground Codex process receive Ctrl-C; retain the cleanup prompt.
trap ':' INT

result=0
command codex -C "$worktree" "$@" || result=$?
choice=k
if [[ -t 0 ]]; then
  printf '\nWorktree: %s\n[R]emove / [K]eep (default Keep): ' "$worktree"
  IFS= read -r choice || choice=k
fi
case "$choice" in
r | R | remove | Remove)
  if ! git -C "$worktree" symbolic-ref --quiet HEAD >/dev/null; then
    printf 'Create a branch for the detached HEAD before removing this worktree.\n' >&2
    keep
    exit "$result"
  fi
  changes="$(git -C "$worktree" status --porcelain=v1 --untracked-files=all --ignored)" || {
    keep
    exit "$result"
  }
  remove_args=(worktree remove)
  if [[ -n "$changes" ]]; then
    printf '\nFiles that will be discarded (including ignored files):\n%s\nType DELETE to discard them: ' "$changes"
    confirm=
    IFS= read -r confirm || confirm=
    if [[ "$confirm" != DELETE ]]; then
      keep
      exit "$result"
    fi
    remove_args+=(--force)
  fi
  if git -C "$root" "${remove_args[@]}" "$worktree"; then
    printf 'Removed worktree. Branch retained: %s\n' "$branch"
  else
    keep
    printf 'Worktree removal failed; inspect it manually.\n' >&2
    [[ "$result" != 0 ]] || result=1
  fi
  ;;
*) keep ;;
esac
exit "$result"
