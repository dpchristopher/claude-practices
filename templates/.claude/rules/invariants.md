# Invariants Rule

> Auto-loaded at session start. Governs the system invariant ledger (`INVARIANTS.md`).

## What INVARIANTS.md is
A durable list of contracts that must always hold across sessions. HANDOFF.md says what
happened last session; INVARIANTS.md says what must never break. The SessionStart hook
loads it in full.

## When to ADD an invariant
The moment a cross-cutting contract is established: authentication/authorization, data
integrity guarantees, performance budgets, the shape of an external API you depend on,
or any behavior whose breakage would not be obvious from a local diff. Seed it as
`⚠ unverified` until you have proven it once.

## When to RE-VERIFY invariants
Before writing HANDOFF at session end, identify which invariants the session's work
*could* have affected and re-verify them — running the "How to verify" command and
pasting the result. Evidence over assertion. Flip status to `✅ holds` or `❌ broken`.

## Hard line
A session that touched an invariant's area and did NOT re-verify it is not done.
Never mark work complete on top of an unverified invariant you may have disturbed.
