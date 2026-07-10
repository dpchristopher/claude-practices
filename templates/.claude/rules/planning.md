# Planning Rule

> Auto-loaded at session start. The canonical checklist for drafting a plan. Gru reads this;
> Bob grades plans against it. When planning, delegate to Gru (gru-planner) — he applies all
> of the below end to end. This rule is the single source of truth for what a good plan contains.

## Before planning
- **Triage:** one-liner → just do it, no plan. Multi-subsystem → decompose into sub-plans first.
- **Read the context:** the project `CLAUDE.md` (its law), `HANDOFF.md`, the active plan,
  `META_ARCHITECTURE.md`, `INVARIANTS.md`, and the rules/agents. Don't re-plan done work.
- **Explore first if needed:** if the problem space is unexamined, run `/thinking-partner`
  with the user before drafting. Don't plan on unproven assumptions.

## A good plan contains (all explicit — no placeholders)
- **Applicability decisions:** which skills/agents/rules apply, each with a reason (nothing
  silently skipped).
- **Skills as named checkpoints;** dialogic ones (`the-fool`, `thinking-partner`,
  `socratic-examiner`, `assumption-archaeologist`) as human-in-the-loop steps.
- **Agent routing:** Bob verifies, Kevin on security/data, Mel on UI, Phil writes tests,
  Carl grades ML outputs, Jerry syncs docs.
- **Affected invariants captured** and re-verified at the end.
- **Evidence-based verification per phase** (command + expected output — not "done").
- **Git + TDD:** feature branch (never main), commit per task, tests before implementation.
- **Explicit "Done when ___"** acceptance criteria (checkable; a `/goal` exit if looped).
- **Dependency ordering:** no task depends on a later one.
- **Loops** given an exit condition written first.
- **A feynman gate** before HANDOFF.

## After drafting (maker ≠ checker)
The author self-audits, THEN an independent checker (Bob) grades the plan against this rubric
before execution. The user reviews and approves the plan. Nothing executes on a red plan.
