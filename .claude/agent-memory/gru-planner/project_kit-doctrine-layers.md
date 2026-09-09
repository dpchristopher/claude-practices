---
name: project-claude-practices-kit-layers
description: claude-practices has two doctrine layers with different install paths; the global one was untracked as of Wave 7 planning.
metadata:
  type: project
---

The kit ships doctrine at two layers, and which layer a change targets determines whether it fires
everywhere or only on installed projects:

- **Global** — `~/.claude/rules/` (always loaded, every project, every turn) plus `~/.claude/CLAUDE.md`.
  As of 2026-08-19 this held only `kit-maintenance.md` and `loop-cost-discipline.md`, and **neither was
  in the repo** — `install.sh`/`install.ps1` copy skills, hooks, and agents but not rules. Wave 7 plans
  a `global-rules/` directory plus installer support to fix that.
- **Per-project** — `templates/.claude/rules/` (10 files), reaching a project only on install or `/init`.

**Why:** a fix written into `~/.claude/rules/` without repo tracking survives on one machine only and
is lost on reinstall or OS rebuild.

**How to apply:** when planning any kit change, state the target layer per task and what re-installation
is required. Respect the line budgets from `kit-maintenance.md` — global `CLAUDE.md` under ~60 lines,
project `CLAUDE.md` under ~90. Verify current state before relying on this; it is a Wave 7 snapshot.
See [[feedback-no-uncosted-fanout]].
