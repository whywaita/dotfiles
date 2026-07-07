#!/bin/bash
set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
dot_codex_dir="$(cd "$script_dir/.." && pwd)"
dotfiles_dir="$(cd "$dot_codex_dir/.." && pwd)"

# shellcheck disable=SC1091
source "$dotfiles_dir/scripts/lib/safe-link.sh"

mkdir -p "$HOME/.codex/skills"

safe_link "$dot_codex_dir/AGENTS.md" "$HOME/.codex/AGENTS.md"
safe_link "$dot_codex_dir/skills" "$HOME/.codex/skills/local"
