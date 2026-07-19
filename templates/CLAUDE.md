# [Project Name] — Developer Context

> **Session start:** Read META_ARCHITECTURE.md → check `.claude/plans/` → read `.claude/HANDOFF.md`. Do this before asking what to work on.

---

## Project

[One sentence: what this project does and who it's for.]

**Stack:** [language/version] · [framework] · [database] · [key libs]

---

## Hard Rules

- NEVER commit `.env` files or credentials
- NEVER push directly to main — always use a feature branch
- NEVER process 50+ items sequentially — use scripts or subagents
- NEVER claim done/fixed/passing without pasted evidence (command + output) — dispatch `bob-verifier` on non-trivial work
- NEVER let unattended loops touch prod data, secrets, or `git push` to main (see `rules/safe-autonomy.md`)
- ALWAYS add `.env`, `venv/`, `__pycache__/`, raw data dirs to `.gitignore`
- [Add project-specific rules here]

---

## Session Start — Mandatory

1. Invoke `/session-workflow` — reads Toolkit, sets protocol
2. Invoke `/superpowers:brainstorming` — explore before building
3. Read `META_ARCHITECTURE.md`, active plan, `HANDOFF.md`
4. Name the session — historical event on today's date, theme connects to the work

---

## Toolkit — Skills for This Project

> Before building anything: check if a skill applies. Invoke if there's even a 1% chance it fits.

| When... | Invoke |
|---|---|
| Ideation, exploring options | `/thinking-partner` |
| Stress-testing a plan | `/socratic-examiner` |
| Something feels off | `/assumption-archaeologist` |
| Any ML, forecasting, analytics | `/labarr-ml` |
| Claude API / AI integration | `/claude-api` |
| Data pipelines, pandas | `/pandas-pro` |
| Complex SQL | `/sql-pro` |
| Stuck on a bug | `/debugging-wizard` |
| Major design decision | `/the-fool` |
| Significant code written | `/code-review` |
| Before marking work done | `bob-verifier` (fresh-eyes checker) |
| Grading a batch of outputs (pass/fail) | `carl-evals` |
| [Project-specific task] | `/[skill]` |

---

## Session End

Write `.claude/HANDOFF.md` (replace, not append):

```
## Completed
## Blockers
## Next action (priority 1)
## Test state
```

Append one row to `.claude/session-metrics.md` (goal met? · rollback? · interventions · friction · practices). Review monthly.

Update `META_ARCHITECTURE.md` if tools, data flow, or toolkit changed.

---

## Division of Responsibility

- **Claude Code** → builds, scripts, queries, edits, tests
- **[External system]** → [what it handles]

---

*Detail lives in `.claude/rules/*.md` — auto-loads with CLAUDE.md. Keep this file under ~90 lines.*
