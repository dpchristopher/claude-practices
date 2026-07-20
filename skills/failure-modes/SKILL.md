---
name: failure-modes
description: |
  Catalog of known Claude Code failure modes with a detection signal and an escape move for each. Use when a session feels stuck, looping, over-planned, or about to claim done without evidence — the "something is going wrong and I need to get unstuck" moment.

  Trigger for:
  - Claude repeating the same fix/command with no progress
  - A tiny change ballooning into a multi-step plan
  - About to mark work "done" without having run it
  - The thinking trio or planning process spinning without converging
  - "Why is this stuck / looping / taking so long"

  Don't trigger for:
  - Normal debugging of a specific error (use debugging-wizard)
  - Fresh ideation with no work underway (use thinking-partner)

  Completes the back-half kit alongside the verification, loop, and measurement rules.
---

# Failure Modes & Recovery

When a session goes wrong, it usually goes wrong in one of a few named ways. Find the row, run the
escape move. Recovery beats thrashing.

## The catalog

| Anti-pattern | Detection signal | Escape move |
|---|---|---|
| **Loop drift** (spinning on the same fix) | Same tool call / same failing command ~3× ("rule of 3"); error text unchanged across attempts | Stop. State the hypothesis out loud, change the *approach* not the parameters. Invoke `debugging-wizard`. Hard budget (~10 turns) → escalate to the user. |
| **Analysis paralysis** (thinking trio runs long) | 3+ file reads / "let me also consider…" with no decision or edit committed | Force a decision: write the chosen option + why, timebox it, exit the thinking skill, act. |
| **Spec bureaucracy** (over-planning a tiny fix) | About to write a multi-section plan for something fixable in one follow-up prompt | Heuristic: would mis-interpretation annoy you? No → skip the plan, just do it. |
| **Premature done** (claiming success unverified) | Saying "fixed/passing" without a pasted command + output | Don't assert without evidence — run it, paste output. Dispatch `bob-verifier`. (See the verification rule.) |
| **Reviewer over-engineering** (gaps that aren't gaps) | Review suggestions expand scope / add abstraction beyond the task | Scope-guard: implement only what the task needs; defer gold-plating to the backlog. |
| **Kit over-process** (the meta one) | The ceremony is slowing a task the user wanted done fast; you're invoking skills to look rigorous, not to help | Name it. Drop to the lightest path that still works. The kit serves the work, not the reverse. |

## The principle

An error inside a loop is the next instruction, not a dead end — but only if it *changes* the next
action. The same action repeated is not recovery; it's the failure. Detect, switch, or escalate.
