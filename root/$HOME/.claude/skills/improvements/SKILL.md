---
name: improvements
description: Review a whole project from a user's and a developer's perspective (intuitive, principled, simple in code and operation, safe, well designed) and report a concise assessment with ranked recommendations. Invoke whenever the user prompts with exactly "improvements", or asks for a project review, design review, or improvement recommendations.
context: fork
agent: general-purpose
---

# improvements - Whole-project design review

Typing "improvements" is the instruction to do this work. Do not ask whether to
proceed.

Always run in a subagent, never in the calling conversation. `context: fork` does
that where the harness honours it; where it does not, delegate the whole review to
one subagent and relay its report. The review reads most of the project, and that
belongs out of the caller's context.

This is a review, not a fix. The output is a report. The `prompt` skill is how its
findings get applied, and `docs` and `tests` are the deep audits for those two
areas; this skill only flags what they would pick up.

## Hard constraints

- **Change nothing.** No edits, no commits, no branches, no stashes. `git status
  --porcelain` must read the same at the end as at the start.
- **Never run a test on the host.** Use the project's container harness. With none,
  do not run tests; say so.
- **Never read secret material** (`.env`, keys, vault or sops files, `~/.private/`),
  and never quote a value that reaches output.
- **Do not re-litigate a recorded decision.** Sections named Decisions,
  Deliberately not built, Accepted rough edges, Deferred, or similar in
  `AGENTS.md`, `README.md` or `docs/` are settled. Raise one only with new evidence
  the record did not weigh, and say which entry it reopens. Memories in the
  project's Claude memory directory carry the same weight.
- **No emdashes, no emojis, no war stories** in the report. No real host names.

## What good looks like

These are the standards to judge against. They come from the user's own projects;
cite the principle a finding violates.

| Principle | Means |
| --- | --- |
| One source of truth | A rule, message, list or default is defined once and every consumer reads it. Two places agreeing by coincidence is a defect. |
| Fewest moving parts | Delete before adding. A feature that adds a code path without removing one needs a reason. No abstraction with one caller, no option nobody sets. |
| Behave like the standard tool | Match `cp`, `mv`, `ls`, `ssh`, `sudo`, git conventions unless there is a stated reason not to. Surprise is a cost. |
| Fail loudly and early | Validate at the boundary. Anything unrecognised is reported, never ignored. An error names the input and the cause. |
| Guard only real harm | Defend against data loss, privilege and secret leaks. Do not add defenses against races or misuse nobody will attempt; that is complexity with no payoff. |
| Validate at the trust boundary only | No speculative guards. Before proposing one, name the write that produces the bad shape; data the code wrote itself is not re-checked. |
| Absence is not ignorance | An empty result and a failed lookup are distinct outcomes. A zero or "nothing found" that could mean "could not ask" is a defect. |
| Consistent surface | Flags, subcommands and messages follow one grammar: verb-first acting flags, state-named modifier flags, one message shape per failure class, exit codes owned in one place. |
| Streams and exit codes | stdout holds only what a caller consumes; everything else goes to stderr. A wrapped command's exit status is never masked. |
| Literal naming | Names say what the thing is or does, in the precise technical term. |
| Safe defaults | The default is the safe choice; a dangerous one is opt-in, explicit, and says what it will do. Boolean flags default to false and name what they add. |
| Consistent with sibling projects | A deviation from the user's other repositories without a written reason is a finding, even when it works. |
| Set and forget | Prefer a rule that never needs editing over a precise one that goes stale. Temporary code is a plain constant marked `CLEANUP (added YYYY-MM-DD)`, never self-clearing. |
| Accidental leaks first | Weigh what an agent or operator would do by mistake above a determined adversary; machinery that only stops the latter must justify its cost. |
| No polling for what can be delivered | Block on the event, not a timer. |
| Tests at the cheapest layer that can fail | Every test falsifiable; e2e only where the real install is the risk. |
| Docs are reference | Current behaviour only, tables over prose, no history, each fact in one file. |

## Method: ten passes

Do all ten, in order. Each pass reads with one question in mind and appends to a
running findings list (scratch file in the scratchpad or `$TMPDIR`, never the
tree). A later pass may withdraw or merge an earlier finding: that is the point
of looping. Keep each finding to: location, what is wrong, which principle, the
evidence, and the smallest fix.

### 1. Orientation

