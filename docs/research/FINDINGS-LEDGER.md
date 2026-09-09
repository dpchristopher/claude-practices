# Findings Ledger — capability research, opened 2026-09-08

> Every finding from the research phases lands here with a bucket and a status.
> Per the brief's Part 6: a finding with no destination is not a finding.
> Detail lives in the per-phase files; this is the index you act from.

**Buckets:** `DOCTRINE` (rule added/corrected/retired) · `CONFIG` (hook, permission, setting,
plugin) · `BUILD` (make something) · `DISCARD` (with reason, so it is not rediscovered)

**Status:** `OPEN` · `VERIFIED` (checked locally, claim holds) · `REFUTED` (checked, claim
false) · `DONE` · `DROPPED`

---

## Verified during Phase 1 — no action needed

These were flagged as risks by the Phase 1b agent and checked locally the same session.
Recording them because a *refuted* finding is worth as much as a confirmed one — it stops
the same alarm being raised next month.

| # | Finding | Verdict | Evidence |
|---|---|---|---|
| V1 | Stop/SubagentStop use `decision: approve\|block`, not `permissionDecision` — a silent no-op if mixed up ([#issues](docs/research/phase1b-community-and-issues.md)) | **REFUTED for this kit** | `stop-verify.sh:11` and `guard-verdict.sh:30` emit no JSON at all; both use `exit 2` + stderr, the documented mechanism for those events. Schema mismatch cannot occur. |
| V2 | SessionEnd hooks are killed before async work finishes (#41577) | **REFUTED for this kit** | `session-metrics-stub.sh` runs `date`, `ls`, `grep`, and one append. Synchronous, no network, milliseconds. The issue concerns non-trivial async work. |

---

## Open findings

### From Phase 1b — community and GitHub issues
*Source: `phase1b-community-and-issues.md`*

| # | Finding | Bucket | Status | Note |
|---|---|---|---|---|
| B1 | `${CLAUDE_PLUGIN_ROOT}` backslash-path bug on Windows, **confirmed against the superpowers plugin by name** | CONFIG | OPEN | Daniel runs superpowers. Unknown whether it is actually degraded for him — needs a local check, not a doc read. |
| B2 | Subagent-originated `SendMessage` broken/inconsistent — 5+ open or duplicate issues | DOCTRINE | OPEN | Confirms this session's finding independently. The `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` flag set tonight gets main-session→subagent only. Set expectations in doctrine rather than assuming the flag fixed it. |
| B3 | `karanb192/claude-code-hooks` ships hook-tier `protect-secrets`, `instructions-audit`, `config-guard`, `dead-end-registry`, `nerf-receipts` | CONFIG | OPEN | Directly on the "push doctrine down a tier" thesis — several are hook-tier versions of things this kit does at rule-tier or by hand. Someone else already built them. |
| B4 | `disler/claude-code-hooks-mastery` — full 13-hook lifecycle, PostToolUse quality gate, PreCompact backup | BUILD | OPEN | The kit wires 8 of ~13 available events. PreCompact is unused entirely. |
| B5 | PreCompact→SessionStart context-handoff pattern, 3 independent implementations | BUILD | OPEN | Mechanized version of what `HANDOFF.md` does by hand. Would survive compaction automatically. |
| B6 | `zircote/claude-team-orchestration` — 7 named agent-team patterns | DOCTRINE | OPEN | Compare against this kit's own agent roster and handoff rules. |
| B7 | Prompt-injection scanning for client-supplied documents | BUILD | OPEN | **Both clients will feed in external content** (travel agency documents, nonprofit files). Nothing currently scans them. |
| B8 | Windows/Git-Bash hook path fix via a `cygpath` wrapper | CONFIG | OPEN | This session hit Windows path breakage twice in Python one-liners. |
| B9 | Cluster of Claude Code Desktop-on-Windows bugs through 2026 (exit code 1, ECONNRESET, ENAMETOOLONG, GPU crash) | DISCARD? | OPEN | Awareness only unless one is actually being hit. |
| B10 | PreToolUse `exit 2` may cause Claude to stop rather than self-correct (#24327) | DOCTRINE | OPEN | Affects `guard-secrets.sh` and `guard-agent-ownership.sh`, which both block with `exit 2`. Agent marked the HN corroboration a user claim, not verified. Needs a primary check. |
| B11 | "2026 source-code leak" blog claims (voice mode, daemon mode, hidden flags) | **DISCARD** | DONE | Excluded by the agent per the citation rules — uncorroborated by any issue or maintainer statement. Recorded so it is not re-surfaced. |

### From the changelog index (pre-read, needs confirmation from Phase 1a)

| # | Finding | Bucket | Status | Note |
|---|---|---|---|---|
| C1 | Week 22 shipped **dynamic workflows** — "orchestrate dozens to hundreds of subagents from a script Claude writes" | DOCTRINE | OPEN | `loop-cost-discipline.md` caps ad-hoc fan-out at 3–4 and says larger goes through the Workflow tool. That rule may predate the feature existing. |
| C2 | Week 21 shipped **`/usage`** — limits broken down by skill, subagent, plugin, MCP server | CONFIG | OPEN | Plausibly the measurement instrument the GC pass is missing. The hand-written metrics log has 11 rows; this is real usage data. |

---

## Phases outstanding

- **1a** Anthropic changelog sweep → `phase1a-anthropic-changelog.md` *(running)*
- **1c** Rules still-true audit → `phase1c-rules-still-true.md` *(running)*
- **1d** GC inventory → `phase1d-gc-inventory.md` *(running)*
- **2** Local models on this hardware — not started
- **3** Named practitioners — not started
- **3b** Anduril / edge AI — not started
- **4** Academic — not started
- **5** Client-facing — not started

---

## Process note

Findings are **documented, not acted on**, until every phase lands. Daniel's call: go through
them one by one afterward. Resist fixing things mid-sweep — a finding acted on before its
phase completes cannot be weighed against the ones still coming.
