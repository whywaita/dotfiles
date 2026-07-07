#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/safe-link.sh"

DOT_FILES=(.zshrc .tmux.conf .gitconfig .gemrc .latexmkrc .screenrc .wezterm.lua)

for file in "${DOT_FILES[@]}"
do
  safe_link "$DOTFILES_DIR/$file" "$HOME/$file"
done

DOT_CONFIG_DIRS=(mdp ghostty nvim)

mkdir -p "$HOME/.config"

for dir in "${DOT_CONFIG_DIRS[@]}"
do
  safe_link "$DOTFILES_DIR/$dir" "$HOME/.config/$dir"
done

# Link git ignore to XDG location
mkdir -p "$HOME/.config/git"
safe_link "$DOTFILES_DIR/git/ignore" "$HOME/.config/git/ignore"
