#!/bin/bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
sync_script="$repo_root/scripts/sync-skills.sh"

failures=0

fail() {
  echo "FAIL: $1"
  failures=$((failures + 1))
}

# frontmatter ブロックだけを取り出す。本文に同名のキーらしき行があっても混ざらないようにする
frontmatter() {
  awk '
    NR == 1 && $0 == "---" { in_fm = 1; next }
    in_fm && $0 == "---"   { exit }
    in_fm { print }
  ' "$1"
}

# テスト用の最小リポジトリレイアウトを作る
make_fixture() {
  local root="$1"

  mkdir -p "$root/scripts"
  mkdir -p "$root/dot_claude/skills/sample-skill"
  mkdir -p "$root/dot_codex/skills"

  cat > "$root/scripts/synced-skills.txt" <<'EOF'
# コメント行は無視される

sample-skill
EOF

  cat > "$root/dot_claude/skills/sample-skill/SKILL.md" <<'EOF'
---
name: sample-skill
description: A sample skill.
argument-hint: <path>
allowed-tools: Read, Write
disable-model-invocation: true
---

# Sample

allowed-tools: this line is body text and must survive.
EOF

  cat > "$root/dot_claude/skills/sample-skill/REFERENCE.md" <<'EOF'
# Reference

Copied verbatim.
EOF
}

# --- Case 1: 同期すると Claude 専用 frontmatter が除去される ---
tmp1="$(mktemp -d)"
trap 'rm -rf "$tmp1"' EXIT
make_fixture "$tmp1"

if ! "$sync_script" --root "$tmp1" >/dev/null; then
  fail "sync should succeed on a valid fixture"
fi

dst="$tmp1/dot_codex/skills/sample-skill/SKILL.md"

if [ ! -f "$dst" ]; then
  fail "synced SKILL.md should exist"
else
  if frontmatter "$dst" | grep -q '^allowed-tools:'; then
    fail "allowed-tools should be stripped from frontmatter"
  fi
  if frontmatter "$dst" | grep -q '^disable-model-invocation:'; then
    fail "disable-model-invocation should be stripped from frontmatter"
  fi
  if ! frontmatter "$dst" | grep -q '^argument-hint: <path>$'; then
    fail "argument-hint should be preserved"
  fi
  if ! frontmatter "$dst" | grep -q '^name: sample-skill$'; then
    fail "name should be preserved"
  fi
  if ! grep -q '^allowed-tools: this line is body text and must survive\.$' "$dst"; then
    fail "body lines must not be stripped"
  fi
fi

if [ ! -f "$tmp1/dot_codex/skills/sample-skill/REFERENCE.md" ]; then
  fail "reference files should be copied"
elif ! diff -q "$tmp1/dot_claude/skills/sample-skill/REFERENCE.md" \
  "$tmp1/dot_codex/skills/sample-skill/REFERENCE.md" >/dev/null; then
  fail "reference files should be copied verbatim"
fi

# --- Case 2: 同期直後の --check は成功する ---
if ! "$sync_script" --check --root "$tmp1" >/dev/null; then
  fail "--check should pass right after a sync"
fi

# --- Case 3: 同期が二度実行されても結果が変わらない（冪等） ---
"$sync_script" --root "$tmp1" >/dev/null
if ! "$sync_script" --check --root "$tmp1" >/dev/null; then
  fail "sync should be idempotent"
fi

# --- Case 4: Codex 側が手で書き換えられていたら --check が失敗する ---
echo "drifted" >> "$dst"
if "$sync_script" --check --root "$tmp1" >/dev/null 2>&1; then
  fail "--check should fail when the Codex copy has drifted"
fi

# --- Case 5: Codex 側のファイルが消えていたら --check が失敗する ---
tmp2="$(mktemp -d)"
trap 'rm -rf "$tmp1" "$tmp2"' EXIT
make_fixture "$tmp2"
if "$sync_script" --check --root "$tmp2" >/dev/null 2>&1; then
  fail "--check should fail when the Codex copy is missing"
fi

# --- Case 6: manifest に無い skill は触らない ---
mkdir -p "$tmp2/dot_codex/skills/untracked"
echo "hand written" > "$tmp2/dot_codex/skills/untracked/SKILL.md"
"$sync_script" --root "$tmp2" >/dev/null
if [ "$(cat "$tmp2/dot_codex/skills/untracked/SKILL.md")" != "hand written" ]; then
  fail "skills outside the manifest must be left untouched"
fi

# --- Case 7: Claude 側に存在しない skill が manifest にあればエラー ---
tmp3="$(mktemp -d)"
trap 'rm -rf "$tmp1" "$tmp2" "$tmp3"' EXIT
make_fixture "$tmp3"
echo "missing-skill" >> "$tmp3/scripts/synced-skills.txt"
if "$sync_script" --root "$tmp3" >/dev/null 2>&1; then
  fail "sync should fail when a manifest entry has no source skill"
fi

# --- Case 8: 本物の manifest が実際に同期済みであること ---
if ! "$sync_script" --check --root "$repo_root" >/dev/null; then
  fail "the repository's own synced skills are out of date; run scripts/sync-skills.sh"
fi

if [ "$failures" -ne 0 ]; then
  echo "$failures test(s) failed"
  exit 1
fi

echo "All tests passed!"
