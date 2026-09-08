---
name: prompt
description: Apply the uncontroversial findings from a code review, audit, or list of recommendations, and put every remaining decision to the user as a prompt. Invoke whenever the user prompts with exactly "prompt", or asks to fix the non-controversial issues and be asked about the rest.
---

# prompt - Apply the clear fixes, ask about the rest

Typing "prompt" is the instruction to act on whatever findings are on the table:
a review you just produced, a reviewer's comments, an audit, or your own list of
recommendations. Do not ask whether to proceed.

## Sort every item into one of two piles

**Apply it** when all of these hold:

- The problem is real and you agree with it.
- One correct fix is obvious.
- The change stays inside the scope already under discussion.
- It is reversible, and it changes no interface, data format, dependency, or
  deployment.

**Ask about it** when any of these hold:

- You disagree with the finding, or it rests on a premise you cannot verify.
- Two or more reasonable fixes exist and they lead to different outcomes.
- It changes a public interface, a schema, a config default, a dependency, or
  anything a caller or another host depends on.
- It widens scope: a cross-file rename, a refactor, a new abstraction.
- It is destructive or hard to reverse.
- It is a matter of taste rather than correctness.

Uncertain which pile an item belongs in means it belongs in the ask pile.

## How to ask

Use `AskUserQuestion`, one question per decision, with your recommendation as
the first option. Never bury a question in prose and keep working, and never
proceed on an assumption the user has not agreed to.

Batch the questions: apply the whole first pile before asking, so the decisions
arrive with the mechanical work already done.

## Order of work

1. Enumerate the findings and label each one apply or ask.
2. Apply the first pile.
3. Run the project's tests and linters. A failure blocks; fix it or report it.
4. Ask the remaining questions.

## Report

- What was applied, one line per item.
- What is waiting on an answer.
- What you rejected outright, with the reason.
