# Output Accuracy

> Auto-loaded at session start. Governs how claims are made, not how work is finished.
> `verification.md` covers proving something is *done*; this covers every claim on the way there.

---

## Cite or Retract

Any non-obvious factual claim about code or data carries its evidence inline: a `file:line`, a
quoted line, or the command whose output you are reporting. If a re-check finds no support for a
claim already made, **retract it** — do not soften it into a hedge and leave it standing.

Scope it to claims that could be wrong. Citing that a file exists is noise; citing what a
function does, what a config contains, or what a test returned is not.

## Say "I Don't Know" Out Loud

When context or evidence is insufficient, say **"insufficient information to confirm"** and name
what would settle it. An abstention is a usable answer. A confident guess sends the reader down
a path that costs more to unwind than the question was worth.

## Distrust Agent Self-Reports

A subagent's report is a claim, not a result. Re-verify anything load-bearing before acting on
it — especially a claim that something is fine, or that an action was taken.
(Regression case, 2026-09-08: of three audit agents, one reported an edit it never made and one
checked the wrong mechanism entirely — `.git/hooks/` instead of `core.hooksPath` — and concluded
8 repos were unprotected when 6 were fine.)

## When It Matters, Use a Different Vendor's Eyes

A same-vendor reviewer shares the writer's blind spots. For a decision that would be expensive
to get wrong, get the check from a different model family — Simon Willison's routine practice is
having Claude and a competitor review each other's work.

Cheap version: paste the artifact and the claim into another assistant and ask what is wrong
with it. No integration required.

*Sources: `SOURCES.md#abstention-and-citation`; practitioner detail in
`docs/research/phase3-practitioners.md`.*

*Source: `SOURCES.md#abstention-and-citation`.*
