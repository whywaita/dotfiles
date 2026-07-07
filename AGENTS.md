# whywaita/dotfiles

個人の dotfiles リポジトリ。シンボリックリンクで `$HOME` に配置する構成。

## セットアップ

```bash
cd $HOME
git clone --recursive git@github.com:whywaita/dotfiles.git
sh dotfiles/setup.sh
```

`setup.sh` は `scripts/setup-*.sh` を順に実行するラッパー。各スクリプトの役割は README の表を参照（重複記載によるドリフトを避けるため、ここには列挙しない）。

## 重要なルール

- **chezmoi は使っていない**。`chezmoi apply` 等の chezmoi コマンドは絶対に実行しないこと

### シンボリックリンク

- リンク作成は `scripts/lib/safe-link.sh` を `source` して `safe_link <src> <dst>` を使うこと。`ln -sf` / `ln -sfn` を直接呼ばない
  - 理由: リンク先に実ディレクトリが既存の場合、macOS の `ln -sfn` はディレクトリの内側に入れ子リンクを作って exit 0 する。`safe_link` は実体を `.backup` に退避してからリンクする
- リポジトリに存在しないファイルをリンク対象に追加しないこと。`ln -sf` はリンク元が無くても成功し、dangling link が残り続ける

### シェルスクリプト

- macOS (BSD) と Linux の両方で動くこと。GNU 専用の機能（`find -printf`、引数なしの `sed -i` 等）を使わない。shellcheck 指摘の解消でコマンドを書き換える場合も BSD 互換を維持すること
- スクリプトの実行ビット（755）を維持すること。ファイルを作り直す際に mode を落とすと CI が `Permission denied` で fail する
- エスケープシーケンス（`\n` 等）の出力には `echo` ではなく `printf` を使うこと
- 外部コマンドに依存する処理は `command -v` でガードすること。依存コマンドは `brewfile.sh` か setup スクリプトで必ず導入する（`.zshrc` から参照するツールも同様）

### 設定ファイル

- TOML の top-level キーは最初のテーブルヘッダ（`[section]`）より前に書くこと。後ろに書くと直前のテーブルのキーとして解釈され、silent に無効になる
- 設定オプションは単位・意味を公式ドキュメントで確認してから設定すること（例: Ghostty の `scrollback-limit` は行数ではなくバイト数）
- 既存のキーバインドや操作感を変える変更は、必ず事前にユーザの承認を得ること

### 整合性の維持

- ファイルを移動・リネームしたら、参照箇所（CI workflow、スクリプト、README、AGENTS.md）を全て更新すること
- `setup.sh` の実行内容や reusable workflow の inputs を変更したら、README の該当表も更新すること
- どこからも参照されないファイル・ディレクトリを追加しないこと。skills の正は `dot_claude/skills/` と `dot_codex/skills/` の 2 箇所（共通ディレクトリは存在しない）

## CI

GitHub Actions（`.github/workflows/test.yaml`）で push / PR / daily に lint・構文チェックを実行する。shellcheck はリポジトリ内の全シェルスクリプト（`git ls-files '*.sh'`）が対象。個別のジョブ定義は workflow ファイルを参照。

### CI を変更するときの注意

- チェックは「失敗したら非ゼロ終了する」ことを必ず確認すること。ツールがエラーを出しても exit 0 で終わるケースがある（例: nvim の headless 実行）ため、出力のエラーパターン検査を併用する
- 検査対象のファイルはハードコードせず `git ls-files` 等で動的に集めること。ハードコードすると新規ファイルが検査から漏れる
- action の参照は SHA ピンにすること（`pinact run -u`）。`@main` 等のブランチ参照を残さない
- キャッシュキーで「latest」を固定しないこと。バージョンをキーに含めるか、キャッシュを使わない

## ファイル編集時の注意

- シェルスクリプトを編集した場合は `shellcheck` を通すこと
- `.wezterm.lua` を編集した場合は `luacheck` で確認すること
- `nvim/*.toml` を編集した場合は `taplo check` で確認すること
- `dot_claude/settings.json` を編集した場合は `python3 -m json.tool` で JSON の妥当性を確認すること
- `dot_codex/config.template.toml` を編集した場合は `taplo check` 等で TOML の妥当性を確認すること
