# claude-practices

Portable best-practices starter kit for Claude Code — software engineering, full-stack apps, machine learning, and task automation.

Built from a real production Claude Code project (June 2026). Focused on session reproducibility, plans that carry forward, and diligent ML/automation workflows.

---

## The Core Problem This Solves

Claude Code sessions forget context between sessions. Plans die. Next session starts blank.

**This kit fixes that** by structuring CLAUDE.md, META_ARCHITECTURE.md, and `.claude/rules/` so Claude auto-loads context at session start and knows exactly how to work on your project.

---

## Contents

```
templates/
  CLAUDE.md                        ← Project rules template (fill in blanks, keep under 200 lines)
  META_ARCHITECTURE.md             ← Tool map + experiment tracking template
  .claude/
    rules/
      ml-discipline.md             ← Experiment tracking, reproducibility, ML pitfalls (auto-loads)
      automation.md                ← Idempotence, error handling, pipeline testing (auto-loads)
      session-workflow.md          ← Full session start/end protocol (auto-loads)
      tool-discipline.md           ← Tool priority, subagents, context budget (auto-loads)

skills/
  thinking-partner-SKILL.md        ← Ideation and exploration
  socratic-examiner-SKILL.md       ← Stress-test a plan before building
  assumption-archaeologist-SKILL.md ← Surface hidden premises
  patterns-guide-SKILL.md          ← Which pattern to use for any situation
  session-workflow/SKILL.md        ← Full methodology reference
  init/SKILL.md                    ← Scaffold a new project from this template
  labarr-ml/                       ← ML methodology (12-step workflow, algorithm families)

hooks/
  session-context.sh               ← SessionStart hook: auto-loads context every session (THIS IS CONTINUATION)

docs/
  Coolest Thing Since Crystal Ball.md  ← Complete loadout, mental models, patterns, anti-patterns
```

---

## Professional Setup (Multi-Project)

If you're running multiple client engagements or projects, the setup has two layers:

- **Global `~/.claude/CLAUDE.md`** — toolkit map + session protocol that fires every turn, every project. Fill in `templates/global-CLAUDE.md` and place it there. **Never commit this file** — it's personal to your machine.
- **Per-project `.claude/`** — lean CLAUDE.md, META_ARCHITECTURE.md, rules, plans, HANDOFF. Use `/init` or copy templates manually for each new project.

See [docs/multi-project-setup.md](docs/multi-project-setup.md) for the full guide, first-session checklist, and how to verify the hook is firing.

---

## Quick Start

### 1. Copy templates to your project

```bash
# macOS/Linux
cp templates/CLAUDE.md /path/to/your-project/
cp templates/META_ARCHITECTURE.md /path/to/your-project/
cp -r templates/.claude /path/to/your-project/
```

```powershell
# Windows (PowerShell)
$proj = "C:\path\to\your-project"
Copy-Item templates\CLAUDE.md $proj
Copy-Item templates\META_ARCHITECTURE.md $proj
Copy-Item templates\.claude $proj -Recurse
```

### 2. Fill in the blanks in CLAUDE.md

Replace every `[bracketed]` section with your project's specifics. Keep it under 200 lines.

### 3. Register skills globally (one-time per machine)

```bash
# macOS/Linux
dest=~/.claude/skills
mkdir -p $dest/{thinking-partner,socratic-examiner,assumption-archaeologist,patterns-guide,session-workflow,init,labarr-ml}
cp skills/thinking-partner-SKILL.md $dest/thinking-partner/SKILL.md
cp skills/socratic-examiner-SKILL.md $dest/socratic-examiner/SKILL.md
cp skills/assumption-archaeologist-SKILL.md $dest/assumption-archaeologist/SKILL.md
cp skills/patterns-guide-SKILL.md $dest/patterns-guide/SKILL.md
cp skills/session-workflow/SKILL.md $dest/session-workflow/SKILL.md
cp skills/init/SKILL.md $dest/init/SKILL.md
cp -r skills/labarr-ml $dest/
```

