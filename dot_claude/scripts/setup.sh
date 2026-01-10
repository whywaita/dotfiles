#!/bin/bash
set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
dot_claude_dir="$(cd "$script_dir/.." && pwd)"

mkdir -p "$HOME/.claude"

ln -sf "$dot_claude_dir/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
ln -sf "$dot_claude_dir/settings.json" "$HOME/.claude/settings.json"
ln -sfn "$dot_claude_dir/commands" "$HOME/.claude/commands"
ln -sfn "$dot_claude_dir/agents" "$HOME/.claude/agents"
ln -sfn "$dot_claude_dir/rules" "$HOME/.claude/rules"
ln -sfn "$dot_claude_dir/skills" "$HOME/.claude/skills"
