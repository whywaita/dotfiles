# whywaita/dotfiles

個人の dotfiles リポジトリ。シンボリックリンクで `$HOME` に配置する構成。

## セットアップ

```bash
cd $HOME
git clone --recursive git@github.com:whywaita/dotfiles.git
sh dotfiles/setup.sh
```

`setup.sh` が以下を行う:

- dotfiles のシンボリックリンク作成（`.zshrc`, `.tmux.conf`, `.gitconfig` 等）
- `~/.config/` 配下へのリンク作成（`mdp` 等）
- Claude Code 設定のリンク作成（`dot_claude/scripts/setup.sh`）
- Codex 設定のリンク作成（`dot_codex/scripts/setup-codex.sh`）
- dein.vim のクローン
- Homebrew のインストール

## 重要なルール

- **chezmoi は使っていない**。`chezmoi apply` 等の chezmoi コマンドは絶対に実行しないこと

## CI

GitHub Actions で以下のチェックを実行する（push / PR / daily）:

- `shellcheck`: シェルスクリプトの静的解析（`setup.sh`, `brewfile.sh`, `dot_claude/scripts/setup.sh`, `tests/setup_claude_test.sh`）
- `zsh -n .zshrc`: Zsh 構文チェック
- `luacheck .wezterm.lua`: Lua 静的解析
- `tmux -f .tmux.conf`: tmux 設定の構文チェック
- `taplo check nvim/*.toml`: TOML 構文チェック
- Neovim 設定の読み込みチェック
- `git config --file .gitconfig --list`: gitconfig 構文チェック
- `./brewfile.sh`: Homebrew パッケージの存在確認

## ファイル編集時の注意

- シェルスクリプトを編集した場合は `shellcheck` を通すこと
- `.wezterm.lua` を編集した場合は `luacheck` で確認すること
- `nvim/*.toml` を編集した場合は `taplo check` で確認すること
