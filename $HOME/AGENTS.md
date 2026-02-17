# Agents

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

### Notes

- Commands use the default repository (no `-r` flag needed)
- The repo directory uses the literal string `$HOME` (not expanded) to represent the home directory
- Files named `*private` or `*.private` are gitignored and should not be committed
- The repository is at `~/.local/share/gog/andornaut/` with remote `git@github.com:andornaut/dotfiles.git`
- `settings.json` (shared config) is managed by gog; `settings.local.json` (machine-specific) is not
- **Always use `gog git` commands** (not direct git commands) to interact with the repository
- **Only commit and push changes when prompted** by the user
- **Never add or remove files to/from gog** unless explicitly instructed by the user
