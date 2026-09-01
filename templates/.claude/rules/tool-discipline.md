# Tool Discipline Rules

> Auto-loaded at session start. Governs which tools to reach for and when.

> **Stack note:** Examples below use the Python default (`pytest`, `pyright`, `pip`). Substitute your stack's equivalents — e.g. `vitest`/`tsc`/`npm` for TypeScript, `go test`/`go vet` for Go. The *discipline* (tests before+after, type-check before runtime, pin deps) is language-agnostic; the commands are illustrative.

---

## Tool Priority Order

Reach for tools in this order — don't skip ahead:

1. **Git** — version control first, always; feature branch before any work
2. **Tests** — pytest before and after changes; red → green → refactor
3. **LSP / type checking** — pyright, pylance catch errors before runtime
4. **pandas-pro / sql-pro** — data work gets the right skill
5. **debugging-wizard** — stuck on a bug? invoke before thrashing
6. **playwright** — browser-based debugging for web UIs
7. **Subagents** — batch processing, parallel research, context offload; state the child count and per-child budget before dispatching (see *Choosing an isolation mechanism*)
8. **MCP tools** — when a dedicated MCP exists for the target system, use it; don't call external APIs directly

---

## Choosing an isolation mechanism

One question: *I need work done elsewhere — which mechanism, and what does it cost?*

| Mechanism | Context it gets | Reach for it when | Cost |
|---|---|---|---|
| Main session | everything | interactive, small, needs live feedback | free |
| **Fork** (`/subtask`; on by default in interactive sessions) | full conversation, system prompt, tools, model; **shares the prompt cache** | a side quest that must keep everything already established | cheapest branch |
| **Fresh subagent** (`Agent`) | fresh and isolated | you need genuine independence, or context kept *out* | full cold-start per child — **state the child count first** |
| **Cross-session message** | none — a thin text payload | the other work has its own long-lived session, repo, or machine state | thin payload is the point |
| **Workflow tool** | per-agent, orchestrated | more than ~4 children, or the fan-out should be rerunnable and visible | real caps + budget visibility |

**Fork when you need the context; fresh subagent when you need the independence.**

**A fork is not a valid maker≠checker checker.** It inherits the maker's context and therefore
the maker's blind spots. This is the most important consequence of fork being on by default
(source: `SOURCES.md#subagent-limits`) — it can quietly turn a real verification step into
self-review.

**Thin payloads are a feature.** A cross-session message carries text only — never history or
files. MAST measures inter-agent misalignment (context collapse, format mismatch when passing
messages) at 32.35% of failures and calls it hardest to debug (source: `SOURCES.md#mast`).

---

## Delegation packet — external or irreversible dispatches only

When a dispatch (fork, subagent, cross-session message, or Workflow) will touch an external
system, spend budget, or take an action from the Prohibited/Explicit-permission-required
categories, name these five before dispatching. Gru's plan already owns
objective/evidence/done-criteria for the phase as a whole — this only covers what it doesn't
(source: `SOURCES.md#agent-reliability`):

| Field | Answers |
|---|---|
| Owner | which agent executes, and who is accountable for the outcome |
| Allowed effects | the explicit boundary — what it may touch, what it may NOT (write vs. read-only, spend cap, no push/deploy) |
| Budget | token/turn/cost ceiling — reuses `loop-cost-discipline.md`'s existing estimate-before-dispatch rule, not a second budgeting system |
| Escalation trigger | the specific condition that halts and asks the user — never a vague "if unsure" |
| Receipt | one line into the plan's Running Notes on completion — what happened, not just that it happened |

Skip this for ordinary in-scope work. Regular-category actions inside the main session or a
normal fork don't need a packet — this exists for the boundary, not for every delegation.

---

## Every named agent must earn its place
Don't accumulate specialist subagents by role-flavor alone ("we should have an X agent").
A named agent earns its place only via a real context isolation or a distinct model/
permission boundary — e.g. a fresh-context checker (maker≠checker needs separate context to
be honest), a cheaper model for mechanical work, or a narrower tool/permission scope than
the main session. If a "new agent" would just be a prompt variation running in the same
context with the same tools, it should be a skill instead, not an agent.

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

_Python example — swap in your test runner:_

```bash
pytest tests/ -v                    # run all tests
pytest tests/test_specific.py -v   # run one file
pytest -k "test_name" -v           # run one test
```

---

## Light vs Heavy Research — Route to the Right Model

**The tell:** if a wrong answer would be immediately obvious, it's light (cheap model /
Stuart-explorer on Haiku). If a wrong answer would quietly mislead a decision, it's heavy
(Opus / Dave-researcher, or Sonnet for moderate).

| | Light (Stuart / Haiku) | Heavy (Dave / Opus, or Sonnet mid) |
|---|---|---|
| Question shape | "Where is X?" "Which file does Y?" | "Best approach across these sources?" "Verify + recommend." |
| Sources | One known place | Many, needs synthesis |
| Output | A fact / path / yes-no | A judgment / ranked recommendation / accuracy verdict |
| Failure cost | Low (obvious if wrong) | High (quietly misleads) |

Route light lookups to `stuart-explorer` to conserve heavier models on a large codebase.
Reserve Opus / `dave-researcher` for synthesis, verification, and recommendations.

---

## Docstrings & Comments

Default to none. A well-named function or module already says what it does; a docstring
should only add what the name can't — the non-obvious WHY.

**Write one when:**
- The module/function is a public API surface others will import
- There's a hidden constraint, invariant, or workaround a reader could easily violate
- The governing rule of a whole module isn't inferable from any single function name
  (e.g. `surgical/compare.py`'s module docstring states the core principle — "when in
  doubt, report a change" — that no individual function's name conveys)

**Skip it when:**
- The name and signature already say everything (`get_user_by_id(id)`)
- It would just restate the code in prose

**Length:** one line, unless the WHY genuinely needs more. A governing-principle module
docstring is a legitimate exception, not a violation of this rule. What's never
acceptable is a docstring that restates the WHAT across multiple paragraphs.

Same test as the `stop-slop` skill's density check: if a reader who deleted the docstring
would lose real information, keep it. If they'd lose only ceremony, cut it.
