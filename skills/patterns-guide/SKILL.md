---
name: patterns-guide
description: Decision guide for which Claude Code pattern to apply. Use when designing an approach, choosing how to structure work, or stuck on "how should I do this?" Covers 10 core patterns plus ML/automation variants.
triggers:
  - which pattern should I use
  - how should I approach this
  - I'm not sure how to structure this
  - what's the best way to
  - designing an approach
  - patterns guide
---

# Patterns Guide

Use this skill when you need to know *how* to approach something — not what to build, but the right structure and discipline to build it well.

---

## Pattern 1: Plan Mode → 1-Shot Implementation

Pour energy into the plan. Execute in a fresh session.

1. Use `/thinking-partner` + `/assumption-archaeologist` to stress-test the plan
2. Write the plan to `.claude/plans/[session-name].md`
3. Start a **fresh Claude Code session** with the plan file as context
4. Execute without switching back to planning mid-stream

**Why:** Planning and execution use different cognitive modes. Mixing them leads to scope drift and rework. A fresh session with a solid plan produces much cleaner output than a session that evolved organically.

**When to use:** Any task that takes more than ~30 minutes, or involves more than 2-3 files.

---

## Pattern 2: Git Worktrees for Parallel Work

Run two features simultaneously in isolated directory copies.

```bash
git worktree add ../project-feature-a feature-a
git worktree add ../project-feature-b feature-b
# Open two Claude Code sessions, one in each worktree
```

**When to use:** Independent features that can be developed simultaneously, or when you want to test something risky without affecting the main working tree.

**Don't use:** For concurrent file edits — worktrees prevent merge conflicts but not logical conflicts. Use subagents for parallel *research*; worktrees for parallel *code changes*.

---

## Pattern 3: Subagents for Batch Processing

For tasks that process many items (files, records, URLs), use subagents — not sequential loops in the main session.

```
Wrong: process 100 PDFs sequentially in main session (context accumulates, model degrades)
Right: spawn subagent per PDF, collect only result summaries
```

**When to use:** 50+ items to process, parallel research tasks, anything that would produce lots of output in the main session.

**How:** Each subagent starts fresh. Only the summary JSON returns to main context. Main session stays lean.

---

## Pattern 4: Context Budget Management

There is no hard limit — but context accumulation degrades output quality.

When context is climbing:
1. Flag it out loud: "Context is getting high (~50+ operations). Want to address it?"
2. Suggest the right move:
   - `/compact` with a hint → for general bloat
   - Offload to subagent → for batch work
   - Fresh session with plan file → for major phase transitions
3. Let the user decide — never autocompact unilaterally

**The most expensive mistake:** Accumulating 100+ tool outputs in the main session. After ~50 operations, quality degrades. The fix is subagents.

---

## Pattern 5: "Grill Me On These Changes"

Before merging a feature branch, ask Claude to challenge it:

*"Grill me on these changes. Look at the diff and find the weakest points — logic errors, edge cases I haven't handled, assumptions that might be wrong."*

Or use `/socratic-examiner` or `/code-review` for structured versions.

**When to use:** Before any merge to main. Before shipping any feature. Whenever you feel suspiciously confident.

---

## Pattern 6: "Prove to Me This Works"

After building a feature, compare behavior between branches:

*"Compare the behavior of this feature between main and the feature branch. What changed? Does it actually do what I said it would?"*

**When to use:** After implementing a significant change. Before shipping. Whenever tests pass but you're not sure if the feature *actually works*.

---

## Pattern 7: /loop for Active Development

During a debugging or feature build session, run tests automatically:

```
/loop 2m pytest tests/test_parser.py -v
```

Tests run every 2 minutes. Failures surface immediately without manual re-runs.

**When to use:** Active debugging or TDD cycles. Not for long-running tasks — use scheduled agents (CronCreate) for cross-session loops.

---

## Pattern 8: Conversational Plan Execution

Execute plans in phases with natural conversation between them.

- Surface findings at phase transitions before moving to the next phase
- Ask "does this change anything?" — don't assume
- Say unexpected things out loud rather than noting them silently
- Reshape the plan mid-stream when findings change what matters

**The test:** Could the user have caught a lazy step? Silent execution hides it. Conversational execution exposes it.

**When to use:** Any multi-phase plan. Especially when the plan has uncertainty or the domain is complex.

---

## Pattern 9: Plan File as Living Log

A plan file is not a checklist — it is a running log that survives context compression.

After completing each phase: write key findings into the plan's Running Notes section before moving on.

**What to write:** Surprises, priority changes, things that contradict the original plan. Not everything — just what Phase N+1 needs to know.

**The test:** If this session ended right now and someone started fresh with only the plan file, could they pick up Phase N+1 without repeating Phase N?

---

## Pattern 10: CLAUDE.md as Living Document

Update CLAUDE.md when:
- A hard rule is added or changed
- A tool or convention is added/removed
- The tech stack changes

Don't document what's already in the code. Document the WHY that isn't visible in code.

---

## ML Pattern: Experiment-First, Then Code

Before training any model:

1. Define the eval metric and acceptance threshold (e.g., "F1 > 0.82 on holdout")
2. Write the evaluation code
3. Train baseline with zero tuning
4. Evaluate — pass/fail
5. Only tune if you failed — never tune before establishing a baseline

**Why:** Tuning before a baseline leads to overfitting to your intuitions rather than to data.

---

## ML Pattern: Holdout Set is Sacred

Split train/val/test **before** any feature engineering or scaling. The holdout test set is never touched during development. It is used once: final evaluation before production.

---

## Automation Pattern: Test Locally, Then Schedule

Never schedule a script without:
1. Running it manually with a small sample
2. Running it again on the same sample (verify idempotent)
3. Running it with empty input (verify graceful)
4. Running it with bad input (verify logged, not crashed)

If it can't pass these four checks manually, it cannot be scheduled.

---

## Choosing a Pattern

| Situation | Pattern |
|---|---|
| About to start building something complex | Plan Mode → 1-Shot (Pattern 1) |
| Need two features in parallel | Git Worktrees (Pattern 2) |
| Processing many items | Subagents (Pattern 3) |
| Context getting heavy | Context Budget (Pattern 4) |
| About to merge | Grill Me (Pattern 5) + Prove It Works (Pattern 6) |
| Active debugging / TDD | /loop (Pattern 7) |
| Executing a multi-phase plan | Conversational Execution (Pattern 8) |
| Between phases | Plan as Living Log (Pattern 9) |
| Project rules changed | Update CLAUDE.md (Pattern 10) |
| Starting any ML work | Experiment-First + Holdout Sacred |
| Building any automation | Test Locally Then Schedule |
