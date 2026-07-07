#!/bin/bash
set -euo pipefail

DEIN_DIR="$HOME/.cache/dein/repos/github.com/Shougo/dein.vim"
if [ -d "$DEIN_DIR/.git" ]; then
  echo "Skip: dein.vim already cloned"
else
  if [ -d "$DEIN_DIR" ]; then
    echo "Removing incomplete dein.vim directory (no .git found)"
    rm -rf "$DEIN_DIR"
  fi
  mkdir -p "$HOME/.cache/dein/repos/github.com/Shougo"
  git clone https://github.com/Shougo/dein.vim.git "$DEIN_DIR"
fi
