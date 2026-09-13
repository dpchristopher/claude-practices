# HANDOFF — 2026-09-13 (fort-mchenry)

## What this session did, plainly
1. **Usage counter fixed.** It now reads transcripts as JSON and counts each agent/skill call once.
   Real numbers: 39 sessions; `feynman-explainer` had run 0 times. An earlier "4x over-count" claim
   came from one session and was retracted (corpus ratio 0.99x).
2. **DECISIONS.md added** (D-001..D-016): why the kit is the way it is, and what would reverse it.
3. **Two builds removed the same day.** A verification-routing guard (D-014 — built on one session's
   data) and `/beast-mode` (D-015 — duplicated Gru's plan and broke its parallelism).
   `/session-close` is now a one-word trigger over `session-workflow` §9 plus a report.
4. **verify-kit check 1c** fails on invisible control bytes — a Python `\1` escape twice wrote byte
   0x01 into files and silently broke a hook.
5. **Missed-close detector** in `hooks/session-context.sh`: at session start it computes whether the
   last session ended without a handoff (commits after HANDOFF.md, or files left uncommitted) and
   prints a warning only when true. Silent when clean, so it never becomes wallpaper.

## How we know it works
9 test cases (clean close silent; commit after handoff fires; PR merge and squash merge silent;
user file left uncommitted fires; kit-only artifacts silent; non-repo silent; broken `stat` silent).
Hook deployed byte-identical to `~/.claude/hooks`. Invariants, citations, install parity, gitleaks pass.

## Gaps the Feynman gate found (all closed)
- Kit hooks write `precompact-state.md` / `orchestration-log.txt` into un-ignored `.claude/` in 6 of 8
  repos → detector would fire every session. Filtered in the hook (D-016).
- META_ARCHITECTURE claimed the `.ps1` twin had the detector; it doesn't. Row split.
- Squash merge was assumed safe, never tested. Now tested: silent.

## Next session
- **Discuss "mini-Gru"** (Daniel's idea): elite execution for tasks too small for a Gru plan. First
  pin down what "technically elite" concretely means; check plan mode, superpowers writing-plans,
  TDD, verification-before-completion, bob-verifier before building anything (D-012/D-015 lesson).
- Click "Run now" on the `monthly-kit-sweep` scheduled task before Oct 1 to pre-approve its tools.

## Carried forward
- Kit artifacts still pollute `git status` in 6 repos (detector filters them; repos not fixed).
- `session-context.ps1` drift (unwired, ~half length) — GC item.
- Widen `plan-router.sh` regex (offered, not done). Civ automation plan unexecuted. Tier 3 unactioned.
