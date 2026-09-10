# claude-practices — Project Guide

> Rules for working **on the kit itself**. Global rules already load from `~/.claude/rules/`;
> this file only covers what is specific to this repo. Architecture: `META_ARCHITECTURE.md`.

## Session Start
1. `.claude/HANDOFF.md` — printed automatically by the SessionStart hook
2. `META_ARCHITECTURE.md` — the two delivery paths, hook inventory, known gaps
3. `bash scripts/verify-kit.sh` — 42 checks. Run it before changing anything and after

## This Repo Is PUBLIC

`dpchristopher/claude-practices`. Nothing machine-specific, client-specific, or personal.
The `local-models` and `daniel-context` skills are deliberately **not** here — one names this
machine's hardware and paths, the other is personal context. Check before adding a skill.

## The Mistake This Repo Keeps Making

**Two delivery paths that behave completely differently:**

| Put it in… | And it reaches… |
|---|---|
| `global-rules/`, `skills/`, `hooks/`, `templates/.claude/agents/` | every session, every project, via `install.sh` |
| `templates/` | **nothing**, until `/init` scaffolds a new project — which has never happened |

Wave 9 wrote four rules into `templates/.claude/rules/` and they reached zero projects.
**If it must apply everywhere, it goes in `global-rules/`.**

Never duplicate a rule across both. `kit-maintenance.md` and `loop-cost-discipline.md` existed
in both and drifted 21 and 17 lines apart. `verify-kit.sh` now fails on this.

## Invariants: Write The Mutation Test First

Three of four invariants here could not fail. INV-01 ran `git status` in the repo while the
installer wrote to `~/.claude`. INV-02 compared repo files to each other. INV-04 asked whether
a *file* cited a source, not whether a *number* did.

**A check that cannot observe what it is about will pass forever.** Before trusting any new
check: inject the fault, watch it fail, restore, watch it pass. If you cannot make it fail, it
is not a check.

This applies to your own fixes. The first version of `verify-install.sh` had the exact blindness
it was written to fix.

## Hooks

Wire in **both** `templates/.claude/settings.json` and the live `~/.claude/settings.json` —
INV-02 enforces parity. Two hooks are deliberately unwired (`stop-verify.sh`,
`guard-readonly-bash.sh`); they live in INV-02's allowlist with reasons. Do not "fix" them.

Hooks are best-effort, not enforcement. Anything that must *never* happen needs a static
permission `deny` rule. See `docs/mechanizing-doctrine.md`.

## Budgets

- Always-loaded growth (`global-rules/`): **≤ +30 lines per wave.** State the real number; if
  over, say so rather than trimming something load-bearing
- This file: under ~90 lines. Detail belongs in `docs/`, linked
- Exceeding a budget is allowed. Silently exceeding it is not

## Claims About This Repo

Every number and capability claim here and in `META_ARCHITECTURE.md` is checkable in seconds.
Check it. Four agent self-reports failed verification during the 2026-09-08 sweep, one of them
reporting an edit it never made — and two of seven "wrong doctrine" findings turned out to be
Claude's errors, not the kit's.

`bash scripts/usage-report.sh` is the instrument for what is actually used. Frequency is not
value: a zero is a question, not a verdict.

## Before Marking Anything Done

1. `bash scripts/verify-kit.sh` — must be green
2. Re-verify any invariant whose area you touched, with pasted evidence
3. Dispatch `bob-verifier` on non-trivial changes
4. Update `CHANGELOG.md`; bump `VERSION` for a wave
5. Feature branch → PR → merge. Never commit doctrine straight to `master`
