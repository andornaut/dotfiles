---
name: tests
description: Audit and optimize a project's test suite so every test is falsifiable, well named, at the right layer, and worth its cost. Invoke whenever the user prompts with exactly "tests", or asks to review, optimize, prune, or fix the tests or test suite.
context: fork
agent: general-purpose
---

# tests - Test suite audit

Typing "tests" is the instruction to do this work. Do not ask whether to proceed.

Always run in a subagent, never in the calling conversation. `context: fork` does that where
the harness honours it; where it does not, delegate the whole tests audit to one subagent and
relay its report. The audit reads and rewrites many files, and that work belongs out of the
caller's context.

## Hard constraints

- **Never run a test on the host.** Every suite, mutation run and harness runs in a
  container with filesystem isolation: the repo mounted read-only and copied inside, nothing
  else from the host mounted writable, no docker socket. A test that deletes, walks or copies
  files can escape its temp directory (via `..`) and act on everything the user can write.
  With no container setup for the project, ask before running anything.
- **Never weaken a test to make it pass.** A failing test means the code is wrong
  or the expectation is wrong. Say which, and fix that.
- **Never delete a failing test** to make the suite green.
- **Never leave a mutation in the tree.** Revert every one, and verify.
- **Do not change application code to suit tests** unless asked. Report the
  design problem instead; see step 5.
- No emdashes, no emojis, in test names, comments or reports.

## Change only what is wrong

A test that passes, dies to a mutation, and names its behaviour is finished. Leave
it alone. Do not restyle a suite to your taste: a large diff buries the deletions
and corrections that matter, and every touched test is one you must re-prove.

## 1. Inventory

Before changing anything, know the shape and cost of the suite.

```bash
git status --porcelain          # must be clean; mutation testing overwrites code
<test command> --collect-only   # or the runner's equivalent listing
<test command>                  # record: pass count, wall clock
```

Record per file: test count, layer, runtime. That table is the before half of
your report, and the runtime tells you which tests have to earn the most.

## 2. Prove every test can fail

**This is the bulk of the work, and it comes before any edit.** A test that
cannot fail is worse than no test: it costs runtime and buys false confidence.

Work one behaviour at a time, not one test at a time:

1. Break the behaviour in the application code: invert a condition, change a
   constant, return early, drop a branch.
2. Run the suite, or the subset that covers it.
3. Record which tests failed.
4. Revert **from the text you captured before mutating**, never with
   `git checkout`: the tree may carry uncommitted work a checkout would
   discard. Then confirm the suite is green again.

A test no mutation killed is a candidate for deletion in step 3. Verify why before
cutting: the mutation may simply have missed its behaviour.

**Know what your operators cannot reach.** Survival proves nothing on its own.

| Operator | Blind to |
| --- | --- |
| Appending to a string literal | Assertions that check a substring, which still hold |
| Flipping a comparison or a boolean | Input-shape variation: one regex, many accepted forms |
| Anything that makes the code do less | Tests asserting an absence, which pass harder when it does less |

An equivalent mutant, one that cannot change behaviour, is not a gap either.
Reason it through before writing a test for it: a boundary no input can reach,
or a branch whose arms return the same value, needs a simplification rather
than a test.

Common tests that survive every mutation:

| Shape | Why it cannot fail |
| --- | --- |
| Asserts on a mock's configured return value | It tests the mock |
| Asserts the framework, the language, or a library | Not your code |
| Calls the unit but asserts nothing, or `assert True` | No claim |
| Snapshot or golden output nobody reviews | Records behaviour, does not judge it |
| Only asserts "did not raise" on a function that cannot raise | Vacuous |

If the project has a mutation-testing tool configured, use it. Do not add one.

## 3. Cut

Tests cost runtime, attention, and every future refactor. Aim for the fewest that
still fail when the application breaks.

**Two tests killed by exactly the same set of mutations are one test.** Keep the
faster and clearer one; delete the other. This is the only rigorous definition of
duplication, so use it rather than judging by how similar the code looks.

