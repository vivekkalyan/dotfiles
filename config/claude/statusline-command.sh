#!/bin/bash

# Get tput colors (matching Pure prompt theme)
if tput setaf 1 &> /dev/null; then
  if [[ $(tput colors) -ge 256 ]] 2>/dev/null; then
    BLUE=$(tput setaf 116)
    WHITE=$(tput setaf 244)
    GREEN=$(tput setaf 64)
    YELLOW=$(tput setaf 166)
    RESET=$(tput sgr0)
    BOLD=$(tput bold)
  else
    BLUE=$(tput setaf 4)
    WHITE=$(tput setaf 7)
    GREEN=$(tput setaf 2)
    YELLOW=$(tput setaf 3)
    RESET=$(tput sgr0)
    BOLD=$(tput bold)
  fi
else
  BLUE="\033[1;34m"
  WHITE="\033[1;37m"
  GREEN="\033[1;32m"
  YELLOW="\033[1;33m"
  RESET="\033[m"
  BOLD=""
fi

# Read JSON input
input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir')
# Replace home directory with ~
cwd_short="${cwd/#$HOME/~}"
cwd_info="${BOLD}${BLUE}${cwd_short}${RESET}"

# Get git info if in a git repo
git_info=""
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(git -C "$cwd" -c advice.detachedHead=false symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)

  # Check if dirty (using --no-optional-locks to avoid lock contention)
  dirty=""
  if ! git -C "$cwd" --no-optional-locks diff --no-ext-diff --quiet --exit-code 2>/dev/null || \
     ! git -C "$cwd" --no-optional-locks diff --cached --no-ext-diff --quiet --exit-code 2>/dev/null || \
     [ -n "$(git -C "$cwd" --no-optional-locks ls-files --others --exclude-standard 2>/dev/null)" ]; then
    dirty="*"
  fi

  git_info=" ${BOLD}${WHITE}${branch}${dirty}${RESET}"
fi

# Context usage
context_info=""
context_window_size=$(echo "$input" | jq '.context_window.context_window_size // 200000')
current_usage=$(echo "$input" | jq '.context_window.current_usage')

if [ "$current_usage" != "null" ]; then
  current_tokens=$(echo "$current_usage" | jq '.input_tokens + .cache_creation_input_tokens + .cache_read_input_tokens')

  if [ "$current_tokens" != "null" ] && [ "$current_tokens" -gt 0 ] 2>/dev/null; then
    pct=$((current_tokens * 100 / context_window_size))
    context_info=" ${BOLD}${GREEN}${pct}%${RESET}"
  fi
fi

# Cost
cost_info=""
total_cost=$(echo "$input" | jq '.cost.total_cost_usd // 0')

if [ "$total_cost" != "0" ] && [ "$total_cost" != "null" ]; then
  if (( $(echo "$total_cost >= 0.01" | bc -l) )); then
    cost_info=" ${BOLD}${YELLOW}\$$(printf "%.2f" $total_cost)${RESET}"
  else
    cost_info=" ${BOLD}${YELLOW}\$$(printf "%.4f" $total_cost)${RESET}"
  fi
fi

# Output
printf "%s%s%s%s" "$cwd_info" "$git_info" "$context_info" "$cost_info"
