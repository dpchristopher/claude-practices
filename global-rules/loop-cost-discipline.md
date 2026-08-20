# Loop Cost Discipline

> Auto-loaded at session start. Applies to any iterative refinement loop or subagent fan-out.
> Refinement has diminishing returns; spend accordingly. Pairs with `safe-autonomy.md`.

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
- **Ad hoc `Agent` fan-out is capped at 3–4 children.** Anything larger goes through the `Workflow`
  tool — real caps and visible spend (source: `SOURCES.md#workflow-limits`).
- A child that returns nothing still costs full price. **Budget for the failure case.**
- Breadth is the constraint, not depth (source: `SOURCES.md#subagent-limits`). Regression case:
  `templates/.claude/rules/evals.md`, 2026-08-19.

---

## Fresh Session vs. /compact

- `/compact` — for general mid-phase bloat; cheap, lossy.
- Fresh session with the plan file as context — at major phase transitions, or when the session
  has degraded (repeated confusion, contradictory context).

The plan file is what makes a fresh restart cheap. If state isn't in the plan file, fix that
before restarting.
