# System Invariants — claude-practices

> Durable contracts that must ALWAYS hold. Unlike HANDOFF.md (last session), this is
> the standing list of things a later session must not break. Loaded in full at every
> session start. When you touch an area an invariant constrains, re-verify it before
> writing HANDOFF — with evidence, not assertion.
>
> Status: `✅ holds` (verified) · `⚠ unverified` (newly added, not yet proven) · `❌ broken` (known regression)

The kit did not eat its own dog food until Wave 7 — it shipped `templates/INVARIANTS.md`
for other projects while keeping none itself. These four were chosen because each is
cheaply checkable and each is something a doctrine wave could plausibly break.

| ID | Invariant (plain language) | Area it constrains | How to verify | Status |
|----|----------------------------|--------------------|---------------|--------|
| INV-01 | Both installers are idempotent, and a dry run writes nothing. | `install.sh` / `install.ps1` | `./install.sh --dry-run && git status --porcelain \| wc -l` → `0` | ⚠ unverified |
| INV-02 | Every file in `hooks/` is installed, and every hook referenced by settings or agent frontmatter exists in `hooks/`. | hooks ↔ settings wiring | `bash scripts/verify-hooks.sh` → `HOOK PARITY OK`, exit 0 | ⚠ unverified |
| INV-03 | No secret-shaped string is committed. | whole repo | `pre-commit run --all-files` (gitleaks) → pass | ⚠ unverified |
| INV-04 | Every platform limit number quoted in shipped doctrine has a dated entry in `SOURCES.md`. | `templates/.claude/rules/*`, `templates/.claude/agents/*`, `global-rules/*` | `bash scripts/verify-sources.sh` → `CITATIONS OK`, exit 0 | ⚠ unverified |

## Notes
- Add an invariant the moment a cross-cutting contract is established (auth, data integrity, perf budget, external API shape).
- Number monotonically (INV-01, INV-02…); never reuse an ID.
- If an invariant is intentionally retired, strike it through and note why — don't delete the row.
- INV-04 is the machine-checkable form of the kit's sourcing discipline: a claim without a
  dated primary source does not ship. It is what stops Wave 5's standard from decaying into
  a slogan.
