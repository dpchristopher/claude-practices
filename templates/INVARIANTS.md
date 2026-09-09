# System Invariants — [Project Name]

> Durable contracts that must ALWAYS hold. Unlike HANDOFF.md (last session), this is
> the standing list of things a later session must not break. Loaded in full at every
> session start. When you touch an area an invariant constrains, re-verify it before
> writing HANDOFF — with evidence, not assertion.
>
> Status: `✅ holds` (verified) · `⚠ unverified` (newly added, not yet proven) · `❌ broken` (known regression)

| ID | Invariant (plain language) | Area it constrains | How to verify | Status |
|----|----------------------------|--------------------|---------------|--------|
| INV-01 | [e.g. OAuth protects all /api/* routes] | [auth layer] | [e.g. `curl -I /api/x` returns 401 unauthenticated] | ⚠ unverified |
| INV-02 | [contract] | [area] | [command/check] | ⚠ unverified |

## Notes
- Add an invariant the moment a cross-cutting contract is established (auth, data integrity, perf budget, external API shape).
- Number monotonically (INV-01, INV-02…); never reuse an ID.
- If an invariant is intentionally retired, strike it through and note why — don't delete the row.