Read `README.md`, `AGENTS.md`, `docs/` index, the build file (`Makefile`,
`Cargo.toml`, `go.mod`, `package.json`), and `git log --oneline -50`. Record: what
the project is, who the users are, the entry points, and every recorded decision.
Measure size: `git ls-files | xargs wc -l | sort -n | tail -30`.

### 2. First run, as a new user

Follow the README's install and getting-started path literally, in the order
written, reading (or running `--help` and dry-run/read-only commands) rather than
installing anything. Note every step that needs knowledge the doc has not given
yet, every command whose output does not say what to do next, and every concept
introduced before it is needed.

### 3. The command surface

Enumerate every command, subcommand, flag and config key from the parser, not the
docs. Check the grammar is uniform, names are literal, defaults are safe, related
flags compose, conflicting flags are refused, and every user-facing message fits
one shape. Collect exit codes. Compare `--help` against the parser.

### 4. Failure and error paths

For each entry point, what happens on bad input, missing file, missing permission,
a dependency down, an interrupted run. Is the message actionable? Is partial state
left behind? Is anything silently ignored? Can a failed lookup read as an empty
result? Does anything write to stdout that a caller would not consume? Grep for swallowed errors (`_ =`,
`|| true`, bare `except`, `.ok()`, empty `catch`).

### 5. Safety

Destructive operations, privilege boundaries, secret handling, file permissions,
trust of input, shell and path injection, temp files, symlink following. For each:
is the harm real, and is the guard proportionate? Flag both missing guards and
guards against harm that cannot happen.

### 6. Architecture

Map packages or modules and their dependencies. Look for: the same rule or list
defined twice, a layer that only forwards, circular knowledge, global state,
a module that does two unrelated jobs, and code whose position does not match its
responsibility.

### 7. Code simplicity

Read the largest files and the longest functions. Look for: abstractions with one
implementation, options and branches nothing reaches, dead code (`deadcode`,
`cargo udeps`, `vulture`, or grep for callers), copy-paste that has drifted,
comments that restate code or narrate history, and names that are figurative or
wrong.

### 8. Operation

Install, upgrade, uninstall, config location, state and log files, services,
permissions on disk, what an operator runs day to day, and what `status` or
`doctor` style commands tell them. Is there one obvious way to do each task? What
does an operator have to remember that the tool could tell them?

### 9. Tests, docs and CI (survey only)

Is there a container harness, and does CI run the same thing as the local command?
Are there obvious untested risk areas? Do docs contradict the code in anything you
found in passes 3 to 8? Record these briefly and name `tests` or `docs` as the
follow-up; do not audit exhaustively.

### 10. Adversarial pass and synthesis

Re-read the findings as the project's author defending the code:

| Drop a finding when | Keep it when |
| --- | --- |
| A recorded decision covers it | New evidence the record did not weigh |
| It is taste, not a principle from the table | It violates a named principle |
| The fix adds more than it removes | The fix deletes code, a flag, a concept or a step |
| It defends against harm nobody will cause | The harm is real: data, privilege, secrets |
| It needs a contrived setup to trigger | A real user or operator can reach the trigger |
| Code looks unreferenced but `git log` shows it is new scaffolding | Nothing calls it and nothing is planned to |
| A dependency is a patch release behind | It is end of life or has an advisory |
| You cannot point to a line or a command output | The evidence is concrete, and any external claim is quoted from its source |

Merge duplicates, then rank by how reachable the trigger is and the impact on the
user, then the impact on the maintainer. Check each fix's consequences (every
platform, filesystem and caller; cost in lines) before recommending it.

## Report

Return the report as the final message, in this shape and nothing else. Keep it
under about 800 words; detail lives in the evidence pointers.

1. **Assessment**: three to six sentences. What the project does well, stated
   specifically, and the one or two themes behind most findings.
2. **Recommendations**, a table ranked most important first:

   | # | Area | Finding | Principle | Evidence | Fix | Effort | Pile |
   | --- | --- | --- | --- | --- | --- | --- | --- |

   `Evidence` is `path:line` or a command and its output. `Effort` is S, M or L.
   `Pile` is `apply` or `ask`, by the `prompt` skill's criteria, so the user can
   type "prompt" next.
3. **Considered and dropped**: one line each for findings pass 10 withdrew, with
   the reason (usually a recorded decision), so they are not raised again.
4. **Follow-ups**: whether `docs` or `tests` is worth running, and why.
5. **Not verified**: anything you could not check (no container harness, a name
   that did not resolve, a path the guard refused).
