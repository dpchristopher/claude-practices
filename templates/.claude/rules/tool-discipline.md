# Tool Discipline Rules

> Auto-loaded at session start. Governs which tools to reach for and when.

---

## Tool Priority Order

Reach for tools in this order — don't skip ahead:

1. **Git** — version control first, always; feature branch before any work
2. **Tests** — pytest before and after changes; red → green → refactor
3. **LSP / type checking** — pyright, pylance catch errors before runtime
4. **pandas-pro / sql-pro** — data work gets the right skill
5. **debugging-wizard** — stuck on a bug? invoke before thrashing
6. **playwright** — browser-based debugging for web UIs
7. **Subagents** — batch processing, parallel research, context offload
8. **MCP tools** — when a dedicated MCP exists for the target system, use it; don't call external APIs directly

---

## When to Use Subagents vs. Main Session

| Use subagents when... | Stay in main session when... |
|---|---|
| Processing 50+ files, records, or URLs | Work is interactive and needs back-and-forth |
| Research that produces lots of output | Change set is small and targeted |
| Parallel independent tasks | You need live feedback on results |
| Risk of context bloat | Context is still lean |

Each subagent starts fresh. Only the summary returns to main context. This keeps main session lean.

---

## Context Budget Awareness

Watch for context climbing. When it does:

- **Flag it** — "Context is getting high (~50+ operations). Want to address it?"
- **Don't act unilaterally** — suggest options, let user decide
- **Options to suggest:**
  - `/compact` with a summary hint (e.g., `/compact Working on auth bug in user.py`)
  - Offload batch work to a subagent
  - Fresh session with plan file + HANDOFF as context

Never autocompact without flagging first. The user decides.

---

## MCP Tool Priority

When a task touches an external system:

1. Check if an MCP server exists for it (check available tools)
2. If yes: use the MCP tool — it handles auth, rate limits, formatting, error handling
3. If no: use a script with proper API client library
4. Never call external APIs directly via raw HTTP when an MCP tool exists for it

---

## Git Workflow

```bash
# Before any work session
git status                          # clean slate?
git checkout -b [session-name]      # feature branch, named after session

# After each logical unit of work
git add [specific files]            # never git add -A blindly
git commit -m "[session-name]: [what and why]"

# Before merging
git diff main                       # review everything
/code-review                        # run the skill
```

Never commit:
- `.env` files
- `venv/` or `__pycache__/`
- Raw data files (add to .gitignore)
- Model artifacts (use experiments/ dir with manifest)

---

## Test Discipline

- Run tests before starting work (establish baseline)
- Run tests after each change (catch regressions immediately)
- Never commit with failing tests
- If tests don't exist for the area you're changing: write them first

```bash
pytest tests/ -v                    # run all tests
pytest tests/test_specific.py -v   # run one file
pytest -k "test_name" -v           # run one test
```
