# [Project Name] — Developer Context

> **Read META_ARCHITECTURE.md first** — it maps every built tool, run commands,
> data flow, and decision tree. CLAUDE.md covers rules; META_ARCHITECTURE.md
> covers what exists.

---

## Who I am
[Your role, your company, what the project does in 1-2 sentences.]

---

## Hard Rules — Never Break These

- **NEVER commit .env files or any API keys to GitHub**
- **NEVER hardcode database connection strings, passwords, or tokens in any file**
- **NEVER push directly to main — always use a feature branch**
- **ALWAYS add .env and venv/ to .gitignore before first commit**
- [Add project-specific rules here]

---

## How to Operate
Invoke `session-workflow` at the start of every session — it covers conversational execution, plan-as-living-log, skills-first rule, and documentation standards.

## Skills First

Before building anything, check if a skill exists for the task. If a skill matches, invoke it before writing any code.

Key skills to remember:
- `thinking-partner` — before ideation / exploration
- `socratic-examiner` — before committing to a plan
- `assumption-archaeologist` — when something feels off but you can't name why
- `superpowers:brainstorming` — required before building new features
- `code-review` — run before merging any feature branch

---

## Division of Responsibility

- **Claude Code** → builds tools, queries databases, creates files, runs scripts
- **Claude desktop chat** → [external connectors your project uses, e.g. CRM, SharePoint]
- **[MCP server name]** → [what it bridges]

When a task requires [external system] — stop and flag it. Claude Code cannot access those connectors.

---

## Tech Stack

- **[Primary database]** — [connection details, driver]
- **[CRM / external system]** — [access method]
- **Python** — all data pipelines, [framework], parsers
- **[Web framework]** — web UI and analytics
- **[File formats]** — [what you generate]

---

## Session Naming Convention

Each work session is named after a historical event on that calendar date. The theme
should connect thematically to the work being done. Add the session name to commit
messages and session doc filenames.

Example: June 15 → "Magna Carta" (foundational documents session)

---

## Python Rules

- Use Black for formatting
- Use a virtual environment for every project: `python -m venv venv`
- Store ALL credentials in .env files — load with python-dotenv
- Always include requirements.txt in every project

---

## Key Terminology

| Term | Meaning |
|---|---|
| [term] | [definition] |
| [term] | [definition] |

---

## Database Quick Reference

**Server:** [address] · [auth method] · [driver]

| Database | Purpose | Use |
|---|---|---|
| [db name] | [purpose] | [read/write rules] |

**Key tables:** [list primary tables and what they contain]

**Primary key:** [field name] across all tables

---

## File Conventions

- [feature area] → `[folder]/`
- SQL scripts → `[folder]/SQL Queries/`
- Session docs → `session_YYYY-MM-DD[-name].md`
- Test outputs → `test_outputs/`

---

*See META_ARCHITECTURE.md for tool map, data flow, and what to build next.*
