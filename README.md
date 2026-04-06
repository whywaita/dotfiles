# whywaita/dotfiles

[![lint and check](https://github.com/whywaita/dotfiles/actions/workflows/test.yaml/badge.svg)](https://github.com/whywaita/dotfiles/actions/workflows/test.yaml)
[![setup](https://github.com/whywaita/dotfiles/actions/workflows/setup.yaml/badge.svg)](https://github.com/whywaita/dotfiles/actions/workflows/setup.yaml)

## Usage

### Full Setup

```bash
cd ${HOME}
git clone --recursive git@github.com:whywaita/dotfiles.git
sh dotfiles/setup.sh
```

### Individual Setup

`setup.sh` is a wrapper that runs the following scripts in order. You can run them individually as needed.

| Script | Description |
|--------|-------------|
| `scripts/setup-symlinks.sh` | Create dotfile symlinks in `$HOME` |
| `scripts/setup-claude.sh` | Setup Claude Code configuration |
| `scripts/setup-codex.sh` | Setup Codex configuration |
| `scripts/setup-nvim.sh` | Clone dein.vim (Neovim plugin manager) |
| `scripts/setup-homebrew.sh` | Install Homebrew |
| `scripts/setup-go-tools.sh` | Install Go tools (git-wt) |
| `brewfile.sh` | Install Homebrew packages |

```bash
# Example: setup only symlinks and Claude Code
./scripts/setup-symlinks.sh
./scripts/setup-claude.sh
```

## Reusable Workflow

You can call the dotfiles setup from other repositories via GitHub Actions.

### Basic Usage

```yaml
jobs:
  setup:
    uses: whywaita/dotfiles/.github/workflows/setup.yaml@main
```

By default, `symlinks`, `claude`, and `codex` are enabled.

### Select Components via Inputs

```yaml
jobs:
  setup:
    uses: whywaita/dotfiles/.github/workflows/setup.yaml@main
    with:
      symlinks: true
      claude: true
      codex: false
      nvim: true
      homebrew: false
      go-tools: false
      brewfile: false
```

### Available Inputs

| Input | Type | Default | Description |
|-------|------|---------|-------------|
| `runs-on` | string | `ubuntu-latest` | Runner to use (e.g. `macos-latest`) |
| `symlinks` | boolean | `true` | Create dotfile symlinks |
| `claude` | boolean | `true` | Setup Claude Code |
| `codex` | boolean | `true` | Setup Codex |
| `nvim` | boolean | `false` | Setup Neovim (dein.vim) |
| `homebrew` | boolean | `false` | Install Homebrew |
| `go-tools` | boolean | `false` | Install Go tools |
| `brewfile` | boolean | `false` | Install Homebrew packages |
| `dotfiles-ref` | string | `main` | Ref of dotfiles repo to use |

### Example: Setup Only Claude Code in CI

```yaml
name: CI
on: [push]

jobs:
  build:
    uses: whywaita/dotfiles/.github/workflows/setup.yaml@main
    with:
      symlinks: false
      claude: true
      codex: false
```
