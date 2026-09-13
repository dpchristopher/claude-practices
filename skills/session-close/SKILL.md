---
name: session-close
description: End-of-session close-out. Syncs docs to what actually changed, records decisions, re-runs checks, gets an independent review, and writes HANDOFF.md — then reports exactly what is done and what is stale. Use when wrapping up a work session, before stepping away, or when asked to "close out", "wrap up", "end the session", or "make sure everything is documented".
triggers:
  - close out the session
  - wrap up
  - end the session
  - session close
  - make sure everything is documented
  - before I step away
---

# Session Close

`session-workflow` §9 lists seven end-of-session steps. Measured across 39 sessions, the
comprehension gate at its centre (`feynman-explainer`) was invoked **zero** times — the
checklist existed and was not run. This skill is §9 made into one command.

**It composes existing parts. It adds no new capability.** Every step below calls something that
already exists. (Decision D-013.)

## Behaviour: REPORTS, does not block

A close that can refuse to finish would trap you exactly when you need to leave. So this skill
**always completes and always reports**. Anything stale or failing is listed loudly at the top of
the report — it is never hidden, but it never holds you hostage.

If you want a hard gate instead, that belongs in `stop-verify.sh` via `PROJECT_CHECK_CMD`, which
already exists per project.

---

## Steps — run in this order

### 1. Establish what changed

```bash
git branch --show-current
git status --porcelain
git log --oneline "$(git merge-base HEAD origin/master 2>/dev/null || echo HEAD~10)"..HEAD
git diff --stat "$(git merge-base HEAD origin/master 2>/dev/null || echo HEAD~10)"
```

Everything after this step is scoped to that diff. If nothing changed, say so and stop — do not
invent documentation work.

### 2. Re-run the checks

- In `claude-practices`: `bash scripts/verify-kit.sh`
- Anywhere else: the project's `PROJECT_CHECK_CMD` from `.claude/settings.json`, if set
- Re-verify any invariant in `INVARIANTS.md` whose area the diff touched, **with pasted output**

**Record the raw result.** Do not summarise a failure as a pass.

### 3. Sync the docs — dispatch `jerry-docs`

Give Jerry the diff from step 1 and this brief:

> Bring `README.md`, `META_ARCHITECTURE.md`, and `CHANGELOG.md` in line with what this diff
> actually does. Reflect reality; do not invent. For any file you did not need to change, say so
> explicitly. **Write the files yourself — do not delegate.** Report every file you edited.

Then **verify Jerry's report** — `git diff --stat` must show the files Jerry claimed. An agent's
self-report is a claim, not a result (D-001).

### 4. Record decisions

If this session made a decision — chose one approach over another, retired a rule, declined an
option — add it to `DECISIONS.md`: the decision, the reason, what was rejected, and **what would
reverse it**. A decision with no reversal condition is a belief. Skip this step if nothing was
decided; do not manufacture entries.

### 5. Comprehension gate — invoke `/feynman-explainer`

Explain the session's changes in plain language, as if to a competent newcomer. **Where the
explanation stalls is a comprehension gap** — name it in the report rather than smoothing past it.
The resulting explanation becomes the body of `HANDOFF.md`.

### 6. Independent review — dispatch `bob-verifier`

On the diff, for non-trivial changes. Use `bob-verifier` rather than `general-purpose`:
`guard-verdict.sh` enforces a verdict marker only on named checker agents, so a review sent to
`general-purpose` runs without that gate. Nothing forces this choice — a hook that tried was removed
(D-014) — so make it deliberately.

Skip for trivial changes (typo, single-line doc fix) and **say you skipped it**.

### 7. Write `.claude/HANDOFF.md`

Replace, do not append:

```
## State
## Completed
## Blockers / didn't work
## Next action (priority 1)
## Test state
## Open / carried forward
```

Include anything the previous `HANDOFF.md` carried forward that is still open.

### 8. Commit — feature branch only

Never commit to `master`/`main`. If on the default branch, create a branch first. Conventional
commit messages (`feat:`, `fix:`, `docs:`). Do **not** push or open a PR unless asked.

---

## The report

End with exactly this shape. **Stale and failing items go first.**

```
SESSION CLOSE — <date>

⚠ NEEDS ATTENTION
  - <anything failing, stale, skipped, or where an agent's claim did not verify>
  (or: nothing)

✓ DONE
  - checks: <command> → <result>
  - docs synced: <files Jerry edited, verified against git diff>
  - decisions recorded: <D-### or "none made">
  - comprehension gaps: <list or "none">
  - review: <Bob's verdict, or "skipped — trivial">
  - handoff: written
  - commit: <sha> on <branch>
```

If a step could not run, it goes under NEEDS ATTENTION with the reason — never silently omitted.
