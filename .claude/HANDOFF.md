# HANDOFF — 2026-09-08 (Wave 9)

## Completed
Wave 9 committed as `9cd8ee8` on branch `wave-9-accuracy-automation` (v1.5.0 → 1.6.0),
not yet pushed or merged. Its real content was **removal, not addition**:

- **Corrected a wrong claim the kit had been shipping.** `verification.md` said "Rules are
  advisory; hooks are enforced." Claude Code's hooks docs say the opposite — hooks are
  best-effort (matchers miss, hooks time out); the **permission system** is the hard
  allow/deny gate. The claim had spread to three live files (`verification.md`,
  `skills/failure-modes/SKILL.md`, and `SOURCES.md`'s `mast` section). All three now read
  "rules are advisory; deterministic mechanisms are structural." Archived plan docs keep
  their original wording by convention.
- **Dropped a dangling reference.** `loop-cost-discipline.md` claimed to pair with
  `safe-autonomy.md`, which exists in neither the repo nor `~/.claude/rules/`. Reference
  removed rather than a file invented to satisfy it. Synced to the installed copy.
- **Added:** cite-or-retract + licensed abstention (`verification.md`); a hooks section in
  `automation.md` (a blocking hook must `exit 2`; hard denies go in permission config).
- **Changed:** `measurement.md` — a scheduled/headless/cron run is a session and logs a row.
- Two new `SOURCES.md` anchors. Line budget **+22** against the ≤+30 aim.

Separately: created **`C:\Clients\CLAUDE.md`** (61 lines, untracked, outside any repo). Holds
client-wide non-negotiables + "Build for Rebuilding" + "fix principles, not examples" from
The Claude Code Guide for Startups. Loads in both client repos via the parent-directory walk.
This closes the open thread in `Betsey_Brown_Travel/.claude/HANDOFF.md` ("considering scoping
the startup guide into this project's `.claude/rules/` only") — scoped one level up instead,
so it covers both clients and any future one.

## Blockers / didn't work
- **`bob-verifier` re-notified with a truncated body** (header only, no findings). Its first
  report's two defects were fixed and verified; whether the second pass found anything
  additional is **unknown**. `SendMessage` is disabled this session, so the agent could not be
  asked. A fresh verification pass on `9cd8ee8` would close this.
- Both research subagents independently reported "nothing to cut." Treated as the agents not
  looking, not as evidence the kit is clean.
- `plugin:github:github` MCP failed to connect this session (auth header malformed).

## Next action (priority 1)
Push `wave-9-accuracy-automation` and open a PR (Wave 8 landed the same way, PR #4). Then
decide whether `C:\Clients` gets `git init` or the CLAUDE.md stays loose.

## Test state
No code changed — docs/rules only. Verified mechanically on the committed state: budget
arithmetic (+20/+2/0 = 22) matches the CHANGELOG; zero residual "hooks are enforced" in live
files; all 11 `SOURCES.md#` anchors resolve; VERSION matches the CHANGELOG's top entry.
Gitleaks passed on commit.

## Open / carried forward
- **A garbage-collection pass is owed.** Wave 9 added 4 rules and cut 0 by the researchers'
  reckoning. `kit-maintenance.md`'s quarterly trigger is the mechanism; this wave does not
  substitute for it.
- **Hook audit result: nothing to fix.** All four blocking shell hooks already `exit 2`
  correctly. `gsd-*.js` hooks always `exit 0` but are plugin code and may block via JSON
  output — not inspected, not ours.
- **`gsd-validate-commit.sh` is dormant and would conflict if enabled.** It requires
  `.planning/config.json` with `hooks.community: true` (no such file exists anywhere in
  `C:\Dev` or `C:\Clients`). If ever enabled it enforces Conventional Commits, which would
  block the `"[session-name]: what and why"` format `session-workflow.md` mandates.
- **Next session topic (Daniel's ask):** audit what's enabled in the harness to improve
  agentic throughput — starting with why `SendMessage` is disabled. It is the cheap way to
  ask a finished subagent a follow-up (hundreds of tokens vs. ~78k to re-dispatch), and its
  absence cost real information tonight.
