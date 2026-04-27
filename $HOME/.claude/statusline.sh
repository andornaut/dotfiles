#!/bin/bash
set -Eeuo pipefail

input=$(cat)
IFS=$'\t' read -r model pct in_tokens out_tokens cost lines_added lines_removed quota_5h quota_7d < <(
  echo "$input" | jq -r '
    [
      .model.display_name // "?",
      ((.context_window.used_percentage // 0) | tostring | split(".")[0]),
      (.context_window.total_input_tokens // 0),
      (.context_window.total_output_tokens // 0),
      (.cost.total_cost_usd // 0),
      (.cost.total_lines_added // 0),
      (.cost.total_lines_removed // 0),
      (if .rate_limits.five_hour.used_percentage then (.rate_limits.five_hour.used_percentage | tostring | split(".")[0]) else "" end),
      (if .rate_limits.seven_day.used_percentage then (.rate_limits.seven_day.used_percentage | tostring | split(".")[0]) else "" end)
    ] | @tsv
  '
)

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

dir=$(pwd)
if [ "$dir" = "$HOME" ]; then
  dir="~"
else
  dir=$(basename "$dir")
fi
ps=$(printf '\033[01;32m%s@%s\033[00m:\033[01;34m%s\033[00m$' \
  "$(whoami)" "$(hostname -s)" "$dir")

if (( $(echo "$cost < 1" | bc -l) )); then
  cost_fmt=$(printf '%.2f' "$cost")
else
  cost_fmt=$(printf '%.1f' "$cost")
fi
usage_info="\$$cost_fmt"
if [ -n "$quota_5h" ] && [ -n "$quota_7d" ]; then
  usage_info="$usage_info | 5h:${quota_5h}% 7d:${quota_7d}%"
fi

stats=$(printf '%s | %s | ctx:%s%% | in:%s out:%s | +%d/-%d lines' \
  "$model" "$usage_info" "$pct" "$(fmt_tokens "$in_tokens")" "$(fmt_tokens "$out_tokens")" \
  "$lines_added" "$lines_removed")

printf '%s %s' "$ps" "$stats"
