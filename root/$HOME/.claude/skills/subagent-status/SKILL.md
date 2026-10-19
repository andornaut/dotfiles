---
name: subagent-status
description: Report the status of this session's subagents as one table (topic, started, current state), plus anything queued behind them. Invoke whenever the user types "subagent status" or "/subagent-status", or asks for the status of the subagents, agents or background work.
---

# subagent-status - Status table of this session's subagents

Typing "subagent status" asks for a status report of the subagents this session started.
Report only; start, stop or message nothing.

## Gather

1. Run `ListAgents`. Its "Subagents" section gives each agent's id, state
   (running or completed) and start time.
2. Name each agent by its topic: the `description` it was spawned with, or what
   it is working on now. Never show the raw agent id.
3. For the current state, use the agent's latest progress line or report in this
   conversation (for example "running its final gate", "waiting for the load to
   drop", "rebasing onto main"). Do not read an agent's output file: it is the
   full transcript and floods the context.
4. Leave out completed agents whose work has already landed and needs nothing
   more. Keep a completed agent that is waiting on something (a merge, a rebase,
   a decision).
5. Also list work queued behind the agents that the user would otherwise not see:
   background merges or pushes, scheduled resumes, and follow-ups held until
   another piece lands.

## Report

One table, newest first or grouped by state, with these columns:

| Subagent | Started | State |
| --- | --- | --- |
| Start-screen and pet shop rework | 22 min ago | Building the shop scene |

- **Subagent:** the topic in a few words.
- **Started:** relative time ("22 min ago").
- **State:** one short phrase.

After the table, at most three short lines: what is queued or waiting (merges,
pushes, held follow-ups), and anything blocked on the user. Nothing else: no
recap of finished work, no next steps unless something is blocked.

If no subagents are running or waiting, say so in one line.
