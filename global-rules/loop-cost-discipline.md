# Loop Cost Discipline

> Auto-loaded at session start. Applies to any iterative refinement loop or subagent fan-out.
> Refinement has diminishing returns; spend accordingly. Pairs with
> `templates/.claude/rules/safe-autonomy.md`, which caps what an unattended agent *can* do.

---

## Estimate Before You Loop

Before kicking off an N-iteration loop, name the number: iterations × approx tokens/iteration ×
price. If you can't estimate it, you're not ready to run it unattended.

---

## Default Cap: 3 Iterations

Refinement gains plateau fast — most of the benefit lands in the first 1–2 passes, and by ~3 most
tasks flatline (SELF-REFINE; FAIR-RAG lands on 2–3 as the sweet spot). Go past 3 only when the
feedback is concrete and external — a failing test, a metric, a rubric — never for "polish."

Vague self-feedback ("make it better") decays immediately. A loop is only worth its cost when
each pass has a real signal to act on.

---

## One Good Pass Beats Five Loops When...

- The task is well-specified and the output already clears the bar.
- The only available feedback would be vague or self-referential.

Kill the loop early if two consecutive iterations produce no measurable improvement.

---

## Parallelize Only When Work > Cold-Start Tax

Each subagent re-pays a context tax (re-reading files, re-deriving context) and only its summary
returns. Parallelize when per-agent work dominates that tax — big independent fan-out (50+ items,
multi-source research). Do NOT parallelize small, shared-state, or sequential work: N cold-starts
cost more than they save. (Heuristic, not a measured constant.)

---

## Estimate Breadth Before Dispatch — Ad Hoc Fan-Out

Before dispatching **any** agent, say two numbers out loud: **how many children, and roughly what
each costs.** If you can't name both, you're not ready to dispatch.

- A multi-part question is **not** a licence to spawn one child per part. Decompose the question
  first, then decide how many children the *answer* needs.
- A child that returns nothing still costs full price. **Budget for the failure case.**
- Anything genuinely large goes through the `Workflow` tool — real caps and visible spend
  (source: `SOURCES.md#workflow-limits`).

### Fan-out: three constraints, revised 2026-09-09

The old rule was a flat numeric cap of 3–4 children plus "breadth is the constraint, not depth."
Both halves were wrong. Evidence and the regression cases: `docs/fan-out-constraints.md`.

1. **No numeric breadth cap.** The 3–4 figure came from one incident and no literature supports
   an optimal N in either direction. It gated correct work twice in 48 hours.
2. **Structure, not headcount.** Before dispatching, ask *does any child disagree with the others
   by design?* A fan-out of agreeing researchers is weaker than a smaller one with a dissenter.
3. **A dispatched agent must produce the artifact itself.** Delegating is permitted; returning a
   delegation as the deliverable is not. If it may spawn children it must synthesize them, or be
   told it may spawn none.
4. **The ceiling is verification capacity.** Fan out as wide as you can actually check. Fifty
   confident claims you cannot verify are worth less than five you can.

---

## Fresh Session vs. /compact

- `/compact` — for general mid-phase bloat; cheap, lossy.
- Fresh session with the plan file as context — at major phase transitions, or when the session
  has degraded (repeated confusion, contradictory context).

The plan file is what makes a fresh restart cheap. If state isn't in the plan file, fix that
before restarting.
