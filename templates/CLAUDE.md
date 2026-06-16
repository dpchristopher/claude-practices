# [Project Name] — Developer Context

> **At the start of every session:** Read @META_ARCHITECTURE.md, check `.claude/plans/` for an active plan, and read `.claude/HANDOFF.md` for last session blockers. Do this before asking what to work on.

---

## Who I am
[Your role, company, what the project does. 1-2 sentences.]

---

## Hard Rules — Never Break These

- **NEVER commit .env files or API keys to GitHub**
- **NEVER hardcode credentials, connection strings, or tokens in any file**
- **NEVER push directly to main — always use a feature branch**
- **ALWAYS add .env, venv/, __pycache__/, raw data dirs to .gitignore before first commit**
- **NEVER process 50+ items sequentially in the main Claude Code session — use scripts or subagents**
- [Add project-specific rules here]

---

## Session Start Protocol

At the start of every session Claude must:

1. Read `META_ARCHITECTURE.md` — what exists, tools, data flow, known gaps
2. Check `.claude/plans/` — is there an active plan? Read it.
3. Read `.claude/HANDOFF.md` — last session blockers and next action
4. Check skills — does the task match a registered skill? Invoke it before writing code.
5. Name the session — historical event on today's date, theme connects to the work

If META_ARCHITECTURE.md or CLAUDE.md don't exist yet, create them before starting work.

---

## Skills First

Before building anything, check if a skill exists. If a skill matches even 1% of the task, invoke it.

| Skill | When to invoke |
|---|---|
| `thinking-partner` | Ideation, exploration, before committing to any approach |
| `socratic-examiner` | Stress-test a plan before building it |
| `assumption-archaeologist` | Something feels off but you can't name why |
| `labarr-ml` | Any ML, forecasting, analytics, or modeling work |
| `sql-pro` | Complex queries, CTEs, window functions, EXPLAIN |
| `pandas-pro` | DataFrame pipelines, data cleaning, memory optimization |
| `debugging-wizard` | Stuck on a bug — reproduce → isolate → hypothesize → fix |
| `the-fool` | Adversarial challenge before any major design decision |
| `patterns-guide` | Designing an approach and need to know which pattern fits |
| `session-workflow` | Need the full methodology reference for this session |

**Trio handoff:** thinking-partner (explore) → socratic-examiner (stress-test) → assumption-archaeologist (excavate hidden premises). Claude manages the handoffs — you don't need to.

---

## Session End Protocol

At the end of every session, write `.claude/HANDOFF.md`:

```markdown
# Handoff — [Date] [Session Name]
## Completed
- [bullet]
## Blockers / didn't work
- [bullet]
## Next action (priority 1)
- [bullet]
## Test state
- [bullet]
## Data/artifact state (if ML)
- [bullet]
```

This file is replaced each session. It is the first thing read at the next session start.

---

## Division of Responsibility

- **Claude Code** → builds tools, runs scripts, queries databases, edits files, runs tests
- **[Other tool/system]** → [what it handles that Claude Code cannot]
- When a task requires [external system] — stop and flag it

---

## Tech Stack

- **[Primary language]** — [version, key libs]
- **[Database]** — [connection method, driver]
- **[Framework]** — [what it does in this project]
- **[Other]** — [purpose]

---

## Session Naming Convention

Historical event on today's date. Theme connects to the work.  
Add to commit messages and session doc filenames.

Example: June 16 → "House Divided" (foundational restructuring session)

---

## [Language] Rules

- [Formatting tool] for formatting
- Virtual environment for every project
- ALL credentials in .env — load with python-dotenv
- requirements.txt in every project with pinned versions

---

## ML / Automation Rules

- See `.claude/rules/ml-discipline.md` for experiment tracking, reproducibility, pitfalls
- See `.claude/rules/automation.md` for idempotence, error handling, scheduling
- Always invoke `/labarr-ml` before designing any ML pipeline
- Experiment artifacts live in `./experiments/NNN-name/` — never scattered

---

## Key Terminology

| Term | Meaning |
|---|---|
| [term] | [definition] |

---

## File Conventions

- Session docs → `session_YYYY-MM-DD-[name].md`
- Plans → `.claude/plans/[session-name].md`
- Handoff → `.claude/HANDOFF.md` (replaced each session)
- Rules → `.claude/rules/*.md` (auto-loaded with CLAUDE.md)
- Experiments → `experiments/NNN-name/` (if ML project)

---

*See META_ARCHITECTURE.md for tool map, data flow, decision tree, and known gaps.*
