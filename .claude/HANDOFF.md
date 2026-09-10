# HANDOFF — 2026-09-09 (Tiers 1–5 closed)

## State
v1.8.1 · master clean and pushed · `bash scripts/verify-kit.sh` → **42/42**
PRs merged this session: #13, #14, #15, #16, #17

## Completed — all five tiers of the capability sweep are closed

**Tier 1 — things that ran and did nothing.** Three invariants could not fail and are now
mutation-proven (INV-04 couldn't detect a fabricated statistic; INV-01 watched the repo while
the installer wrote to `~/.claude`; INV-02 never checked exists→referenced). Fixing them
immediately surfaced two genuinely uncited numbers in shipped doctrine and the fact that the
template never shipped `guard-fanout.sh`. **8 GSD hooks removed** — measured at 859ms per
invocation on a matcher covering effectively every tool call, all self-gating on a `.planning/`
dir that exists nowhere: ~1s per Bash call, ~3.5s per Write/Edit recovered. Two hooks that
logged 89 lines of `agent=unknown` now work and self-diagnose.

**Tier 2 — doctrine that was wrong.** The tier model conflated static `deny` rules (genuinely
hard) with Auto Mode's classifier (best-effort, per Anthropic after a demonstrated ~80% bypass).
The fan-out rule was wrong in both halves: the 3–4 cap was unevidenced and gated correct work
twice, and "breadth not depth" was backwards. Replaced with structure-over-headcount, a
depth/artifact requirement, and verification capacity as the real ceiling.

**Tier 3 — client-facing.** Discussed, little actioned by choice. The DPA question dissolved:
there is no written agreement with Betsey, so no confidentiality term to be inconsistent with.
Daniel declined to pay for a Team seat.

**Tier 4/5 — adopted four, deferred the rest with reasons.** `usage-report.sh` (first real usage
data this kit has had), `precompact-handoff.sh` (wired), `file-sweep.sh`, cross-model review in
`output-accuracy.md`, and the first skill-overlap audit run on data rather than guesses.

**Created the two files the session protocol had been pointing at for months:**
`META_ARCHITECTURE.md` and a project `CLAUDE.md`.

## Blockers / didn't work
- **Two of seven Tier 2 "wrong doctrine" findings were Claude's errors, not the kit's** — nesting
  depth was already correct; the `local-models` skill never made a hardware claim.
- The first `verify-install.sh` had the exact blindness it was written to fix; caught only by
  mutation-testing the fix.
- A `python3` heredoc silently did nothing while its commit still succeeded. A commit message
  claimed 53 lines for a 77-line file.
- `/usage` cannot be run from a non-interactive session and its data is not on disk.

## Next action (priority 1)
**Decide the session-protocol question.** `session-workflow` fired in 9 of 39 measured sessions,
`superpowers:brainstorming` in 6, against a rule saying *"Both. That order. Every session."*
Half the gap was missing files, now fixed. The rest is four genuinely skipped steps: naming the
session, `/code-review`, the Feynman gate, and the `[session-name]:` commit format — and Claude
argues that last one is worse than conventional commits. This is a tier-demotion question (a
SessionStart hook), not a wording one.

## Test state
42/42 on `verify-kit.sh`. All four invariants mutation-tested this session. Gitleaks passed on
every commit.

## Open / carried forward
- `docs/research/FINDINGS-LEDGER.md` — Tier 3's unactioned items, 13 recorded discards
- `docs/research/QUEUED-QUESTIONS.md` — npm answered; Q-2 (public repo description mismatch) and
  Q-3 (should the tool-vetting method become doctrine) still open
- **The "40% context budget" figure has no source** and Daniel has said he does not want it.
  It is not in the repo; if it appears in any public description, that should change.
- Make the capability sweep recur monthly. Cut phase 3b; narrow phase 5.
- Four skills and the GSD apparatus sit at zero measured invocations. Frequency is not value —
  but `mcp-builder`/`mcp-developer` are deprecated with a 2026-12 removal date.
- **Do not raise API key rotation.** Declined repeatedly; closed.
