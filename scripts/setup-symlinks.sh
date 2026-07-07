#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Helper function to safely create symlinks, backing up pre-existing non-symlink directories
safe_link() {
  local src="$1"
  local dst="$2"
  local is_dir="$3"  # "dir" for directory, "" for file

  if [ -e "$dst" ] || [ -L "$dst" ]; then
    if [ ! -L "$dst" ]; then
      # Destination exists and is not a symlink, back it up
      mv "$dst" "$dst.backup"
      echo "Backed up existing $dst to $dst.backup"
    fi
  fi

  if [ "$is_dir" = "dir" ]; then
    ln -sfn "$src" "$dst"
  else
    ln -sf "$src" "$dst"
  fi
}

DOT_FILES=(.zshrc .tmux.conf .gitconfig .gemrc .latexmkrc .screenrc .wezterm.lua)

for file in "${DOT_FILES[@]}"
do
  src="$DOTFILES_DIR/$file"
  dst="$HOME/$file"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    echo "Skip: $dst already linked correctly"
  else
    safe_link "$src" "$dst" ""
  fi
done

DOT_CONFIG_DIRS=(mdp ghostty nvim)

mkdir -p "$HOME/.config"

for dir in "${DOT_CONFIG_DIRS[@]}"
do
  src="$DOTFILES_DIR/$dir"
  dst="$HOME/.config/$dir"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    echo "Skip: $dst already linked correctly"
  else
    safe_link "$src" "$dst" "dir"
  fi
done

# Link git ignore to XDG location
mkdir -p "$HOME/.config/git"
safe_link "$DOTFILES_DIR/git/ignore" "$HOME/.config/git/ignore" ""
