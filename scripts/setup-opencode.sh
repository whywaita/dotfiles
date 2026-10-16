#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/safe-link.sh"

mkdir -p "$HOME/.config/opencode"

# Symbolic link for AGENTS.md
safe_link "$DOTFILES_DIR/dot_opencode/AGENTS.md" "$HOME/.config/opencode/AGENTS.md"

# opencode.json may contain private endpoints, so it is gitignored.
# Link it only when it exists locally.
if [ -f "$DOTFILES_DIR/dot_opencode/opencode.json" ]; then
  safe_link "$DOTFILES_DIR/dot_opencode/opencode.json" "$HOME/.config/opencode/opencode.json"
fi
