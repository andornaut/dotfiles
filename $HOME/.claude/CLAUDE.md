For project-specific instructions, read the `AGENTS.md` file in the project root (and any relevant subdirectories) instead of or in addition to `CLAUDE.md` files.

## Ask before acting

Never implement, refactor, or make changes unless the user explicitly asks for it.
If the user asks "can we", "should we", "see if we can", or similar phrasing, treat it as a request for a suggestion or analysis — not an instruction to proceed.
Wait for explicit confirmation (e.g. "yes, do it", "go ahead", "implement that") before making any edits.

## Function parameter ordering

Put dependencies and context parameters to the left, and the subject being operated on to the right.

## Shell rules

- Never run `sudo` commands. If a task requires `sudo`, prompt the user to run the command themselves instead.

## Git rules

- Always respect `.gitignore`. Never use `git add -f` or `--force` to bypass `.gitignore` unless explicitly instructed to do so.
- If `git add` fails because a file is ignored, stop and inform the user rather than force-adding it.
- When committing, also push to the remote unless there is a reason not to (e.g. no remote tracking branch, or the user says otherwise).
