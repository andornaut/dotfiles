#!/bin/bash
set -Eeuo pipefail

# Fetch Pro account quota via API response headers
CACHE_FILE="$HOME/.claude/quota-cache.json"
CACHE_MAX_AGE=600  # 10 minutes
CREDENTIALS_FILE="$HOME/.claude/.credentials.json"

input=$(cat)
IFS=$'\t' read -r model pct in_tokens out_tokens cost lines_added lines_removed < <(
  echo "$input" | jq -r '
    [
      .model.display_name // "?",
      ((.context_window.used_percentage // 0) | tostring | split(".")[0]),
      (.context_window.total_input_tokens // 0),
      (.context_window.total_output_tokens // 0),
      (.cost.total_cost_usd // 0),
      (.cost.total_lines_added // 0),
      (.cost.total_lines_removed // 0)
    ] | @tsv
  '
)

is_cache_expired() {
  [ ! -f "$CACHE_FILE" ] && return 0
  local cache_age=$(($(date +%s) - $(stat -c %Y "$CACHE_FILE" 2>/dev/null || stat -f %m "$CACHE_FILE" 2>/dev/null || echo 0)))
  [ "$cache_age" -gt "$CACHE_MAX_AGE" ]
}

get_quota() {
  local quota_5h quota_7d

  if is_cache_expired; then
    local token=$(jq -r '.claudeAiOauth.accessToken' "$CREDENTIALS_FILE" 2>/dev/null)
    if [ -n "$token" ] && [ "$token" != "null" ]; then
      # Make minimal API call to get rate limit headers
      local response=$(curl -s -i -X POST https://api.anthropic.com/v1/messages \
        -H "Authorization: Bearer $token" \
        -H "Content-Type: application/json" \
        -H "anthropic-version: 2023-06-01" \
        -H "anthropic-beta: oauth-2025-04-20" \
        -d '{"model":"claude-haiku-4-5-20251001","max_tokens":1,"messages":[{"role":"user","content":"hi"}]}' 2>/dev/null)

      # Extract rate limit headers
      quota_5h=$(echo "$response" | grep -i "anthropic-ratelimit-unified-5h-utilization:" | cut -d: -f2 | tr -d ' \r')
      quota_7d=$(echo "$response" | grep -i "anthropic-ratelimit-unified-7d-utilization:" | cut -d: -f2 | tr -d ' \r')

      # Cache the results
      if [ -n "$quota_5h" ] && [ -n "$quota_7d" ]; then
        echo "{\"five_hour\":$quota_5h,\"seven_day\":$quota_7d}" > "$CACHE_FILE"
      fi
    fi
  fi

  if [ -f "$CACHE_FILE" ]; then
    IFS=$'\t' read -r quota_5h quota_7d < <(
      jq -r '[.five_hour // "", .seven_day // ""] | @tsv' "$CACHE_FILE" 2>/dev/null
    )

    if [ -n "$quota_5h" ] && [ -n "$quota_7d" ]; then
      # Convert to percentage (multiply by 100)
      local quota_5h_pct=$(printf '%.0f' "$(echo "$quota_5h * 100" | bc -l)")
      local quota_7d_pct=$(printf '%.0f' "$(echo "$quota_7d * 100" | bc -l)")
      echo "5h:${quota_5h_pct}% 7d:${quota_7d_pct}%"
      return 0
    fi
  fi

  return 1
}

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

# Try to get quota, fall back to cost if unavailable
if quota_info=$(get_quota); then
  usage_info="$quota_info"
else
  # Format cost with better precision
  if (( $(echo "$cost < 1" | bc -l) )); then
    cost_fmt=$(printf '%.2f' "$cost")
  else
    cost_fmt=$(printf '%.1f' "$cost")
  fi
  usage_info="\$$cost_fmt"
fi

stats=$(printf '%s | %s | ctx:%s%% | in:%s out:%s | +%d/-%d lines' \
  "$model" "$usage_info" "$pct" "$(fmt_tokens "$in_tokens")" "$(fmt_tokens "$out_tokens")" \
  "$lines_added" "$lines_removed")

printf '%s %s' "$ps" "$stats"
