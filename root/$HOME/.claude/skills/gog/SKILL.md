---
name: gog
description: Sync dotfiles with the gog dotfiles manager. Invoke whenever the user prompts with exactly "gog", or asks to add/apply dotfiles, run gog git commands, or sync dotfiles across hosts.
---

# gog - Dotfiles Manager

[gog](https://github.com/andornaut/gog) manages dotfiles by symlinking files from
`~/.local/share/gog/<repository>/$HOME/` to the home directory.

## Commands

```bash
gog add <path>          # move a file into the repository and symlink it back
gog apply               # link a repository's contents to the filesystem
gog repository ls       # name the repositories
gog git status          # run any git command inside a repository
gog git add -f '<$HOME/path/to/file>'
gog git commit -m "message"
gog git push
```

Always reach the repository through `gog git`, never through git directly. Commands
use the default repository unless given `-r <repository>`.

## Workflow

**CRITICAL:** when the user prompts with exactly "gog" (no other context), that is the
instruction to sync, and you MUST follow every step below. Never commit or push at any
other time.

1. Check status with `gog git status`.
2. If there are changes: `gog git add -A`, commit with a message describing them, then
   `gog git push`. If there are none, say so and carry on to step 3 regardless.
3. Sync every host. Read the host list from the ansible-ctrl inventory; never hard-code
   one here:

   The first field is an alias, not an address: a host that carries
   `ansible_host=` is reachable at that value and at nothing else, so SSH to the
   alias fails to resolve. The `[routers]` group runs no gog and is dropped.

   ```bash
   inventory=$(ls ~/src/github.com/*/ansible-ctrl/hosts)
   # Emits one address per gog host, and `local` emits the local one alone.
   parse() { awk -v want="$1" '
     /^\[/ { group = substr($0, 2, index($0,"]")-2); next }
     /^#/ || !NF || $1 ~ /=/ { next }            # comments, blanks, [all:vars] settings
     { if (group == "routers") { skip[$1]=1; next }
       for (i=2;i<=NF;i++) if ($i ~ /^ansible_host=/) { split($i,a,"="); addr[$1]=a[2] }
       if ($0 ~ /ansible_connection=local/) local_alias=$1
       seen[$1]=1 }
     END { if (want=="local") { print (local_alias in addr ? addr[local_alias] : local_alias); exit }
           for (h in seen) if (!(h in skip)) print (h in addr ? addr[h] : h) }
   ' "$2"; }
   hosts=$(parse hosts "$inventory" | sort)
   local_host=$(parse local "$inventory")
   ```

   A host is listed twice, once with its settings and again bare under a group
   heading, so the addresses are collected before anything is printed.

   - `local_host` is this machine: run the loop directly, without SSH.
   - Every other host over SSH. Desktops may be offline, so tolerate failure with
     `ssh -o BatchMode=yes -o ConnectTimeout=<n>` and report which hosts synced and which
     were skipped.
   - Do NOT run `gogstart` or `gog git start` over SSH. `git start` includes `git push`,
     which fails on a host without push access, and `gogstart` is not defined in a
     non-interactive shell. Run pull and apply directly:

     ```bash
     ssh <host> 'for r in $(gog repository ls); do gog -r "$r" git pull -q --autostash && gog -r "$r" apply; done'
     ```

## Repository layout

- Repositories live at `~/.local/share/gog/<repository>/`.
- Inside one, the home directory is the literal string `$HOME`, unexpanded.

## Keeping the global skills in sync

A global skill is written once and read by both tools. The file lives at
`~/.claude/skills/<name>/SKILL.md`, and `~/.cursor/skills/<name>` is a relative
symlink to it:

```bash
ln -s ../../.claude/skills/<name> ~/.cursor/skills/<name>
gog add "$HOME/.claude/skills/<name>/SKILL.md"
gog add "$HOME/.cursor/skills/<name>"
```

A symlink rather than a copy, so a skill cannot say one thing to one tool and
something else to the other. Adding a skill on one side only leaves the other
tool without it, which is silent: nothing reports a skill that is merely absent.
So add both, and when checking, compare the two listings rather than either one.

## Never commit

The dotfiles repository is public. Nothing that identifies a host, a private path or a
credential belongs in it.

- **Never write a host name** into this file or any other durable file. Read hosts from
  the inventory each time.
- Files matching `*private`, `*.private` or `*.private.*` are gitignored.
- Of `~/.claude`, only `statusline.sh` and `skills/` sync, plus the symlinks under
  `~/.cursor/skills/`. `CLAUDE.md`, `settings.json`, `settings.local.json` and
  `projects/` are gitignored, because they carry permission rules, MCP configs,
  transcripts and memory.
