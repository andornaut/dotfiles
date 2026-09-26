---
name: docs
description: Audit and rewrite a project's documentation so it is concise, accurate and well organized. Invoke whenever the user prompts with exactly "docs", or asks to update, review, tidy, or fix the docs, README, AGENTS.md, or docs/ directory.
context: fork
agent: general-purpose
---

# docs - Documentation audit

Typing "docs" is the instruction to do this work. Do not ask whether to proceed.

Always run in a subagent, never in the calling conversation. `context: fork` does that where
the harness honours it; where it does not, delegate the whole docs audit to one subagent and
relay its report. The audit reads and rewrites many files, and that work belongs out of the
caller's context.

## Hard constraints

- **Never use emdashes.** Use a colon, comma, parentheses, or two sentences.
- **No emojis** in authored prose, code comments, READMEs, or commit messages.
- **Never commit `AGENTS.md`, `CLAUDE.md`, or `GEMINI.md`.** They are local only.
- **Nothing committed may reference them.** No "see AGENTS.md", no links, no
  mentions in code, docs, templates, or commit messages.
- **Never delete a link because its name did not resolve.** See step 2.
- **Do not change code to match the docs** unless the user asks. When a doc and
  the code disagree, the code is the fact: fix the doc and report the
  discrepancy.

## Change only what is wrong

Do not churn prose. Rewriting a file wholesale to impose your own voice is not
an improvement, and it is expensive: a large diff buries the handful of real
corrections, makes review impossible, and rewrites history that was fine.

| Change a sentence when | Leave it alone when |
| --- | --- |
| It states something false or stale | It is accurate and clear |
| It repeats what another sentence already said | You would simply have worded it differently |
| It buries a list or table in a paragraph | Its style is not to your taste |
| It is a war story, a history, or filler | It is terse already |

Prefer targeted edits to regenerating the file. Rewrite a whole section only
when its structure is the problem, for example a wall of prose that has to
become a table. Judge the result by the diff, not by the finished file; step 7
is where that judgement is made.

## 1. Inventory

List every documentation file, then decide which are in scope.

```bash
find . -name "*.md" -not -path "./node_modules/*" -not -path "./.git/*" \
  -not -path "./vendor/*" -not -path "./.venv/*" | sort
git ls-files '*.md' | xargs -r wc -l
```

| In scope | Out of scope |
| --- | --- |
| `README.md` at any depth | Anything not tracked by git |
| `AGENTS.md`, `CLAUDE.md`, `GEMINI.md` | Generated files (`.pytest_cache/`, `site/`, `target/`) |
| `docs/**`, `CONTRIBUTING.md`, `SECURITY.md` | Vendored or third-party docs |
| Doc comments that duplicate the above | `CHANGELOG.md` (a log, not a doc) |

`CLAUDE.md` and `GEMINI.md` are often symlinks to `AGENTS.md`. Check with `ls -l`
and edit the target once rather than the links.

## 2. Verify every claim

This is the bulk of the work. A tidy document that lies is worse than a messy one.
Treat each factual statement as a claim to be traced to evidence.

| Claim | How to verify |
| --- | --- |
| Flags, options, defaults | Run `<cmd> --help`; read the argument parser |
| Commands in a code block | Run them, or read the script that defines them |
| File and directory paths | `ls` / `test -e` |
| Function, class, constant names | `grep` the source |
| Ordering ("step 3 does X") | Read the orchestrating function top to bottom |
| Version numbers, minimum versions | Read the manifest or `__version__`; do not trust prose |
| Environment variables | `grep` for the lookup |
| Behaviour claims | Run the application, ideally in a dry-run or read-only mode |
| External links | `curl -sS -o /dev/null -w '%{http_code}'` |

Record what a claim resolved to before rewriting it. A statement that cannot be
verified is either cut or marked as the uncertainty it is. Never invent a
plausible default.

