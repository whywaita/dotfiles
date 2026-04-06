#!/bin/bash
set -euo pipefail

if command -v brew >/dev/null 2>&1; then
  echo "Skip: Homebrew already installed"
else
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
