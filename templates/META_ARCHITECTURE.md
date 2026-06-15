# [Project Name] — Meta Architecture

> **Read this first** when starting any new session on this project.
> Last updated: [date] ([session name])

This document maps every built tool, how they connect, when to use each one, and what
still needs to be built. It is the single source of truth for Claude Code sessions — not
CLAUDE.md (which covers coding rules). This covers **what exists and how to navigate it**.

---

## Tool Inventory

| Tool | Location | Entry Point | Status | Tests |
|---|---|---|---|---|
| **[Tool Name]** | `[path/to/tool/]` | `[run command or entry file]` | ✅ Working | [N passing] |
| **[Tool Name]** | `[path/to/tool/]` | `[run command or entry file]` | 🚧 In progress | — |

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

## [MCP Server / External Data Source] Tools

| Tool | Data Source | Status | Notes |
|---|---|---|---|
| `[tool_name(params)]` | [table or API] | ✅ Live | [notes] |
| `[tool_name(params)]` | [table or API] | ⚠ Built | [caveat] |

**Key relationships:**
- `[primary key field]` = primary key across all tables
- `[FK field]` in [System A] = `[FK field]` in [System B]

---

## Available Connectors (external systems — access method noted)

| Connector | What it accesses | How to use |
|---|---|---|
| [System name] | [what's in it] | [Claude Code MCP / Claude chat only / etc.] |

---

## Available Skills (globally registered at `~/.claude/skills/`)

| Skill | Trigger | When to use |
|---|---|---|
| `thinking-partner` | "help me think through X" | Ideation before committing |
| `socratic-examiner` | "challenge this" | Stress-test a plan before building |
| `assumption-archaeologist` | "what am I missing" | Surface hidden assumptions |
| `[domain-skill]` | [trigger phrase] | [when to use] |

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
→ [approach for small batches]
→ [approach for large batches]
→ Never run [N]+ [items] sequentially in the main Claude Code session

---

## Codebase Layout

```
[project-root]/
├── CLAUDE.md                    ← coding rules, tech stack, hard rules
├── META_ARCHITECTURE.md         ← this file — tool map, data flow, decision tree
├── [feature-area]/
│   ├── [tool-1]/
│   │   ├── [entry-point].py     ← [description]
│   │   └── tests/               ← [N] passing tests
│   ├── [tool-2]/
│   └── [tool-3]/
├── docs/                        ← reference files, notes
└── test_outputs/                ← generated outputs, batch results
```

**What to ignore:**
- `[folder]` — [why it's not relevant]

---

## Known Gaps (Prioritized)

| Gap | Impact | Fix |
|---|---|---|
| [gap description] | [what breaks without it] | [how to fix it] |
| [gap description] | [what breaks without it] | [how to fix it] |

---

## Subagent Pattern for Batch Processing

For large batch runs ([N]+ items), don't process sequentially in the main Claude Code
session — context accumulates and the model degrades. Instead:

```python
# Wrong: sequential in main session (context blows up)
for item in large_list:
    result = process(item)  # each result stays in context

# Right: standalone script outside Claude Code
# OR one subagent per item (only summary returns to main context)
```

Use standalone scripts for full-corpus runs. Claude Code is for interactive work
and small targeted test runs.

---

## Open Questions

| Question | Why it matters |
|---|---|
| [question] | [why the answer changes what you build] |

---

*This document is updated after every session that changes the system. If you find
something that contradicts this doc, update this doc rather than working around it.*
