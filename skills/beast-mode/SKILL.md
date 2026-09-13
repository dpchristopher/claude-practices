---
name: beast-mode
description: Execute a Gru implementation plan end to end with maximum autonomy — every task through a maker, an independent checker, and a mechanical verify, stopping on any failed gate and pausing at tasks marked WITH DANIEL. Use when a plan from gru-planner exists and has been approved, and the ask is to "execute the plan", "run the plan", "go beast mode", or "build all of it".
triggers:
  - beast mode
  - execute the plan
  - run gru's plan
  - build all of it
  - go through the whole plan
---

# Beast Mode

Gru plans. Beast mode executes. **It composes existing parts and adds no new capability**
(decision D-013): `superpowers:subagent-driven-development`, the named maker/checker agents Gru
already assigns per task, and — for large plans — the `Workflow` tool.

**Beast mode is where Fable earns its cost** (D-011). A long chain that must recover from failure
without a human is exactly where Fable's measured edge sits — Terminal-Bench 4.0 is +13.8 points
over Opus, versus +3.4 on in-editor coding ([Anthropic, Introducing Claude Fable 5.1](https://www.anthropic.com/claude-fable-and-mythos-5-1): Terminal-Bench 4.0 55.8% vs 42.0%; CursorBench 3.2.0 73.4% vs 70.0%). For a long unattended run, run the orchestrating
session on Fable. For a short plan you are watching, Opus is fine.

---

## Before anything runs — four gates

**1. A plan exists and was approved.** Beast mode executes a Gru plan. It does not write one. If
there is no plan, stop and suggest `@gru-planner`. If the plan was never reviewed, suggest routing
it to `bob-verifier` first — maker≠checker applies to plans too.

**2. Explicit go-ahead, every session.** `~/.claude/CLAUDE.md`: *"Unattended loops with permission
prompts disabled require Daniel's explicit per-session go-ahead; never let them touch prod data,
secrets, or `git push` to main."* Ask once, clearly, stating how many tasks will run and that it
will not push. **Do not proceed on an ambiguous answer.** Approval from a previous session does
not carry over.

**3. Read the plan's own hazards before the first task.** Gru's plans carry task-ordering
constraints that are load-bearing, not cosmetic. Example from the Civ plan: adding a validator
check before the reference JSONs carry fingerprints makes `stop-verify.sh` block **every turn,
including the turns needed to fix it**. Execute tasks in the plan's stated order. Never reorder
to save time.

**4. Check the fan-out ceiling for this project.** `guard-fanout.sh` returns `ask` past a
rolling-window dispatch threshold, and **`ask` is not auto-approved even in `bypassPermissions`
mode** — beast mode will stall on a prompt mid-run. Default threshold is 4 per 5 minutes;
`claude-practices` sets 8. For a plan that dispatches heavily, either route it through the
`Workflow` tool (the sanctioned path for large fan-out, with real caps and visible spend) or pace
dispatches. Do not silently raise the threshold.

---

## Per task — the loop

For each task, in the plan's order:

**a. Maker** — dispatch the agent Gru named for the task. Brief it with the task's full text from
the plan, its "done when" criterion, and:

> **Produce the artifact yourself. Do not return a delegation as your deliverable.** Write output
> to files, not only to your reply.

That instruction exists because it failed for real: on 2026-09-08 a dispatched agent spawned four
children, returned *"I'll wait for their completion notifications, then write the synthesis"* as
its **final answer**, and terminated — orphaning all four and producing nothing.

**b. Verify the maker's claim locally.** Before any checker sees it, confirm the files it says it
wrote exist and changed (`git diff --stat`). An agent's self-report is a claim, not a result
(D-001) — in one session an agent reported an edit it never made.

**c. Mechanical check** — run the task's "done when" command exactly as the plan states it, plus
the project check (`PROJECT_CHECK_CMD`, or `verify-kit.sh` in `claude-practices`). Paste the real
output. **A mechanical check beats a reviewer's opinion; run it first and let it gate the rest.**

**d. Checker** — dispatch `bob-verifier` on the task's diff. Use Bob rather than
`general-purpose`: `guard-verdict.sh` enforces a verdict marker only on named checker agents, so a
review sent to `general-purpose` runs without that gate. This is a choice to make deliberately,
**not** something a hook enforces — a guard that tried was removed the day it was added (D-014),
because `/code-review` and the superpowers spec reviewer legitimately use `general-purpose`.

**e. Mutation test, where the task built a check.** If the task added any guard, validator check,
invariant, or hook: inject the fault, confirm it fails, restore, confirm it passes. **A check that
cannot fail is not a check** (D-005). Three of four invariants in this kit once could not fail,
and the first fix to one of them had the same blindness.

**f. Commit** the task on the feature branch, conventional message. One task, one commit.

### Iteration cap

If a task fails c, d, or e: fix and retry, **at most 3 attempts** (`loop-cost-discipline.md`).
Stop after two consecutive attempts that produce no measurable improvement. Then STOP the run and
report — do not continue to the next task on top of a failure.

---

## Stop and pause conditions

| Condition | Action |
|---|---|
| Task marked **WITH DANIEL** | **PAUSE.** Report progress, present the decision, wait. Never skip past it |
| A gate fails after 3 attempts | **STOP.** Report what failed and the last real output |
| A plan hazard would be violated | **STOP.** Do not reorder around it |
| A kill condition in the plan is met | **STOP.** Execute the plan's stated fallback, not an improvisation |
| Anything would touch secrets, prod data, or push to main | **STOP.** Out of scope for any autonomous run |
| The plan is ambiguous about a task | **PAUSE** and ask. Do not guess what Gru meant |

Pausing is not failing. A run that pauses correctly at a decision is working as designed.

---

## The report

At every pause or stop, and at the end:

```
BEAST MODE — <plan file> — <date>

STATUS: <complete | paused at task N | stopped at task N>

⚠ NEEDS ATTENTION
  - <failures, stalls, unverified agent claims, WITH DANIEL decisions waiting>
  (or: nothing)

TASKS
  ✓ 1.1  <title> — <sha> — check: <result> — Bob: <verdict>
  ✓ 1.2  ...
  ⏸ 2.7  WITH DANIEL — <the decision needed>
  ·  3a.1 not started

AGENT CLAIMS THAT DID NOT VERIFY
  - <or: none>
```

Then run `/session-close` before stepping away.
