#!/bin/bash
# Source from Bash or Zsh. Only the leading worktree option is intercepted.
codex() {
  case "${1:-}" in
  --worktree | -w)
    shift
    command bash "$HOME/.codex/codex-worktree.sh" "$@"
    ;;
  *) command codex "$@" ;;
  esac
}
