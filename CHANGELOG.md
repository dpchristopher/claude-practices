# Changelog

All notable changes to claude-practices. Versions follow semver-ish intent:
minor = new capability, patch = fix/cleanup.

## [1.5.0] — 2026-08-31 (Wave 8 — Delegation Discipline: Handoffs, Sprawl Gate, Rule Reviewer)
### Added
- `otto-rules` agent — literal, zero-judgment checklist reviewer (`model: haiku`, `Read/Grep/Glob` only, same cost tier as Stuart, no Bash so no readonly-bash guard needed). Runs a project-local checklist of literal patterns and reports matches only; flags anything needing interpretation back to Bob/Kevin instead of attempting it.
- `## Handoffs` sections on Gru, Bob, and Dave — formalizes delegation targets and expected return shapes that were previously implicit (e.g. Gru Phase G "hand to Bob"). Otto is the common new target across all three: a cheap pre-filter before judgment-tier review or research.
- `## Delegation packet` in `tool-discipline.md` — five fields (Owner, Allowed effects, Budget, Escalation trigger, Receipt) required before any dispatch that touches an external system, spends budget, or falls in the Prohibited/Explicit-permission-required action categories. Deliberately does not duplicate Gru's plan fields (objective/evidence/done-criteria stay Gru's); reuses `loop-cost-discipline.md`'s existing budget-estimate rule and the plan's Running Notes log instead of inventing new mechanisms.
- Agent-Creation Gate in `kit-maintenance.md` — promotes the existing "check before adding" bullet from a quarterly-GC habit to a standing pre-creation check, named against the industry term "agent sprawl" (source: `SOURCES.md#agent-sprawl`).
- Held-out gate for self-generated optimizations in `evals.md` — a `skill-creator`-produced prompt/skill edit is a candidate, not an upgrade, until it clears a held-out case set, mirroring the DSPy/APE held-out-vs-training split.
- Five new `SOURCES.md` anchors: `agent-handoffs`, `agent-sprawl`, `deterministic-vs-judgment-review`, `optimization-candidates`, `agent-reliability`.
- `otto-rules` added to the README agent list and Gru's Phase B/D roster references.
- **`.gitattributes`** gained `* text=auto eol=lf` — normalizes Windows checkouts to LF.

### Fixed
- **`.gitignore`'s `.claude/` pattern was unanchored** and silently matched `templates/.claude/`
  too, meaning `otto-rules.md` would never have been tracked despite every doc referencing it —
  caught by Bob before commit, not after. Anchored to `/.claude/` (repo root only).
- CRLF had crept into this wave's edited files on a Windows checkout with no normalizing
  `.gitattributes` rule, turning small doc edits into full-file rewrites in the diff. Fixed via
  the `text=auto eol=lf` rule above plus a scoped `git add --renormalize` on only the touched
  files (not a repo-wide rewrite).
- Gru's own Minions roster line (persona intro) and `docs/optional-integrations.md`'s "9 agents"
  reference were missed on the first pass and didn't count Otto — both updated to 10.
- `kit-maintenance.md`'s Agent-Creation Gate had silently narrowed from "skill or agent" to
  "agent" only during the promotion from the old inline bullet — restored to cover both.
- `SOURCES.md#agent-handoffs` overclaimed that Otto has a `## Handoffs` section (it doesn't —
  Otto is the common *target*, documented in its own `## Where you fit` section) — corrected.
- Bob's fan-out section (cap-at-3 sub-verifiers) read as ambiguous against the new Otto handoff
  row (different trigger, no size gate) — added an explicit carve-out: Otto is a pre-filter,
  not a sub-verifier, and doesn't count against the cap.
- All six caught by dispatching `bob-verifier` on the diff before commit — maker≠checker, same
  discipline the kit ships, applied to the kit's own change.

