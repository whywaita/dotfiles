#!/bin/bash
set -euo pipefail

if ! command -v go >/dev/null 2>&1; then
  echo "Error: go is not installed" >&2
  exit 1
fi

echo "Installing Go tools..."
go install github.com/k1LoW/git-wt@latest
