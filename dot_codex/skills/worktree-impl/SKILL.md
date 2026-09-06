---
name: worktree-impl
argument-hint: [branch-name]
description: Plan mode 終了後、実装開始前に使用する。git worktree を作成して隔離環境で実装を進める。変更を加える際に自動的に提案すること。
---

計画が固まった後、実装を始める前に git worktree を作り、その中で作業するためのスキル。

## 配置ルール

- worktree は `<repo>/.worktrees/<sanitized-name>/` に置く
- `<sanitized-name>` はブランチ名の `/` を `-` に置換したもの
- `.worktrees/` が `.gitignore` に無ければ追加する

## 手順

### 1. 事前確認

```bash
git rev-parse --is-inside-work-tree
git fetch origin
git worktree list
```

### 2. ブランチ名の決定

- 引数があればそれを使う
- 無ければ計画内容から候補を決め、`git branch -r` で既存の命名規則に合わせてから、ユーザーに確認する

### 3. worktree の作成

```bash
base="$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')"
git worktree add -b <branch-name> .worktrees/<sanitized-name> "origin/$base"
```

### 4. 次のアクションを提案

1. worktree で新しいセッションを開く（`cd <worktree-path>` してから使用中のエージェント CLI を起動）
2. 現在のセッションで `cd <worktree-path>` して続行
3. 手動で移動

## 注意点

- 同じブランチを複数の worktree でチェックアウトすることはできない
- 作業完了後は `git worktree remove .worktrees/<sanitized-name>` で削除する
