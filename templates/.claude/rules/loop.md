# Loop Rule

> Auto-loaded at session start. Governs autonomous / self-correcting loops. The point is
> not to babysit an agent move by move — it is to design a loop that runs without you, then
> trust it because you built the brakes in.

## Lean on native primitives — don't reinvent them
- **`/goal`** is the iteration engine: state a checkable goal and a separate evaluator
  re-checks it each turn, continuing until it holds. Use it instead of hand-rolling a loop.
- **`/rewind`** is the safety net: per-change checkpoints you can roll back to. Use it
  rather than scripting your own undo.

This rule supplies only the discipline the platform does not.

## The seven rules of a loop you can trust
1. **Write the exit condition BEFORE the loop starts.** Concrete and machine-checkable —
   "all tests pass AND lint clean; stop after 2 clean passes." A loop with no defined exit
   burns tokens.
2. **Maker ≠ checker.** The agent doing the work never grades itself. Route checking to a
   fresh-context reviewer (Bob the verifier) or judge (Carl the evals-judge).
3. **State lives on disk, not in context.** Progress, the exit condition, and open work go
   in files (the plan, INVARIANTS.md, HANDOFF) so the loop resumes across sessions.
4. **Earn autonomy in stages: L1 → L2 → L3.** L1 = loop reports, you apply fixes. L2 =
   loop applies fixes, you review each. L3 = unattended. Never start at L3.
5. **Checkpoint per iteration.** Each pass is a git commit — the diff is your audit trail.
   (Rollback itself is `/rewind`; the commits are for the record.)
6. **Detect a stuck loop.** If the same error repeats, or no new commit lands in N
   iterations, STOP and surface to a human. Repetition is not progress.
7. **Loops open PRs; they never auto-merge.** The human merge is the final gate.

## The checker must point at the WHOLE check
Make the exit condition the full suite (all tests + lint), not the single failing item. A
narrow checker is gameable — Claude can make test A pass by breaking test B if B isn't in
the gate. Green must mean the whole thing is green. Pair with Bob reviewing the diff to
catch "fixed X by gutting Y," and keep passing cases as regression tests so old wins can't
silently break.

## When the goal may be impossible
A loop cannot achieve the impossible (e.g. an ML threshold the data can't support). That's
what the brakes are for: it hits the iteration cap or stuck-loop detection and STOPS with
an honest report of what it tried and why it failed — escalating to you rather than
thrashing or faking a result. An honest "I can't, here's why" is the designed outcome.

## When NOT to loop
A single scoped prompt often beats the whole apparatus. Reach for a loop only when the
goal is objectively checkable and iterative refinement provides measurable value. If you
can describe the fix in one sentence, just make it.
