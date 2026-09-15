---
name: gru-lite
description: Gru-quality execution for small and medium tasks without a Gru plan. Premise check, a runnable "done when", tests first, and a bob-verifier review only when computed risk triggers it. Use when a build request is bigger than one obvious edit but smaller than a multi-subsystem plan. plan-router.sh points here on build intent.
triggers:
  - small feature
  - medium task
  - gru lite
  - build this properly
---

# Gru-lite

Output without Gru was noticeably worse than with it, and Gru costs too much for small and medium
work. Gru's cost is mostly thoroughness overhead: a cold agent re-reading the whole project, a
yes/no table over the whole kit, a self-grading loop, a long plan file. Its quality most likely
comes from five cheap habits. This skill keeps those and drops the overhead. That split is a
hypothesis (D-017) — the review log below is what tests it.

Runs in the main conversation, not as a subagent, so nothing is re-read from a cold start.

## Escalate to Gru instead — before or during

- The work spans more than one subsystem, or the task list below passes ~10 items.
- The premise check fails, or the problem hasn't been explored (`/thinking-partner` first).
- Partway through, the approach changes shape. Stop and say so; don't quietly grow the task.

## The steps

1. **Start point.** On a feature branch, never main. Record where the task starts:

   ```bash
   bash "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills/gru-lite/review-triggers.sh" start
   ```

   It stores the commit inside `.git`, so step 7 needs no shell variable — the Bash tool does not
   keep variables between calls, and a lost base once measured a 300-line change as zero.
   **Run it, and every command below, from inside the project** (`cd <repo> && bash ...` in the
   same call): the Bash tool resets its directory, and a session can start outside the repo. From
   outside, `start` records nothing and `check` can only answer "unknown → review".
2. **Premise.** Say the goal in one sentence, then the one assumption that would sink it. Check that
   assumption against the code or data and cite what you found (`file:line`, command output).
3. **Context — only what this touches.** The files you will change and their tests; `INVARIANTS.md`;
   the project `CLAUDE.md` rules that apply; `DECISIONS.md` and `HANDOFF.md` entries for this area,
   so earlier decisions are not redone or contradicted. Not the whole kit.
4. **Done when.** A command and its expected output, written before any code. If success can only
   be confirmed by judgment, say so — that is a review trigger, not a failure.
5. **Task list, in chat.** About 10 lines or fewer, in dependency order, each naming its test. No
   plan file.
6. **Build, tests first.** Red, then green, per task. Note honestly if an attempt failed, was
   retried, or the approach changed — that is also a review trigger.
7. **Verify.** Run the done-when command and paste the output. Then decide on review:

   ```bash
   bash "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills/gru-lite/review-triggers.sh" check \
     [--done-when-not-command] [--rough-build]
   ```

   - **`BOB: YES`** — dispatch `bob-verifier` with the diff, the premise, and the done-when. Verify
     what Bob reports before acting on it. Fix, re-run done-when, then log the outcome with the same
     script: `... review-triggers.sh outcome found "<what>"` or `... outcome clean`.
   - **`BOB: NO`** — log `... review-triggers.sh outcome skipped`. Do not dispatch Bob anyway "to be
     safe"; that is the cost this skill exists to remove. If you think the triggers missed something
     real, dispatch Bob and say which trigger should have fired — that is calibration data.
8. **Commit** in `session-workflow`'s format.

## What decides review — computed, not judged

`review-triggers.sh` fires Bob on any of: **size** (over 100 changed lines or 3 files — starting
guesses), **risky path** (hooks, auth, secrets, migrations, settings, CI, `.env`, plus the project's
`.claude/risky-paths.txt`), **invariant file** (named in `INVARIANTS.md` — path, file name, glob, or
folder), **judgment** (done-when not runnable), **rough** (a retry or change of approach),
**unknown** (the change can't be measured — no repo, no valid base, git failed). Failing to measure
always means review, never "measured zero".
Thresholds override with `GRU_LITE_MAX_LINES` / `GRU_LITE_MAX_FILES`.

## Report

```
GRU-LITE — <task>
premise:   <assumption> — <held, with evidence>
done when: <command> -> <pasted result>
review:    BOB: YES (<triggers>) -> <found X, fixed | clean>   |   BOB: NO (<measured>)
commit:    <sha> on <branch>
```

## Calibration

Every decision and outcome is a line in `~/.claude/gru-lite-log.md`. After 10–15 tasks, read it:
a trigger that fires and never finds anything gets cut or loosened; a problem that got through
with no trigger firing gets a new trigger. The thresholds are guesses until then.
