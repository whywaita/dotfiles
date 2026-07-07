#!/bin/bash
set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
dot_codex_dir="$(cd "$script_dir/.." && pwd)"

mkdir -p "$HOME/.codex/skills"

# Helper function to safely create symlinks, backing up pre-existing non-symlink directories
safe_link() {
  local src="$1"
  local dst="$2"

  if [ -e "$dst" ] || [ -L "$dst" ]; then
    if [ ! -L "$dst" ]; then
      # Destination exists and is not a symlink, back it up
      mv "$dst" "$dst.backup"
      echo "Backed up existing $dst to $dst.backup"
    fi
  fi

  ln -sfn "$src" "$dst"
}

safe_link "$dot_codex_dir/AGENTS.md" "$HOME/.codex/AGENTS.md"
safe_link "$dot_codex_dir/skills" "$HOME/.codex/skills/local"
