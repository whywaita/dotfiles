---
path: "**/.github/workflows/*.{yml,yaml}"
---

# GitHub Actions Workflow Style

- workflow ファイルを作成・編集した後は、必ず `actionlint` を実行して構文エラーがないことを確認すること
- `actionlint` 実行後、`pinact run -u` を実行して全ての action 参照を SHA ピンにすること（タグ参照のまま残さない）
- 新しいリポジトリに CI を構築する場合は、actionlint を実行する job を必ず含めること。以下のパターンを使う:

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

- action のバージョンは `@vX.Y.Z` のようなタグではなく、SHA ハッシュで固定する（`pinact run -u` が自動で行う）
- `pinact run -u` はタグをSHAに変換し、コメントで元のタグバージョンを付記する
