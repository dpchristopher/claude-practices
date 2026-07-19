# Global Workflow Rules

> Place this file at `~/.claude/CLAUDE.md` on your machine.
> Fill in the bracketed sections. Do NOT commit this file to any repo — it is personal to your machine.
> Personal context (who you are, clients, career) belongs in a `daniel-context`-style skill, not here.
> This file is operational only: toolkit map, session protocol, hard rules.
> Target: under 60 lines. It burns tokens every turn across every project.

---

## Cross-Project Toolkit — Always Check These First

> If there's even a 1% chance a skill applies, invoke it before doing anything else.

| When... | Invoke |
|---|---|
| Starting ANY session or new project | `/session-workflow` then `/superpowers:brainstorming` |
| Starting a new project from scratch | `/init` |
| Exploring options before committing | `/thinking-partner` |
| Any ML, forecasting, analytics, modeling | `/labarr-ml` |
| AI integration / Claude API work | `/claude-api` |
| Data pipelines, pandas, cleaning | `/pandas-pro` |
| Complex SQL | `/sql-pro` |
| Stuck on a bug | `/debugging-wizard` |
| Major design decision | `/the-fool` |
| Stress-testing a plan | `/socratic-examiner` |
| Something feels off | `/assumption-archaeologist` |
| Building an MCP server | `/mcp-builder` |
| Significant code written | `/code-review` |
| Before marking any non-trivial change done | `bob-verifier` (fresh-eyes checker) |
| Grading a batch of model/agent/ML outputs | `carl-evals` (binary pass/fail) |
| [Your domain-specific task] | `/[your-skill]` |

---

## Session Protocol

**START:** invoke `/session-workflow` + `/superpowers:brainstorming`. Both. That order. Every session.
**END:** write `.claude/HANDOFF.md`; append one row to `~/.claude/session-metrics.md`. Update `META_ARCHITECTURE.md` if system changed.

---

## Hard Rules

- NEVER commit `.env` files or API keys to any repo
- NEVER push directly to main — always use a feature branch
- NEVER process 50+ items sequentially in the main session — use subagents or scripts
- NEVER claim done/fixed/passing without pasted evidence (command + output) — dispatch `bob-verifier` on non-trivial work
- NEVER run unattended loops with permission prompts disabled, or let them touch prod data, secrets, or `git push` to main
- Log one row per session to `~/.claude/session-metrics.md`; review monthly, keep/cut/revise one practice
- Skills first. Always. No exceptions.
- [Add your own rules here]
