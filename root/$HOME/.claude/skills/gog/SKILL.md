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

   ```bash
   inventory=$(ls ~/src/github.com/*/ansible-ctrl/hosts)
   # `$1 !~ /=/` drops the [all:vars] lines, whose first field is a setting
   hosts=$(awk '!/^[[#]/ && NF && $1 !~ /=/ {print $1}' "$inventory" | sort -u)
   local_host=$(awk '/ansible_connection=local/ {print $1}' "$inventory" | head -1)
   ```

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

## Never commit

The dotfiles repository is public. Nothing that identifies a host, a private path or a
credential belongs in it.

- **Never write a host name** into this file or any other durable file. Read hosts from
  the inventory each time.
- Files matching `*private`, `*.private` or `*.private.*` are gitignored.
- Of `~/.claude`, only `statusline.sh` and `skills/` sync. `CLAUDE.md`, `settings.json`,
  `settings.local.json` and `projects/` are gitignored, because they carry permission
  rules, MCP configs, transcripts and memory.
