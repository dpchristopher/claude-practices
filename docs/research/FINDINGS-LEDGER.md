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

### From Phase 3 - named practitioners

*Source: `phase3-practitioners.md`. Bar was 5 compositions; delivered 9.*

| # | Finding | Bucket | Status | Note |
|---|---|---|---|---|
| P1 | **Auto Mode's permission classifier is NOT a hard gate.** Johann Rehberger demonstrated a ~80%-success attack against it (via Simon Willison 2026-08-27, cross-checked to The Register / GovInfoSecurity / Cybernews). Anthropic stated outright that Auto Mode is *"a best-effort classifier, not a security guarantee."* | DOCTRINE | OPEN - HIGH | **Contradicts `docs/mechanizing-doctrine.md`, written this session.** Its tier 1 says "Permission deny - Claude literally cannot." That holds for *static* deny rules; it does NOT hold for Auto Mode's *dynamic* classifier. The tier model needs an explicit split between the two. This is the same defect shape as the "hooks are enforced" error - a mechanism assumed deterministic that is best-effort. Action: confirm Claude Code Desktop >= 2.1.257. |
| P2 | **Anthropic ships `sandbox-runtime` (srt)** for containing agents | BUILD | OPEN | The "don't reinvent the wheel" answer for isolating client-repo work that touches credentials. Evaluate before building anything bespoke. |
| P3 | **Cross-model adversarial review** - Simon Willison routinely has Claude and GPT review each other's work | DOCTRINE | OPEN | Cheap extension of the kit's distrust-one-agent instinct: across *vendors*, not just across subagents. Tonight produced three cases where a same-vendor agent's confident claim failed verification. |
| P4 | **Two-line file-by-file vulnerability/bug-sweep loop** (Nicholas Carlini's method, via Thomas Ptacek at sockpuppet.org, cross-checked three ways) | BUILD | OPEN | Near-zero-effort periodic sweep for the client repos and Civ_Project. |
| P5 | **obra names the credential / untrusted-content / external-comms triad as UNSOLVED** | DOCTRINE | OPEN | Directly relevant: both clients feed in exactly that kind of external content. **Ledger item B7 should be read as a partial mitigation, not a closed question** - the author of the plugin Daniel runs says the general problem is open. |
| P6 | ghuntley.com unreachable on both attempts (connection reset) | - | OPEN | A genuine gap, not a low-yield result. Retry next month; the expectation of heavy relevant content there is still unconfirmed either way. |
| P7 | Four further compositions in the phase file | mixed | OPEN | See `phase3-practitioners.md` for the full nine. |

### From Phase 2 - local models on this hardware

*Source: `phase2-local-models.md`. Bar was a concrete model+backend recommendation with measured tok/s from a real source. Cleared.*

| # | Finding | Bucket | Status | Note |
|---|---|---|---|---|
| L1 | **Chip-matched benchmark found.** `ggml-org/llama.cpp` discussion #23313 confirms Arc B390 = 12 Xe3 cores, tested June 2026: **7B Q4_0 = 19.2 tok/s; 27B Q4_K_M = 3.55-4.31 tok/s**. | - | **VERIFIED** | Primary source, exact chip. Not an estimate. |
| L2 | **RAM was never the constraint - iGPU compute and bandwidth are.** A 3B -> 27B jump is not "8-10x more capacity," it is an **~18-20x slowdown per call** (2.1s -> ~35-45s). | DOCTRINE | OPEN - HIGH | **Directly refutes what this session told Daniel twice**: that 63.5 GB of RAM meant he was badly underusing the machine. The headroom is real and irrelevant. Correct the framing before acting on it. |
| L3 | **Intel IPEX-LLM is archived (2026-01-28)**, with stated "known security issues" and no further patches | CONFIG | **VERIFIED** | Confirmed on the repo. Remove from consideration entirely. |
| L4 | **Ollama has no official Intel Arc support** (docs.ollama.com/gpu: NVIDIA/AMD/Apple only, plus an unofficial Vulkan fallback) | CONFIG | OPEN | LM Studio, already installed and using Vulkan, remains the right vehicle. |
| L5 | **Foundry Local caps at ~14-20B by design, ONNX-only, no GGUF** | CONFIG | OPEN | Confirmed on Microsoft Learn. It cannot be the vehicle for a 27-32B tier; LM Studio is. |
| L6 | **The NPU is not the speed play.** A GitHub issue on Core Ultra 9 288V shows NPU **54% slower than CPU** for small models. A second comparison shows iGPU beating NPU ~2x on an 8B model. | DOCTRINE | OPEN | Second figure flagged directional, not exact - the primary page 403'd. Contradicts the current setup, which runs phi-4-mini on the NPU. |
| L7 | **Embeddings and reranking are the one clean local win** - CPU-only, no backend fragmentation, vendor-independent | BUILD | OPEN | The clearest actionable item in this phase. |
| L8 | **The `local-models` delegation boundary needs a third tier.** Its task-shape rules (one-step, verifiable, <=8K tokens) hold up; what is missing is a middle tier between "fast local 3-4B" and "Claude." | DOCTRINE | OPEN | Agent deliberately did not fix it - the skill's own rehearsal-ladder discipline requires a measured A/B first. |
| L9 | **There may be no American-lab-compliant dense model in the 27-32B band.** Qwen and Gemma are excluded by the existing American-labs-only rule; gpt-oss-20b is the nearest compliant fit at 20B. | DOCTRINE | OPEN | Resolve before building anything on that tier. The constraint may make the tier unreachable. |

### From Phase 4 - academic literature

*Source: `phase4-academic.md`. Bar was >=1 finding surviving the strict citation rule; delivered 8, all fetched and read at source. The agent dispatched zero children, reasoning that delegating the reading would recreate the exact self-report problem the task was about.*

| # | Finding | Bucket | Status | Note |
|---|---|---|---|---|
| Q1 | **Four independent 2026 papers, four unrelated methodologies, converge: an agent's self-report of success is not evidence, and is often wrong with no adversarial intent.** arXiv 2607.24300, 2606.05976, 2606.28430, 2604.19049 | DOCTRINE | **VERIFIED** | Independent academic confirmation of tonight's lived experience: three subagents produced confident claims that failed local checking, one reporting an edit it never made. `output-accuracy.md`'s distrust rule now has real backing rather than a single anecdote. |
| Q2 | **The citation rule demonstrated itself mid-research.** A WebSearch summary invented a statistic ("80+ agents... ~16%") for arXiv 2604.19049 that a direct fetch of the same paper's abstract shows does not exist - the real figure is 10 reviewers, and no 16% appears anywhere. | DOCTRINE | **VERIFIED** | The sharpest evidence in the sweep for why "an unread abstract is not a source" is a hard rule. Third time this kit has caught a fabricated statistic; first time caught live, in-flight. |
| Q3 | **No paper gives a validated optimal fan-out N, in either direction.** The 3-4 cap is neither contradicted nor numerically supported. | DOCTRINE | **VERIFIED** | Honest null result. The cap remains a judgment call from one incident. |
| Q4 | **Structure beats headcount.** arXiv 2608.18167 and 2607.25656: a 3-agent setup with an explicit adversarial/critic role beat a 5-agent baseline, and naive multi-agent agreement produces a "false-consensus" failure mode. | DOCTRINE | **VERIFIED** | Reframes the fan-out lever from *how many* to *what roles*. A refinement candidate for `loop-cost-discipline.md`, not a contradiction of it. Note this is the same 2608.18167 that Wave 9 declined to cite from an unread abstract - now actually read. |
| Q5 | EXCLUDED: "entropy principle" paper (2606.08162) | DISCARD | DONE | Fully read, then excluded on credibility: single non-peer-reviewed author, commercial affiliation, pseudo-physics framing. |
| Q6 | EXCLUDED: "41-87% production failure rate" (2605.03310) | DISCARD | DONE | Read directly; the abstract gives no citation for the figure and the paper's own experiment does not measure it. Exactly the shape of the numbers Waves 8 and 9 dropped. |
| Q7 | EXCLUDED: AdaptOrch (2602.16873) | DISCARD | DONE | Surfaced in fan-out searches but does not address breadth at all. |

### Process failure observed during Phase 5 - worth more than the phase itself

The Phase 5 agent was told to research six questions and write **one** file. Instead it
dispatched **four children**, returned a status update as its final answer - *"I'll wait for
their completion notifications, then... write the synthesis"* - and **terminated**, orphaning
all four. No file was written. It burned ~40k tokens to produce a progress report.

Why this matters more than the phase:

| # | Finding | Bucket | Status |
|---|---|---|---|
| M1 | **A subagent can mistake "I have delegated the work" for "the work is done."** It reported intent as completion, in the same confident register as a real result. | DOCTRINE | **VERIFIED** - observed directly |
| M2 | **Orphaned grandchildren keep running with no one to synthesize them.** The parent exits; the children do not stop. Work continues, unclaimed, and its output has no destination. | DOCTRINE | **VERIFIED** |
| M3 | This is the fourth instance tonight of an agent's self-report failing verification - and the most direct. Q1 of Phase 4 (four independent papers converging on "self-report is not evidence") predicted exactly this, hours earlier. | DOCTRINE | **VERIFIED** |
| M4 | `guard-fanout` did NOT catch it. The children were dispatched inside a subagent, and the threshold for this repo is 8. The brake exists at the wrong layer to stop a *child* from fanning out. | CONFIG | OPEN |

**Candidate rule, for the one-by-one pass:** a dispatched agent must produce the artifact
itself. Delegation is permitted; **returning a delegation as the deliverable is not.** If a
subagent may spawn children, it must also wait for and synthesize them - or it must be told
plainly that it may not spawn any.

Note this cuts against the earlier conclusion that fan-out width should be bounded only by
verification capacity. Width was not the problem here. **Depth was** - and nothing in the kit
currently constrains it.

### From Phase 5 - client-facing

*Source: `phase5-client-facing.md`. Assembled by the parent session from four orphaned agents.
Bar was 2 applicable patterns; cleared with 4.*

| # | Finding | Bucket | Status | Note |
|---|---|---|---|---|
| C5-1 | **Claude for Nonprofits: up to 75% off, Team at $8/user/month, 2-seat minimum, for orgs under 20 people.** Verified via Goodstack, 501(c)(3). | BUILD | **HIGH** | Reframes The Caregiver Club from zero-budget-free-tier to $16/month. **And Team is the tier that carries a DPA** - so the cheap path and the compliant path are the same path. |
| C5-2 | **A consultant working on a personal Pro/Max account is under consumer terms with NO DPA.** Anthropic's DPA covers only Claude for Work and the API; the consumer privacy page explicitly excludes commercial products. Whose account does the accessing determines whose terms apply. | DOCTRINE | **HIGH** | Bears directly on how the Betsey audit runs today - through Daniel's own accounts, against her Drive and Asana. Doc-grounded, not inferred. |
| C5-3 | **90% of unsupervised AI itineraries contain an error; 24% recommend permanently closed venues.** Independent study, travel-marketing agency, tested vanilla ChatGPT. | DOCTRINE | OPEN | A numerate argument that Betsey's verification **is** the billable expertise, and a caution against any AI-itinerary feature on her site. |
| C5-4 | **Spreadsheet-as-interface** - staffer types a keyword into a Google Sheet cell, automation does the rest (SisterLove, ~18 people) | BUILD | OPEN | Avoids every adoption blocker found: no terminal, no prompt engineering, no new tool. |
| C5-5 | **Terminal intimidation is the top adoption blocker.** One account describes an employee who avoided Claude Code entirely because the terminal was too intimidating. | DOCTRINE | OPEN | **Both clients get claude.ai with Projects and Skills, never Claude Code.** |
| C5-6 | Willison: *"I do not think it is fair to tell regular non-programmer users to watch out for 'suspicious actions that may indicate prompt injection'!"* | DOCTRINE | OPEN | Lands directly on B7 and P5. If the guidance is unreasonable for a technical audience, it is unreasonable for Betsey and for nonprofit volunteers. |
| C5-7 | Bradford Tobin's contract disclosure clause and three-tier disclosure framework | BUILD | OPEN | Copy near-verbatim. Mandatory disclosure when AI creates the substance, for IP and liability. |
| C5-8 | **The actual Anthropic DPA was never fetched** - all specifics come from third-party compliance-vendor summaries | - | OPEN | Read the real DPA before relying on any of it. |
| C5-9 | Least-privilege OAuth scoping and approval gates for external sends, public links, permission changes, deletions | CONFIG | OPEN | Implemented nowhere currently. |

**Phase verdict: KEEP but NARROW.** The general "what do AI consultancies do" search is near-pure
noise. The two threads worth re-running are Anthropic's nonprofit/business program changes and
the liability picture - official-source questions with real answers.

**Structural gap across all five phases:** Reddit and Facebook groups - where practitioners in
these industries actually talk - were unreachable by every agent, every time. That is a tooling
limit, not an absence of material, and it means the whole sweep systematically under-samples the
most candid sources.

---

## SWEEP COMPLETE - all 5 phases landed 2026-09-08

| Phase | Result |
|---|---|
| 1a Anthropic changelog | 12 unused capabilities; caught a stale fact in its own dispatch prompt |
| 1b Community / GitHub | 6 compositions; 2 risks refuted locally |
| 1c Rules still-true | 6 real defects incl. 2 mutation-tested; **3 of 7 FALSE findings were themselves wrong** |
| 1d GC inventory | GSD apparatus never used once; 2 hooks recording pure garbage |
| 2 Local models | RAM was never the constraint - refuted this session's own framing |
| 3 Practitioners | 9 compositions; Auto Mode classifier is not a hard gate |
| 3b Anduril | Mostly no - **CUT from future sweeps** |
| 4 Academic | 8 findings survived strict citation; caught a fabricated stat live |
| 5 Client-facing | 4 applicable patterns - **KEEP but narrow** |

**Cross-cutting theme.** Tonight's repair work fixed *wiring*. This sweep found the next layer
down: things that are wired and still do not work. INV-01 and INV-04 cannot fail. Two hooks log
only `unknown`. 68 GSD skills have never run. And **four separate agent self-reports failed
verification**, one of them reporting an edit it never made - which Phase 4 then found four
independent papers predicting.

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
- **2** Local models on this hardware — LANDED
- **3** Named practitioners — LANDED (9 compositions)
- **3b** Anduril / edge AI — LANDED (verdict: mostly no; cut from future sweeps)
- **4** Academic — LANDED (8 findings survived full verification)
- **5** Client-facing — LANDED (4 patterns; keep but narrow)

---

## Process note

Findings are **documented, not acted on**, until every phase lands. Daniel's call: go through
them one by one afterward. Resist fixing things mid-sweep — a finding acted on before its
phase completes cannot be weighed against the ones still coming.
