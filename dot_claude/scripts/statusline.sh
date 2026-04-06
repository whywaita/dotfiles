#!/bin/bash

input=$(cat)

# Parse all values in one jq call
eval "$(echo "$input" | jq -r '
  @sh "remaining=\(.context_window.remaining_percentage)",
  @sh "used=\(.context_window.used_percentage)",
  @sh "input_tokens=\(.context_window.total_input_tokens // 0)",
  @sh "window_size=\(.context_window.context_window_size // 200000)",
  @sh "model=\(.model.display_name // "unknown")",
  @sh "cwd=\(.workspace.current_dir // .cwd // "")"
')"

# Context remaining percentage
if [ "$remaining" != "null" ] && [ -n "$remaining" ]; then
  ctx="$remaining"
elif [ "$used" != "null" ] && [ -n "$used" ]; then
  ctx=$(echo "100 - $used" | bc)
else
  # Compute from tokens
  if [ "$window_size" -gt 0 ] 2>/dev/null; then
    ctx=$(echo "scale=0; (($window_size - $input_tokens) * 100) / $window_size" | bc)
  else
    ctx="100"
  fi
fi
context_str="Ctx: ${ctx}%"

# Git branch
branch=""
if [ -n "$cwd" ] && [ -d "$cwd" ]; then
  branch=$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null || GIT_OPTIONAL_LOCKS=0 git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
fi
branch_str=""
if [ -n "$branch" ]; then
  branch_str="$branch"
fi

# Assemble
parts=("$context_str" "$model")
if [ -n "$branch_str" ]; then
  parts+=("$branch_str")
fi

printf "%s" "$(IFS=' | '; echo "${parts[*]}")"
