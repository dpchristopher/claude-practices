# Measurement Rules

> Auto-loaded at session start. The instrument that tells you which practices earn their keep.
> Without it, the kit accretes rules with no way to prune the dead ones.

---

## Log One Row Per Session

At session end (alongside HANDOFF), append a row to `.claude/session-metrics.md`. ~30 seconds.
**Four metrics, hard cap** — resist adding more:

- **goal met?** — Y / N
- **rollback needed?** — Y / N (did work have to be redone or reverted)
- **interventions** — count (how many times you had to steer or correct)
- **friction** — 1–3 (1 smooth · 2 bumpy · 3 fought it)

Plus tags: which practices/skills were in play (e.g. `verification`, `bob-verifier`,
`labarr-ml`), and one line on the top failure if there was one.

Keep it binary where possible. No 1–5 quality scores — the difference between a 3 and a 4 is
noise (Hamel's rule).

---

## Monthly Review — The Part That Matters

Once a month, ~15 minutes:

1. **Error analysis first.** Read the "top failure" notes; cluster the 2–3 failures that recur.
   This — not the averages — drives change.
2. **Crude before/after by tag.** Compare goal-met and rollback rates for sessions where a
   practice fired vs. where it didn't. Not a clean experiment (no randomization) — just
   directional.
3. **One decision.** Keep / cut / revise exactly one practice. Forces action; prevents the kit
   from only ever growing.

The log without the monthly read-and-decide is just a dead dashboard. **The review is the product.**
