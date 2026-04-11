# 基本設定

- .whywaita ディレクトリ配下は git 管理しないこと（絶対にリポジトリに含めない）
- github.com の URL で 404 が返された場合は `gh` コマンドでリトライすること（権限の問題の可能性あり）
- ソースコード編集後は、その言語のフォーマッタを実行すること（Go: `go fmt`, Deno: `deno fmt` 等）
- テストは必ず書くこと。TDD の Red-Green-Refactor サイクルに従い、まず失敗するテストを書き、通る最小限のコードを書き、リファクタリングする
- git commit 時はまず `git commit -S` で signed commit を試みること。失敗した場合は `git -c commit.gpgsign=false commit` でフォールバックする

# GitHub Actions Workflow

- workflow ファイル（`.github/workflows/*.yml`, `.github/workflows/*.yaml`）を作成・編集した後は、必ず `actionlint` を実行して構文エラーがないことを確認すること
- `actionlint` 実行後、`pinact run -u` を実行して全ての action 参照を SHA ピンにすること（タグ参照のまま残さない）
- 新しいリポジトリに CI を構築する場合は、actionlint を実行する job を必ず含めること。パターン:

```yaml
actionlint:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@vX
    - name: Install actionlint
      run: bash <(curl -s https://raw.githubusercontent.com/rhysd/actionlint/main/scripts/download-actionlint.bash)
    - name: Run actionlint
      run: ./actionlint
```

- action のバージョンはタグではなく SHA ハッシュで固定する（`pinact run -u` が自動で行う）