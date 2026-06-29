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

## The trust-then-verify gap (named failure mode)
The common failure: a plausible-looking implementation that doesn't handle an edge case
or doesn't actually work end-to-end. Counter it: always provide a verification path, and
test as a real user would (run it, click it, hit the endpoint). If you can't verify it,
don't ship it.

## Maker ≠ checker
The agent that wrote the change should not be the sole judge of it. For non-trivial work,
have a fresh-context reviewer verify (see Bob the verifier). The writer is too forgiving
of its own work.

## Hooks back this up
- `guard-secrets.sh` (PreToolUse) blocks writes to secret files deterministically.
- `post-edit-format.sh` (PostToolUse) auto-formats edited files when a formatter exists.
- `stop-verify.sh` (Stop, opt-in) can block turn-end until a project check passes.
Rules are advisory; hooks are enforced. Use hooks for things that MUST happen.
