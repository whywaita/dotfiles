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

# Test case: pre-existing directory should be backed up
tmp_home2="$(mktemp -d)"
cleanup2() {
  rm -rf "$tmp_home2"
}
trap cleanup2 EXIT

export HOME="$tmp_home2"

# Pre-create ~/.claude/skills as a real directory with a dummy file
mkdir -p "$HOME/.claude/skills"
echo "dummy" > "$HOME/.claude/skills/dummy.txt"

# Run setup.sh
bash "$dot_claude_dir/scripts/setup.sh"

# Verify the directory is now a symlink
if [ ! -L "$HOME/.claude/skills" ]; then
  echo "ERROR: ~/.claude/skills should be a symlink after setup"
  exit 1
fi

# Verify it points to the correct location
if [ "$(readlink "$HOME/.claude/skills")" != "$dot_claude_dir/skills" ]; then
  echo "ERROR: ~/.claude/skills symlink points to wrong location"
  echo "  expected: $dot_claude_dir/skills"
  echo "  actual:   $(readlink "$HOME/.claude/skills")"
  exit 1
fi

# Verify the old directory was backed up
if [ ! -d "$HOME/.claude/skills.backup" ]; then
  echo "ERROR: ~/.claude/skills.backup should exist"
  exit 1
fi

if [ ! -f "$HOME/.claude/skills.backup/dummy.txt" ]; then
  echo "ERROR: ~/.claude/skills.backup/dummy.txt should exist"
  exit 1
fi

echo "All tests passed!"
