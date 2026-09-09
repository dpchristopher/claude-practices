# Measurement Rules

> Auto-loaded at session start. The instrument that tells you which practices earn their keep.
> Without it, the kit accretes rules with no way to prune the dead ones.

---

## Log One Row Per Session

At session end (alongside HANDOFF), append a row to `.claude/session-metrics.md`. ~30 seconds.
**A scheduled, headless, or cron agent run is a session** and logs its own row — unattended
automation is the likeliest blind spot for a habit built around interactive work.
**Four metrics, hard cap** — resist adding more:

- **goal met?** — Y / N
- **rollback needed?** — Y / N (did work have to be redone or reverted)
- **interventions** — count (how many times you had to steer or correct)
- **friction** — 1–3 (1 smooth · 2 bumpy · 3 fought it)

Plus tags: which practices/skills were in play (e.g. `verification`, `bob-verifier`,
`labarr-ml`), and one line on the top failure if there was one.

**Probation resolved 2026-09-08 — `guard-fanout` KEPT.** It had fired 5 times (state dirs under
`$TMPDIR/claude-fanout`) and was tagged in the log zero times. The contract said "tag any session
where it fired," and nothing ever did — so the probation was unresolvable by its own terms, and
the hook was nearly cut for a logging failure rather than its own behavior. **A probation clause
that depends on a manual step is not an evaluation path.** Attach future probations to something
observable, or automate the observation.

That is what `session-metrics-stub.sh` (SessionEnd) now does: it appends a row every session with
the machine-observable fields filled and the four judgment fields left as `?` for you. A sparse
log cannot prune anything — 10 rows in several months is why the 2026-09-08 GC pass had no
grounds to cut a single one of 14 never-logged skills.

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
