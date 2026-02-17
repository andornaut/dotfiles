#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name // "?"')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
IN_TOKENS=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
OUT_TOKENS=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')

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
STATS=$(printf 'model:%s context:%s%% in:%s out:%s' \
  "$MODEL" "$PCT" "$(fmt_tokens "$IN_TOKENS")" "$(fmt_tokens "$OUT_TOKENS")")

printf '%s (%s)' "$PS" "$STATS"