```powershell
# Windows (PowerShell)
$dest = "$env:USERPROFILE\.claude\skills"
$skills = @("thinking-partner","socratic-examiner","assumption-archaeologist","patterns-guide","session-workflow","init")
foreach ($s in $skills) {
    New-Item -ItemType Directory -Force "$dest\$s" | Out-Null
}
Copy-Item skills\thinking-partner-SKILL.md "$dest\thinking-partner\SKILL.md"
Copy-Item skills\socratic-examiner-SKILL.md "$dest\socratic-examiner\SKILL.md"
Copy-Item skills\assumption-archaeologist-SKILL.md "$dest\assumption-archaeologist\SKILL.md"
Copy-Item skills\patterns-guide-SKILL.md "$dest\patterns-guide\SKILL.md"
Copy-Item skills\session-workflow\SKILL.md "$dest\session-workflow\SKILL.md"
Copy-Item skills\init\SKILL.md "$dest\init\SKILL.md"
Copy-Item skills\labarr-ml "$dest\labarr-ml" -Recurse
```

### 4. Install the SessionStart hook (this IS continuation)

The `hooks/session-context.sh` hook is the continuation mechanism. Every session start it automatically loads CLAUDE.md, META_ARCHITECTURE.md, your active plan, and HANDOFF.md — then tells Claude to invoke `/session-workflow` and `/superpowers:brainstorming`. You don't build continuation; you install this hook.

```bash
# macOS/Linux
mkdir -p ~/.claude/hooks
cp hooks/session-context.sh ~/.claude/hooks/session-context.sh
chmod +x ~/.claude/hooks/session-context.sh
```

```powershell
# Windows (PowerShell)
New-Item -ItemType Directory -Force "$env:USERPROFILE\.claude\hooks" | Out-Null
Copy-Item hooks\session-context.sh "$env:USERPROFILE\.claude\hooks\session-context.sh"
```

Then add to your project's `.claude/settings.json`:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "type": "command",
        "command": "bash ~/.claude/hooks/session-context.sh"
      }
    ]
  }
}
```

### 5. Start a new project with /init

For brand-new projects, use the `/init` skill instead of copying templates manually. It asks three questions, scaffolds the full directory structure, fills in CLAUDE.md, inits git, and hands off to brainstorming.

```
/init
```

### 6. Start working

Open a Claude Code session in your project. The hook fires automatically — context loads before you type the first message. Claude already knows the project state.

At session end: write `.claude/HANDOFF.md`. Next session picks up exactly where you left off.

---

## How Context Carries Forward Between Sessions

Only two things auto-load at Claude Code session start:
- `CLAUDE.md`
- `.claude/rules/*.md`

Everything else (META_ARCHITECTURE, plans, HANDOFF) must be explicitly referenced. This kit handles that three ways:

1. **CLAUDE.md** includes an instruction to read META_ARCHITECTURE.md, `.claude/plans/`, and `.claude/HANDOFF.md` at session start
2. **`.claude/rules/session-workflow.md`** auto-loads and reinforces the full protocol
3. **SessionStart hook** pre-outputs summaries of all three into Claude's context before the first message — this is the primary continuation mechanism

Result: open a session, describe the work, and Claude already knows the project state.

---

## The 4 Most Important Practices

1. **Skills First** — before building, check if a skill exists; invoke before writing code
2. **Plan → Fresh Session** — plan in one session, execute in a clean context
3. **HANDOFF every session** — `.claude/HANDOFF.md` is replaced each session; next session reads it first
4. **Experiments directory** — ML artifacts always go in `experiments/NNN-name/`; never scattered

---

## The Thinking-Partner Trio

Three skills designed as a linked system:

| Skill | Use when |
|---|---|
| `thinking-partner` | Exploring options before committing to anything |
| `socratic-examiner` | Stress-testing what emerged from thinking-partner |
| `assumption-archaeologist` | Excavating hidden premises that both missed |

Use in sequence on any non-trivial decision. Claude manages the handoffs between them.

---

## Session Naming Convention

Each work session is named after a historical event on that calendar date with a theme that connects to the work. Use in commit messages and plan filenames.

Example: June 16 → "House Divided" (Lincoln, 1858) — foundational restructuring session
