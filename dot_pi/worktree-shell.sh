#!/bin/bash
# Source from Bash or Zsh. Only the leading worktree option is intercepted.
pi() {
  case "${1:-}" in
  --worktree | -w)
    shift
    command bash "$HOME/.pi/pi-worktree.sh" "$@"
    ;;
  *) command pi "$@" ;;
  esac
}
