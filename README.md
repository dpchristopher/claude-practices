# claude-practices

Portable best practices starter kit for Claude Code projects.

## Contents

```
/docs/Coolest Thing Since Chrystal Ball.md  — Complete reference: personal loadout, mental models, patterns, anti-patterns
/templates/CLAUDE.md        — CLAUDE.md template (fill in blanks, keep under 200 lines)
/templates/META_ARCHITECTURE.md  — META_ARCHITECTURE.md template
/skills/thinking-partner-SKILL.md       — Thinking partner skill (ideation/exploration)
/skills/socratic-examiner-SKILL.md      — Socratic examiner skill (stress-test plans)
/skills/assumption-archaeologist-SKILL.md — Assumption archaeologist (surface premises)
```

## Quick Start

1. Copy `/templates/CLAUDE.md` to your project root — fill in the blanks
2. Register the thinking-partner skills globally (one-time per machine):
   ```bash
   # macOS/Linux
   mkdir -p ~/.claude/skills/{thinking-partner,socratic-examiner,assumption-archaeologist}
   cp skills/thinking-partner-SKILL.md ~/.claude/skills/thinking-partner/SKILL.md
   cp skills/socratic-examiner-SKILL.md ~/.claude/skills/socratic-examiner/SKILL.md
   cp skills/assumption-archaeologist-SKILL.md ~/.claude/skills/assumption-archaeologist/SKILL.md
   
   # Windows (PowerShell)
   $base = "$env:USERPROFILE\.claude\skills"
   mkdir "$base\thinking-partner", "$base\socratic-examiner", "$base\assumption-archaeologist"
   copy skills\thinking-partner-SKILL.md "$base\thinking-partner\SKILL.md"
   copy skills\socratic-examiner-SKILL.md "$base\socratic-examiner\SKILL.md"
   copy skills\assumption-archaeologist-SKILL.md "$base\assumption-archaeologist\SKILL.md"
   ```
3. Create `META_ARCHITECTURE.md` once you have 2+ working tools (use the template)
4. Read `/docs/BEST_PRACTICES.md` — especially sections 1 (Mental Models) and 5 (Key Patterns)

## The 3 Most Important Practices

1. **Skills First** — before building, check if a skill exists
2. **Context Budget** — keep main session under 40%; subagents for batch work
3. **Plan → Fresh Session** — invest in planning, execute in a clean context

## Session Naming Convention

Each work session is named after a historical event on that calendar date with a theme
that connects to the work. Makes sessions memorable, commit messages interesting.
