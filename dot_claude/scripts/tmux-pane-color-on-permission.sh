#!/usr/bin/env bash
set -euo pipefail

[ -n "${TMUX_PANE:-}" ] || exit 0

payload=$(cat)
message=$(printf '%s' "$payload" | jq -r '.message // empty' 2>/dev/null || true)

case "$message" in
  *permission*|*許可*)
    tmux set -p -t "$TMUX_PANE" window-style 'bg=colour159'
    tmux set -p -t "$TMUX_PANE" window-active-style 'bg=colour159'
    ;;
esac
