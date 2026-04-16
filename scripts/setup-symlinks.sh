#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

DOT_FILES=(.zshrc .vim .vimrc .tmux .tmux.conf .gitconfig .gemrc .latexmkrc .screenrc .wezterm.lua)

for file in "${DOT_FILES[@]}"
do
  src="$DOTFILES_DIR/$file"
  dst="$HOME/$file"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    echo "Skip: $dst already linked correctly"
  else
    ln -sf "$src" "$dst"
  fi
done

DOT_CONFIG_DIRS=(mdp ghostty)

mkdir -p "$HOME/.config"

for dir in "${DOT_CONFIG_DIRS[@]}"
do
  src="$DOTFILES_DIR/$dir"
  dst="$HOME/.config/$dir"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    echo "Skip: $dst already linked correctly"
  else
    ln -sf "$src" "$dst"
  fi
done
