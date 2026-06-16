# Coolest Thing Since Chrystal Ball
### Claude Code Practices, Loadout & Patterns

**Version:** 1.0 — June 15, 2026 (Magna Carta session)
**Purpose:** Personal reference and portable starter kit. Upload this to Claude at the
start of any new project to get the full setup instantly.

---

## 0. My Personal Loadout — Install This First

Everything here is already vetted. On a new machine, run these commands and you're back
to full power immediately.

### Plugins (`~/.claude/settings.json` → `enabledPlugins`)

```json
{
  "enabledPlugins": {
    "claude-md-management@claude-plugins-official": true,
    "claude-code-setup@claude-plugins-official": true,
    "frontend-design@claude-plugins-official": true,
    "github@claude-plugins-official": true,
    "legalzoom@claude-plugins-official": true,
    "playwright@claude-plugins-official": true,
    "playground@claude-plugins-official": true,
    "skill-creator@claude-plugins-official": true,
    "superpowers@claude-plugins-official": true,
    "mcp-server-dev@claude-plugins-official": true,
    "session-report@claude-plugins-official": true,
    "pyright-lsp@claude-plugins-official": true
  },
  "extraKnownMarketplaces": {
    "claude-plugins-official": {
      "source": {
        "source": "git",
        "url": "https://github.com/anthropics/claude-plugins-official.git"
      }
    }
  },
  "autoUpdatesChannel": "latest",
  "effortLevel": "medium",
  "skipWorkflowUsageWarning": true
}
```

> ⚠️ `extraKnownMarketplaces` is required — without it Claude Code won't know where
> to find the `claude-plugins-official` plugins and none of them will install.

| Plugin | Why I use it |
|---|---|
| superpowers | Core workflow skills — brainstorming, plan writing, verification, subagents |
| claude-md-management | Keeps CLAUDE.md clean and up to date |
| github | PR review, issue management from Claude Code |
| playwright | Interactive browser debugging for web UIs |
| mcp-server-dev | Building and extending MCP servers |
| session-report | Auto-generates session summaries |
| pyright-lsp | Python type checking and hover docs |
| skill-creator | Build new skills without leaving Claude Code |
| frontend-design | UI component work |
| playground | Experimenting with prompts and ideas |
| claude-code-setup | Project setup automation |
| legalzoom | Contract review when needed |

### dx plugin — run this command once in any Claude Code session

```
/plugin install dx@ykdojo
```

Adds `/dx:handoff` — writes a HANDOFF.md at end of session so the next session picks
up exactly where you left off. The most underrated quality-of-life tool.

### Skills (`~/.claude/skills/` — one folder per skill with SKILL.md inside)

**Thinking-partner trio** (original — no prior art for this exact combination):

```powershell
# Files live in this starter kit at /skills/
$dest = "$env:USERPROFILE\.claude\skills"
$src = "path\to\claude-practices\skills"
foreach ($s in @("thinking-partner","socratic-examiner","assumption-archaeologist")) {
    New-Item -ItemType Directory -Force "$dest\$s" | Out-Null
    Copy-Item "$src\$s-SKILL.md" "$dest\$s\SKILL.md"
}
```

**Skills from Jeffallan/claude-skills** (download from GitHub):

```powershell
$base = "https://raw.githubusercontent.com/Jeffallan/claude-skills/main/skills"
$dest = "$env:USERPROFILE\.claude\skills"
foreach ($s in @("sql-pro","mcp-developer","pandas-pro","the-fool","debugging-wizard")) {
    New-Item -ItemType Directory -Force "$dest\$s" | Out-Null
    Invoke-WebRequest "$base/$s/SKILL.md" -OutFile "$dest\$s\SKILL.md" -UseBasicParsing
}
```