**Links that fail to resolve are not dead links.** A filtering DNS resolver
answers `NXDOMAIN` or `0.0.0.0` for whole categories of domain, and DNS over
HTTPS may be blocked, so a second opinion is unavailable. Report such a link as
unverified from this host and leave it in place. Only a status code from a host
that did resolve is evidence.

## 3. Cut

| Cut | Keep |
| --- | --- |
| Restatement of the preceding sentence | The one statement that carries the fact |
| A sentence that only announces the next section | Section headings |
| History, migrations, "previously this used to" | The current behaviour |
| War stories: how a bug was found, what went wrong, dates, incidents | The rule, and a one-line technical reason if the mechanism is not obvious |
| Rationale for a decision nobody is questioning | Rationale for a constraint that looks wrong until explained |
| Marketing language, superlatives, "simply", "just", "powerful" | Plain description |
| Examples that repeat an earlier example's shape | The one clearest example |
| Anything the code already states plainly | What the code cannot state: intent, constraints, gotchas |

Prefer the precise technical term to a figurative stand-in. Write "the current
working directory", not "where you are standing".

## 4. Reorganize

- Group related statements under a heading. A document with no headings past
  the title is a document nobody can scan.
- Convert any paragraph enumerating three or more things into a table or list.
- Tables for anything with parallel structure: flags, statuses, file layouts,
  comparisons, per-ecosystem behaviour.
- Lead each section with the fact, then the qualification. Not the reverse.
- One concept per section. If a section needs "also" three times, split it.

## 5. Divide by audience

| File | Audience | Contains |
| --- | --- | --- |
| `README.md` | Users and operators | What it does, how to install, how to run, flags, safety |
| `AGENTS.md` | Coding agents | Architecture, conventions, invariants, non-obvious constraints |
| `docs/**` | Deep dives | Detail that would bloat the README |

Do not duplicate across them. When a fact belongs in both, put it in the
committed doc and trim the other. Fix duplication by deletion, never by adding
a cross-reference to an agent instruction file.

## 6. Run the gates

Run them after editing, not before. Use the project's own tooling where it has
some: a repo with a Prettier or markdownlint config expects its files to match.

```bash
npx --yes prettier --check .                            # if the project uses Prettier
npx --yes markdownlint-cli2 '**/*.md' '!node_modules'   # if it lints markdown
git diff --stat
```

## 7. Review what you changed

**Do this before reporting, and before committing.** You have just spent the
task deciding what was wrong; now read the diff as if someone else wrote it and
you are the reviewer who has to approve it. This step catches what step 2 cannot:
errors you introduced, and edits you talked yourself into.

Go hunk by hunk. For each one:

| Ask | Fail means |
| --- | --- |
| Which is it: a correction, a deletion, or a restructure? | You cannot name it. Revert it. |
| If a correction: what evidence did step 2 record for the new value? | You are going from memory. Re-verify or revert. |
| If a restructure: is every fact from the old text still present? | List them both ways and diff the lists. A dropped fact is the classic cost of turning prose into a table. |
| If a deletion: was the cut text genuinely redundant, or only long? | Long is not redundant. Put it back. |
| Does the new text read correctly to someone who does not know the project? | Ambiguity you can only resolve because you just read the source. |
| Did you add a claim the old text did not make? | New claims need the same evidence as corrections. Nothing invented to fill a table cell. |

Then sweep the whole diff for the hard constraints:

```bash
git diff | grep -nP '^\+.*[\x{2014}\x{1F300}-\x{1FAFF}\x{2600}-\x{27BF}]'   # emdashes, emoji
git diff | grep -niE '^\+.*(AGENTS|CLAUDE|GEMINI)\.md'                        # agent-file references
```

When in doubt about a hunk, revert it. An unmade edit costs nothing; a wrong one
outlives the session. Say in the report what you reverted and why: a review that
changed nothing is a review you did not do.

## Report

Say what changed and what was verified:

- Claims corrected, with the old and new value.
- Claims that could not be verified, and why.
- Discrepancies between code and docs that were left for the user to decide.
- What step 7 reverted, and why.
- Line counts before and after, per file, and the hunk count.
