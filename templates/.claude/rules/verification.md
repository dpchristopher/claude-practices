# Verification Rules

> Auto-loaded at session start. Governs how "done" is proven — evidence over assertion.

---

## The Core Rule: Evidence, Not Assertions

Never claim work is done, fixed, or passing without showing proof. "Proof" means the command
you ran and its actual output — test results, a build log, a screenshot — pasted into the
conversation. If you cannot show it, it is not done.

"Done" means the tests pass, not the agent feeling good about the work.

---

## Verification Hierarchy — Most Objective First

1. **Deterministic checks** — tests, linters, type-checkers, schema validation. Prefer these.
2. **Visual / runtime** — run it, screenshot it, exercise it as a user would.
3. **LLM-as-judge** — a model grading output. Least robust; use last, and only when 1 and 2
   can't cover it.

Reach for a real check before asking a model whether something "looks right."

---

## Don't Mark Complete Without End-to-End Testing

A terminal message ends the turn, not the task. Before saying "done":

- Run the actual thing a user would run.
- Confirm it works end-to-end, not just that the code compiles.
- Paste the evidence.

The most common failure: plausible-looking code that was never exercised end-to-end.

---

## Use the Verifier and Evals Agents — Don't Grade Your Own Work

A maker checking its own work justifies what it already did. Separate the maker from the checker:

- **Before marking any non-trivial change done** → dispatch `bob-verifier` (fresh-context
  reviewer; sees the diff + criteria, reports only correctness gaps).
- **To grade a batch of model/agent/ML outputs against a rubric** → dispatch `carl-evals`
  (binary PASS/FAIL, clusters failures by root cause). Pairs with `labarr-ml`.

Guardrail: a reviewer told to find gaps will always find some. Flag only gaps that affect
correctness or the stated requirements — not style preferences. Don't gold-plate.
