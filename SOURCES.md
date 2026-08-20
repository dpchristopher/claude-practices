# Sources

Every platform limit number and research claim quoted in shipped doctrine traces to a dated
primary source here. Rules reference this file by anchor — `(source: SOURCES.md#subagent-limits)` —
rather than carrying URLs inline, because the always-loaded layer is on a hard line budget.

`scripts/verify-sources.sh` enforces this (INV-04): a limit number in doctrine with no pointer
fails the check.

**The standard, set in Wave 5 and held since:** a claim resting only on secondary or aggregator
sourcing does not ship. Verify against official docs or the primary paper, or leave it out.

---

## subagent-limits

Verified 2026-08-19 against `code.claude.com/docs/en/sub-agents`.

| Claim | Value | Control | Source |
|---|---|---|---|
| Concurrent subagent limit | 20 | `CLAUDE_CODE_MAX_CONCURRENT_SUBAGENTS` | [sub-agents docs](https://code.claude.com/docs/en/sub-agents) |
| Total subagents per session | **no limit** | — | same |
| Nesting depth default | 3 (was up to 5, unchangeable, in v2.1.172–216) | `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH`, default since v2.1.219 | same |
| Fork mode default | on in interactive sessions (v2.1.232+), off in headless/SDK | `CLAUDE_CODE_FORK_SUBAGENT` | same |
| Fork inherits | full conversation, system prompt, tools, model; **shares the prompt cache** | — | same |

**Debunked, recorded so it does not resurface:** the widely repeated claim that "the
200-subagent-per-session cap was removed" is false. There was never a 200 cap. The real
concurrent default is 20, and there is no total-lifetime cap. Traced to aggregator blogs,
contradicted by the official docs.

## workflow-limits

Verified 2026-08-19 against the `Workflow` tool's own specification.

| Claim | Value |
|---|---|
| Concurrent agents per workflow | 16 |
| Total agents per workflow run | 1,000 |
| Max items per `parallel()` / `pipeline()` call | 4,096 |
| "Large workflow" warning threshold | past 25 agents or ~1.5M projected tokens |
| Stop-hook loop force-end | after 8 consecutive blocks |
| Dynamic workflow size guideline (`/config`) | `small` <5, `medium` <15, `large` <50 agents |

These govern **the Workflow tool only** — not ad hoc `Agent` dispatch, which is bound by the
subagent limits above. Conflating the two was a real defect in the kit before Wave 7.

## cross-session

| Claim | Value | Source |
|---|---|---|
| Cross-session messaging shipped | 2026-08-07 | Claude Code changelog |
| Mechanism | `mcp__ccd_session_mgmt__send_message`, `list_sessions`, `@`-mention | tool specification, verified in-session 2026-08-19 |
| Payload | plain text only — never conversation history, never files | same |

## automation-surfaces

| Surface | Durability | Source |
|---|---|---|
| `CronCreate` | session-only, in-memory, 7-day auto-expire | tool specification, verified 2026-08-19 |
| Claude Code Routines | durable cloud, survives machine offline; schedule / API / GitHub webhook; Pro 5, Max 15, Team+Enterprise 25 runs per day | [Introducing routines in Claude Code](https://claude.com/blog/introducing-routines-in-claude-code), 2026-04-14 |

Routines launched **before** Wave 5 (2026-07-13) and were missed at the time — a gap in the
kit's own coverage, not a new platform feature. The full four-surface taxonomy is deferred to
Wave 8.

---

## mast

**Why Do Multi-Agent LLM Systems Fail?** — Cemri, Pan, Yang, Agrawal, Chopra, Tiwari, Keutzer,
Parameswaran, Klein, Ramchandran, Zaharia, Gonzalez, Stoica. UC Berkeley (one author at Intesa
Sanpaolo). [arXiv:2503.13657](https://arxiv.org/abs/2503.13657).

**Verified 2026-08-19 against the paper's HTML full text (v3).** The arXiv abstract page and the
project's GitHub README do not carry the taxonomy; two percentages circulating in secondary
summaries were wrong and are corrected below.

**Method:** 1,642 annotated execution traces across 7 multi-agent frameworks, six expert
annotators, Cohen's κ = 0.88.

### The taxonomy — 14 modes, 3 categories

| Category | Mode | % |
|---|---|---|
| **FC1. System design issues — see note** | FM-1.1 Disobey task specification | 11.8% |
| | FM-1.2 Disobey role specification | 1.5% |
| | FM-1.3 Step repetition | 15.7% |
| | FM-1.4 Loss of conversation history | 2.80% |
| | FM-1.5 Unaware of termination conditions | 12.4% |
| **FC2. Inter-agent misalignment — 32.35%** | FM-2.1 Conversation reset | 2.20% |
| | FM-2.2 Fail to ask for clarification | 6.80% |
| | FM-2.3 Task derailment | 7.40% |
| | FM-2.4 Information withholding | 0.85% |
| | FM-2.5 Ignored other agent's input | 1.90% |
| | FM-2.6 Reasoning-action mismatch | 13.2% |
| **FC3. Task verification — 23.5%** | FM-3.1 Premature termination | 6.20% |
| | FM-3.2 No or incomplete verification | 8.20% |
| | FM-3.3 Incorrect verification | 9.10% |

### Corrections made at verification

| Circulating claim | Actual |
|---|---|
| Inter-agent misalignment ~37% | **32.35%** — confirmed, and consistent with its own modes |
| "identified failures require more sophisticated solutions" | not the operative sentence — see verbatim below |

### FC1's category total: withheld, and why

**Do not quote a category percentage for FC1.** Three retrieval attempts produced three
different values: 43.8%, 43.9%, and an arithmetic sum of its own five modes of 44.2%. The
mode-level numbers are stable across independent fetches and are safe to cite; the category
header is not, and the discrepancy is likely a rounding or per-trace-vs-per-failure counting
detail this ledger cannot resolve without reading the figure directly.

Per the sourcing rule: a number that cannot be reliably located does not ship. FC2 (32.35%) and
FC3 (23.5%) *do* reconcile against their own itemizations and are safe.

An earlier draft of this wave claimed "44.2% was wrong, it is 43.8%." **That claim is retracted.**
It was itself under-verified — caught by a fresh-context review, which is exactly the case for
maker≠checker.

### Verbatim conclusion

> "Although first step interventions lead to performance gains, not all failure modes are
> resolved, and task completion rates still remain low, indicating that more substantial
> improvements are needed."

and reliability

> "requires combinatorial changes ranging from agent system organization to model level
> improvements."

This is external evidence for a structural choice the kit already made independently —
`verification.md`'s *"Rules are advisory; hooks are enforced."* Better prompting is a first-step
intervention; the paper measures it as insufficient on its own.

---

## judge-calibration

| Claim | Source |
|---|---|
| Calibrate an LLM judge against human labels before trusting it; treat its output as usable only on slices where it agrees | Hamel Husain and Shreya Shankar, [Evals Skills for Coding Agents](https://hamel.dev/blog/posts/evals-skills/), March 2026 — the `validate-evaluator` skill |

The kit adopts the **method**, not the package. The eight-skill bundle targets LLM product
pipelines (RAG, generative output); the decision to skip it is recorded in
`docs/optional-integrations.md` so a later wave does not re-litigate it.
