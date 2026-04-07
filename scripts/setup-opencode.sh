#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

mkdir -p "$HOME/.config/opencode"

# AGENTS.md のシンボリックリンク
ln -sf "$DOTFILES_DIR/dot_opencode/AGENTS.md" "$HOME/.config/opencode/AGENTS.md"