#!/bin/bash

set -eux

if [ "${CI:-false}" == "true" ]; then
  set +e
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

"$SCRIPT_DIR/scripts/setup-symlinks.sh"
"$SCRIPT_DIR/scripts/setup-claude.sh"
"$SCRIPT_DIR/scripts/setup-codex.sh"
"$SCRIPT_DIR/scripts/setup-nvim.sh"
"$SCRIPT_DIR/scripts/setup-homebrew.sh"
"$SCRIPT_DIR/scripts/setup-go-tools.sh"
