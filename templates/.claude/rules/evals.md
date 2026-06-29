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

## The data flywheel
Operational failures feed back into the eval set over time (annotate → feed back → review
→ improve). The eval set is a living asset, not a one-time gate.

## Tooling (optional)
Opik (`@opik.track` tracing, LLM-as-judge metrics, PyTest integration) is a reasonable
local stack if you want instrumentation — but the discipline above matters more than the tool.
