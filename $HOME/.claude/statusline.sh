#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name // "?"')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
IN_TOKENS=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
OUT_TOKENS=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
LINES_ADDED=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
LINES_REMOVED=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')

fmt_tokens() {
  local n=$1
  if [ "$n" -ge 1000000 ]; then
    printf '%.1fM' "$(echo "$n / 1000000" | bc -l)"
  elif [ "$n" -ge 1000 ]; then
    printf '%.0fk' "$(echo "$n / 1000" | bc -l)"
  else
    printf '%d' "$n"
  fi
}

DIR=$(pwd)
DIR=${DIR/#$HOME/\~}
PS=$(printf '\033[01;32m%s@%s\033[00m:\033[01;34m%s\033[00m$' \
  "$(whoami)" "$(hostname -s)" "$DIR")

# Format cost with better precision
if (( $(echo "$COST < 1" | bc -l) )); then
  COST_FMT=$(printf '%.2f' "$COST")
else
  COST_FMT=$(printf '%.1f' "$COST")
fi

STATS=$(printf '%s | ctx:%s%% | in:%s out:%s | +%d/-%d lines | $%s' \
  "$MODEL" "$PCT" "$(fmt_tokens "$IN_TOKENS")" "$(fmt_tokens "$OUT_TOKENS")" \
  "$LINES_ADDED" "$LINES_REMOVED" "$COST_FMT")

printf '%s %s' "$PS" "$STATS"
