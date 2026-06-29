# Global Workflow Rules

> Place this file at `~/.claude/CLAUDE.md` on your machine.
> Fill in the bracketed sections. Do NOT commit this file to any repo — it is personal to your machine.
> Personal context (who you are, clients, career) belongs in a `daniel-context`-style skill, not here.
> This file is operational only: toolkit map, session protocol, hard rules.
> Target: under 60 lines. It burns tokens every turn across every project.

---

## Cross-Project Toolkit — Always Check These First

> If there's even a 1% chance a skill applies, invoke it before doing anything else.

> Canonical per-project applicability lives in each project's `META_ARCHITECTURE.md` Toolkit table; full methodology in the `session-workflow` skill. This table is the always-on cross-project quick-reference only.

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
| [Your domain-specific task] | `/[your-skill]` |

---

## Session Protocol

**START:** invoke `/session-workflow` + `/superpowers:brainstorming`. Both. That order. Every session.
**END:** write `.claude/HANDOFF.md`. Update `META_ARCHITECTURE.md` if system changed.

---

## Hard Rules

- NEVER commit `.env` files or API keys to any repo
- NEVER push directly to main — always use a feature branch
- NEVER process 50+ items sequentially in the main session — use subagents or scripts
- Skills first. Always. No exceptions.
- [Add your own rules here]
