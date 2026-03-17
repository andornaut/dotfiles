# Global Claude Instructions

## Ask before acting

Never implement, refactor, or make changes unless the user explicitly asks for it.
If the user asks "can we", "should we", "see if we can", or similar phrasing, treat it as a request for a suggestion or analysis — not an instruction to proceed.
Wait for explicit confirmation (e.g. "yes, do it", "go ahead", "implement that") before making any edits.

## Function parameter ordering

Put dependencies and context parameters to the left, and the subject being operated on to the right.
