# Session Workflow Rules

> Auto-loaded at session start. This is how every session runs — not what to build, but how to work.

---

## Session Start (Every Session, No Exceptions)

1. **Read META_ARCHITECTURE.md** — tools, data flow, known gaps, decision tree
2. **Check `.claude/plans/`** — if a plan exists, read it before doing anything else
3. **Read `.claude/HANDOFF.md`** — last session blockers and next action
4. **Check skills** — does the task match a registered skill? Invoke it before writing code
5. **Name the session** — historical event on today's date, theme connects to the work

If META_ARCHITECTURE.md doesn't exist yet, create it. If no plan exists, create one before building.

---

## Plan Drafting — Embed Skills Explicitly

When drafting any plan, read the **Toolkit section of META_ARCHITECTURE.md** first. For each phase of the plan, identify which skills belong as explicit checkpoints and write them into the plan steps as `- [ ] Invoke /skill-name — [what to do with it]`.

Skills are not optional extras — they are named steps in the plan. If a skill belongs in a phase, it goes in the plan explicitly before execution starts. This is what makes plans reproducible: the next session reads the plan and knows exactly which skills to invoke and when.

---

## Skills First & the Thinking Trio

> Canonical methodology lives in the `session-workflow` skill (`skills/session-workflow/SKILL.md`). Invoke `/session-workflow` for the full protocol. Project-specific skill applicability lives in the Toolkit table of `META_ARCHITECTURE.md`.

The non-negotiable: before building anything, check if a skill applies and invoke it (even 1% relevance). For non-trivial decisions, run the trio in order — `thinking-partner` → `socratic-examiner` → `assumption-archaeologist`.

---

## TDD Pattern (Code and ML)

Write tests before writing implementation:

**For code:**
1. Write failing test that defines expected behavior
2. Write minimum implementation to pass
3. Refactor — don't change tests

**For ML:**
1. Define eval metric and acceptance threshold before training
2. Write evaluation code first
3. Train the model
4. Evaluate against threshold — pass/fail
5. Tune only if you failed the threshold

---

## Conversational Execution Pattern

Never run silently through a plan and present a wall of output.

- Surface findings at each phase transition before moving on
- When something unexpected comes up, say it out loud
- Ask "does this change anything?" at phase transitions
- Give natural pause points to redirect

**The test:** Could the user catch a lazy step? Silent execution hides it. Conversational execution exposes it.

---

## Plan File as Living Log

A plan file is not a checklist — it is a running log that survives context compression.

After each phase: write key findings into the plan's Running Notes section before moving on. Write what Phase N+1 needs to know: surprises, priority changes, things that contradict the original plan.

**The test:** If the session ended right now and someone started fresh with only the plan file, could they pick up Phase N+1 without repeating Phase N?

---

## Session End (Every Session)

Before closing:

1. Update `META_ARCHITECTURE.md` if anything changed (tools, data flow, gaps)
2. Run `/code-review` if any significant code was written
3. Write `.claude/HANDOFF.md` — replace each session, covers:
   - What was completed
   - Blockers / what didn't work
   - Next action (priority 1)
   - Test state
   - Data/artifact state (if ML)
4. Commit with session name in commit message

---

## Context Management

There is no hard limit. When context is climbing, flag it and ask — don't act unilaterally.

Options when context is high:
- `/compact` with a summary hint — for general bloat
- Offload to subagent — for batch work or research
- Fresh session with plan file as context — for major phase transitions

Never process 50+ files sequentially in the main session — use standalone scripts or subagents.
