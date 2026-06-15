---
name: session-workflow
description: Meta-operational playbook for how to run a Claude Code session. Apply at
  the start of any session or when starting a new project. Covers conversational
  execution, plan-as-living-log, skills-first rule, and documentation standards.
triggers:
  - starting a new session
  - new project setup
  - beginning a plan
  - how should we work
  - session workflow
---

# Session Workflow

This skill defines how to operate within a Claude Code session — not what to build, but how to work.

## 1. Session Start Checklist

When starting any session:

1. **Read CLAUDE.md** — project rules, hard constraints, tech stack
2. **Read META_ARCHITECTURE.md** — what exists, data flow, known gaps, decision tree
3. **Check for a plan file** — `.claude/plans/` or project root; if one exists, read it before doing anything
4. **Check skills** — does the task match any registered skill? Invoke before writing code
5. **Name the session** — historical event on today's date, theme connects to the work

If CLAUDE.md or META_ARCHITECTURE.md don't exist yet, create them before starting work.

## 2. Skills First Rule

Before building anything, writing any code, or making any architectural decision — check if a skill exists for the task.

**Key skills to check:**
- `thinking-partner` — ideation, exploration, before committing to an approach
- `socratic-examiner` — stress-test a plan before building it
- `assumption-archaeologist` — surface hidden premises in a plan
- `labarr-ml` — any machine learning, forecasting, or analytics work
- `sql-pro` — complex SQL queries, CTEs, window functions
- `pandas-pro` — DataFrame pipelines, data cleaning
- `debugging-wizard` — when stuck on a bug
- `the-fool` — adversarial challenge before a major design decision

If a skill matches even 1% of the task, invoke it.

## 3. Conversational Execution Pattern

**Never run silently through a plan and present a wall of output at the end.**

The correct pattern:
- Surface findings at each phase transition before moving on
- When something unexpected comes up, say it out loud — don't just note it in a doc
- Ask "does this change anything?" at phase transitions
- Give the user natural pause points to redirect or ask questions
- If you were lazy or incomplete, the conversational style lets the user catch it

**The test:** Could the user catch a lazy step? If execution was silent, probably not. If conversational, yes.

## 4. Plan File as Living Log

A plan file is not just a checklist. It is a running log that survives context compression.

- After completing each phase, write key findings into the plan's Running Notes section before moving on
- Write what Phase N+1 will need to know: surprises, priority changes, things that contradict the original plan
- If the session ended right now and someone started fresh with only the plan file, could they pick up Phase N+1 without repeating Phase N? If yes, the notes are good.

**The test:** Notes should be good enough that a fresh session can resume cold.

## 5. Documentation Standards

- **CLAUDE.md** — rules, constraints, tech stack. Keep under 200 lines. Never put tool inventory here.
- **META_ARCHITECTURE.md** — what exists, data flow, decision tree, known gaps. Update after every session that changes the system.
- **Session docs** — `session_YYYY-MM-DD-[name].md` in project root or `docs/`
- **Plan files** — `.claude/plans/[session-name].md`

Update META_ARCHITECTURE.md before closing any session that added or changed a tool.

## 6. New Project Setup

When starting a new project from scratch:

1. Create `CLAUDE.md` from template (in `Desktop/claude-practices/templates/CLAUDE.md`)
2. Create `META_ARCHITECTURE.md` from template (in `Desktop/claude-practices/templates/META_ARCHITECTURE.md`)
3. Create `.gitignore` — always include `.env`, `venv/`, `__pycache__/`, `*.pyc`, raw data folders
4. Initialize git and create first branch — never work directly on main
5. Create `requirements.txt` and `venv/` before writing any Python

## 7. Context Management

There is no hard context limit. When context is climbing, flag it and ask — don't act unilaterally.

If the user wants to address it, suggest the right move based on what's happening:
- `/compact` with a summary hint — for general context bloat
- Offload batch work to a subagent — for repetitive processing tasks
- Fresh session with plan file as context — for major phase transitions

Never process large batches (50+ files) sequentially in the main session — use standalone scripts or subagents.
