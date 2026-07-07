#!/bin/bash
set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
dot_claude_dir="$(cd "$script_dir/.." && pwd)"

mkdir -p "$HOME/.claude"

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

safe_link "$dot_claude_dir/CLAUDE.md" "$HOME/.claude/CLAUDE.md" ""
safe_link "$dot_claude_dir/settings.json" "$HOME/.claude/settings.json" ""
safe_link "$dot_claude_dir/commands" "$HOME/.claude/commands" "dir"
safe_link "$dot_claude_dir/agents" "$HOME/.claude/agents" "dir"
safe_link "$dot_claude_dir/rules" "$HOME/.claude/rules" "dir"
safe_link "$dot_claude_dir/skills" "$HOME/.claude/skills" "dir"
