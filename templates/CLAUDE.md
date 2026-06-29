# [Project Name] — Developer Context

## Reading Order — Session Start

> **MANDATORY (the SessionStart hook puts these in context — confirm they're current):**
> 1. `CLAUDE.md` (this file) — rules, stack, hard rules
> 2. `META_ARCHITECTURE.md` (summary) — what exists, data flow, known gaps
> 3. Active plan in `.claude/plans/` — current work
> 4. `INVARIANTS.md` (in full) — durable contracts that must NOT break
> 5. `.claude/HANDOFF.md` (in full) — last session blockers + next action
>
> **ON-DEMAND (named here; read when the work touches them):**
> - `.claude/rules/*.md` — auto-load with this file; detailed doctrine
> - `experiments/`, `docs/` — ML artifacts, deeper references

---

## Project

[One sentence: what this project does and who it's for.]

**Stack:** [language/version] · [framework] · [database] · [key libs]

---

## Hard Rules

- NEVER commit `.env` files or credentials
- NEVER push directly to main — always use a feature branch
- NEVER process 50+ items sequentially — use scripts or subagents
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

Update `META_ARCHITECTURE.md` if tools, data flow, or toolkit changed.

---

## Division of Responsibility

- **Claude Code** → builds, scripts, queries, edits, tests
- **[External system]** → [what it handles]

---

*Detail lives in `.claude/rules/*.md` — auto-loads with CLAUDE.md. Keep this file under 80 lines.*

---

## Imports & Keeping This File Lean

CLAUDE.md loads every session — only put things here that apply broadly. Move volatile or
occasionally-relevant material (long roadmaps, big reference tables, detailed specs) OUT of
this file and pull it in on demand with an `@`-import:

```
See the roadmap in @docs/roadmap.md and API notes in @docs/api-notes.md
```

`@path` references are read when relevant rather than loaded every turn. The prune test for
anything in this file: *would removing it cause Claude to make a mistake?* If not, cut it or
move it behind an `@`-import. A lean CLAUDE.md is one whose rules actually get followed —
bloat causes rules to be ignored.
