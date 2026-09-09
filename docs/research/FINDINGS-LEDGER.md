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

### From Phase 1c — rules still-true audit (Bob, opus)
*Source: `phase1c-rules-still-true.md`. Bob returned 7 FALSE / 4 STALE / 5 UNVERIFIABLE / 3 VACUOUS.*

**Verified as REAL — the two mutation-tested findings are the strongest work of the night:**

| # | Finding | Bucket | Status | Note |
|---|---|---|---|---|
| R1 | **INV-04 cannot fail on the files that matter.** `verify-sources.sh:42` is a file-level `grep -q "SOURCES\.md"`. Bob mutation-tested it: injected *"99 concurrent agents and 4 levels deep"* into `loop.md` → `CITATIONS OK`, exit 0. Four of five files quoting limits already carry a pointer, so they are green by construction. | CONFIG | OPEN | **Wave 8's and Wave 9's fabricated stats would not have been caught by this.** The invariant that exists to enforce sourcing discipline cannot detect a fabricated number. |
| R2 | **INV-01 watches the wrong directory.** `install.sh:13` sets `DEST="$HOME/.claude"`; the check runs `git status --porcelain` *in the repo*, which cannot see `~/.claude`. A dry run that copied every file would still print `0`. `wc -l` also swallows the exit code. | CONFIG | OPEN | This session "verified" INV-01 from a clean tree and stamped it with evidence. **That verification was meaningless** — same defect class as INV-02. |
| R3 | **INV-02's first clause is checked by nothing.** Mutation: add a hook wired nowhere → `HOOK PARITY OK`. | CONFIG | OPEN | The deployment-parity direction added this session genuinely fails on mutation; the *original* direction still does not. |
| R4 | `automation.md:11` and `ml-discipline.md:11` claim "Auto-loaded at session start" while their own frontmatter is `paths:`-scoped. | DOCTRINE | OPEN | Consequence: Wave 9's hooks correction at `automation.md:96-112` only loads when someone edits a `pipeline*.py`. |
| R5 | `bob-verifier.md:50` cites `SOURCES.md#subagent-limits` for a breadth cap, but the only `3` in that anchor is **nesting depth**. | DOCTRINE | OPEN | The exact breadth/depth conflation `SOURCES.md:45-46` names as a pre-Wave-7 defect. Dave and the global rule cite `#workflow-limits` correctly. |
| R6 | **All 13 `templates/.claude/rules/*.md` load in zero projects.** Four of five projects have no `.claude/rules/`; Civ_Project has three project-local files instead. | DOCTRINE | OPEN | Independently confirmed earlier this session. **The kit's own repo does not load its own rules** — which is why R4, and a reference to a deleted `surgical/compare.py`, survived. |

**REFUTED — Bob was wrong; do not act on these:**

| # | Bob's claim | Verdict | Evidence |
|---|---|---|---|
| X1 | F3: `/code-review` does not exist; a session-end step silently failing open | **REFUTED** | It exists and is available this session. Bob searched the kit skills dir and the enabled-plugins list and missed it. |
| X2 | F4: `/superpowers:brainstorming` is a deprecated no-op | **REFUTED** | `skills/brainstorming/` is real. The deprecated one is `brainstorm`, a different command. CLAUDE.md references the correct one. **Acting on this fix would have pointed the session protocol at the no-op.** |
| X3 | F7: `guard-readonly-bash.sh` is a live orphan, wired in no settings.json | **REFUTED** | Not an orphan — invoked via `hooks:` in Kevin/Mel/Carl frontmatter. Deliberately not wired globally: it blocks `rm`, `git commit`, `pip install`. |
| X4 | Bob's self-declared **highest-priority** risk: agent-frontmatter `hooks:` may not be honoured, leaving Kevin/Mel/Carl unguarded | **REFUTED** | [Subagent docs](https://code.claude.com/docs/en/sub-agents) list `hooks` as a supported frontmatter field. These agents live in `~/.claude/agents/` (user-level), so it applies. Only *plugin* agents ignore it. |

**Meta-finding:** Bob got **3 of 7 FALSE findings wrong**, plus his top-priority open question, and two of those errors would have caused actively harmful fixes. Third instance tonight of a confident agent claim failing verification. Direct evidence for `output-accuracy.md`'s distrust-agent-self-reports rule, and an argument that fan-out width should be bounded by **verification capacity**, not token cost.

### From Phase 1d — GC inventory
*Source: `phase1d-gc-inventory.md`. Built its evidence from the transcript corpus rather than the 11-row metrics log — strongest methodology of the four.*

| # | Finding | Bucket | Status | Note |
|---|---|---|---|---|
| G1 | **GSD apparatus: 68 skills, 24 agents, 9 hooks — zero usage ever.** No `.planning/` dirs anywhere, zero real `gsd-*` dispatches, zero genuine `/gsd-*` invocations, 8 versions stale. | CONFIG | OPEN | Agent's split recommendation: keep skills/agents (free at rest, preserves optionality) but **the 9 hooks fire on every tool call globally** regardless of GSD use. Real ongoing cost, zero payoff. |
| G2 | **`subagent-audit.sh` and `log-instructions-loaded.sh` fire correctly but record nothing usable.** | CONFIG | **VERIFIED** | Checked locally: all 89 lines of `Civ_Project/.claude/orchestration-log.txt` read `agent=unknown` or `loaded=(none captured)`. Field-extraction regexes never match the real payload shape. New variant of tonight's pattern — connected, but recording garbage. |
| G3 | `session-context.ps1` is referenced by no settings.json anywhere | CONFIG | OPEN | Genuine orphan, unlike X3. |
| G4 | Merge candidates with quoted overlapping triggers: `mcp-builder` / `mcp-developer` / `mcp-server-dev`; `the-fool` / `socratic-examiner`; three session-record mechanisms; a `frontend-design` name collision between kit and plugin | DOCTRINE | OPEN | |
| G5 | Confirmed **real** usage: `superpowers`, `playwright` (actual browser tool_use calls), `session-workflow`, `daniel-context`. Confirmed broken: `github` plugin. | — | OPEN | First evidence-based usage data the kit has ever had. |
| G6 | The transcript corpus (`~/.claude/projects/*/**.jsonl`) is a far better usage instrument than the hand-written log | BUILD | OPEN | Answers the brief's "what signal would we need" question. |

