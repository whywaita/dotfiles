#!/bin/bash

set -eux

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

"$SCRIPT_DIR/scripts/setup-symlinks.sh"
"$SCRIPT_DIR/scripts/setup-claude.sh"
"$SCRIPT_DIR/scripts/setup-codex.sh"
"$SCRIPT_DIR/scripts/setup-opencode.sh"
"$SCRIPT_DIR/scripts/setup-nvim.sh"
"$SCRIPT_DIR/scripts/setup-homebrew.sh"

if command -v go >/dev/null 2>&1; then
  "$SCRIPT_DIR/scripts/setup-go-tools.sh"
else
  echo "Warning: go is not installed; skipping setup-go-tools.sh. Run brewfile.sh first to install go." >&2
fi
