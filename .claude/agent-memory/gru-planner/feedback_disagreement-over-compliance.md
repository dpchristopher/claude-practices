---
name: feedback-disagreement-over-compliance
description: User wants items he proposed argued against when they are weak; verify his premises against the repo before planning on them.
metadata:
  type: feedback
---

Push back on the user's own proposals when they are weak, and verify his stated premises against the
actual repo before building tasks on them. He states this preference explicitly ("I value disagreement
over compliance") and rewards it.

**Why:** his research briefs are usually well-sourced but occasionally name the wrong target files or
carry a claim from a secondary source. On the Wave 7 brief, three premises were wrong on inspection:
`ROLLBACK.md`/`BACKUP.md` had no `git worktree` text (it was in `patterns-guide/SKILL.md` and the
`Coolest Thing` doc), the global rule layer was not in version control at all, and a proposed
`UserPromptSubmit` keyword hook would have fired on nearly every prompt in an agents-focused repo.
Accepting any of those verbatim would have produced tasks that edit the wrong files.

**How to apply:** grep the repo for every file a brief names before writing a task against it. Put
corrections in a named "findings that change the brief" section rather than silently fixing them, and
give a reasoned argument (not a flag) when recommending against an item he proposed. See
[[feedback-no-uncosted-fanout]].
