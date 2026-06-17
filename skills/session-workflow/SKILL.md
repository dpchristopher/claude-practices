---
name: session-workflow
description: Meta-operational playbook for how to run a Claude Code session. Apply at the start of any session, when starting a new project, or when you need to know how to work methodically. Covers session start/end protocol, skills-first rule, conversational execution, plan-as-living-log, TDD, ML eval discipline, and documentation standards.
triggers:
  - starting a new session
  - new project setup
  - beginning a plan
  - how should we work
  - session workflow
  - what's the protocol
  - how do I approach this
---

# Session Workflow

This skill defines how to operate within a Claude Code session — not what to build, but how to work.

## 1. Session Start — Non-Negotiable

When starting any session:

1. **Read CLAUDE.md** — rules, hard constraints, tech stack
2. **Read META_ARCHITECTURE.md** — what exists, data flow, known gaps, decision tree
3. **Check `.claude/plans/`** — if a plan exists, read it before doing anything
4. **Read `.claude/HANDOFF.md`** — last session blockers and next priority action
5. **Check skills** — does the task match a registered skill? Invoke before writing code
6. **Name the session** — historical event on today's date, theme connects to the work

If CLAUDE.md or META_ARCHITECTURE.md don't exist yet: create them before starting work.

---

## 2. Skills First — The Non-Negotiable Rule

Before building anything, check if a skill exists for the task.

| Task involves... | Invoke |
|---|---|
| Ideation or exploration | `thinking-partner` |
| Committing to a plan | `socratic-examiner` |
| Something feels off | `assumption-archaeologist` |
| Any ML, forecasting, analytics | `labarr-ml` |
| Complex SQL | `sql-pro` |
| DataFrame / data pipelines | `pandas-pro` |
| Stuck on a bug | `debugging-wizard` |
| Major design decision | `the-fool` |
| Choosing an approach or pattern | `patterns-guide` |

**Trio handoff:** thinking-partner (explore) → socratic-examiner (stress-test) → assumption-archaeologist (excavate hidden premises). Claude manages handoffs automatically.

If a skill matches even 1% of the task, invoke it.

---

## 3. Conversational Execution Pattern

**Never run silently through a plan and present a wall of output at the end.**

The correct pattern:
- Surface findings at each phase transition before moving on
- When something unexpected comes up, say it out loud — don't just note it in a doc
- Ask "does this change anything?" at phase transitions
- Give natural pause points to redirect or ask questions
- Reshape the plan mid-stream when findings change what matters

**The test:** Could the user catch a lazy step? Silent execution hides it. Conversational execution exposes it.

---

## 4. Plan File as Living Log

A plan file is not a checklist — it is a running log that survives context compression.

- After completing each phase, write key findings into the plan's Running Notes section before moving on
- Write what Phase N+1 needs to know: surprises, priority changes, contradictions
- If the session ended right now and someone started fresh with only the plan file, could they pick up Phase N+1 without repeating Phase N? If yes, notes are good.

---

## 5. TDD Pattern

**For code:**
1. Write failing test defining expected behavior
2. Write minimum implementation to pass
3. Refactor — don't change tests

**For ML:**
1. Define eval metric and acceptance threshold *before* training (e.g., "F1 > 0.82 on holdout")
2. Write evaluation code first
3. Train baseline
4. Evaluate against threshold — pass/fail
5. Tune only if you failed — never tune before establishing a baseline

Holdout test set is never touched during development. Used once: final evaluation before production.

---

## 6. Documentation Standards

- **CLAUDE.md** — rules, constraints, tech stack. Under 200 lines. No tool inventory.
- **META_ARCHITECTURE.md** — what exists, data flow, decision tree, known gaps. Update after every session that changes the system.
- **`.claude/plans/[session-name].md`** — active plan, living log with running notes
- **`.claude/HANDOFF.md`** — replaced each session; last session blockers + next action
- **`.claude/rules/*.md`** — detailed rules that auto-load; keep CLAUDE.md lean by moving detail here

---

## 7. New Project Setup

When starting a new project from scratch:

1. Create `CLAUDE.md` from template (`claude-practices/templates/CLAUDE.md`)
2. Create `META_ARCHITECTURE.md` from template (`claude-practices/templates/META_ARCHITECTURE.md`)
3. Copy `.claude/rules/` from template (`claude-practices/templates/.claude/rules/`)
4. Create `.gitignore` — always include `.env`, `venv/`, `__pycache__/`, `*.pyc`, raw data folders
5. Initialize git and create first branch — never work directly on main
6. Create `requirements.txt` with pinned versions before writing any Python
7. For ML projects: create `experiments/` directory structure

---

## 8. Context Management

There is no hard limit. When context is climbing, flag it and ask — never act unilaterally.

Options when context is high:
- `/compact` with a summary hint — for general bloat
- Offload batch work to a subagent — for repetitive processing
- Fresh session with plan file + HANDOFF as context — for major phase transitions

Never process 50+ files sequentially in the main session — use standalone scripts or subagents.

---

## 9. Session End — Every Session

Before closing any session:

1. Update `META_ARCHITECTURE.md` if any tool, data flow, or gap changed
2. **If any skills were added, removed, or renamed:** update the Toolkit table in `META_ARCHITECTURE.md` — add the new row, remove the stale one. The table is the single source of truth for which skills apply to this project. A stale table means plans won't embed the right skills next session.
3. Run `/code-review` if significant code was written
4. Write `.claude/HANDOFF.md` (replace, not append):
   ```
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
5. Commit with session name in commit message: `"[session-name]: [what and why]"`

---

## 10. ML / Automation Sessions

**Additional start steps for ML sessions:**
- Invoke `/labarr-ml` before designing any pipeline
- Review `experiments/manifest.json` for current best model
- Check `data_manifest.json` in latest experiment for dataset version

**Additional end steps for ML sessions:**
- Save experiment artifacts to `experiments/NNN-name/` before closing
- Update `experiments/manifest.json` with this run's results
- Document findings in `experiments/NNN-name/README.md`

**For automation sessions:**
- Test all scripts locally before scheduling (see `.claude/rules/automation.md`)
- Verify idempotence before marking done
- Update automation pipeline table in `META_ARCHITECTURE.md`
