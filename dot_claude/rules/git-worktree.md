# Git Worktree リファレンス

## 概念
git worktree は同一リポジトリで複数の作業ツリーを管理する機能。
メインの作業ディレクトリを汚さずに、別ブランチでの作業を並行して行える。

## 配置ルール
- worktree は `<repo>/.worktrees/<branch-name>/` に配置する
- `.worktrees/` は `.gitignore` に追加して管理対象外にする

## よく使うコマンド

### 新規作成（新ブランチ）
```bash
git worktree add -b <branch-name> .worktrees/<sanitized-name> origin/<base>
```

### 新規作成（既存ブランチ）
```bash
git worktree add .worktrees/<name> <existing-branch>
```

### 一覧表示
```bash
git worktree list
```

### 削除
```bash
git worktree remove .worktrees/<name>
```

### クリーンアップ
```bash
git worktree prune
```

## 注意点
- 同じブランチを複数の worktree でチェックアウトできない
- 作業完了後は worktree を削除してクリーンアップすること
