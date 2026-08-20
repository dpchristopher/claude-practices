---
name: feedback-no-uncosted-fanout
description: Never dispatch subagents without a stated child count and budget; plan-only tasks mean zero live dispatches.
metadata:
  type: feedback
---

When planning, route-to-agent decisions go **in the plan text as recommendations**, not as live
dispatches. Before any real dispatch, state two numbers first: how many children, and roughly what
each costs. Ad hoc fan-out caps at 3-4 children; anything larger goes through the `Workflow` tool.

**Why:** on 2026-08-19 a `dave-researcher` dispatch with a 4-part research question fanned out into
5 uncosted child agents, consumed the entire session usage limit, and returned zero output. Root
cause was **breadth without a pre-dispatch estimate, not nesting depth**. A child that returns
nothing still costs full price.

**How to apply:** when the user says "draft a plan" or "don't spawn subagents," take it literally —
produce the plan document and nothing else. Even for a task an agent nominally owns (a single-source
fact check is Dave's job on paper), do it in the main session with one tool call if it is one source.
See [[feedback-disagreement-over-compliance]] and [[project-claude-practices-kit-layers]].