### From Phase 1a — Anthropic changelog sweep
*Source: `phase1a-anthropic-changelog.md`. 15 weekly digests (w19–w30, w32–w34) plus engineering blog. 12 unused capabilities against a bar of 5.*

| # | Finding | Bucket | Status | Note |
|---|---|---|---|---|
| A1 | **Subagent nesting default dropped from 5 layers to 3** (`CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH`); 5 was the default only May–Aug (v2.1.172–216) | DOCTRINE | **VERIFIED** | The agent caught a stale figure **in this session's own dispatch prompt**, copied from the w24 headline. Exactly the drift this sweep exists to catch, found inside the sweep's own input. |
| A2 | `TaskCreate`/`TaskUpdate`/`TodoWrite` are removed by default on Opus 4.8, Sonnet 5 and later. Hooks matching them would fire zero times. | CONFIG | **REFUTED for this kit** | Checked locally: no hook in `~/.claude/settings.json`, `~/.claude/hooks/`, or any project settings matches those tools. Risk does not apply. |
| A3 | **Auto mode became the Pro/Max/Team default on 2026-08-14** | CONFIG | OPEN | Worth confirming what mode Desktop sessions actually start in now. Interacts with tonight's `guard-fanout` diagnosis, where an `ask` decision is not auto-approved in any mode. |
| A4 | 12 unused capabilities documented in the phase file | mixed | OPEN | Full table in `phase1a-anthropic-changelog.md`; work through it in the one-by-one pass. |
| A5 | Claude Managed Agents "dreaming/outcomes" claim | DISCARD | DONE | Direct fetch 404'd; sourced only from a search snippet. Flagged **not independently verified** per the standing rules rather than carried. |

### From Phase 3b - Anduril / edge AI

*Source: `phase3b-anduril-edge-ai.md`. The bar was a plain yes/no on transfer.*

**Verdict: MOSTLY NO.** Anduril and Palmer Luckey publish heavily, but it is product
marketing, recruiting, and geopolitics. Nothing discloses model sizes, quantization,
latency budgets, or a verification methodology for high-stakes AI - the exact things
this phase existed to find.

| # | Finding | Bucket | Status | Note |
|---|---|---|---|---|
| D1 | Anduril public GitHub: 17 repos, Lattice SDKs in six languages plus sample apps. No ML code, no weights, no benchmarks. | DISCARD | DONE | Integration tooling, not AI engineering. |
| D2 | Palmer's essays and interviews (Free Press, Axios, Fortune, 60 Minutes) carry one technical claim: "all Anduril's weapons have a kill switch." No testing protocols, error rates, or safety methodology. | DISCARD | DONE | Confirmed by direct read of the transcript. |
| D3 | `sample-app-auto-reconnaissance` splits sensed data (Entities API, read-only) from commandable actions (Tasks API, interruptible and visible to an operator) | DOCTRINE | OPEN | The one genuine verifiable pattern found - and on inspection it **confirms a design this kit already has**: hooks returning `ask` as a visible, interruptible checkpoint. Convergent evidence, not a new idea. |
| D4 | No individually-publishing Anduril engineers found despite several search angles | - | OPEN | A gap in the search, not proof none exist. Worth one recheck in a future sweep. |
| D5 | Two sources (Medium-hosted Anduril post, Forbes on Palantir/Anduril offline AI) returned HTTP 403 | - | OPEN | Marked not-verified per the citation rule rather than cited from snippets. |

**Phase verdict for the recurring sweep: CUT.** A full agent returned one pattern the kit
already implements. Recording the negative result so next month does not re-run it on the
same hope.

### From the changelog index (pre-read, now confirmed by Phase 1a)

| # | Finding | Bucket | Status | Note |
|---|---|---|---|---|
| C1 | Week 22 shipped **dynamic workflows** — "orchestrate dozens to hundreds of subagents from a script Claude writes" | DOCTRINE | OPEN | `loop-cost-discipline.md` caps ad-hoc fan-out at 3–4 and says larger goes through the Workflow tool. That rule may predate the feature existing. |
| C2 | Week 21 shipped **`/usage`** — limits broken down by skill, subagent, plugin, MCP server | CONFIG | OPEN | Plausibly the measurement instrument the GC pass is missing. The hand-written metrics log has 11 rows; this is real usage data. |

---

## Phases outstanding

- **1a** Anthropic changelog sweep → `phase1a-anthropic-changelog.md` — LANDED

**PHASE 1 COMPLETE.** 4 of 4 agents landed. 30 findings indexed; 6 already closed by local verification (2 confirmed, 4 refuted).
- **1c** Rules still-true audit → `phase1c-rules-still-true.md` — LANDED
- **1d** GC inventory → `phase1d-gc-inventory.md` — LANDED
- **2** Local models on this hardware — not started
- **3** Named practitioners — not started
- **3b** Anduril / edge AI — LANDED (verdict: mostly no; cut from future sweeps)
- **4** Academic — not started
- **5** Client-facing — not started

---

## Process note

Findings are **documented, not acted on**, until every phase lands. Daniel's call: go through
them one by one afterward. Resist fixing things mid-sweep — a finding acted on before its
phase completes cannot be weighed against the ones still coming.
