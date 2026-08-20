# HANDOFF — 2026-08-19

## Completed
**Wave 7 — Doctrine Refresh (v1.4.0)**, merged from `feature/wave-7-doctrine-refresh`.

- **The global rule layer is now in version control and installed.** `global-rules/` → `~/.claude/rules/`, with a step 4 in both installers. It previously existed only on one machine, untracked, and a reinstall could not restore it.
- **The fan-out brake**, in three places: `loop-cost-discipline.md` (global, always loaded), the rewritten fan-out sections of `dave-researcher.md` and `bob-verifier.md`, and a pinned regression case in `evals.md`. Plus `hooks/guard-fanout.sh` — opt-in, asks past 4 dispatches.
- **Corrections:** nesting depth 5→3 (Bob and Dave carried a stale number); three limit systems separated; the "200-subagent cap" debunked.
- **New:** `SOURCES.md` ledger, kit `INVARIANTS.md`, two verifier scripts, judge-calibration doctrine, MAST corroboration, SessionStart exit-condition warning, isolation-mechanism decision table.
- **README reframed** from "sessions forget context" to a dated snapshot of practice.

## Blockers
None. All four invariants now verified.

Two dormant items, neither needing action:

1. **MAST FC1 category percentage is unresolved.** Three retrieval attempts gave 43.8 / 43.9 / 44.2 (mode-sum). The number is withheld from doctrine and the discrepancy is documented in `SOURCES.md#mast`. Nothing depends on it — the mode-level figures are what doctrine actually cites. Resolve by reading Figure 1 of the paper only if it ever matters.
2. **`guard-fanout.sh` is on probation.** Installed but dormant — opt-in, not wired into any `settings.json`. Tagged in `measurement.md` for a keep/cut decision at the next monthly review. The rule it enforces is already in the always-loaded global layer, so leaving it off costs nothing.

## Next action (priority 1)
**Wave 8: the automation-surface taxonomy.** Four surfaces now exist with different durability — `CronCreate` (session-only, 7-day expiry), Routines (durable cloud, survives machine offline), the Workflow tool, and Desktop Scheduled Tasks. The hard part is placement, not content: `automation.md` is `paths:`-scoped and will not load when the surface is being *chosen*. That likely means splitting the rule — decision content unconditional, implementation content path-scoped. Downstream of it: a fourth rung on `loop.md`'s autonomy ladder, since L3 containment assumes an active local session and Routines run off-machine.

**Also queued, blocked on you:** run `/the-fool` on discover-on-demand (`SearchSkills`/`SearchPlugins`) vs. the curated-roster rule. Genuine philosophical fork. Relevant evidence: `~/.claude/skills/` already holds 90+ skills, mostly `gsd-*`, so the curation premise is not holding at the global layer already.

## Test state
- INV-01 ✅, INV-02 ✅, INV-03 ✅, INV-04 ✅ — all four verified with pasted evidence
- gitleaks git hook installed at `.git/hooks/pre-commit`; fires on every commit
- Fresh install into a throwaway HOME: 9 agents, 2 global rules, 11 hooks, 9 skills
- `verify-hooks.sh` → `HOOK PARITY OK`; `verify-sources.sh` → `CITATIONS OK`
- SessionStart exit-condition check tested across 4 states × 2 shells
- `guard-fanout.sh` concurrency probe: 5 parallel dispatches count correctly (the pre-fix version silently undercounted)

## Notes for next session
Bob's review found 6 real gaps, including that this wave's flagship MAST "correction" was itself under-verified. **Both a wrong number I shipped and a wrong number I corrected were caught by a fresh-context reviewer, not by me.** That is the strongest evidence this wave produced for why maker≠checker is load-bearing — worth remembering the next time a review feels like ceremony.
