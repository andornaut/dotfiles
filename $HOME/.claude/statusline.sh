#!/bin/bash
# Drop -e so a single failing command degrades gracefully instead of blanking
# the whole status line.
#
# shellcheck disable=SC2154  # fmt_tokens/colorize_pct assign via printf -v "$1"
set -uo pipefail

# Optional fields emit "-" rather than "": tab is IFS whitespace, so a run of
# tabs collapses into one and an empty field would shift every later field left.
IFS=$'\t' read -r model pct in_tokens out_tokens cost lines_added lines_removed \
  quota_5h quota_7d cwd < <(
  jq -r '
    def opt: if . == null then "-" else . end;
    [
      .model.display_name // "?",
      ((.context_window.used_percentage // 0) | floor),
      (.context_window.total_input_tokens // 0),
      (.context_window.total_output_tokens // 0),
      (.cost.total_cost_usd // 0),
      (.cost.total_lines_added // 0),
      (.cost.total_lines_removed // 0),
      (.rate_limits.five_hour.used_percentage | if . then floor else null end | opt),
      (.rate_limits.seven_day.used_percentage | if . then floor else null end | opt),
      (.workspace.current_dir // .cwd | opt)
    ] | @tsv
  '
)

# jq failing or being absent leaves every field empty, which is distinct from the
# "-" sentinel jq itself emits. Collapse the two so the numeric fields always
# hold a number and "-" always means "optional field absent" below.
: "${model:=?}"
: "${pct:=0}"
: "${in_tokens:=0}"
: "${out_tokens:=0}"
: "${cost:=0}"
: "${lines_added:=0}"
: "${lines_removed:=0}"
: "${quota_5h:=-}"
: "${quota_7d:=-}"
: "${cwd:=-}"

# Integer-only formatting: no bc fork. printf -v keeps these fork-free.
fmt_tokens() {
  local n=$2 unit div frac
  if (( n >= 1000000 )); then
    unit=M div=1000000
  elif (( n >= 1000 )); then
    unit=k div=1000
  else
    printf -v "$1" '%d' "$n"
    return
  fi
  frac=$(((n % div) / (div / 10)))
  if (( frac )); then
    printf -v "$1" '%d.%d%s' $((n / div)) "$frac" "$unit"
  else
    printf -v "$1" '%d%s' $((n / div)) "$unit"
  fi
}

colorize_pct() {
  local n=$2 color
  if (( n >= 80 )); then
    color='01;31'
  elif (( n >= 50 )); then
    color='01;33'
  else
    color='00;32'
  fi
  printf -v "$1" '\033[%sm%s%%\033[00m' "$color" "$n"
}

# The payload is authoritative; pwd only reflects whoever spawned this script.
[ "$cwd" = "-" ] && cwd=$(pwd)
if [ "$cwd" = "$HOME" ]; then
  dir="~"
else
  dir=${cwd##*/}
fi

# Walk up for a repo. .git is a file (holding "gitdir: <path>") in worktrees and
# submodules; a detached HEAD holds a raw sha instead of a "ref:" line.
branch=""
d=$cwd
while [ -n "$d" ] && [ "$d" != "/" ]; do
  if [ -e "$d/.git" ]; then
    gitdir=$d/.git
    if [ -f "$gitdir" ]; then
      read -r gitdir_line < "$gitdir"
      gitdir=${gitdir_line#gitdir: }
      if [ "$gitdir" = "$gitdir_line" ]; then
        # No "gitdir: " prefix means the file is empty or not a git pointer.
        # Blank it so a working-tree file named HEAD is never mistaken for a ref.
        gitdir=""
      elif [ "${gitdir#/}" = "$gitdir" ]; then
        # Submodules record a relative path. Resolve it against the repo dir,
        # not against the pwd of whoever spawned this script.
        gitdir=$d/$gitdir
      fi
    fi
    if [ -n "$gitdir" ] && [ -r "$gitdir/HEAD" ]; then
      read -r head < "$gitdir/HEAD"
      if [ "${head#ref: }" != "$head" ]; then
        # Strip only the refs/heads/ prefix: a "##*/" strip would turn
        # feature/some-name into some-name.
        branch=${head#ref: }
        branch=${branch#refs/heads/}
      else
        branch=${head:0:7}
      fi
    fi
    break
  fi
  # A relative cwd with no slash left would strip to itself and spin forever.
  case $d in
    */*) d=${d%/*} ;;
    *) break ;;
  esac
done

hostname_short=${HOSTNAME:-$(hostname -s)}
ps=$(printf '\033[01;32m%s@%s\033[00m:\033[01;34m%s\033[00m%s$' \
  "${USER:-$(id -un)}" "${hostname_short%%.*}" "$dir" \
  "${branch:+ \033[01;35m($branch)\033[00m}")

# ${cost%.*} is the integer-dollar part: show cents under $1, one decimal above.
if [ "${cost%.*}" -eq 0 ] 2>/dev/null; then
  cost_fmt=$(printf '%.2f' "$cost")
else
  cost_fmt=$(printf '%.1f' "$cost")
fi
usage_info="\$$cost_fmt"
quota=""
if [ "$quota_5h" != "-" ]; then
  colorize_pct quota_5h_fmt "$quota_5h"
  quota="5h:$quota_5h_fmt"
fi
if [ "$quota_7d" != "-" ]; then
  colorize_pct quota_7d_fmt "$quota_7d"
  quota="${quota:+$quota }7d:$quota_7d_fmt"
fi
usage_info="$usage_info${quota:+ | $quota}"

colorize_pct pct_fmt "$pct"
fmt_tokens in_fmt "$in_tokens"
fmt_tokens out_fmt "$out_tokens"

stats=$(printf '%s | %s | ctx:%s | in:%s out:%s | +%d/-%d lines' \
  "$model" "$usage_info" "$pct_fmt" "$in_fmt" "$out_fmt" \
  "$lines_added" "$lines_removed")

printf '%b %b' "$ps" "$stats"
