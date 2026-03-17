---
name: feedback_param_ordering
description: User prefers dependency/context params on the left, subject param on the right in free functions
type: feedback
---

Dependencies (accumulators, context, inputs) should come before the subject being operated on.

**Why:** Makes the "thing being acted on" visually distinct at the right side, consistent with how method receivers work.

**How to apply:** In free functions, order params as: dependencies/context first (e.g. `derived: &mut Vec<Command>`, `command: &Command`, `mode: &InputMode`), subject last (e.g. `handler: &mut dyn CommandHandler`).
