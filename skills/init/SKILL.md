---
name: init
description: Scaffold a new Claude Code project from the claude-practices template. Run once at project creation. Prompts for project basics, creates all required files, inits git, then hands off to brainstorming.
triggers:
  - new project
  - start a project
  - init
  - set up project
  - create project
---

# Init — New Project Setup

Run this skill ONCE at the start of any new project.

## Step 1: Gather basics (ask the user)

Ask these three questions before doing anything:

1. Project name?
2. One sentence: what does this project do?
3. Tech stack? (language, key libs, database if any)

---

## Step 2: Scaffold the directory structure

From the project root, create:

```
mkdir -p .claude/plans .claude/rules data/{raw,processed,incoming}
mkdir -p src docs notebooks experiments
```

---

## Step 3: Copy templates from claude-practices

Copy these files into the project root:
- `CLAUDE.md` (from `claude-practices/templates/CLAUDE.md`)
- `META_ARCHITECTURE.md` (from `claude-practices/templates/META_ARCHITECTURE.md`)
- `HANDOFF.md` → `claude-practices/templates/HANDOFF.md` (if exists, else skip)
- `.claude/rules/*.md` (from `claude-practices/templates/.claude/rules/`)

If claude-practices is not cloned locally, use the template content embedded at the bottom of this skill file.

---

## Step 4: Fill in CLAUDE.md

Replace every `[bracketed]` section with the answers from Step 1.
Keep CLAUDE.md under 200 lines. Do not add tool inventory here.

---

## Step 5: Create .gitignore

```
.env
venv/
__pycache__/
*.pyc
data/raw/
data/processed/
data/incoming/
experiments/*/model.pkl
.log
```

---

## Step 6: Initialize git

```bash
git init
git add CLAUDE.md META_ARCHITECTURE.md .gitignore .claude/
git commit -m "init: project scaffold from claude-practices template"
git checkout -b main
```

---

## Step 7: Confirm and hand off

Show the user what was created. Then say:
"Project scaffolded. Invoking /brainstorming to explore what we're building."

Then invoke `/superpowers:brainstorming` — pass the project name and purpose as context.
