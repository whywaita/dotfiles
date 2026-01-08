#!/bin/bash

set -eux

if [ "${CI:-false}" == "true" ]; then
  set +e
fi

DOT_FILES=(.zshrc .vim .vimrc .tmux .tmux.conf .gitconfig .gemrc .latexmkrc .screenrc .wezterm.lua)

for file in "${DOT_FILES[@]}"
do
  src="$HOME/dotfiles/$file"
  dst="$HOME/$file"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    echo "Skip: $dst already linked correctly"
  else
    ln -sf "$src" "$dst"
  fi
done

DOT_CONFIG_DIRS=(mdp)

for dir in "${DOT_CONFIG_DIRS[@]}"
do
  src="$HOME/dotfiles/$dir"
  dst="$HOME/.config/$dir"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    echo "Skip: $dst already linked correctly"
  else
    ln -sf "$src" "$dst"
  fi
done

# Setup Claude Code configuration
mkdir -p "$HOME"/.claude

# Symlink Claude Code configuration files
ln -sf "$HOME"/dotfiles/dot_claude/CLAUDE.md "$HOME"/.claude/CLAUDE.md
ln -sf "$HOME"/dotfiles/dot_claude/settings.json "$HOME"/.claude/settings.json

# Symlink directories
ln -sfn "$HOME"/dotfiles/dot_claude/commands "$HOME"/.claude/commands
ln -sfn "$HOME"/dotfiles/dot_claude/agents "$HOME"/.claude/agents
ln -sfn "$HOME"/dotfiles/dot_claude/rules "$HOME"/.claude/rules
ln -sfn "$HOME"/dotfiles/dot_claude/skills "$HOME"/.claude/skills

DEIN_DIR="$HOME/.cache/dein/repos/github.com/Shougo/dein.vim"
if [ -d "$DEIN_DIR/.git" ]; then
  echo "Skip: dein.vim already cloned"
else
  mkdir -p "$HOME"/.cache/dein/repos/github.com/Shougo
  git clone https://github.com/Shougo/dein.vim.git "$DEIN_DIR"
fi

if command -v brew >/dev/null 2>&1; then
  echo "Skip: Homebrew already installed"
else
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