### Notes
- **A borrowed statistic was caught and dropped before shipping.** Draft doctrine for Otto cited "69.8% of harmful runs caught by deterministic checks," attributed to the SABER paper (arXiv:2606.01317), from a search-engine-summarized result. Direct fetch of the paper itself during this wave found a different, unrelated headline figure (54% harmful safety-violation rate) and no trace of 69.8%/30.2%. The number does not ship — only the qualitative pattern (rule-based and LLM review are complementary layers) does, re-cited to a source that was actually confirmed. Same discipline as Wave 7's MAST FC1 withholding; see `SOURCES.md#deterministic-vs-judgment-review`.
- **Three other new claims rest on vendor blogs, not primary docs or a paper:** `agent-sprawl`, `optimization-candidates`, `agent-reliability`. Flagged explicitly at a lower confidence tier in `SOURCES.md` rather than silently presented as MAST-grade verification — this wave's practices are design patterns, not measured platform limits, and are held to an appropriately lighter (but stated, not hidden) bar.
- **Line budget:** `kit-maintenance.md` and `evals.md` are the only two files touching the always-loaded per-wave budget (57→65 lines and 43→51 lines respectively — **+16 total**, well under the ≤+30 aim). Otto, the three `## Handoffs` sections, and the delegation-packet section are all on-demand agent/rule files, not always-loaded, so they don't count against it.
- **What "installed globally" actually covers:** `install.ps1`/`install.sh` push `otto-rules.md` and the updated `kit-maintenance.md` to `~/.claude/agents/` and `~/.claude/rules/` — available immediately in every project. The `tool-discipline.md` and `evals.md` changes are per-project **template** files; they only reach an existing project (Civ, Wealth Management Dash, etc.) if that project's `.claude/rules/` is refreshed from the template by hand — they do not retroactively apply on their own.