| Skill | Why I use it |
|---|---|
| thinking-partner | Ideation and exploration before committing to anything |
| socratic-examiner | Stress-tests a plan or position before I build it |
| assumption-archaeologist | Surfaces hidden premises — catches things that feel obvious but aren't |
| session-workflow | Full methodology reference — session start/end protocol, skills-first rule, TDD, ML eval, context management |
| patterns-guide | Decides which pattern fits a given situation — 10 core patterns + ML/automation variants |
| sql-pro | Complex SQL queries, CTEs, EXPLAIN analysis |
| mcp-developer | Building new MCP server tools |
| pandas-pro | Data pipeline and DataFrame work |
| the-fool | 5-mode adversarial challenge — pre-mortem, red team, steelman |
| debugging-wizard | Systematic debugging when I'm stuck |
| labarr-ml | ML/analytics methodology — 12-step LaBarr workflow, interpretability-first, time series, risk, credit modeling |

### VSCode Extensions (`code --list-extensions` to verify, `code --install-extension <id>` to reinstall)

| Extension ID | What it does |
|---|---|
| `anthropic.claude-code` | Claude Code IDE integration |
| `bagaducedigital.deluge-lang` | Deluge syntax highlighting (low-code platform scripting) |
| `dbaeumer.vscode-eslint` | ESLint linting for JS/React |
| `dsznajder.es7-react-js-snippets` | React/JSX shorthand snippets |
| `eamodio.gitlens` | Git blame, history, and branch visualization |
| `esbenp.prettier-vscode` | Auto-format JS/TS/HTML/CSS on save |
| `formulahendry.auto-rename-tag` | Auto-rename matching HTML/JSX tags |
| `gdp.delugelang` | Second Deluge extension (backup highlighting) |
| `humao.rest-client` | HTTP request runner (.http files) — REST API testing |
| `ms-mssql.mssql` | MSSQL connection, query runner (SQL Server databases) |
| `ms-python.black-formatter` | Black auto-format Python on save |
| `ms-python.python` | Core Python extension |
| `ms-python.vscode-pylance` | Python intellisense and type checking |
| `ms-toolsai.jupyter` | Jupyter notebook support |
| `mtxr.sqltools` | SQL explorer / multi-DB client |
| `mtxr.sqltools-driver-mssql` | MSSQL driver for SQLTools |
| `oderwat.indent-rainbow` | Colored indentation guides |
| `rangav.vscode-thunder-client` | GUI REST client (alternative to REST Client) |
| `usernamehw.errorlens` | Inline error messages right on the failing line |

To bulk reinstall on a new machine:
```powershell
$exts = @(
  "anthropic.claude-code","bagaducedigital.deluge-lang","dbaeumer.vscode-eslint",
  "dsznajder.es7-react-js-snippets","eamodio.gitlens","esbenp.prettier-vscode",
  "formulahendry.auto-rename-tag","gdp.delugelang","humao.rest-client",
  "ms-mssql.mssql","ms-python.black-formatter","ms-python.python",
  "ms-python.vscode-pylance","ms-toolsai.jupyter","mtxr.sqltools",
  "mtxr.sqltools-driver-mssql","oderwat.indent-rainbow",
  "rangav.vscode-thunder-client","usernamehw.errorlens"
)
foreach ($e in $exts) { code --install-extension $e }
```

