# claude-practices — Meta Architecture

> What exists in this repo, how it reaches a machine, and which parts are load-bearing.
> Created 2026-09-09, after the usage report found that `session-workflow`'s start protocol
> pointed at this file for months while it did not exist — which is part of why the protocol
> fired in 9 of 39 sessions.
>
> **This repo is PUBLIC** (`dpchristopher/claude-practices`). Nothing machine-specific,
> client-specific, or personal belongs here. The `local-models` and `daniel-context` skills are
> deliberately kept out for that reason.

---

## What this repo actually is

A portable Claude Code practices kit with **two delivery paths that behave completely
differently**. Confusing them is the single most common failure in this repo's history.

| Path | Source | Reaches | Loads |
|---|---|---|---|
| **Global** | `global-rules/*.md`, `skills/`, `hooks/`, `templates/.claude/agents/` | `~/.claude/` via `install.sh` / `install.ps1` | Every session, every project, every turn |
| **Template** | `templates/` | A new project, **only** via the `/init` skill | That project only |

**The template path has never scaffolded a project.** Measured 2026-09-08. That is why four
Wave 9 rules written into `templates/.claude/rules/` reached zero projects, and why a reference
to a deleted file survived there unnoticed.

> **Rule of thumb: if it must apply everywhere, it goes in `global-rules/`.** Putting it in
> `templates/` means it applies nowhere until someone scaffolds a project.

---

## Tool inventory

| Tool | Location | Entry point | Status |
|---|---|---|---|
| **Installer** | `install.sh` / `install.ps1` | `bash install.sh [--dry-run]` | ✅ Working — copies skills, hooks, agents, global-rules into `~/.claude/` |
| **Kit audit** | `scripts/verify-kit.sh` | `bash scripts/verify-kit.sh` | ✅ 42 checks — repo state, hook wiring, permissions, rules, per-project gates, secrets guards, invariants, backup |
| **INV-01** | `scripts/verify-install.sh` | `bash scripts/verify-install.sh` | ✅ Dry run writes nothing; `VERIFY_INSTALL_IDEMPOTENCE=1` adds a real-install comparison |
| **INV-02** | `scripts/verify-hooks.sh` | `bash scripts/verify-hooks.sh` | ✅ Four directions: referenced→exists, exists→referenced, `.sh`/`.ps1` parity, template→deployed |
| **INV-04** | `scripts/verify-sources.sh` | `bash scripts/verify-sources.sh` | ✅ Per-line citation proximity, 4-line window |
| **Usage report** | `scripts/usage-report.sh` | `bash scripts/usage-report.sh [days]` | ✅ Measures real skill/agent use from the transcript corpus |
| **File sweep** | `scripts/file-sweep.sh` | `bash scripts/file-sweep.sh <glob> "<question>" [--run]` | ✅ Carlini one-file-at-a-time review; prints commands unless `--run` |
| **Backup** | `backup-state.sh` | `bash backup-state.sh ~/OneDrive/claude-backups` | ✅ Manual, no scheduler. Covers the un-tracked precious paths |

**Every check above is mutation-tested.** Three of them previously could not fail; see
`CHANGELOG.md` 1.8.x and PR #13.

---

## Hooks — what fires, and where it is wired

Wiring lives in `templates/.claude/settings.json` (shipped) and `~/.claude/settings.json` (live).
INV-02 enforces that those two agree.

| Hook | Event | Purpose |
|---|---|---|
| `session-context.sh` / `.ps1` | SessionStart | Prints HANDOFF + context before the first turn |
| `guard-secrets.sh` | PreToolUse `Write\|Edit` | Blocks writes to secret files (`exit 2`) |
| `guard-fanout.sh` | PreToolUse `Agent` | Asks past a rolling-window dispatch threshold |
| `guard-agent-ownership.sh` | PreToolUse `Agent` | Blocks direct `gsd-*` dispatch outside a GSD project |
| `post-edit-format.sh` | PostToolUse `Write\|Edit` | Auto-formats when a formatter exists |
| `plan-router.sh` | UserPromptSubmit | Nudges planning intent |
| `subagent-audit.sh` | SubagentStop | Records which agent ran |
| `guard-verdict.sh` | SubagentStop | Blocks a checker agent that emits no verdict |
| `log-instructions-loaded.sh` | InstructionsLoaded | Records which context files loaded |
| `session-metrics-stub.sh` | SessionEnd | Appends the machine-observable half of a metrics row |
| `precompact-handoff.sh` | PreCompact | Snapshots git state before compaction |
| `stop-verify.sh` | Stop | **Opt-in** — blocks turn-end until `PROJECT_CHECK_CMD` passes |
| `guard-readonly-bash.sh` | PreToolUse `Bash` | **Agent-frontmatter only** — Kevin/Mel/Carl. Blocks mutating commands |

The last two are in INV-02's `UNWIRED_BY_DESIGN` allowlist with stated reasons. Wiring either
globally would break normal work.

---

## Toolkit — skills in this project

