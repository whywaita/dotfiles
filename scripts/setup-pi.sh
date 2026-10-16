#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# shellcheck disable=SC1091
source "$DOTFILES_DIR/scripts/lib/safe-link.sh"

# Keep the wrapper beside pi's agent dir (~/.pi/agent) so pi never loads it.
mkdir -p "$HOME/.pi"

safe_link "$DOTFILES_DIR/dot_pi/worktree-shell.sh" "$HOME/.pi/worktree-shell.sh"
safe_link "$DOTFILES_DIR/dot_pi/scripts/pi-worktree.sh" "$HOME/.pi/pi-worktree.sh"
