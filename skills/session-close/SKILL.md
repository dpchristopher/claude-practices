---
name: session-close
description: End-of-session close-out. Runs session-workflow §9 end to end and reports exactly what is done and what is stale. Use when wrapping up a work session, before stepping away, or when asked to "close out", "wrap up", "end the session", or "make sure everything is documented".
triggers:
  - close out the session
  - wrap up
  - end the session
  - session close
  - make sure everything is documented
  - before I step away
---

# Session Close

**The steps live in `session-workflow` §9. This skill does not restate them.** It exists for two
reasons §9 alone doesn't cover: a single trigger for the moment of leaving, and a report.

Why a trigger matters: measured across 39 sessions, §9's comprehension gate (`feynman-explainer`)
ran **zero** times. The checklist existed and was not reached. This makes reaching it one word.

A first version of this skill re-listed §9's steps and, in doing so, quietly overrode two of them —
it swapped `/code-review` for `bob-verifier` and changed the commit format. Two specs for one job
drift. So this version points at §9 and adds nothing to the steps. (D-015.)

## Do this

1. Open `session-workflow` §9 and **run every step in order.** Scope all of it to what changed —
   establish that first with `git status --porcelain` and `git log` since the branch point.
   If nothing changed, say so and stop.
2. Produce the report below.

## Two behaviours §9 does not specify

**Report, never block.** Always finish and always report. A close that can refuse to complete traps
you exactly when you need to leave. Anything failing or stale goes at the top — visible, never
hidden, never holding you there. A hard gate, if wanted, belongs in `stop-verify.sh`.

**Verify what agents claim.** Where §9 dispatches an agent, confirm its reported edits against
`git diff --stat` before reporting them as done. An agent's report is a claim, not a result.

## The report

Stale and failing items first.

```
SESSION CLOSE — <date>

⚠ NEEDS ATTENTION
  - <anything failing, stale, skipped, or an agent claim that did not verify>
  (or: nothing)

✓ DONE — by §9 step
  1  META_ARCHITECTURE: <files, verified against git diff | no change needed>
  2  toolkit table:     <updated | no skill changes>
  3  code review:       <result | skipped — no significant code>
  4  invariants:        <re-verified, pasted output | none touched>
  5  decisions:         <D-### | none made>
  6  feynman gate:      <comprehension gaps named | none>
  7  handoff:           written
  8  commit:            <sha> on <branch>
```

A step that could not run goes under NEEDS ATTENTION with the reason — never silently omitted.
