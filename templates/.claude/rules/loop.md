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

## The eight rules of a loop you can trust
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
8. **Route model choice per stage, not just per loop.** A single loop can mix cheap
   mechanical stages (cheap model) with judgment/synthesis stages (strongest model) — state
   the model per stage before running, not just once for the whole loop.

## The checker must point at the WHOLE check
Make the exit condition the full suite (all tests + lint), not the single failing item. A
narrow checker is gameable — Claude can make test A pass by breaking test B if B isn't in
the gate. Green must mean the whole thing is green. Pair with Bob reviewing the diff to
catch "fixed X by gutting Y," and keep passing cases as regression tests so old wins can't
silently break.

## Split work only where context isolates cleanly
Decompose a multi-agent task by WHERE context can be truly separated, not by problem phase.
A naive plan→implement→test handoff chain shares too much context across steps and degrades
like a telephone game — each handoff loses fidelity. Verification is the classic case that
splits cleanly (a fresh-context checker needs the diff and the spec, nothing else); a
sequential pipeline of loosely-related steps usually does not. Prefer a fresh-context
verifier over a context-passing pipeline whenever the choice exists.

## When the goal may be impossible
A loop cannot achieve the impossible (e.g. an ML threshold the data can't support). That's
what the brakes are for: it hits the iteration cap or stuck-loop detection and STOPS with
an honest report of what it tried and why it failed — escalating to you rather than
thrashing or faking a result. An honest "I can't, here's why" is the designed outcome.

## When NOT to loop
A single scoped prompt often beats the whole apparatus. Reach for a loop only when the
goal is objectively checkable and iterative refinement provides measurable value. If you
can describe the fix in one sentence, just make it.

## L3 (unattended) requires containment, not just correctness
The autonomy ladder's brakes (exit condition, stuck-loop detection, whole-check gate) govern
CORRECTNESS. Before granting L3, also bound the BLAST RADIUS, independently:
- Network egress limited or sandboxed — an unattended loop should not have open internet
  access it doesn't need.
- Credentials scoped to test/staging, never production, for anything that can write.
- A hard spend cap on anything that can cost money (API calls, cloud resources).
Correctness brakes and containment brakes are separate checks — a loop can be "correct" and
still be dangerous if it runs unsandboxed with production credentials and no spend limit.
Grant L3 only when both are satisfied.

## Loop cost budgets (concrete numbers, not just "watch it")
When a loop runs as a Dynamic Workflow, real ceilings apply — use them as the budget:
- Hard caps: 16 concurrent agents, 1,000 total per run.
- A "Large workflow" warning fires past 25 agents or ~1.5M projected tokens — treat it as a stop-and-check.
- Set a default ceiling with the Dynamic workflow size guideline in `/config` (`small` <5, `medium` <15, `large` <50 agents).
- A Stop-hook loop is force-ended after 8 consecutive blocks — don't rely on it as your only brake.
- Watch spend live in `/workflows` (per-agent token totals) and the `SubagentStop` audit log.
State the intended agent-count and model-per-stage budget BEFORE starting an unattended loop.
