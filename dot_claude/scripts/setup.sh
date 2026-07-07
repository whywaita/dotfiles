#!/bin/bash
set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
dot_claude_dir="$(cd "$script_dir/.." && pwd)"
dotfiles_dir="$(cd "$dot_claude_dir/.." && pwd)"

# shellcheck disable=SC1091
source "$dotfiles_dir/scripts/lib/safe-link.sh"

mkdir -p "$HOME/.claude"

safe_link "$dot_claude_dir/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
safe_link "$dot_claude_dir/settings.json" "$HOME/.claude/settings.json"
safe_link "$dot_claude_dir/commands" "$HOME/.claude/commands"
safe_link "$dot_claude_dir/agents" "$HOME/.claude/agents"
safe_link "$dot_claude_dir/rules" "$HOME/.claude/rules"
safe_link "$dot_claude_dir/skills" "$HOME/.claude/skills"
