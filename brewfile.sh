#!/bin/bash

set -eux

# CI mode: only check if packages exist in the registry (no actual installation)
# Local mode: actually install packages
CI_MODE="${CI:-false}"

# Packages to install
FORMULAE=(
  # shell
  zsh
  # Utilities
  openssl
  libyaml
  readline
  anyenv
  # git
  git
  # tools
  tmux
  nkf
  vim
  nvim
  w3m
  curl
  wget
  tree
  nmap
  # dev
  go
  kubectl
  gpg2
  ghq
  watch
)

CASKS=(
  iterm2
  vlc
  coteditor
  alfred
  adobe-acrobat-reader
  xquartz
  karabiner-elements
  slack
  1password
  docker
  gpg-suite
)

if [ "$CI_MODE" == "true" ]; then
  echo "Running in CI mode: checking package existence only"

  FAILED_FORMULAE=()
  FAILED_CASKS=()

  # Check formulae exist
  for formula in "${FORMULAE[@]}"; do
    if brew info "$formula" > /dev/null 2>&1; then
      echo "✓ Formula exists: $formula"
    else
      echo "✗ Formula NOT found: $formula"
      FAILED_FORMULAE+=("$formula")
    fi
  done

  # Check casks exist
  for cask in "${CASKS[@]}"; do
    if brew info --cask "$cask" > /dev/null 2>&1; then
      echo "✓ Cask exists: $cask"
    else
      echo "✗ Cask NOT found: $cask"
      FAILED_CASKS+=("$cask")
    fi
  done

  if [ ${#FAILED_FORMULAE[@]} -gt 0 ] || [ ${#FAILED_CASKS[@]} -gt 0 ]; then
    echo ""
    echo "=== Summary of failed packages ==="
    if [ ${#FAILED_FORMULAE[@]} -gt 0 ]; then
      echo "Failed formulae (${#FAILED_FORMULAE[@]}):"
      for f in "${FAILED_FORMULAE[@]}"; do
        echo "  - $f"
      done
    fi
    if [ ${#FAILED_CASKS[@]} -gt 0 ]; then
      echo "Failed casks (${#FAILED_CASKS[@]}):"
      for c in "${FAILED_CASKS[@]}"; do
        echo "  - $c"
      done
    fi
    exit 1
  fi

  echo "All packages exist in the Homebrew registry"
else
  # Local installation mode

  # update Homebrew
  brew update
  brew upgrade

  # Install formulae
  for formula in "${FORMULAE[@]}"; do
    brew install "$formula"
  done

  # Install casks
  for cask in "${CASKS[@]}"; do
    brew install --cask "$cask"
  done

  # remove dust
  brew cleanup
fi
