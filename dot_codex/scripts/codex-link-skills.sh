#!/bin/bash
set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
dot_codex_dir="$(cd "$script_dir/.." && pwd)"

mkdir -p "$HOME/.codex/skills"

ln -sfn "$dot_codex_dir/AGENTS.md" "$HOME/.codex/AGENTS.md"
ln -sfn "$dot_codex_dir/skills" "$HOME/.codex/skills/local"
