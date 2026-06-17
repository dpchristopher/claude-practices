# Multi-Project Professional Setup

For professionals running multiple client engagements or projects in Claude Code simultaneously. This guide explains the two-layer architecture and how to set up a new client project correctly.

---

## The Two-Layer Architecture

```
~/.claude/                          ← GLOBAL (fires on every project, every session)
  CLAUDE.md                         ← Toolkit map + session protocol + hard rules
  settings.json                     ← Hook registration (session-context.sh here)
  hooks/
    session-context.sh              ← Loads project context at session start
  skills/
    daniel-context/ (or your-name)  ← Personal context — invoke on demand
    session-workflow/
    thinking-partner/
    labarr-ml/
    ...

your-project/.claude/               ← PROJECT-SPECIFIC (this project only)
  settings.json                     ← Project overrides (optional)
  CLAUDE.md                         ← Project rules, stack, toolkit — LEAN (<80 lines)
  plans/                            ← Active plans
  HANDOFF.md                        ← Session handoff (replaced each session)
  rules/
    ml-discipline.md                ← Auto-loads for ML projects
    automation.md                   ← Auto-loads for automation projects
    session-workflow.md             ← Full protocol detail
    tool-discipline.md              ← Tool priority, subagents, context budget
```

**Key principle:** Global layer installs once, works everywhere. Project layer is lean and specific to the engagement.

---

## What Goes Where

| Content | Goes in | Why |
|---|---|---|
| Toolkit map, session protocol, hard rules | `~/.claude/CLAUDE.md` | Fires every turn, every project |
| Personal context (who you are, clients, career) | Personal context skill | On-demand only — not every turn |
| Project rules, tech stack, project toolkit | `project/CLAUDE.md` | Project-specific, under 80 lines |
| Detail (ML rules, automation rules) | `project/.claude/rules/*.md` | Auto-loads but keeps CLAUDE.md lean |
| Active work plan | `project/.claude/plans/` | Loaded by hook and HANDOFF |
| Last session blockers, next action | `project/.claude/HANDOFF.md` | First thing read at session start |

---

## First-Session Checklist for a New Client Project

Run this the first time you open a new engagement (Opaa, Moneta, etc.) in Claude Code:

**Option A — Use `/init` (recommended)**
```
/init
```
Answer the three questions. Everything gets scaffolded automatically.

**Option B — Manual**

1. Copy templates into the project root:
   ```bash
   # macOS/Linux
   cp ~/.claude/skills/claude-practices/templates/CLAUDE.md ./
   cp ~/.claude/skills/claude-practices/templates/META_ARCHITECTURE.md ./
   cp -r ~/.claude/skills/claude-practices/templates/.claude ./.claude
   ```
   ```powershell
   # Windows
   Copy-Item "$env:USERPROFILE\.claude\skills\claude-practices\templates\CLAUDE.md" .
   Copy-Item "$env:USERPROFILE\.claude\skills\claude-practices\templates\META_ARCHITECTURE.md" .
   Copy-Item "$env:USERPROFILE\.claude\skills\claude-practices\templates\.claude" ".claude" -Recurse
   ```

2. Fill in `CLAUDE.md` — replace every `[bracketed]` section. Keep under 80 lines.

3. Fill in `META_ARCHITECTURE.md` — document the tools, stack, data flow you know about so far.

4. Create `.gitignore` — always include `.env`, `venv/`, `__pycache__/`, `*.pyc`, raw data folders.

5. Initialize git:
   ```bash
   git init
   git add CLAUDE.md META_ARCHITECTURE.md .gitignore .claude/
   git commit -m "init: project scaffold from claude-practices"
   git checkout -b main
   ```

6. Open a Claude Code session. The hook fires. Start with `/session-workflow` + `/superpowers:brainstorming`.

---

## Verifying the Hook Is Firing

When you open a session in a properly configured project, you should see output like this **before you type anything:**

```
═══════════════════════════════════════
SESSION CONTEXT
═══════════════════════════════════════

## PROJECT RULES (CLAUDE.md — first 20 lines)
...

## ACTIVE PLAN (...)
...

## LAST SESSION — BLOCKERS & NEXT ACTION
...

CONTEXT LOADED.
⚠️  MANDATORY STARTUP — DO THIS BEFORE RESPONDING:
   1. Ask: does this context look current, or is anything stale?
   2. Invoke /session-workflow
   3. Invoke /superpowers:brainstorming
═══════════════════════════════════════
```

If you don't see this output, check:
1. Is `session-context.sh` registered in `~/.claude/settings.json` under `SessionStart`?
2. Does the hook file exist at `~/.claude/hooks/session-context.sh`?
3. Is bash available on your system? (On Windows, Git Bash must be in PATH)

---

## GSD vs Lightweight Structure

| If you... | Use |
|---|---|
| Have a well-defined project with clear phases | GSD framework (`/gsd-new-project`) |
| Are doing exploratory or short-term client work | Lightweight claude-practices structure |
| Need structured milestone tracking and agent orchestration | GSD |
| Need fast setup and session continuity without overhead | claude-practices templates |

Both can coexist. GSD's `.planning/` directory and claude-practices' `.claude/` directory don't conflict.