## [1.4.0] — 2026-08-19 (Wave 7 — Doctrine Refresh: Limits, Isolation & the Fan-Out Brake)
### Added
- `global-rules/` — the always-loaded layer is now **in version control and installed**. Both installers gained a step 4 writing `global-rules/*.md` → `~/.claude/rules/`. Before this, `kit-maintenance.md` and `loop-cost-discipline.md` existed only on one machine: untracked, un-backed-up, and unrecoverable by reinstall.
- **The fan-out brake**, in three places: an *Estimate breadth before dispatch* section in `loop-cost-discipline.md` (global, always loaded); rewritten fan-out sections in `dave-researcher.md` and `bob-verifier.md`; and a pinned regression case in `evals.md`.
- `SOURCES.md` — dated primary-source ledger. Rules cite it by anchor (`SOURCES.md#mast`) rather than carrying URLs inline.
- `INVARIANTS.md` for the kit itself (INV-01…04). The kit shipped `templates/INVARIANTS.md` for other projects while keeping none of its own.
- `scripts/verify-hooks.sh` (INV-02: hook↔settings parity, sh/ps1 drift) and `scripts/verify-sources.sh` (INV-04: every limit number carries a citation).
- SessionStart hook warns when the active plan has no `Done when` / exit condition — targets MAST's measured 12.4% termination-condition failure mode, and enforces a `loop.md` rule nothing previously checked. Bash and PowerShell both.
- `hooks/guard-fanout.sh` — **opt-in** `PreToolUse(Agent)` guard. Silent for dispatches 1–4, then `permissionDecision: "ask"`. L2 on the autonomy ladder, never a hard deny.
- Judge-calibration doctrine in `verification.md` (Husain's `validate-evaluator` method).
- MAST corroboration mapped onto the `failure-modes` skill catalog.

### Changed
- **README reframed** from "Claude Code sessions forget context between sessions" to a dated snapshot: *"How I actually use Claude Code, as of August 2026."* The premise was obsolete — cross-session messaging means sessions can talk. The platform closed the mechanical gap; the judgment gap is what the kit was always actually about.
- `tool-discipline.md`: *When to Use Subagents vs. Main Session* **superseded** by *Choosing an isolation mechanism* — one table covering main session / fork / fresh subagent / cross-session message / Workflow tool.
- `loop.md`: cost budgets rescoped to the Workflow tool and merged with a three-limit-systems table.
- `loop.md` rule 6 now uses `Monitor` for event-driven watching, carrying its discipline: **silence is not success.**
- Built-in `EnterWorktree`/`ExitWorktree` replace manual `git worktree add` in `patterns-guide/SKILL.md` and the Chrystal Ball doc.
- `session-workflow.md`'s *Context Management* replaced with a pointer — it restated `tool-discipline.md` near-verbatim.
- `templates/global-CLAUDE.md` synced to the live global file (bob-verifier/carl-evals rows, evidence rule, unattended-loop rule, metrics logging, refinement cap).
- `kit-maintenance.md` gained a per-wave growth aim and records this wave's overage against it.

### Fixed
- **Nesting depth: the kit claimed "5 levels deep."** The platform default has been **3** since v2.1.219. Bob's and Dave's prompts carried the stale number; both rewritten. Doctrine now designs for 3 deliberately rather than chasing the default.
- Three CLAUDE.md line budgets were in circulation (200 / 80 / ~90) — reconciled to 90.
- Broken README link: `Coolest Thing Since Crystal Ball.md` → `Chrystal`.
- `failure-modes` was missing from the README skills list.

### Notes
- **Sourcing.** Every limit number in shipped doctrine traces to a dated entry in `SOURCES.md`, enforced by `verify-sources.sh` (INV-04). Held to Wave 5's standard: primary docs or the paper itself, never aggregators.
- **MAST verification changed the numbers — including one of its own corrections.** Gating on the primary source caught that inter-agent misalignment is **32.35%**, not the circulating ~37%, and that the paraphrased conclusion was not the paper's operative sentence. It also gained category FC3 *Task Verification* (23.5%) entirely — of which incomplete or incorrect verification is 17.3% of all failures, a measured case for maker≠checker. **FC1's category total is deliberately not quoted:** three retrieval attempts gave 43.8%, 43.9%, and a mode-sum of 44.2%. A mid-wave claim that "44.2 was wrong, it is 43.8" is **retracted** — it was itself under-verified, and a fresh-context review caught it. Mode-level percentages are stable and safe; see `SOURCES.md#mast`.
- **The 200-subagent cap never existed.** A widely repeated claim that "the 200-subagent cap was removed" is false. Real concurrent default is 20; there is no total-lifetime cap. Recorded here so it does not resurface.
- **Line budget: +51 against a +30 aim.** 19 lines were cut through genuine dedup. The remaining growth is doctrine this wave deliberately added. Accepted by the user rather than deleting something load-bearing to hit an estimate made before the content existed.
- **`maxTurns` on Dave: not added.** The field's validity on a non-Haiku agent was not verified, and the plan forbade guessing. The prompt-level cap stands.
- **Deferred to Wave 8:** the four-surface automation taxonomy (CronCreate / Routines / Workflow / Desktop Scheduled Tasks) and its downstream fourth autonomy rung — the hard part is placement, since `automation.md` is `paths:`-scoped and will not load when the surface is being *chosen*.
- **Blocked pending `/the-fool`:** discover-on-demand (`SearchSkills`/`SearchPlugins`) vs. the curated-roster rule. A genuine philosophical fork. Worth knowing when it is decided: `~/.claude/skills/` already holds 90+ skills, mostly `gsd-*`, so the curation premise is already not holding at the global layer.

## [1.3.1] — 2026-07-22 (Wave 6 gap closure)
### Added
- `effort: high` on the heavy reasoning agents (`dave-researcher`, `gru-planner`) — field/values verified against the sub-agents docs.
- `hooks/guard-verdict.sh` — enforced verdict gate: a `SubagentStop` hook wired into Bob/Carl/Kevin that blocks (exit 2) a checker from finishing without emitting its required verdict marker. Makes maker≠checker *enforced*, not just instructed. Feasibility (SubagentStop payload carries `last_assistant_message`; exit 2 blocks) verified live against the hooks docs before building.
### Fixed
- `guard-verdict.sh` matches the agent's final message only (not the whole payload), with encoding-independent ASCII anchors — closes an emoji-encoding false-block and a metadata-path false-pass surfaced by a fresh-context Bob review.

## [1.3.0] — 2026-06-29 (Wave 6 — Ops, Safety & Runnable Mechanisms)
### Added
- Content-based secret scanning in `guard-secrets.sh` — blocks hardcoded keys pasted into ordinary files, not just secret-named files.
- `.pre-commit-config.yaml` (gitleaks) + `SECURITY.md` — commit-time secret backstop and layered-defense doc with a git-history sweep command.
- `--dry-run` / `-DryRun` on both installers + an install manifest written to `~/.claude` (preview before writing; enables surgical rollback).
- Example Dynamic Workflows: `fan-out-audit.js`, `fix-until-green.js` (the runnable form of the loop rule) + a workflows README.
- Agent-scoped read-only Bash guard on Kevin/Mel/Carl (`guard-readonly-bash.sh`) — closes the Bash side-door on read-only reviewers.
- `maxTurns: 8` on Stuart (bounds cost on the cheap light-research agent).
- `BACKUP.md` + `backup-state.sh` — backs up un-git-tracked agent memory / local state.
- `ROLLBACK.md` — /rewind + git tags + install-manifest rollback procedure.
- Loop cost budgets (concrete agent/token ceilings) in `loop.md`; Bob reframed review→refute; Dave gains a vote-on-claims protocol.

### Fixed
- README consistency: path-scoped rules no longer mislabeled "auto-loads"; the continuity section now correctly describes INVARIANTS.md-via-hook and conditional rule loading.

### Notes
- Addresses reviewer (boss) feedback across all eight areas: dry-run, agent hooks, secret protections, backups, rollbacks, loops, workflows, adversarial reviewing. Load-bearing hook mechanism re-verified live against official docs before building.

## [1.2.0] — 2026-06-29 (Wave 5 — Native Platform Features & Elite Doctrine)
### Added
- `memory: project` on Bob, Kevin, Gru — persistent per-agent knowledge across sessions (native subagent memory).
- Gru: Dynamic Workflow awareness (flags repeatable orchestration as a `.claude/workflows/*.js` candidate) and per-task model delegation (Simon Willison).
- Bob and Dave: nested fan-out via the `Agent` tool (5-level-deep subagent spawning).
- Bob: a 5th check — code-quality degradation from long autonomous runs (Armin Ronacher: defensive fallbacks vs. invariants, duplicated logic, over-local reasoning).
- `paths:`-scoped `.claude/rules/`: ml-discipline and automation now load only when relevant files are touched.
- `loop.md`: per-stage model routing, context-centric decomposition doctrine ("split where context isolates, not by problem phase"), and an L3 containment precondition (network/credential/spend bounds, separate from correctness brakes) — all from Simon Willison's agentic-loop writing.
- `tool-discipline.md`: a roster-bloat doctrine note — every named agent must earn its place via context isolation or a permission/model boundary, not role-flavor alone.
- `subagent-audit.sh` and `log-instructions-loaded.sh` hooks — diagnostic audit trail of orchestration runs and loaded context files; never block.
- `settings.json`: `autoMemoryEnabled: false` (keeps INVARIANTS/HANDOFF as the single memory authority over the platform's own auto-memory) and `Agent(Explore)` denied (nudges orchestration toward the named Minion roster).

### Notes
- Sourcing discipline: every item above was independently re-verified against live official docs (code.claude.com/docs) or a named practitioner's own primary-source blog (Simon Willison, Armin Ronacher). Items resting only on secondary/aggregator sourcing were explicitly excluded this wave.

## [1.1.0] — 2026-06-29 (Wave 4 — Gru & Planning Autopilot)
### Added
- Gru (planner) agent — planning orchestrator: triage → read project + kit → applicability pass → draft with everything explicit → self-audit → hand to Bob. Writes a draft plan for approval.
- Mel (design-reviewer) and Jerry (doc-writer) agents.
- `planning` rule — canonical plan rubric (Gru reads it; Bob grades against it).
- `plan-router.sh` UserPromptSubmit hook — conservative auto-route of planning intent to Gru.

### Changed
- `settings.json` wires the UserPromptSubmit hook.
- Install scripts now copy committed agents into `~/.claude/agents/` (agents go global, reproducibly).

## [1.0.0] — 2026-06-29 (Wave 3 — Loop Discipline & Finale)
### Added
- `loop` rule — self-correction loop discipline built on native `/goal` + `/rewind`: exit-condition-first, maker≠checker, state-on-disk, L1→L2→L3 autonomy ladder, stuck-loop detection, loops open PRs (never auto-merge).
- `docs/optional-integrations.md` — opt-in Graphiti (temporal memory) and Playwright/browser-verify (UI self-check) patterns, with the don't-install-the-kitchen-sink caution.
- `@`-import / leanness guidance in the `CLAUDE.md` template.

### Notes
- Completes the back-half hardening roadmap (Waves 0–3): clean-up → continuity/invariants → verification/evals → loops. The kit now covers planning AND the back half (verification, evals, self-correction, articulation).

## [0.4.0] — 2026-06-29 (Wave 2 — Verification & Evals)
### Added
- `verification` rule — evidence over assertion, verification taxonomy (rules > visual > LLM-judge), the trust-then-verify failure mode.
- `evals` rule — binary pass/fail, read-traces-to-saturation, regression-cases-from-failures, data flywheel.
- Carl (evals-judge) agent — binary pass/fail grader; the checker, never the maker.
- Verification hooks: `guard-secrets.sh` (PreToolUse, blocks writes to secret files, allows `.env.example`/`.template`/`.sample`), `post-edit-format.sh` (PostToolUse, no-op-safe auto-format), `stop-verify.sh` (opt-in Stop hook).
- `.gitattributes` enforcing LF on shell scripts (cross-platform safety).

### Changed
- `settings.json` now wires the secret-write guard and formatter hooks by default (Stop hook opt-in).
- Install scripts copy ALL `hooks/*` (so future hooks need no install-script edits).

## [0.3.0] — 2026-06-29 (Wave 1 — Back-Half Foundation)
### Added
- `INVARIANTS.md` ledger template + `invariants` auto-load rule (cross-session contract tracking).
- `feynman-explainer` skill — comprehension gate completing the thinking trio.
- Minion agents in `templates/.claude/agents/`: Bob (verifier), Kevin (security-reviewer), Stuart (explorer/Haiku), Dave (researcher/Opus), Phil (test-author).
- `settings.json` template — deny secrets, allow safe git commands.
- Windows-native `session-context.ps1` hook sibling.
- MANDATORY/ON-DEMAND Reading Order index at the top of the `CLAUDE.md` template.
- Light vs heavy research rubric in `tool-discipline.md`.

### Changed
- SessionStart hook now loads `INVARIANTS.md` in full; install scripts carry both hooks.
- Session-end discipline now re-verifies affected invariants and runs the Feynman gate.

## [0.2.0] — 2026-06-29 (Treaty of Versailles)
### Changed
- Normalized all skills to `skills/<name>/SKILL.md` directory form.
- Replaced hand-copy README blocks with idempotent `install.sh` / `install.ps1`.
- Single source of truth for the skills tables (methodology → `session-workflow` skill; applicability → `META_ARCHITECTURE.md`).
- Framed Python tooling in `tool-discipline.md` as a swappable default.

### Added
- `VERSION` and this changelog.

### Notes
- Foundation for back-half hardening (Waves 1–3): INVARIANTS.md, feynman-explainer,
  Minion-themed agents, verification/evals rules, native-/goal loop discipline.
  See `docs/superpowers/specs/2026-06-29-claude-practices-hardening-design.md`.

## [0.1.0] — prior
- Initial kit: templates, thinking trio, session-workflow, init, labarr-ml, SessionStart hook.