| Skill | Invoke when… |
|---|---|
| `/session-workflow` | Session start, or when process is unclear |
| `/patterns-guide` | Choosing how to structure work |
| `/socratic-examiner` | A position has formed and needs stress-testing before committing |
| `/assumption-archaeologist` | A plan looks fine but rests on something unexamined |
| `/the-fool` | A structured adversarial exercise — pre-mortem, red team, evidence audit |
| `/thinking-partner` | Direction unclear, options unexplored |
| `/feynman-explainer` | Comprehension gate before marking work done; produces the HANDOFF body |
| `/failure-modes` | Session feels stuck, looping, or over-planned |
| `/init` | Scaffolding a new project from this kit |
| `/labarr-ml` | Any ML, forecasting, analytics, or modelling work |
| `/code-review` | Significant code written |

Ownership boundaries between the overlapping ones: `docs/skill-overlap-audit.md`.

**Measured usage, 39 sessions:** `session-workflow` 9 · `thinking-partner` 3 · `the-fool` 1 ·
`socratic-examiner`, `assumption-archaeologist`, `failure-modes`, `feynman-explainer` **0**.
A zero is a question, not a verdict — but four zeroes is worth knowing.

---

## Agents

Ten named agents in `templates/.claude/agents/`, installed to `~/.claude/agents/`.

| Agent | Role | Model |
|---|---|---|
| `gru-planner` | Drafts kit-compliant plans end to end | opus |
| `bob-verifier` | Fresh-context adversarial reviewer. **Before marking anything done** | opus |
| `dave-researcher` | Multi-source research and synthesis | opus |
| `kevin-security` | Security review — auth, data, deps, client-facing | opus |
| `mel-design` | UI review, density over decoration | opus |
| `phil-test-author` | Writes tests that verify real behaviour | sonnet |
| `jerry-docs` | Keeps docs in sync with what the code does | sonnet |
| `otto-rules` | Literal grep/regex checklist review, zero judgment | haiku |
| `stuart-explorer` | Cheap codebase lookup | haiku |
| `carl-evals` | Binary pass/fail grading against a rubric | — |

**These win over the GSD plugin's 24 equivalents** — enforced by `guard-agent-ownership.sh`,
not just stated. GSD has never been used: zero `.planning/` directories, zero dispatches.

**Measured dispatches, 39 sessions:** `general-purpose` 215 · `dave-researcher` 120 ·
`bob-verifier` 60 · `Explore` 19 · `gru-planner` 10 · the rest in single digits. The generic
catch-all is 47% of all dispatches, which is a sharper ownership problem than GSD ever was.

---

## Invariants

`INVARIANTS.md` holds four contracts, each with a runnable check. All four were audited
2026-09-09; three could not fail and were rewritten.

| | Contract | Check |
|---|---|---|
| INV-01 | Installers are idempotent; a dry run writes nothing | `scripts/verify-install.sh` |
| INV-02 | Hooks and settings agree, in four directions | `scripts/verify-hooks.sh` |
| INV-03 | No secret-shaped string is committed | gitleaks via `core.hooksPath` |
| INV-04 | Every limit number in doctrine has a nearby `SOURCES.md` pointer | `scripts/verify-sources.sh` |

**The lesson from that audit, which applies to any new invariant:** a check that cannot observe
what it is about will pass forever. INV-01 watched the repo while the installer wrote to
`~/.claude`. INV-02 compared repo files to each other. INV-04 asked whether a *file* cited
anything, not whether a *number* did. **Write the mutation test first.**

---

## Known gaps

- **`HANDOFF.md` is the only session-end step that still depends on remembering.** Metrics,
  orchestration logging, and pre-compaction state are all automatic now.
- **`session-workflow`'s start protocol fired in 9 of 39 sessions.** Partly because two of its
  six steps pointed at files this repo did not have — this one, and a project `CLAUDE.md`.
  This file closes half of that. A tier-demotion (SessionStart hook) is the candidate fix for
  the rest.
- **Backup has no scheduler.** `backup-state.sh` is manual.
- **`templates/` reaches nothing** until `/init` scaffolds a project. See the delivery table above.
- **No project `CLAUDE.md` in this repo** — the kit that ships the template has none itself.
- Four skills and the GSD apparatus sit at zero measured invocations.

---

## Decision tree

| Situation | Do this |
|---|---|
| Adding a rule that must apply everywhere | `global-rules/`, then `install.sh`. Mind the ≤30-line per-wave budget |
| Adding a rule scoped to one project type | `templates/.claude/rules/` — and know it reaches nothing until `/init` runs |
| Adding an invariant | Write the mutation test first. If you cannot make it fail, it is not a check |
| Adding a hook | Wire it in **both** `templates/.claude/settings.json` and the live config; INV-02 enforces parity |
| Adding a skill or agent | Check `~/.claude/skills` and `~/.claude/agents` first — the Agent-Creation Gate in `kit-maintenance.md` |
| Something must *never* happen | A static permission `deny` rule, not a hook. See `docs/mechanizing-doctrine.md` |
| Before marking non-trivial work done | Dispatch `bob-verifier`. Re-verify touched invariants with evidence |
| Deciding whether to cut a skill | `bash scripts/usage-report.sh`. Frequency is not value |