The rule holds only when the operators can tell the tests apart. Two cases that
feed different inputs to one regex will always die together under coarse
operators, and cutting them would throw away the variation the tests exist for.
Before deleting on co-death, check that some mutation could in principle kill
one and not the other. **Report the mutation score by operator and the size of
the largest blast radius**: one mutation that kills most of the suite makes
every signature it appears in worthless.

| Delete | Keep |
| --- | --- |
| No mutation kills it | It is the only thing that catches some mutation |
| Same mutation set as a cheaper test | The cheaper, clearer one |
| Tests a private helper already covered through the public interface | The public-interface test |
| Asserts what the type system already guarantees | Behaviour types cannot express |
| Re-tests a library's own behaviour | Your use of it, at your boundary |

Say in the report what each deleted test used to cover and which surviving test
covers it now.

## 4. Reshape what survives

**Layer.** Prefer the cheapest layer that can fail for the right reason.

| Layer | Exercises | Use for |
| --- | --- | --- |
| Unit | One module through its public interface, no I/O | The default. Most logic belongs here |
| Integration | Real collaborators: filesystem, database, subprocess | Where the contract with that collaborator is the risk |
| End to end | The shipped artifact from outside: spawn the CLI, drive the browser, call the service over HTTP | A few paths a user actually takes |

An end-to-end test that imports application code is a unit test in costume. If it
does not go through the same entry point a user does, it is not end to end, and it
is buying none of the confidence its runtime is charging for.

**Names.** The name states the behaviour and the condition that triggers it, so a
failure is legible without opening the file. Name the behaviour, never the method.

- Bad: `test_parse`, `test_case_2`, `test_it_works`, `test_returns_true`
- Good: `test_a_release_inside_the_window_is_dropped`

**Data-driven.** Where three or more tests differ only in inputs and expected
output, collapse them into one parameterized test over a table of cases. Each row
must be a distinct behaviour, and each must carry a readable id so a failure names
the case rather than an index.

Do not collapse cases whose bodies would then need an `if`. Branching inside a
parameterized test means those rows are different behaviours: split them back out.

Collapsing also makes step 2 cheaper, since one mutation now proves many rows.

**Comments.** The name carries the intent, so a comment restating the code is
noise. Keep only what names a non-obvious reason: why this value is the boundary,
why this input is the dangerous one.

## 5. Read the suite as design feedback

A test that is hard to write is reporting a problem in the code, not in itself.
Collect these and put them in the report. Do not act on them unasked.

| Symptom in the test | Likely cause | Suggest |
| --- | --- | --- |
| Long arrange block, many mocks | The unit has too many collaborators | Split it, or inject fewer |
| Many near-identical cases at an input boundary | The input space is too permissive | Validate and normalise at the boundary, fail fast |
| Asserts on internal state | The behaviour is not observable through the interface | Return it, or stop testing it |
| Asserts the order of internal calls | Implementation is leaking into the contract | Assert outcomes |
| Setup differs per case in ways the name cannot express | The unit does more than one thing | Split the unit |
| Needs an elaborate fixture to reach one branch | That branch may be unreachable, or the edge case should not exist | Delete the branch, or reject the input earlier |

## 6. Run and review

```bash
<test command>                  # all green, and note the new wall clock
git status --porcelain          # no mutation left behind
git diff
```

Then review your own diff, hunk by hunk:

| Ask | Fail means |
| --- | --- |
| Is every surviving test still proven falsifiable after the edit? | You changed it and did not re-prove it. Re-run its mutation. |
| For each deletion: which test covers that behaviour now? | You cannot name one. Restore it. |
| For each collapsed table: does each row still fail for its own reason? | Mutate once and check every row you expect to die does. |
| Did any name stop matching what the test asserts? | The rename outran the assertion. |
| Is any hunk only a restyle? | Revert it. |

## Report

- Test count and wall clock, before and after.
- Every test deleted, with what it covered and what covers it now.
- Every test that no mutation could kill, and what you did about it.
- Mutations run, and which tests each one killed.
- Design problems found in step 5, as suggestions, with the test that revealed each.
