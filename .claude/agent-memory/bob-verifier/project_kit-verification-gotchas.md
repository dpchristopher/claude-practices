---
name: kit-verification-gotchas
description: Where this kit's own self-verification is weaker than it claims — INV-04's file-level citation check, INV-02's half-check, and the per-wave line-growth gate
metadata:
  type: project
---

The kit's verifier scripts pass more easily than their invariant text implies. Check the substance,
not just the exit code.

- **`scripts/verify-sources.sh` (INV-04) is file-level, not claim-level.** Once a file contains any
  `SOURCES.md` string, every limit number in it passes. Wave 7 shipped `loop.md`'s "25 agents",
  "~1.5M projected tokens", and "8 consecutive blocks" with no ledger entry, and the script still
  printed `CITATIONS OK`. Always diff the numbers quoted in doctrine against `SOURCES.md` by hand.
- **`scripts/verify-hooks.sh` (INV-02) checks only referenced→exists and .sh/.ps1 pairing.** It does
  not check INV-02's first clause ("every file in `hooks/` is installed"). That clause holds because
  both installers glob `hooks/*`, but the script is not what proves it.
- **Arithmetic-check any percentage table.** Wave 7's `SOURCES.md#mast` FC2/FC3 category headers
  equal the sums of their listed modes; FC1's does not (43.8 vs 44.2 itemized) — which surfaced a
  bad "correction" no script could catch.
- **`kit-maintenance.md` carries a per-wave growth aim (≤ +30 lines across `global-rules/` +
  unconditional `templates/.claude/rules/`).** Compute it yourself: `wc -l` HEAD vs `git show
  master:<file>`, and remember `global-rules/` files also exist live in `~/.claude/rules/`, so the
  honest baseline is the live copy, not zero.

**Why:** these are the checks that give a doctrine wave its "verified" feeling; if I trust the exit
codes I inherit their blind spots.

**How to apply:** on any wave touching rules, agents, or `SOURCES.md`, run the scripts *and* do the
three manual checks above. See [[verify-before-claiming]] for the discipline on not over-reporting.
