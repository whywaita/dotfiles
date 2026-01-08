---
allowed-tools: Bash(git worktree:*), Bash(git branch:*), Bash(git fetch:*), Bash(pwd:*), Bash(ls:*), Bash(mkdir:*)
argument-hint: [branch-name]
description: Plan mode終了後、実装開始前に使用する。git worktreeを作成して隔離環境で実装を進める。変更を加える際に自動的に提案すること。
---

Plan mode が終わった後、実装を開始する前に git worktree を作成し、その中で作業を進めるためのスキル。
git worktree の詳細は `rules/git-worktree.md` を参照すること。

## Step 1: 事前確認

1. 現在のディレクトリが git リポジトリであることを確認
2. `git fetch origin` で最新の状態を取得
3. `git worktree list` で既存の worktree 一覧を確認

## Step 2: ブランチ名の決定

引数でブランチ名が指定されていればそれを使用。指定がない場合：

1. Plan mode で作成した計画内容を参考に適切なブランチ名を決める
2. 既存ブランチのパターンを `git branch -r` で確認して命名規則を合わせる
3. ブランチ名を提案し、ユーザーに確認

## Step 3: Worktree の作成

1. base ブランチを取得:
   ```bash
   git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'
   ```
2. worktree を作成:
   ```bash
   git worktree add -b <branch-name> .worktrees/<sanitized-name> origin/<base>
   ```
   - `<sanitized-name>`: ブランチ名の `/` を `-` に置換

## Step 4: 次のアクションを提案

1. **新しいセッションを worktree で開始**
   ```bash
   cd <worktree-path> && claude
   ```
2. **現在のセッションで移動して続行**
3. **手動で移動**
