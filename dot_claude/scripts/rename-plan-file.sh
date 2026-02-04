#!/bin/bash
# Plan完了後にプランファイル名を自動で書き換えるスクリプト
# worktree-implと同じロジックで、プランの内容から適切なファイル名を推定

set -e

PLANS_DIR="./plans"

# plansディレクトリが存在しない場合は何もしない
if [ ! -d "$PLANS_DIR" ]; then
  exit 0
fi

# 最新のプランファイルを取得（.mdファイルのみ）
latest_file=$(ls -t "$PLANS_DIR"/*.md 2>/dev/null | head -n 1)

if [ -z "$latest_file" ]; then
  exit 0
fi

# ファイル名から拡張子を除いた部分を取得
filename=$(basename "$latest_file" .md)

# ランダム名のパターン（単語-単語-単語）にマッチするか確認
# 3つの単語がハイフンで繋がれている場合のみ処理
if echo "$filename" | grep -qE '^[a-z]+-[a-z]+-[a-z]+$'; then
  # ファイルの1行目からタイトルを取得（# を除去）
  title=$(head -n 1 "$latest_file" | sed 's/^#\s*//')

  if [ -z "$title" ]; then
    exit 0
  fi

  # タイトルをファイル名に適した形式に変換
  # worktree-implのsanitize処理と同様：
  # - 小文字化
  # - 空白をハイフンに置換
  # - スラッシュをハイフンに置換
  # - 英数字とハイフン以外を削除
  # - 連続するハイフンを1つに
  # - 先頭と末尾のハイフンを削除
  new_filename=$(echo "$title" | \
    tr '[:upper:]' '[:lower:]' | \
    tr ' /' '--' | \
    sed 's/[^a-z0-9-]//g' | \
    sed 's/--*/-/g' | \
    sed 's/^-//;s/-$//')

  # 新しいファイル名が有効な場合のみリネーム
  if [ -n "$new_filename" ]; then
    new_path="$PLANS_DIR/${new_filename}.md"

    # 既に同じ名前のファイルが存在する場合はスキップ
    if [ ! -e "$new_path" ]; then
      mv "$latest_file" "$new_path"
      echo "📝 プランファイルをリネームしました: $(basename "$new_path")"
    fi
  fi
fi
