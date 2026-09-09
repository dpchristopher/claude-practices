# HANDOFF — 2026-09-08 (kit repair + full capability sweep)

## State
v1.8.1 · master clean and pushed · `bash scripts/verify-kit.sh` → 41/41.

## Part 1 — Kit repair (all merged: PRs #5, #6, #7, #8, #9, #12)
- **Wave 9** corrected a wrong claim the kit had shipped for months: "hooks are enforced."
  Hooks are best-effort; the **permission system** is the hard gate. Swept from three live files.
- **INV-02 was structurally blind** — compared repo files to each other, never read the deployed
  config, so it reported green while 8 hooks fired nowhere. Fixed; went red with 5 named
  failures, then green after wiring.
- **8 hooks wired**, 7 deny rules added (0 before), `stop-verify` gating all 5 projects,
  `output-accuracy.md` loading globally, `C:\Clients` made a repo with shared client doctrine,
  off-disk backup taken.
- **`guard-fanout` counted the wrong thing** — session-lifetime, not concurrency. Fixed to a
  rolling window. It had gated every dispatch after 4 for hours, and presented as "bypass
  permissions is broken."

## Part 2 — Capability sweep (all 5 phases landed; see `docs/research/`)
`FINDINGS-LEDGER.md` is the index. ~45 findings, each with a bucket and status.
**Nothing has been acted on. Daniel's call: go through them one by one.**

Highest-value, all verified:
1. **INV-01 and INV-04 cannot fail.** INV-04 was mutation-tested — a fabricated statistic
   injected into a rule file still passed. INV-01 runs `git status` in the repo while
   `install.sh` writes to `~/.claude`, so this session's stamped verification of it was
   meaningless.
2. **The GSD apparatus has never been used once** — 68 skills, 24 agents, 9 hooks, zero
   `.planning/` dirs, zero dispatches. Those 9 hooks fire on every tool call regardless.
3. **Two hooks record only garbage** — 89 of 89 lines read `agent=unknown`.
4. **Auto Mode's classifier is not a hard gate.** Anthropic said so after a demonstrated ~80%
   bypass. Contradicts `docs/mechanizing-doctrine.md`, written this same session.
5. **Local models: RAM was never the constraint.** Chip-matched benchmark — 7B at 19.2 tok/s,
   27B at 3.5–4.3. A 3B→27B jump is ~18–20× slower per call, not 8× more capable.
6. **Client work on a personal Pro/Max account has no DPA.** Bears on the Betsey engagement.
7. **Claude for Nonprofits: $8/user/month, 2-seat minimum** — and Team is the tier with a DPA,
   so cheap and compliant coincide for The Caregiver Club.

## Blockers / didn't work
- **Four agent self-reports failed verification**, including one reporting an edit it never made
  and one whose 3 of 7 highest-severity findings were wrong — two of which would have caused
  actively harmful fixes. Phase 4 then found four independent papers predicting exactly this.
- **The Phase 5 agent returned a delegation as its deliverable** — spawned 4 children, reported
  intent as completion, terminated, orphaning them. Salvaged manually. `guard-fanout` did not
  catch it: the brake sits at the wrong layer to stop a *child* fanning out.
- **Reddit and Facebook groups were unreachable by every agent in every phase.** The sweep
  systematically under-samples the most candid practitioner sources.

## Next action (priority 1)
Work through `FINDINGS-LEDGER.md` one by one with Daniel. Start with the four that are both
verified and load-bearing: INV-01/INV-04 being unfailable, the GSD hooks, the two garbage-logging
hooks, and the Auto Mode tier correction.

## Open
- **Daniel's question, logged and unresearched:** if RAM is not the local-model constraint, what
  is 63 GB actually for? Three hypotheses recorded; needs local benchmarking, not web research.
- Restart Claude Code for `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` (SendMessage).
- Confirm a new metrics row appears after this session closes — proves the SessionEnd hook fires.
- Make the sweep recur monthly. Cut phase 3b; narrow phase 5.
- **Do not raise API key rotation.** Declined repeatedly; considered closed.
