# Verification Rule

> Auto-loaded at session start. Governs how "done" is proven.

## Evidence over assertion
Never claim work is done by asserting it. Show the evidence: the command you ran and its
real output, the test result, or a screenshot. If you cannot produce evidence, the work
is not done — say so.

## Verification taxonomy (prefer the strongest available)
1. **Rules-based (best):** a deterministic check — tests pass, linter clean, schema
   validates, type-checker green. Quote the failing/passing rules.
2. **Visual:** for UI, a screenshot or rendered output confirming the change.
3. **LLM-as-judge (weakest):** only for genuinely fuzzy criteria; least robust, so never
   rely on it where a rules-based check is possible.

Reach for the strongest method the task allows. A rules-based check beats a confident paragraph.

## If you must use a judge, calibrate it first
An uncalibrated judge is an opinion with a number attached. Before trusting one: label a
sample yourself, measure how often the judge agrees with you, and treat its verdicts as usable
only on the slices where it actually agrees. Re-calibrate when the task shifts — a judge tuned
on one distribution silently degrades on another. Method from Hamel Husain's `validate-evaluator`
(source: `SOURCES.md#judge-calibration`).

## The trust-then-verify gap (named failure mode)
The common failure: a plausible-looking implementation that doesn't handle an edge case
or doesn't actually work end-to-end. Counter it: always provide a verification path, and
test as a real user would (run it, click it, hit the endpoint). If you can't verify it,
don't ship it.

## Maker ≠ checker
The agent that wrote the change should not be the sole judge of it. For non-trivial work,
have a fresh-context reviewer verify (see Bob the verifier). The writer is too forgiving
of its own work.

## Cite or retract (generation time, not review time)
Every factual claim about code or data carries its evidence inline: a `file:line`, a
quoted line, or the command whose output you are reporting. If a re-check finds no
support for a claim you already made, retract it — do not soften it into a hedge and
leave it standing. This is the upstream half of "evidence over assertion" above: that
rule governs claiming *done*, this one governs every claim on the way there.
Scope it to non-obvious claims; citing that a file exists is noise.

## Say "I don't know" out loud
When context or evidence is insufficient, say "insufficient information to confirm"
and name what would settle it. An abstention is a usable answer; a confident guess
sends the reader down a path that costs more to unwind than the question was worth.
(Source: `SOURCES.md#abstention-and-citation`.)

## Hooks back this up — but hooks are not a guarantee
- `guard-secrets.sh` (PreToolUse) blocks writes to secret files deterministically.
- `post-edit-format.sh` (PostToolUse) auto-formats edited files when a formatter exists.
- `stop-verify.sh` (Stop, opt-in) can block turn-end until a project check passes.

Hooks are **best-effort automation, not an enforcement boundary.** They can fail to
fire — matcher misses, timeouts, a path the pattern didn't anticipate. For anything
that must *never* happen, use the permission system, which is the actual allow/deny
gate; use hooks for the things you want to happen automatically without remembering.
A hook meant to block must `exit 2` — any other non-zero code is treated as
non-blocking and the action proceeds. (Source: `SOURCES.md#hooks-are-advisory`.)
