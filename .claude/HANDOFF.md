# HANDOFF — 2026-08-19

> **Read this first if you are on a new machine.** See *New-machine setup* below before anything else.

## Completed
**Wave 7 — Doctrine Refresh (v1.4.0)**, merged and pushed. Plus two follow-ups: Wave 7.1 (`/init` fixes) and Wave 7.2 (gitleaks).

- **The global rule layer is in version control and installed.** `global-rules/` → `~/.claude/rules/`, with a step 4 in both installers. It previously existed only on one machine, untracked — a reinstall could not restore it. This is what makes the machine move survivable.
- **The fan-out brake**, in three places: `loop-cost-discipline.md` (global, always loaded), the rewritten fan-out sections of `dave-researcher.md` and `bob-verifier.md`, and a pinned regression case in `evals.md`. Plus `hooks/guard-fanout.sh` — opt-in, dormant.
- **Corrections:** nesting depth 5→3 (Bob and Dave carried a stale number); three limit systems separated; the "200-subagent cap" debunked as never having existed.
- **New:** `SOURCES.md` ledger, kit `INVARIANTS.md`, two verifier scripts, judge-calibration doctrine, MAST corroboration, SessionStart exit-condition warning, isolation-mechanism decision table.
- **README reframed** from "sessions forget context" to a dated snapshot of practice.
- **`/init` fixed** — it never copied `.claude/settings.json`, so scaffolded projects got the rules but the SessionStart hook never fired and continuity silently died. It also promised embedded fallback content that did not exist. Both fixed.
- **gitleaks installed and hooked.** INV-03 had never actually run. Now passing, and firing on every commit.

## New-machine setup

Everything the kit needs is in the repo except two personal files, which are in **`OneDrive/claude-machine-move/`** (deliberately not committed — the global CLAUDE.md is personal by its own doctrine).

```bash
git clone https://github.com/dpchristopher/claude-practices.git
cd claude-practices
./install.sh          # or .\install.ps1 on Windows
```

That installs skills, hooks, agents, and `global-rules/` → `~/.claude/rules/`.

Then restore the two personal files from `OneDrive/claude-machine-move/`:
- `GLOBAL-CLAUDE.md` → `~/.claude/CLAUDE.md`
- `session-metrics.md` → `~/.claude/session-metrics.md`
- `memory/` → `~/.claude/projects/<project-slug>/memory/`

If that OneDrive folder is missing, `templates/global-CLAUDE.md` reconstructs the global file — it was synced to match the live one in Wave 7 and differs only in header wording and placeholder rows.

Two tools the kit assumes but does not install:

```bash
pip install pre-commit && python -m pre_commit install    # gitleaks backstop (INV-03)
powershell -c "irm https://astral.sh/uv/install.ps1 | iex"  # uv — needed by MCP servers
```

**Not carried by the repo:** ~83 of the 92 installed skills come from plugins and marketplaces, not this kit. Reinstall those separately if you want them.

## Blockers
None. All four invariants verified with pasted evidence.

Two dormant items, neither needing action:

1. **MAST FC1 category percentage unresolved.** Three retrieval attempts gave 43.8 / 43.9 / 44.2 (mode-sum). Withheld from doctrine, discrepancy documented in `SOURCES.md#mast`. Nothing depends on it — doctrine cites the mode-level figures, which are stable.
2. **`guard-fanout.sh` on probation.** Installed but dormant — opt-in, wired into no `settings.json`. Tagged in `measurement.md` for a keep/cut decision at the next monthly review. The rule it enforces is already always-loaded, so leaving it off costs nothing.

## Next action (priority 1)
**Wave 8: the automation-surface taxonomy.** Four surfaces now exist with different durability — `CronCreate` (session-only, 7-day expiry), Routines (durable cloud, survives machine offline), the Workflow tool, and Desktop Scheduled Tasks. The hard part is placement, not content: `automation.md` is `paths:`-scoped and will not load when the surface is being *chosen*. That likely means splitting the rule — decision content unconditional, implementation content path-scoped. Downstream of it: a fourth rung on `loop.md`'s autonomy ladder, since L3 containment assumes an active local session and Routines run off-machine.

**Also queued, blocked on you:** run `/the-fool` on discover-on-demand (`SearchSkills`/`SearchPlugins`) vs. the curated-roster rule. A genuine philosophical fork. Relevant evidence: `~/.claude/skills/` holds 90+ skills, mostly `gsd-*`, so the curation premise is already not holding at the global layer.

## Test state
- INV-01 ✅, INV-02 ✅, INV-03 ✅, INV-04 ✅ — all four with pasted evidence
- gitleaks fires on every commit via `.git/hooks/pre-commit`; full-repo run passed
- Fresh install into a throwaway HOME: 9 agents, 2 global rules, 11 hooks, 9 skills
- `verify-hooks.sh` → `HOOK PARITY OK`; `verify-sources.sh` → `CITATIONS OK`
- SessionStart exit-condition check tested across 4 states × 2 shells
- `guard-fanout.sh` concurrency probe: 5 parallel dispatches count correctly (pre-fix version silently undercounted)

## Notes for next session

**The thing worth carrying forward:** three separate numeric claims in this wave were wrong — two I asserted, and one was a *correction* I made to a number that turned out to be right-ish. Bob caught the worst of it; re-verification caught the rest. I also self-reported the line-budget figure incorrectly twice.

None of these were caught by me reading my own work. Every one needed either a fresh context or an independent re-fetch. That is the strongest argument this wave produced for maker≠checker being load-bearing rather than ceremony — and a standing signal that **any numeric claim in prose should be treated as unverified until something outside the writing checks it.**

Practical consequence for the next wave: when doctrine quotes a number, the citation is not enough. Verify the number reconciles against whatever it is derived from, because `verify-sources.sh` only proves a pointer exists — it cannot tell you the number is right.