**labarr-ml skill** (local — files at `Desktop\Skills\Labarr Skill\`):

```powershell
$dest = "$env:USERPROFILE\.claude\skills\labarr-ml"
New-Item -ItemType Directory -Force $dest | Out-Null
$src = "$env:USERPROFILE\Desktop\Skills\Labarr Skill"
Copy-Item "$src\SKILL.md","$src\methodology.md","$src\techniques.md","$src\domains.md" $dest
```

### Future installs to revisit

- **Hermes-agent** (`github.com/nousresearch/hermes-agent`) — persistent self-improving
  agent with cross-session memory. Revisit when production data is accumulating and you
  need a long-lived analyst rather than per-session work.

---

## How to Use This Document

1. Read Section 1 (Mental Models) before anything else
2. Copy the CLAUDE.md template (Section 2) to your project root and fill in the blanks
3. Create META_ARCHITECTURE.md (Section 3 template) after you have a working tool or two
4. Register the thinking-partner skill trio globally (Section 4) — one-time setup per machine
5. Apply the patterns (Section 5) as you build

---

## 1. Mental Models

### The Command → Agent → Skill Pattern

Everything in Claude Code follows this orchestration hierarchy:

```
User command or natural language request
  ↓
Agent (main Claude Code session or subagent)
  ↓
Skills (workflow playbooks loaded on demand)
```

- **Commands** are what you type. Be specific about what you want.
- **Agents** are Claude instances — the main session or isolated subagents.
- **Skills** are loaded on demand, not always-on. They encode "how to do X" for complex tasks.

### Skills vs. Subagents

| | Skills | Subagents |
|---|---|---|
| Runs in | Main conversation context | Fresh isolated context window |
| Use for | Workflow playbooks, checklists, procedures | Context-heavy research, parallel tasks |
| Returns | Content stays in conversation | Only summary returns to parent |
| File location | `~/.claude/skills/<name>/SKILL.md` | `~/.claude/agents/<name>.md` |
| Invocation | `/skill-name` or auto-trigger | `@agent-name` or auto-delegation |

### The Toolkit-in-META Pattern

META_ARCHITECTURE.md is not just a reference document — it drives plan quality.

The **Toolkit section** in META_ARCHITECTURE.md lists every available skill with explicit guidance on where it belongs in a plan. When Claude reads META at session start and then drafts a plan, it uses the Toolkit to embed skill invocations as named checkpoints in each phase:

```
## Phase 2: Design Query Strategy
- [ ] Invoke /sql-pro — sketch CTE structure and review approach
- [ ] Write queries
- [ ] Validate output

## Phase 3: Build ML Pipeline  
- [ ] Invoke /labarr-ml — confirm algorithm choice and eval metric
- [ ] Define acceptance threshold before training
- [ ] Train baseline, evaluate, document in experiments/
```

Skills become steps in the plan, not things you have to remember to invoke. The plan is then a living log — it carries the skill checkpoints forward across sessions.

**The chain:** CLAUDE.md auto-loads → says read META → META Toolkit tells Claude which skills go where → plan drafts with skills embedded → next session reads plan → skills are already named.

### The Context Budget Rule

There is no hard limit. When context is getting high, Claude should flag it and ask if you want to address it — not act unilaterally. If you say yes, it suggests the best path forward: `/compact` with a hint, offloading batch work to a subagent, or starting a fresh session with the plan file as context. The right move depends on what you're doing, not the number.

- Use `/compact` proactively with a hint before autocompact kicks in
- Delegate research and exploration to subagents — only summaries return
- Never run large batches of file processing sequentially in the main session

The most expensive mistake: accumulating 100+ tool outputs in the main context. Each
result stays in context. After ~50 operations, the model degrades. The fix is subagents
— each runs in isolation, only the result JSON returns.

### The "Skills First" Rule

Before building anything, check if a skill exists. If a skill matches the task, invoke
it. Skills encode accumulated knowledge about how to do tasks well. Skipping them means
rediscovering what's already been learned.

---

## 2. CLAUDE.md Template

Copy this to your project root. Fill in the `[bracketed]` sections. Keep it under
200 lines — move domain-specific detail to `.claude/rules/*.md`.

```markdown
# [Project Name] — Developer Context

> **Read META_ARCHITECTURE.md first** — it maps every built tool, run commands,
> data flow, and decision tree. CLAUDE.md covers rules; META_ARCHITECTURE.md
> covers what exists.

---

## Who I am
[Your role, company, team. One paragraph.]

---

## Hard Rules — Never Break These

- **NEVER commit .env files or any API keys**
- **NEVER hardcode credentials in any file**
- **NEVER push directly to main — always use a feature branch**
- **ALWAYS add .env and venv/ to .gitignore before first commit**
- [Add project-specific rules here]

---

## Skills First

Before building anything, check if a skill exists. Available skills: see META_ARCHITECTURE.md.

Key skills to remember:
- `thinking-partner` — before ideation / exploration
- `socratic-examiner` — before committing to a plan
- `assumption-archaeologist` — when something feels off but you can't name why
- `superpowers:brainstorming` — required before building new features
- `code-review` — run before merging any feature branch

---

## Division of Responsibility

- **Claude Code** → [what Claude Code builds and runs]
- **[Other tool]** → [what it handles]
- When a task requires [external system] — stop and flag it. Claude Code cannot access [connector].

---

## Tech Stack

- [Technology 1] — [what it does]
- [Technology 2] — [what it does]

---

## Session Naming Convention

Each work session is named after a historical event on that calendar date. The theme
should connect thematically to the work being done. Add the session name to commit
messages and session doc filenames.

Examples: June 15 → "Magna Carta" (foundational documents), June 6 → "D-Day" (major push)

---

## [Language/Framework] Rules

[Coding standards for your stack]

---

## Key Terminology

| Term | Meaning |
|---|---|
| [acronym] | [expansion] |

---

## File Conventions

- [Convention 1]
- [Convention 2]
```

---

## 3. META_ARCHITECTURE.md Template

Create this file after you have 2+ working tools. Update it after every session that
changes the system.

```markdown
# [Project Name] — Meta Architecture

> **Read this first** when starting any new session on this project.
> Last updated: [date] ([session name])

---

## Tool Inventory

| Tool | Location | Entry Point | Status | Tests |
|---|---|---|---|---|
| **[Tool 1]** | `path/to/tool/` | `python cli.py [args]` | ✅ Working | N tests |

### How to Run Each Tool

[One run command per tool, copy-pasteable]

---

## Available Services / APIs / Connectors

| Service | Access method | What it provides | Constraints |
|---|---|---|---|
| [Service] | [How accessed] | [What data] | [Limits] |

---

## Available Skills

| Skill | Trigger | When to use |
|---|---|---|
| `skill-name` | "trigger phrase" | [when] |

---

## Data Flow

[ASCII diagram showing how data moves through the system]

---

## Tool Decision Tree

**I need to do X — what do I use?**
→ [Recommendation + why]

---

## Codebase Layout

[Tree diagram with one-line description per folder]

**What to ignore:** [folders that are scaffolds/unused/future]

---

## Known Gaps (Prioritized)

| Gap | Impact | Fix |
|---|---|---|
| [Gap] | [Impact] | [Specific fix] |

---

## Open Questions

| Question | Why it matters |
|---|---|
| [Question] | [Stakes] |

---

*Update this document after every session that changes the system.*
```

---

## 4. Thinking-Partner Skill Trio — Global Registration

These three skills work as a system with explicit handoffs between them.

**One-time setup per machine:**
```bash
mkdir -p ~/.claude/skills/thinking-partner
mkdir -p ~/.claude/skills/socratic-examiner
mkdir -p ~/.claude/skills/assumption-archaeologist

# Copy SKILL.md files from wherever you store them:
cp thinking-partner-SKILL.md ~/.claude/skills/thinking-partner/SKILL.md
cp socratic-examiner-SKILL.md ~/.claude/skills/socratic-examiner/SKILL.md
cp assumption-archaeologist-SKILL.md ~/.claude/skills/assumption-archaeologist/SKILL.md
```

**On Windows (PowerShell):**
```powershell
mkdir "$env:USERPROFILE\.claude\skills\thinking-partner"
mkdir "$env:USERPROFILE\.claude\skills\socratic-examiner"
mkdir "$env:USERPROFILE\.claude\skills\assumption-archaeologist"
```

**How the trio works:**

```
User is exploring → thinking-partner
  → User forms a plan → socratic-examiner (stress-test)
    → Plan has hidden premises → assumption-archaeologist (excavate)
      → Premises surfaced → back to thinking-partner or socratic-examiner
```

Each skill explicitly tells Claude when to hand off to the next one. You don't need
to manage the handoffs — Claude does it.

**Invocation:** `/thinking-partner`, `/socratic-examiner`, `/assumption-archaeologist`
Or Claude auto-triggers based on description match.

---

## 5. Key Patterns

### Pattern 1: Plan Mode → 1-Shot Implementation

Pour energy into the plan. Execute in a fresh session.

1. Create a plan file (`.claude/plans/[session-name].md` or project root)
2. Use `/thinking-partner` + `/assumption-archaeologist` to stress-test the plan
3. Start a fresh Claude Code session with the plan file as context
4. Execute without switching back to planning mid-stream

### Pattern 2: Git Worktrees for Parallel Work

Run two features simultaneously in isolated directory copies.

```bash
git worktree add ../project-feature-a feature-a
git worktree add ../project-feature-b feature-b
# Open two Claude Code sessions, one in each worktree
```

Use when: working on independent features simultaneously, or when you want
to test something risky without affecting the main working tree.

### Pattern 3: Subagents for Batch Processing

For tasks that process many items (files, records, URLs), use one subagent per item.

```
Wrong: process 100 PDFs sequentially in main session (context accumulates)
Right: spawn subagent for each PDF, collect only result summaries
```

The main session context stays lean. Each subagent starts fresh and returns only
what you need.

### Pattern 4: Context Budget Management

- When context climbs, flag it and ask — don't act unilaterally; suggest `/compact`, subagents, or fresh session
- `/compact` proactively with a summary hint: `/compact We're fixing the auth bug in user.py`
- Use subagents to offload research and exploration
- Start fresh sessions for new tasks — don't carry context from prior work

### Pattern 5: "Grill Me On These Changes"

Before merging a feature branch, ask Claude to challenge it:

*"Grill me on these changes. Look at the diff and find the weakest points — logic errors, edge cases I haven't handled, assumptions that might be wrong."*

Use the `socratic-examiner` or `code-review` skill for structured versions of this.

### Pattern 6: "Prove to Me This Works"

After building a feature, ask Claude to compare behavior between branches:

*"Compare the behavior of this feature between master and the feature branch. What changed? Does it actually do what I said it would?"*

### Pattern 7: /loop for Active Development

During a debugging or feature build session, run tests automatically:

```
/loop 2m run pytest tests/test_parser.py -v
```

Tests run every 2 minutes in the background. Failures surface immediately.
/loop expires after 3 days, max 50 tasks per session. For persistent cross-session
tasks, use scheduled agents (CronCreate).

### Pattern 8: Conversational Plan Execution

Execute plans in phases with natural conversation between them — don't run silently
and hand the user a finished report.

**Why it matters:** Silent execution hides lazy work and missed steps. In a conversational
execution, the user can push back on findings, redirect priorities, and catch incomplete
work before it gets documented as "done." A wall of output at the end is much harder to
audit than a flowing conversation.

**How it works:**
- Surface findings at phase transitions before moving to the next phase
- Ask "does this change anything?" or "should we continue or adjust?" — don't assume
- When something unexpected comes up, say it out loud rather than just noting it in a doc
- Reshape the plan mid-stream when findings change what matters — don't finish a stale plan
- Give the user natural pauses to ask clarifying questions

**The test:** Could the user have caught a lazy step? If execution was silent, probably not.
If conversational, yes. Run the plan in a way that would expose your own mistakes.

### Pattern 9: Plan File as Living Log — Not Just a Checklist

A plan file isn't just a to-do list. It's a running log that survives context compression.

**The practice:** After completing each phase, write the key findings directly into the plan file's Running Notes section before moving on. Not in the conversation — in the file.

**Why it matters:** Conversations compress. Sessions end. If your Phase 1 findings only live in the chat, they're gone when the context window fills or you start a new session. If they're in the plan file, Phase 4 can read them cold without re-deriving anything. The summary that restarts a compressed session is reconstructed from what's in files — not from what was said.

**What to write:** Not everything — just what Phase N+1 will need to know. Surprises, priority changes, things that contradict the original plan.

**The test:** If this session ended right now and someone started fresh with only the plan file, could they pick up Phase N+1 without repeating Phase N? If yes, the notes are good. If no, write more.

### Pattern 10: CLAUDE.md as Living Document

Update CLAUDE.md when:
- A hard rule is added or changed
- A tool or convention is added/removed
- The tech stack changes

Don't document what's already in the code. Document the WHY that isn't visible in code.

### Pattern 11: Toolkit-Driven Plan Drafting

Before writing any plan, read the Toolkit section of META_ARCHITECTURE.md. For each phase of the plan, identify which skills belong as explicit checkpoints and write them into the plan steps as named invocations.

**Why it matters:** Plans without explicit skill steps are task lists. Plans with skill checkpoints are executable workflows that survive session transitions. The next session reads the plan, sees `/labarr-ml` at phase 3, and invokes it — no memory required.

**The rule:** If a skill belongs in a phase, it goes in the plan before execution starts.

### Pattern 12: Experiment-First for ML (LaBarr Sequence)

Follow the 12-step LaBarr workflow as gates, not suggestions:

```
Problem Framing → Data Prep → Train/Test Split → Imputation →
Low-Variability Removal → Univariate Screening → Multivariate Selection →
Simple Baseline → Diagnostic Gate → Complex Models → Final Comparison → Threshold Selection
```

Key discipline:
- Define the eval metric and acceptance threshold **before training** ("F1 > 0.82 on holdout")
- Build the simple baseline (logistic regression / OLS) **before any complex model**
- Pass the diagnostic gate **before advancing to tree ensembles or neural nets**
- Holdout test set is touched **once** — final evaluation only, never during tuning
- Default to the simpler model — complexity must be **earned** by demonstrated performance gain

"Better variables will always beat fancier modeling techniques." — LaBarr

### Pattern 13: Test-Locally-Then-Schedule for Automation

Before scheduling any script, run four manual checks:

1. **Small sample** — run with 10-20 records, verify output is correct
2. **Idempotence** — run again on the same sample, verify no duplicates
3. **Empty input** — run with no records, verify graceful handling not crash
4. **Bad input** — run with malformed data, verify error is logged not silent

Only after all four pass does the script get a cron job or trigger.

**Why it matters:** Scheduled scripts fail silently. A non-idempotent script duplicates records on every run. A script that crashes on empty input stops working the moment the queue drains. These bugs are invisible until they cause real damage.

---

## 6. What NOT to Do

| Anti-pattern | Why it fails | Better approach |
|---|---|---|
| Run 100+ files through main session | Context accumulates, model degrades | Subagents or standalone scripts |
| Put everything in CLAUDE.md | File grows past 200 lines, rules get ignored | CLAUDE.md for rules; META_ARCHITECTURE.md for facts; `.claude/rules/` for domain detail |
| Build without checking for skills | Reinvents workflow playbooks already encoded | Skills First rule |
| Skip plan mode | Scope drift, rework | Always plan → then implement in fresh session |
| Use subagents for concurrent file edits | Merge conflicts, unpredictable state | Worktrees for parallel code changes |
| Call external APIs directly when an MCP tool exists | Bypasses the MCP tool interface | Use MCP tools (they handle auth, formatting, error handling) |

---

## 7. Session Naming Convention

Historical event naming makes sessions memorable and thematically coherent.

**Process:**
1. Find a historical event that occurred on today's date
2. Choose the one whose theme connects best to the work being done
3. Name the session after it — use it in plan filenames, commit messages, session notes

**Examples:**
- June 15 → Magna Carta (1215) — foundational documents session
- June 6 → D-Day (1944) — major feature push
- July 4 → Declaration of Independence — project launch
- October 29 → Stock Market Crash (1929) — risk analysis / debugging session

**Fallback:** If nothing fits, pick the most memorable event of the day and find a
loose connection. The discipline of naming matters more than perfect thematic fit.

---

## 8. Documentation Practices

**When to write session docs:**
- After any session that changes the system architecture
- After debugging something non-obvious
- After finding a gotcha that would surprise a future session

**Session doc format** (`Bid_Workflow/session_YYYY-MM-DD-name.md`):
```
# Session: [Name] — [Date]
## What was built
## Why decisions were made
## Known gaps / next session priorities
## Test state at end
```

**Memory files** (`~/.claude/projects/.../memory/`):
- Write after confirming something non-obvious about the codebase
- Keep fresh — stale memories are worse than no memories
- Types: user, feedback, project, reference

---

## 9. Recommended Installs

Everything below was evaluated June 15, 2026 and confirmed worth having.

### dx plugin — install first

```
/plugin install dx@ykdojo
```

Adds `/dx:handoff` — run at the end of any session to write a `HANDOFF.md` with current
goal, what worked, what didn't, and next steps. Gets picked up automatically at the start
of the next session. Solves the "context lost between sessions" problem cleanly.

Also adds `/dx:gha` (GitHub Actions debugging), `/dx:clone`, `/dx:half-clone`.

### Official Anthropic plugins (add to `~/.claude/settings.json`)

```json
"mcp-server-dev@claude-plugins-official": true,
"session-report@claude-plugins-official": true,
"pyright-lsp@claude-plugins-official": true
```

- **mcp-server-dev** — skills for building and extending MCP servers. Use when adding
  new tools to any MCP server.
- **session-report** — auto-generates structured session reports. Reduces manual
  session note writing.
- **pyright-lsp** — Python language server with hover docs and type checking. Worth
  having on any Python-heavy project.

### Skills from this repo (clone once, install globally)

Source: `https://github.com/dpchristopher/claude-practices`

| Skill folder | What it does | When to use |
|---|---|---|
| `thinking-partner` | Ideation and exploration before committing | Before any design decision |
| `socratic-examiner` | Stress-tests plans and positions | Before committing to an approach |
| `assumption-archaeologist` | Surfaces hidden premises | When something feels off |
| `session-workflow` | Full methodology reference — start/end protocol, TDD, ML eval | Session start or process questions |
| `patterns-guide` | Which pattern fits a situation — 10 core + ML/automation | Designing an approach or stuck |
| `labarr-ml` | LaBarr 12-step ML workflow, interpretability-first, time series, risk, credit | Any ML or analytics work |

**One-time install (PowerShell):**
```powershell
$src = "C:\path\to\claude-practices\skills"
$dest = "$env:USERPROFILE\.claude\skills"
$skills = @("thinking-partner","socratic-examiner","assumption-archaeologist","patterns-guide","session-workflow")
foreach ($s in $skills) {
    New-Item -ItemType Directory -Force "$dest\$s" | Out-Null
    Copy-Item "$src\$s-SKILL.md" "$dest\$s\SKILL.md" -Force
}
# labarr-ml has multiple files
Copy-Item "$src\labarr-ml" "$dest\labarr-ml" -Recurse -Force
```

### Skills from Jeffallan/claude-skills (download to `~/.claude/skills/`)

Source: `https://raw.githubusercontent.com/Jeffallan/claude-skills/main/skills/<name>/SKILL.md`

| Skill folder | What it does | When to use |
|---|---|---|
| `sql-pro` | Advanced SQL, CTEs, window functions, EXPLAIN analysis | Writing or optimizing complex database queries |
| `mcp-developer` | Building MCP servers and tools (Python/TypeScript SDKs) | Adding new tools to an MCP server |
| `pandas-pro` | DataFrame manipulation, vectorized ops, memory optimization | Data cleaning and pipeline work |
| `the-fool` | 5-mode adversarial challenge (pre-mortem, red team, steelman) | Before committing to any important decision |
| `debugging-wizard` | Systematic reproduce → isolate → hypothesize → fix | Stuck on a bug and need structure |

**One-time download (PowerShell):**
```powershell
$base = "https://raw.githubusercontent.com/Jeffallan/claude-skills/main/skills"
$dest = "$env:USERPROFILE\.claude\skills"
foreach ($s in @("sql-pro","mcp-developer","pandas-pro","the-fool","debugging-wizard")) {
    New-Item -ItemType Directory -Force "$dest\$s" | Out-Null
    Invoke-WebRequest "$base/$s/SKILL.md" -OutFile "$dest\$s\SKILL.md" -UseBasicParsing
}
```

### Future consideration: Hermes-agent

For persistent cross-session agents that create their own skills from experience.
Not relevant during active build phases. Revisit when you have production data
accumulating and need a long-lived analyst.

- GitHub: https://github.com/nousresearch/hermes-agent
- Related: https://github.com/letta-ai/letta-code

---

*This starter kit was built from a real production Claude Code project.
It is intentionally project-agnostic — everything here applies to any Claude Code project.*
