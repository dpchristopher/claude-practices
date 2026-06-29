---
name: feynman-explainer
description: Use as a comprehension gate before marking work done and when writing HANDOFF. Forces a plain-language explanation of a change as if teaching a competent newcomer; points where the explanation stalls are logged as comprehension gaps. Completes the thinking trio.
triggers:
  - before marking a task done
  - writing HANDOFF
  - do I actually understand this
  - explain this simply
  - comprehension check
---

# Feynman Explainer

A comprehension gate. You do not understand a change until you can explain it simply.
This skill turns that test into a step you actually run.

## When to invoke
1. **Before claiming a task done** — articulate what changed and why it works.
2. **When writing HANDOFF.md** — the explanation becomes the HANDOFF body.

## The procedure
1. **Explain the change in plain language**, as if to a competent newcomer to this
   codebase. No jargon, no hand-waving over "and then it just works." Cover: what
   changed, why, and how you know it works.
2. **Mark every stall.** Wherever you reach for jargon, get vague, or can't say *why*
   something works — that is a **comprehension gap**, not a wording problem.
3. **Map each gap to a concrete follow-up:** read file X / run test Y / re-verify
   invariant Z. A gap is not closed by rephrasing; it is closed by going and checking.
4. **If a gap reveals a real defect**, hand off: `/debugging-wizard` for code,
   `/labarr-ml` for an ML issue.
5. **The simple explanation, with gaps resolved, is the HANDOFF body.** HANDOFF quality
   and comprehension are gated by the same act.

## The test
If you cannot explain why the change works without jargon, you have not verified it —
you have only produced something that looks right. Close the gap before "done."

## Why it works (research-backed)
Explaining-to-teach forces retrieval, which builds understanding far better than
re-reading (Karpicke & Blunt 2011, *Science*; learning-by-teaching as retrieval
practice, Koh/Lee/Lim 2018). The discomfort of articulating simply is the signal
(Bjork's desirable difficulty), and without it most of what you "learned" decays
(Ebbinghaus, 1885).

## Place in the trio
`thinking-partner` (explore) → `socratic-examiner` (stress-test) →
`assumption-archaeologist` (excavate premises) → **`feynman-explainer`** (prove you
understand what you built). The first three precede building; this one gates "done."
