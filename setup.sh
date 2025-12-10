#!/bin/bash

set -eux

if [ "${CI:-false}" == "true" ]; then
  set +e
fi

DOT_FILES=(.zshrc .vim .vimrc .tmux .tmux.conf .gitconfig .gemrc .latexmkrc .screenrc .wezterm.lua)

for file in "${DOT_FILES[@]}"
do
  ln -s "$HOME"/dotfiles/"$file" "$HOME"/"$file"
done

mkdir -p "$HOME"/.cache/dein/repos/github.com/Shougo/dein.vim
git clone https://github.com/Shougo/dein.vim.git "$HOME"/.cache/dein/repos/github.com/Shougo/dein.vim

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
