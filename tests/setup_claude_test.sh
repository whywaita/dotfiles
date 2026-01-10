#!/bin/bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
dot_claude_dir="$repo_root/dot_claude"

tmp_home="$(mktemp -d)"
cleanup() {
  rm -rf "$tmp_home"
}
trap cleanup EXIT

export HOME="$tmp_home"

bash "$dot_claude_dir/scripts/setup.sh"

assert_link() {
  local actual="$1"
  local expected="$2"

  if [ ! -L "$actual" ]; then
    echo "Expected symlink: $actual"
    exit 1
  fi

  if [ "$(readlink "$actual")" != "$expected" ]; then
    echo "Symlink mismatch: $actual"
    echo "  expected: $expected"
    echo "  actual:   $(readlink "$actual")"
    exit 1
  fi
}

assert_link "$HOME/.claude/CLAUDE.md" "$dot_claude_dir/CLAUDE.md"
assert_link "$HOME/.claude/settings.json" "$dot_claude_dir/settings.json"
assert_link "$HOME/.claude/commands" "$dot_claude_dir/commands"
assert_link "$HOME/.claude/agents" "$dot_claude_dir/agents"
assert_link "$HOME/.claude/rules" "$dot_claude_dir/rules"
assert_link "$HOME/.claude/skills" "$dot_claude_dir/skills"
