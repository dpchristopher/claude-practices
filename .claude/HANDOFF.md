# HANDOFF — 2026-09-08 (Wave 9 + system audit)

## Completed
**Three PRs merged** (#5 Wave 9, #6 INV-02 fix, #7 backup fix). master at v1.6.0, clean.

- **Wave 9** — mostly removal. Corrected a wrong claim the kit shipped ("hooks are
  enforced") across three live files; hooks are best-effort, the permission system is the
  hard gate. Dropped a dangling `safe-autonomy.md` reference. Added cite-or-retract and
  abstention rules; a hooks section (`exit 2`) in `automation.md`; cron/headless metrics
  wording. Line budget +22 of ≤+30.
- **`C:\Clients` is now a git repo** (`9f58fc4`) holding a shared `CLAUDE.md`: client-data
  non-negotiables + "fix principles, not examples" + "Build for Rebuilding" from the
  startup guide. Loads in both client repos via the parent-directory walk. Both client
  repos gitignored; gitleaks wired.
- **System audit (3 agents)** found one dominant pattern: *things built correctly, then
  never connected.* Fixes applied and verified:
  - Both client repos had NO secrets guard — now on `core.hooksPath`, proven by a live
    test (fake GitHub PAT detected, commit blocked, 0 commits).
  - **INV-02 was structurally blind** — it compared repo files to each other and never read
    the deployed config, so it reported green while 8 hooks sat unwired. Added a deployed-
    parity check; it went red with 5 named failures, then green after wiring.
  - **6 hooks wired** into `~/.claude/settings.json`: guard-secrets, post-edit-format,
    plan-router, subagent-audit, guard-verdict, log-instructions-loaded.
  - 7 global deny rules added (0 before). Dead `additionalDirectories` dropped. Duplicate
    `superpowers` plugin entry removed. `.env` added to `Civ_Project/.gitignore`.
  - Pixel-agents removed from the 3 per-tool-call events (kept on 9 others).
  - Agent-ownership rule in global CLAUDE.md: my agents win, GSD's are for `/gsd-*` only.
  - `backup-state.sh` now includes the global CLAUDE.md; ran it to `~/OneDrive/claude-backups`.
- **All 4 invariants re-verified with evidence.** INV-01 was briefly stamped without being
  verified, caught, reverted with the reason written in, then genuinely verified from a
  clean tree.

## Blockers / didn't work
- **`SendMessage` is disabled**, so a finished subagent can't be asked a follow-up. Cost real
  information when bob-verifier re-notified with a truncated body (its report did stand —
  recovered by grepping the transcript, which is the workaround).
- `plugin:github:github` MCP fails to connect (malformed auth header); `gh` CLI works fine.
- Two audit agents were unreliable: one claimed an edit it never made, one got the gitleaks
  mechanism wrong (checked `.git/hooks/` instead of `core.hooksPath`). Verify agent claims.

## Next action (priority 1)
**Rotate FRED, EIA, and BEA API keys** (Econ Project). Still unrotated, carried across
multiple sessions, with a Kevin finding that `BEA_API_KEY` bypassed redaction. Oldest real
risk on the board. `Econ Project/.claude/HANDOFF.md` has the sequencing.

## Test state
INV-01/02/03/04 all pass with 2026-09-08 evidence. Gitleaks passed on every commit tonight.
`verify-hooks.sh` green on merged master.

## Open / carried forward
- **Wave 9's four new rules reach zero projects.** They live in `templates/.claude/rules/`,
  which only deploys via `/init` on a NEW project — and that template has never scaffolded
  one. Decide whether cite-or-retract and abstention should move to `global-rules/`
  (costs ~11 lines of always-loaded budget) or stay inert.
- **Backup is manual with no scheduler.** Same "mechanism exists, nothing connects it"
  pattern. A `SessionEnd` hook would close it.
- **`guard-readonly-bash.sh` and `stop-verify.sh` deliberately NOT wired** — the first blocks
  rm/git commit/pip install and is for read-only reviewer agents; the second is a no-op
  until `PROJECT_CHECK_CMD` is set.
- Close the `admiring-payne-79e31a` session, then remove that merged Civ worktree + branch.
- **A GC pass is owed.** Wave 9 added and cut nothing by the researchers' reckoning; two
  audits later found plenty. 34 agents (24 GSD, 10 kit), 13 plugins.
- Daniel's stated next topic: harness/agentic optimization — starting with why SendMessage
  is off.
