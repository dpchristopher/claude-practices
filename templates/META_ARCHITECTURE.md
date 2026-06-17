# [Project Name] — Meta Architecture

> **One-liner:** [What this project is and what it does — complete this before anything else.]  
> **Read this first** at every session start. Last updated: [date] ([session name])

Tool map, data flow, decision tree, known gaps. CLAUDE.md covers rules — this covers **what exists and how to navigate it**.

---

## Tool Inventory

| Tool | Location | Entry Point | Status | Tests |
|---|---|---|---|---|
| **[Tool Name]** | `[path/to/tool/]` | `[run command]` | ✅ Working | [N passing] |
| **[Tool Name]** | `[path/to/tool/]` | `[run command]` | 🚧 In progress | — |

### How to Run Each Tool

**[Tool Name]:**
```
[exact run command]
```

**Run all tests:**
```
[test command]
```

---

## Available Connectors

| Connector | What it accesses | How to use |
|---|---|---|
| [System] | [what's in it] | [Claude Code MCP / script / etc.] |

---

## Toolkit — Skills Available in This Project

> **When drafting any plan:** read this table first. For each phase of the plan, identify which skills belong as explicit checkpoints and write them into the plan steps. Do not leave skill invocations implicit — name them in the plan.

| Skill | Invoke in plan when... | Where in plan |
|---|---|---|
| `/thinking-partner` | Direction is unclear, options haven't been explored | Phase start — before committing to approach |
| `/socratic-examiner` | A plan or architecture is taking shape | After design phase — before building |
| `/assumption-archaeologist` | Something feels off or premises haven't been questioned | After socratic-examiner, or when stuck |
| `/labarr-ml` | Any ML pipeline, forecasting, analytics, or modeling | At ML phase start — before any model design |
| `/sql-pro` | Writing complex queries, CTEs, window functions, or optimization | At query-writing step |
| `/pandas-pro` | DataFrame pipelines, data cleaning, memory optimization | At data processing step |
| `/debugging-wizard` | Bug is proving hard to isolate | At debugging phase start |
| `/the-fool` | Major architectural or product decision | Before committing to design |
| `/patterns-guide` | Choosing how to structure work or approach a problem | During planning, before design is locked |
| `/code-review` | Significant code was written | Before merging any feature branch |
| `/session-workflow` | Need the full methodology reference | Session start or when process is unclear |
| `[domain-skill]` | [trigger condition] | [where in plan] |

**How to embed skills in a plan:**
```markdown
## Phase 2: Design Query Strategy
- [ ] Invoke `/sql-pro` — sketch CTE structure and review approach
- [ ] Write queries
- [ ] Validate output against expected shape

## Phase 3: Build ML Pipeline
- [ ] Invoke `/labarr-ml` — confirm algorithm choice and eval metric
- [ ] Define acceptance threshold before training
- [ ] Train baseline, evaluate, document in experiments/
```

Skills are checkpoints, not optional extras. If a skill belongs in a phase, it goes in the plan explicitly.

---

## Data Flow

```
[Input source]
  ↓
[Step 1 — tool/process name]
  → [what it does]
  ↓
[Step 2 — tool/process name]
  → [what it does]
  → ⚠ GAP: [known gap / next task]
  ↓
[Output]
```

---

## Tool Decision Tree

**I have [input type] — what do I use?**
→ [Tool name] — [when/why]

**I need [data type] — what do I use?**
→ In a Claude Code session: [method]
→ In a script: [method]

**I need to run [process] in batch — what do I use?**
→ Small batches: [approach]
→ Large batches (50+): standalone script or subagents — never sequential in main session

---

## Codebase Layout

```
[project-root]/
├── CLAUDE.md                    ← rules, stack, hard rules
├── META_ARCHITECTURE.md         ← this file
├── .claude/
│   ├── plans/                   ← active plan files (session-name.md)
│   ├── HANDOFF.md               ← last session blockers + next action
│   └── rules/                   ← auto-loaded rule files
│       ├── ml-discipline.md
│       ├── automation.md
│       ├── session-workflow.md
│       └── tool-discipline.md
├── [feature-area]/
│   ├── [tool-1]/
│   └── [tool-2]/
├── experiments/                 ← ML experiment artifacts (if applicable)
│   ├── 001-baseline/
│   └── manifest.json
├── docs/
└── test_outputs/
```

---

## Experiment Tracking (ML Projects)

| Experiment | Date | Key Change | Best Metric | Notes |
|---|---|---|---|---|
| 001-baseline | [date] | [what was baseline] | [metric=value] | [notes] |
| 002-[name] | [date] | [what changed] | [metric=value] | [notes] |

**Best model:** `experiments/[NNN-name]/model.pkl`  
**Manifest:** `experiments/manifest.json` — single source of truth for which run is best and why

### Experiment Directory Structure

```
experiments/
  ├── 001-baseline/
  │   ├── hparams.json        ← all hyperparams for this run
  │   ├── metrics.csv         ← eval results (accuracy, F1, AUC, etc.)
  │   ├── train_log.txt       ← loss per epoch, warnings, timing
  │   ├── model.pkl           ← trained model artifact
  │   ├── data_manifest.json  ← dataset hash/version (for reproducibility)
  │   └── README.md           ← what was tested, findings, next steps
  └── manifest.json           ← { experiments: [...], best_model: "002-name" }
```

---

## Data Versioning

| Dataset | Version/Hash | Date | Location | Notes |
|---|---|---|---|---|
| [dataset name] | [git hash or date] | [date] | [path or URL] | [notes] |

---

## Automation Pipelines

| Pipeline | Trigger | Frequency | Entry Point | Status |
|---|---|---|---|---|
| [pipeline name] | [cron/manual/event] | [frequency] | `[script.py]` | ✅ Running |

---

## Known Gaps (Prioritized)

| Gap | Impact | Fix |
|---|---|---|
| [gap] | [what breaks] | [how to fix] |

---

## Open Questions

| Question | Why it matters |
|---|---|
| [question] | [stakes] |

---

*Update this document after every session that changes the system. If something contradicts this doc, update the doc.*
