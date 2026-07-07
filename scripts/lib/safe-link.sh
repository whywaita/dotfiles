#!/bin/bash
# 共有ヘルパ: シンボリックリンクを安全に作成する
# - 既に正しいリンクが張られていれば何もしない
# - リンク先に実体（非シンボリックリンク）が存在する場合は .backup に退避してからリンクする
# 使い方: source してから safe_link <src> <dst>

safe_link() {
  local src="$1"
  local dst="$2"

  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    echo "Skip: $dst already linked correctly"
    return 0
  fi

  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    mv "$dst" "$dst.backup"
    echo "Backed up existing $dst to $dst.backup"
  fi

  ln -sfn "$src" "$dst"
}
