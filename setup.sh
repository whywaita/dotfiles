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
"$HOME"/dotfiles/dot_claude/scripts/setup.sh

# Setup Codex configuration
"$HOME"/dotfiles/dot_codex/scripts/setup-codex.sh

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

# Install Go tools
echo "Installing Go tools..."
go install github.com/k1LoW/git-wt@latest
