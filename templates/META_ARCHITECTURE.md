# [Project Name] — Meta Architecture

> **Read this first** when starting any new session on this project.  
> Last updated: [date] ([session name])

This document maps every built tool, how they connect, when to use each one, and what still needs to be built. CLAUDE.md covers rules — this covers **what exists and how to navigate it**.

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

## Available Skills

| Skill | When to use |
|---|---|
| `thinking-partner` | Ideation before committing to an approach |
| `socratic-examiner` | Stress-test a plan before building |
| `assumption-archaeologist` | Surface hidden premises in a plan |
| `labarr-ml` | Any ML, forecasting, or analytics work |
| `sql-pro` | Complex SQL, CTEs, window functions |
| `pandas-pro` | DataFrame pipelines, data cleaning |
| `debugging-wizard` | Stuck on a bug |
| `patterns-guide` | Which pattern to use for a design decision |
| `[domain-skill]` | [when to use] |

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
