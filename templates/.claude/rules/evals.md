# Evals Rule

> Auto-loaded at session start. Governs how you judge whether an output (model, ML, or
> agent) is actually good. Pairs with `labarr-ml` for ML work.

## Binary pass/fail, not scores
Judge each output good or bad. Do not use 1–5 or Likert scales — they are harder to act
on and invite fence-sitting. A binary forces a decision and a reason.

## Read traces to saturation
Do error analysis by reading real traces until you stop learning anything new (the rule
is saturation, not a fixed count). Cluster the failures you find; the clusters tell you
what to fix.

## You are the benevolent dictator
As a solo operator you ARE the single domain-expert judge — own the rubric. Don't
outsource the definition of "good" to a generic framework.

## No generic metrics
Don't measure quality with off-the-shelf metrics (BERTScore/ROUGE and friends) — build a
problem-specific check that reflects what actually matters for your task.

## Failures become regression cases
Every confirmed failure becomes a pinned case in an eval set, asserted on future runs so
the same break can't silently return. This is the manual capture-trace → add-to-dataset →
assert-in-CI workflow (not a one-click feature).

### Pinned cases
Applies to the kit's own operational failures, not only model outputs.

**2026-08-19 — uncosted fan-out burn.** A researcher agent got a 4-part question, spawned 5
children with no estimate, consumed the whole session limit, returned nothing. Root cause was
breadth, not depth — the depth limit was never reached. **Assertion: a dispatch with no stated
child count is a fail regardless of output.** Fix lives in `loop-cost-discipline.md` (global)
and the fan-out sections of `dave-researcher.md` / `bob-verifier.md`.

## The data flywheel
Operational failures feed back into the eval set over time (annotate → feed back → review
→ improve). The eval set is a living asset, not a one-time gate.

## Self-generated optimizations need a held-out gate
A self-generated prompt/skill edit (e.g. `skill-creator`'s benchmarking or description
optimization) is a candidate, not an upgrade, until it clears a held-out case set it did not
see while being generated — the same held-out-vs-training split the DSPy/APE line of
prompt-optimization work uses before promoting a candidate (source:
`SOURCES.md#optimization-candidates`). Never auto-promote a generated optimization on its own
self-report; score it against pinned cases the way a model output would be scored.

## Tooling (optional)
Opik (`@opik.track` tracing, LLM-as-judge metrics, PyTest integration) is a reasonable
local stack if you want instrumentation — but the discipline above matters more than the tool.
