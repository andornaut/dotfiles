For project-specific instructions, read the `AGENTS.md` file in the project root (and any relevant subdirectories) instead of or in addition to `CLAUDE.md` files.

## Ask before acting

Never implement, refactor, or make changes unless the user explicitly asks for it.
If the user asks "can we", "should we", "see if we can", or similar phrasing, treat it as a request for a suggestion or analysis — not an instruction to proceed.
Wait for explicit confirmation (e.g. "yes, do it", "go ahead", "implement that") before making any edits.

## Function parameter ordering

Put dependencies and context parameters to the left, and the subject being operated on to the right.

## Writing style

No emojis, emdashes, flowery language, or marketing-speak. Be concise and direct.

## Secrets

- Do not read files that contain secrets (e.g. `.env`, credentials, API keys, tokens, private keys) unless the user has specifically authorized it.

## Shell rules

- Never run `sudo` commands. If a task requires `sudo`, prompt the user to run the command themselves instead.

## Git rules

- Never force push. If you need to force push, suggest the command to the user and let them run it.
- Be careful not to lose local changes. Use `git stash` and other tools to preserve uncommitted work when necessary.
- Always respect `.gitignore`. Never use `git add -f` or `--force` to bypass `.gitignore` unless explicitly instructed to do so.
- If `git add` fails because a file is ignored, stop and inform the user rather than force-adding it.
- Always push to the remote after committing unless there is a reason not to (e.g. no remote tracking branch, or the user says otherwise).
- Do not automatically commit any `AGENTS.md`, `CLAUDE.md`, or `GEMINI.md` files — these are local-only and should never be staged or committed.

## gog - Dotfiles Manager

[gog](https://github.com/andornaut/gog) manages dotfiles by symlinking files from `~/.local/share/gog/<repository>/$HOME/` to the home directory.

### Commands

```bash
# Add a file to the dotfiles repo (moves file and creates symlink)
gog add <path>

# Run git commands in the repo
gog git status
gog git diff
gog git add -f '<$HOME/path/to/file>'
gog git commit -m "message"
gog git push

# Apply symlinks from repo to filesystem
gog apply
```

### Workflow

**CRITICAL:** When the user prompts with exactly "gog" (without additional context), you MUST follow this workflow:
1. Check status with `gog git status`
2. Add all changes with `gog git add -A`
3. Commit with a descriptive message based on the changes
4. Push with `gog git push`

### Notes

- Commands use the default repository (no `-r` flag needed)
- The repo directory uses the literal string `$HOME` (not expanded) to represent the home directory
- Files named `*private` or `*.private` are gitignored and should not be committed
- The repository is at `~/.local/share/gog/andornaut/` with remote `git@github.com:andornaut/dotfiles.git`
- `settings.json` (shared config) is managed by gog; `settings.local.json` (machine-specific) is not
- **Always use `gog git` commands** (not direct git commands) to interact with the repository
- **Only commit and push changes when prompted** by the user (typing "gog" is a prompt to sync changes)
- **Never add or remove files to/from gog** unless explicitly instructed by the user
- **NEVER modify the source code of the `gog` tool itself** (located in `src/github.com/andornaut/gog/`) unless explicitly directed to do so by the user. The prompt "gog" is strictly for syncing dotfiles.
