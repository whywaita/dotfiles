# whywaita/dotfiles

[![lint and check](https://github.com/whywaita/dotfiles/actions/workflows/test.yaml/badge.svg)](https://github.com/whywaita/dotfiles/actions/workflows/test.yaml)

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
| `scripts/setup-codex.sh` | Setup Codex configuration, skills, and the worktree shell wrapper |
| `scripts/setup-opencode.sh` | Setup OpenCode configuration |
| `scripts/setup-nvim.sh` | Clone dein.vim (Neovim plugin manager) |
| `scripts/setup-homebrew.sh` | Install Homebrew |
| `scripts/setup-go-tools.sh` | Install Go tools (git-wt) |
| `scripts/sync-skills.sh` | Sync skills listed in `scripts/synced-skills.txt` from `dot_claude/skills/` to `dot_codex/skills/` (`--check` to verify only) |
| `brewfile.sh` | Install Homebrew packages |

```bash
# Example: setup only symlinks and Claude Code
./scripts/setup-symlinks.sh
./scripts/setup-claude.sh
```

### Codex worktree sessions

Run `./scripts/setup-codex.sh` and open a new Zsh session (or run
`source "$HOME/.codex/worktree-shell.sh"` in the current Bash/Zsh session).
Git and Codex CLI are required; `brewfile.sh` installs both.

```bash
codex --worktree feature-name
codex -w                         # Generate a unique name
codex -w feature-name -- "Fix the failing tests"
```

The leading `--worktree` / `-w` option creates `.worktrees/<name>` on a new
`codex/<name>` branch from the current HEAD, then launches Codex there.
Uncommitted changes in the original checkout are not copied. The wrapper adds
`/.worktrees/` to Git's local `info/exclude` if needed. Other invocations pass
through unchanged; worktree mode rejects `--cd` / `-C` and `--remote` overrides.

After Codex exits, choose **Remove** or **Keep** (the default). Remove retains
the branch, and requires typing `DELETE` before discarding uncommitted,
untracked, or ignored files. Detached HEAD worktrees are kept until you create
a branch for them. Keep prints a command to open the resume picker
in that worktree. A missing terminal, an empty answer, or a disconnected
session leaves the worktree intact. Forced termination cannot show a prompt.
Existing worktree or branch names are rejected; use the printed resume command
to continue existing work. Codex's exit code is preserved unless cleanup alone fails.

Run the lifecycle tests with `python3 tests/codex_worktree_test.py`.

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
| `opencode` | boolean | `false` | Setup OpenCode |
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
