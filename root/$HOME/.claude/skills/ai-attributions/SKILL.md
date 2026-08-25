---
name: ai-attributions
description: Strip AI attributions out of a repository's git history with the ai-attributions tool. Invoke whenever the user prompts with exactly "ai-attributions", or asks to remove AI/agent attribution, co-author or session trailers, "generated with" footers, or agent identities from commits, or to rewrite a commit to meet ai-attribution expectations.
---

# ai-attributions

[ai-attributions](https://github.com/andornaut/ai-attributions) rewrites git history to
drop co-author and session trailers, "generated with" footers, and the agent identities
on the commits themselves. It is on `PATH` as `ai-attributions`; `apply` also needs
`git-filter-repo`, and `scan` needs neither that nor a configured git identity.

## Commands

```bash
ai-attributions scan                    # report, change nothing (the default command)
ai-attributions apply --base <ref>      # rewrite the commits the refs in scope add over <ref>
ai-attributions backups                 # list the pre-rewrite refs earlier runs saved
ai-attributions restore <timestamp>     # put one saved run back
```

`repo-path` defaults to the current directory; more than one path runs each in turn.
`scan` and `apply` share their flags.

Flag | What it does
--- | ---
`--base ref` | only the commits the refs in scope add over `ref`
`--current-branch` | only the branch that is checked out, not every local branch and tag
`--exclude glob` | skip refs matching this glob (repeatable)
`--exit-code` | exit 1 when anything is found, as `git diff` does
`--identity identity` | identity for agent-authored commits, or `none` to leave them alone
`--emdashes` | also rewrite emdashes and endashes, in file content as well as messages
`--agents-files` | also report the agent instruction files the ref tips carry
`--verbose` | list every commit rather than a summary

## Workflow

1. `ai-attributions scan`. It writes nothing. If it reports nothing, say so and stop.
2. Read the base off the report. It names the oldest commit that will change hash
   ("starting at `<hash> <date> <subject>`"); the base is that commit's parent,
   `<hash>^`. Confirm it with `git log`.
3. `ai-attributions apply --base <that parent> --current-branch`. Drop
   `--current-branch` only when other local branches or tags need the same rewrite.
   `apply` refuses to run while tracked files have uncommitted changes, so commit or
   stash first.
4. Verify: `git log --format='%h %an <%ae> | %cn <%ce> | %s'` over the rewritten range,
   and re-run `scan` to confirm it comes back clean.
5. Publish per **Publishing** below.

Run the project's tests only when `--emdashes` was passed. Without it the rewrite
touches commit metadata and messages alone, and every tree is byte-identical.

## Always pass --base

`git-filter-repo` works through `git fast-export`, which does not carry the `gpgsig`
header, so every signed commit an `apply` re-emits loses its signature, and every hash
from the earliest re-emitted commit onward changes. Without `--base` that is the whole
ref. `--base <newest clean commit>` narrows the walk: commits the base already carries
keep their message, identity, hash and signature.

## Publishing

The force push is the operator's, never the agent's. Do not pass `--push`, and do not
run the `git push --atomic ... --force-with-lease=...` line `apply` prints: print it and
stop there.

One case needs no force push. When the remote never carried the attributions (an agent
branch merged locally, say), the rewritten history is still a fast-forward over the
remote branch. Check it, and where it holds, a plain `git push` publishes the rewrite:

```bash
git merge-base --is-ancestor origin/<branch> HEAD && echo "fast-forward"
```

## Backups

`apply` saves each ref under `refs/ai-attributions-backup/<timestamp>/` before rewriting
and prunes to the last four runs. `backups` lists them, `restore <timestamp>` puts one
back, and `clean [timestamp]` or `clean --keep-last <n>` takes them away. A rewrite that
was already published still needs a force push to undo on the remote.

## Remote branches

Remote branches sit outside the set: any carrying attributions are reported below the
findings and rewritten by nothing. An abandoned agent branch is worth deleting rather
than rewriting, but deleting a remote ref is the operator's call. Ask, do not delete.
