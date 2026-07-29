#!/bin/bash
# dot_claude/skills から dot_codex/skills へ、指定された skill を機械的に同期する。
#
# 同期対象は scripts/synced-skills.txt に列挙した skill のみ。
# 手で書き分けている skill はここに載せないこと（上書きされる）。
#
# 変換内容: SKILL.md の frontmatter から Codex が解釈しないキーを除去する。
# それ以外のファイルは verbatim でコピーする。
#
# 使い方:
#   scripts/sync-skills.sh            同期する
#   scripts/sync-skills.sh --check    差分があれば非ゼロ終了する（CI 用）

set -euo pipefail

# Codex 側の frontmatter に残さないキー
CLAUDE_ONLY_KEYS='allowed-tools|disable-model-invocation'

usage() {
  cat <<'EOF'
Usage: sync-skills.sh [--check] [--root DIR]

  --check      同期せず、差分の有無だけを検査する。差分があれば非ゼロ終了
  --root DIR   リポジトリルート（既定: このスクリプトの親ディレクトリ）
EOF
}

check_only=0
root=""

while [ $# -gt 0 ]; do
  case "$1" in
    --check)
      check_only=1
      shift
      ;;
    --root)
      if [ $# -lt 2 ]; then
        echo "Error: --root requires a directory" >&2
        exit 2
      fi
      root="$2"
      shift 2
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      echo "Error: unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [ -z "$root" ]; then
  script_dir="$(cd "$(dirname "$0")" && pwd)"
  root="$(cd "$script_dir/.." && pwd)"
fi

if [ ! -d "$root" ]; then
  echo "Error: root is not a directory: $root" >&2
  exit 2
fi
root="$(cd "$root" && pwd)"

manifest="$root/scripts/synced-skills.txt"
src_root="$root/dot_claude/skills"
dst_root="$root/dot_codex/skills"

for required in "$manifest" "$src_root" "$dst_root"; do
  if [ ! -e "$required" ]; then
    echo "Error: missing required path: $required" >&2
    exit 2
  fi
done

# frontmatter からのみ Claude 専用キーを除去する。
# 除去したキーが複数行の値を持つ場合、続くインデント行もまとめて落とす。
strip_claude_only_keys() {
  awk -v keys="$CLAUDE_ONLY_KEYS" '
    NR == 1 && $0 == "---" { in_fm = 1; print; next }
    in_fm && $0 == "---"   { in_fm = 0; dropping = 0; print; next }
    in_fm && $0 ~ "^(" keys "):" { dropping = 1; next }
    in_fm && dropping && /^[ \t]/ { next }
    in_fm { dropping = 0; print; next }
    { print }
  ' "$1"
}

skills=()
while IFS= read -r line || [ -n "$line" ]; do
  line="${line%%#*}"
  line="$(printf '%s' "$line" | tr -d '[:space:]')"
  [ -n "$line" ] || continue
  case "$line" in
    */* | *..*)
      echo "Error: invalid skill name in $manifest: $line" >&2
      exit 2
      ;;
  esac
  skills+=("$line")
done < "$manifest"

if [ "${#skills[@]}" -eq 0 ]; then
  echo "No skills listed in $manifest; nothing to do."
  exit 0
fi

stage_root="$(mktemp -d)"
cleanup() {
  rm -rf "$stage_root"
}
trap cleanup EXIT

drift=0

for skill in "${skills[@]}"; do
  src="$src_root/$skill"
  dst="$dst_root/$skill"

  if [ ! -d "$src" ]; then
    echo "Error: skill listed in manifest but missing from dot_claude/skills: $skill" >&2
    exit 1
  fi

  stage="$stage_root/$skill"
  mkdir -p "$stage"
  cp -R "$src/." "$stage/"

  # stage 内の SKILL.md を変換する
  while IFS= read -r skill_md; do
    strip_claude_only_keys "$skill_md" > "$skill_md.tmp"
    mv "$skill_md.tmp" "$skill_md"
  done < <(find "$stage" -type f -name 'SKILL.md')

  if [ "$check_only" -eq 1 ]; then
    if [ ! -d "$dst" ]; then
      echo "Out of sync: $skill is missing from dot_codex/skills" >&2
      drift=1
      continue
    fi
    if ! diff -r "$stage" "$dst" >&2; then
      echo "Out of sync: $skill" >&2
      drift=1
    fi
    continue
  fi

  rm -rf "$dst"
  cp -R "$stage" "$dst"
  echo "Synced: $skill"
done

if [ "$check_only" -eq 1 ]; then
  if [ "$drift" -ne 0 ]; then
    echo "Synced skills are out of date. Run scripts/sync-skills.sh" >&2
    exit 1
  fi
  echo "Synced skills are up to date."
fi
