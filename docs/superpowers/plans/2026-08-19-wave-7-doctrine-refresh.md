# Wave 7 — Doctrine Refresh: Limits, Isolation Mechanisms & the Fan-Out Brake

> **Status: DRAFT — awaiting user review and an independent Bob pass. Nothing executes on an unapproved plan.**

**Goal:** Reconcile the kit's doctrine with the platform as it actually is in August 2026, and install
a real brake on the failure that already cost a session — uncosted ad hoc agent fan-out. Correct what
is wrong, replace what is superseded, prune what is dead, and cite every number.

**Architecture:** Markdown + Bash + JSON. No application code. Every task ends in a grep/test-backed
commit.

**Branch:** `feature/wave-7-doctrine-refresh` off `master`. Version 1.3.1 → **1.4.0** (minor: new
global-rules install path + new hook + new doctrine).

**Repo:** `C:/Users/dpchr/OneDrive/Desktop/claude-practices`

**Sourcing discipline (Wave 5's bar, held):** every factual claim added by this wave carries a dated
primary-source citation in the new `SOURCES.md`. Any claim that cannot be traced to a primary source
this wave does not ship. The MAST percentages are **currently below this bar** and Phase 1 gates them.

---

## Triage (Phase 0 of the planning rule)

Not a one-liner. Not a rewrite either. Nineteen candidate items span four subsystems:

| Sub-project | Items | Verdict |
|---|---|---|
| **A. Limits, isolation & the fan-out brake** | 1, 2, 3, 4, 7, 11, 12, 18 | **Wave 7 — core.** One coherent decision surface: "which isolation mechanism, at what cost." |
| **B. Native tool replacements** | 5, 6 | **Wave 7 — cheap, and they are replacements, which pays the prune tax.** |
| **C. Evidence & evals gaps** | 15, 16, 19 | **Wave 7 — small, high-leverage; 15 gated on verification.** |
| **D. Automation-surface taxonomy** | 8, 9 | **DEFER to Wave 8.** See "What defers and why." |
| **E. Roster philosophy fork** | 10 | **DEFER — needs `/the-fool` with the user first.** Not plannable yet. |
| **F. Fan-out prompt hook** | 17 | **Downscoped and made conditional.** See Task 6.2 — as specified it is a bad idea. |
| Plus user requirements | A (README), B (citations), C (global layer), D (prune) | **Wave 7 — all four.** |

Wave 7 ships A + B + C + the four user requirements. D, E, F(as-specified) defer.

---

## Findings from reading the current repo that CHANGE the brief

These were discovered while grounding this plan. They alter what the tasks touch. Read before executing.

1. **Finding #6's target files are wrong.** `ROLLBACK.md` and `BACKUP.md` contain **no** `git worktree`
   instructions — verified by `grep -rn "worktree"`. The manual worktree commands actually live in
   **`skills/patterns-guide/SKILL.md:39-46`** and **`docs/Coolest Thing Since Chrystal Ball.md:476-478`**,
   with passing mentions in `templates/.claude/workflows/README.md:21`. Task 4.2 targets the real files.

2. **The global rule layer is not in version control at all.** `~/.claude/rules/kit-maintenance.md` and
   `~/.claude/rules/loop-cost-discipline.md` exist only on this machine. `find` across the repo returns
   no copy. `install.sh` copies **skills, hooks, agents — not rules, not `global-CLAUDE.md`.** So the
   single most important fix of this wave (#11) would land in an untracked, un-backed-up, un-reinstallable
   file. **This is a prerequisite, not a nice-to-have** — Task 1.3 fixes it before Task 2.1 writes into it.

3. **Dave's own prompt is the proximate cause of the incident.** `templates/.claude/agents/dave-researcher.md:29-33`
   instructs: *"you may spawn a sub-researcher per source or angle (nested subagents, up to 5 levels deep)"*
   with **no budget, no count cap, and no estimate step**. The global rule fix alone does not remove the
   instruction that caused the burn. Task 2.2 rewrites it. Bob carries the same text at `bob-verifier.md:46-50`.

4. **`templates/global-CLAUDE.md` is stale** vs. the live `~/.claude/CLAUDE.md` — the shipped template is
   missing the `bob-verifier` dispatch row, `carl-evals`, the unattended-loop rule, the session-metrics
   rule, and the refinement cap. Anyone installing the kit fresh gets a weaker global file than the author
   runs. Task 1.3 syncs it while it is already touching that layer.

5. **README has a broken link.** README:65 references `docs/Coolest Thing Since Crystal Ball.md`; the file
   on disk is `Coolest Thing Since Chrystal Ball.md` (misspelled). One-line fix, folded into Task 7.2.

6. **Three different CLAUDE.md line budgets are in circulation.** README:21 and README:103 say "under 200
   lines"; `templates/CLAUDE.md` footer says "under 80 lines"; `kit-maintenance.md` says "~90". Folded into
   the prune pass (Task 8.1).

7. **Changelog dates disagree with the brief.** The `[1.2.0]` Wave 5 entry is dated `2026-06-29`, as are all
   plan filenames; the brief says Wave 5 landed 2026-07-13. Not worth a task — noted so nobody "fixes" it
   into a new inconsistency. If the dates are wrong, correct them in one changelog edit during Task 9.1.

---

## Affected invariants

The kit repo has **no `INVARIANTS.md` of its own** — only `templates/INVARIANTS.md`. The kit does not eat
its own dog food. Task 1.2 seeds a real one with four rows, chosen because each is cheaply checkable and
each is something this wave could plausibly break:

| ID | Invariant | Area | How to verify |
|----|-----------|------|---------------|
| INV-01 | Both installers are idempotent and a dry run writes nothing. | `install.sh` / `install.ps1` | `./install.sh --dry-run && git status --porcelain \| wc -l` → `0` |
| INV-02 | Every file in `hooks/` is installed and every hook referenced by `templates/.claude/settings.json` exists in `hooks/`. | hooks ↔ settings wiring | Task 1.2 ships `verify-hooks.sh`; exits 0 with `HOOK PARITY OK` |
| INV-03 | No secret-shaped string is committed. | whole repo | `pre-commit run --all-files` (gitleaks) → pass |
| INV-04 | Every platform limit number quoted in shipped doctrine has a dated entry in `SOURCES.md`. | `templates/.claude/rules/*`, agents, `global-rules/*` | Task 1.2 ships `verify-sources.sh`; exits 0 with `CITATIONS OK` |

INV-04 is the machine-checkable form of user requirement B. Re-verify all four at Phase 9.

---

## Phase 1 — Foundations (everything else depends on these)

### Task 1.1 — Branch and baseline evidence
**Model:** main session. **Agent:** none (mechanical, 4 commands).

- [ ] `git checkout master && git pull && git checkout -b feature/wave-7-doctrine-refresh`
- [ ] Capture baseline evidence into the plan's Running Notes:
```bash
cd "C:/Users/dpchr/OneDrive/Desktop/claude-practices"
git status --porcelain | wc -l        # expect 0
cat VERSION                            # expect 1.3.1
ls hooks/ | wc -l                      # expect 11
ls templates/.claude/agents/*.md | wc -l   # expect 9
wc -l templates/.claude/rules/*.md     # record for the prune pass
```
**Evidence:** paste the five outputs. **Done when:** branch exists, tree clean, baseline pasted.

---

### Task 1.2 — Seed `INVARIANTS.md` + two verifier scripts
**Model:** main session for the invariant text (judgment); **Phil (sonnet)** writes and runs the two scripts.
Phil is the right call — these are the wave's test harness and Phil's job is tests that verify real behavior.

- [ ] Write `INVARIANTS.md` at repo root using `templates/INVARIANTS.md`'s table shape, with INV-01…INV-04
      above, all seeded `⚠ unverified`.
- [ ] Phil writes `scripts/verify-hooks.sh`: for every `hooks/*` file assert it appears in the install
      manifest path list; for every `~/.claude/hooks/...` string in `templates/.claude/settings.json` and in
      every `templates/.claude/agents/*.md` frontmatter, assert the referenced file exists in `hooks/`.
      Print `HOOK PARITY OK` and exit 0, or print each mismatch and exit 1.
- [ ] Phil writes `scripts/verify-sources.sh`: grep shipped doctrine (`templates/.claude/rules/*.md`,
      `templates/.claude/agents/*.md`, `global-rules/*.md`) for numeric limit claims matching
      `-E '\b(1,000|1000|[0-9]{1,3})\s*(concurrent|total|agents|levels|deep|daily)\b'`; for each hit, assert
      the file contains a `SOURCES.md` pointer within the same section heading. Print `CITATIONS OK` / exit 0,
      or list uncited numbers / exit 1. **This script defines what "cited" means — keep it strict enough to
      catch a bare number, loose enough not to flag prose.** Phil tunes it until it flags a deliberately
      planted uncited number and passes on the real corpus.
- [ ] TDD order: Phil plants a fake uncited number in a scratch copy, confirms `verify-sources.sh` exits 1,
      removes it, confirms exit 0. Same for a dangling hook reference.

**Evidence:**
```bash
bash scripts/verify-hooks.sh; echo "exit=$?"     # HOOK PARITY OK / exit=0
bash scripts/verify-sources.sh; echo "exit=$?"   # will exit 1 until SOURCES.md exists — expected here
```
**Commit:** `Wave 7: seed kit INVARIANTS.md + hook-parity and citation verifier scripts`

---

### Task 1.3 — Put the GLOBAL rule layer under version control and into the installer
**Model:** main session. **Agent:** none — this is a small structural change where a wrong call is
immediately visible. **Prerequisite for Task 2.1.**

- [ ] Create `global-rules/` at repo root. Copy in the two live files verbatim as the starting point:
      `~/.claude/rules/kit-maintenance.md` and `~/.claude/rules/loop-cost-discipline.md`.
- [ ] Add a `global-rules/README.md` (≤15 lines) stating the two-layer model explicitly: **`global-rules/`
      → `~/.claude/rules/` (always loaded, every project, every turn — keep tiny); `templates/.claude/rules/`
      → per-project, installed by copy or `/init`.**
- [ ] Extend `install.sh` with a step 4 mirroring step 3's `do_cp` loop, writing `global-rules/*.md` into
      `$DEST/rules/` and recording to the manifest. Mirror it in `install.ps1`. Both must honour `--dry-run`
      / `-DryRun`.
- [ ] Sync `templates/global-CLAUDE.md` to match the live `~/.claude/CLAUDE.md`'s hard-rules block (add the
      `bob-verifier` dispatch row, `carl-evals` row, the no-unattended-loops rule, session-metrics logging,
      the ~3-iteration refinement cap). **Hold the ≤60-line budget** — if it does not fit, the overflow moves
      into `global-rules/`, not into the always-loaded CLAUDE.md.

**Evidence:**
```bash
./install.sh --dry-run | grep -c "global-rule:"          # expect 2
git status --porcelain | wc -l                            # expect 0 — dry run wrote nothing (INV-01)
HOME=/tmp/wave7-test ./install.sh >/dev/null && ls /tmp/wave7-test/.claude/rules/ | wc -l   # expect 2
wc -l templates/global-CLAUDE.md                          # expect <= 60
rm -rf /tmp/wave7-test
```
**Commit:** `Wave 7: track global rule layer in-repo and install it (global-rules/ -> ~/.claude/rules/)`

---

### Task 1.4 — GATE: verify the MAST paper against the primary PDF
**Model:** main session, **one `WebFetch`, no agent, no fan-out.** This is deliberate: the item is a
single-source fact extraction, and dispatching a research agent for it would repeat the exact failure this
wave exists to fix. Doing it in-session is the plan demonstrating its own rule.

- [ ] Fetch `https://arxiv.org/abs/2503.13657` and the full text (`https://arxiv.org/pdf/2503.13657`).
- [ ] Verify, item by item, and record each as CONFIRMED / CORRECTED / UNVERIFIED:
      - The 14 failure modes and their **exact names**, and the 3 categories.
      - The percentages: Step Repetition 15.7%, Unaware of Termination Conditions 12.4%, Disobey Task
        Specification 11.8%, Loss of Conversation History 2.8%, System-design 44.2%, inter-agent
        misalignment ~37%.
      - The trace count (1,600+), framework count (7), and κ=0.88.
      - The verbatim wording of the conclusion currently paraphrased as *"identified failures require more
        sophisticated solutions."*
- [ ] Write the results into `SOURCES.md` (created here) with the fetch date.

**Hard branch — decide before Phase 5:**
- If **confirmed** → Phase 5 may quote the numbers.
- If **any number is wrong** → use the corrected number.
- If a number **cannot be located in the paper** → **the doctrine cites the mapping qualitatively and quotes
  no percentage.** The kit's value here is that MAST's measured failure modes independently corroborate rules
  the kit already has; that argument survives without decimals. Do not ship a number the PDF does not state.

**Evidence:** paste the CONFIRMED/CORRECTED/UNVERIFIED table into the plan's Running Notes and into `SOURCES.md`.
**Commit:** `Wave 7: create SOURCES.md; verify MAST (arXiv:2503.13657) claims against the primary PDF`

---

### Task 1.5 — Establish `SOURCES.md` as the citation home
**Model:** main session. **Design decision requiring user sign-off before Phase 3 quotes anything.**

**Recommendation:** a single root `SOURCES.md` ledger, not inline URLs and not changelog-only notes.

**Why:** inline URLs bloat always-loaded rule files against a hard line budget; changelog notes bury a claim's
provenance across waves so you cannot answer "where did this number come from" without archaeology. A single
dated ledger is greppable, is what makes INV-04 machine-checkable, and gives the next wave one file to re-verify.

- [ ] Structure: one row per claim — `| Claim | Primary source URL | Date verified | Quoted in |`, grouped by
      anchor heading (`## subagent-limits`, `## automation-surfaces`, `## mast`, `## judge-calibration`).
- [ ] Rules reference it by anchor only: `(source: SOURCES.md#subagent-limits)`. Costs ~6 tokens per claim.
- [ ] Seed with the MAST rows from Task 1.4 and the platform-limit rows the brief supplies (nesting depth 3 /
      `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH` v2.1.219+; concurrency 20 / `CLAUDE_CODE_MAX_CONCURRENT_SUBAGENTS`;
      fork default v2.1.232+ / `CLAUDE_CODE_FORK_SUBAGENT`; cross-session messaging 2026-08-07; Workflow caps
      16/1,000; Husain evals-skills, hamel.dev/blog/posts/evals-skills/, March 2026).

**Evidence:** `bash scripts/verify-sources.sh; echo "exit=$?"` → `CITATIONS OK`, `exit=0` (INV-04 flips to `✅ holds`).
**Commit:** `Wave 7: SOURCES.md seeded with Wave 7's primary-source ledger`

---

## Phase 2 — The fan-out brake (the item that matters most)

> Root cause on record: **breadth without a pre-dispatch estimate, not depth.** A 4-part question became 5
> uncosted children, burned the session limit, and returned zero output. Three files carry the fix; the
> global rule alone is insufficient because Dave's own prompt still instructs unbounded fan-out.

### Task 2.1 — Extend `global-rules/loop-cost-discipline.md` (GLOBAL layer)
**Model:** main session (doctrine = judgment). **Agent:** none.

- [ ] Add a section titled **"Estimate breadth before dispatch — ad hoc fan-out"** immediately after the
      existing "Parallelize Only When Work > Cold-Start Tax". Content, verbatim intent:
      - Before dispatching **any** agent, state two numbers out loud: **how many children** and **roughly what
        each will cost**. If you cannot name both, you are not ready to dispatch.
      - A multi-part question is **not** a licence to spawn one child per part. Decompose the question first,
        then decide how many children the *answer* needs.
      - **Ad hoc `Agent` fan-out is capped at 3–4 children.** Anything larger routes through the `Workflow`
        tool, which gives visible progress in `/workflows`, real caps, and token-budget awareness.
      - A child that returns nothing still costs full price. **Budget for the failure case.**
      - Named regression: 2026-08-19 — one researcher agent, a 4-part question, 5 uncosted children, entire
        session limit consumed, zero output returned.
- [ ] Keep the addition **under 14 lines.** This file is always loaded on every project on every turn.
- [ ] Add the pointer `(source: SOURCES.md#subagent-limits)` where the 3–4 cap references platform limits.

**Evidence:**
```bash
grep -c "Estimate breadth before dispatch" global-rules/loop-cost-discipline.md   # expect 1
wc -l global-rules/loop-cost-discipline.md                                        # expect <= 70
```
**Commit:** `Wave 7: global rule — estimate breadth before dispatch; ad hoc fan-out capped at 3-4`

---

### Task 2.2 — Fix Dave's and Bob's fan-out instructions (the proximate cause)
**Model:** main session. **Agent:** none — two targeted paragraph rewrites.

- [ ] `templates/.claude/agents/dave-researcher.md:29-33` — replace the "Nested fan-out for multi-source
      research" section. New content must:
      - Drop "up to 5 levels deep" entirely (it is wrong — see Task 3.1 — and it was never the constraint
        that mattered).
      - Require, **before any dispatch**: state the child count and the per-child budget.
      - Cap ad hoc children at **3–4**; route larger jobs to the `Workflow` tool.
      - Add the line: **"A 4-part question is one research job, not four agents. Decompose the question, then
        decide how many children the answer needs."**
      - Keep the existing "do the synthesis yourself" instruction — it was never the problem.
- [ ] `templates/.claude/agents/bob-verifier.md:46-50` — same treatment for "Nested fan-out for large diffs".
      Bob's case is narrower (per-finding sub-verifiers), so the honest edit is: **default to zero children;**
      fan out only when the diff genuinely exceeds what one pass can hold, and then ≤3, budget stated first.
- [ ] Consider adding `maxTurns` to Dave as a hard structural brake, mirroring Stuart's `maxTurns: 8`.
      **Verify the field is valid for a non-Haiku agent against the sub-agents docs before adding it** — do
      not guess. If unverifiable, skip it and say so; the prompt-level cap still stands.

**Evidence:**
```bash
grep -c "5 levels deep" templates/.claude/agents/*.md    # expect 0 across all files
grep -c "state the child count" templates/.claude/agents/dave-researcher.md   # expect 1
grep -c "3" templates/.claude/agents/bob-verifier.md     # manual read-back of the section
```
**Commit:** `Wave 7: Dave and Bob get a pre-dispatch budget and a 3-4 child cap (2026-08-19 regression)`

---

### Task 2.3 — Pin the incident as a regression case
**Model:** main session. **Agent:** none. Uses `evals.md`'s existing mechanism — **no new mechanism invented.**

- [ ] `templates/.claude/rules/evals.md` — under the existing "Failures become regression cases" section, add
      a short **"Pinned cases"** subsection with the 2026-08-19 fan-out burn as the first entry, in the shape:
      *what happened · root cause · the assertion that would have caught it · where the fix lives.*
      Assertion for this one: **"a dispatch with no stated child-count is a fail, regardless of output quality."**
- [ ] Add the same row to `.claude/session-metrics.md`'s top-failure column for this session, tagged
      `loop-cost-discipline`, so the monthly review in `measurement.md` sees it.

**Evidence:** `grep -c "Pinned cases" templates/.claude/rules/evals.md` → `1`;
`grep -c "2026-08-19" templates/.claude/rules/evals.md` → `1`.
**Commit:** `Wave 7: pin the 2026-08-19 fan-out burn as a regression case in evals.md`

---

## Phase 3 — Limits and isolation mechanisms (one coherent decision surface)

> Items 1, 2, 3, 4, 7, 18 are not six separate edits. They are one question the doctrine currently cannot
> answer: **"I need work done elsewhere — which mechanism, and what does it cost?"** Write it once, in one
> place, as one table.

### Task 3.1 — Correct the three limit systems (items 1, 2, 3)
**Model:** main session. **Agent:** none.

- [ ] `templates/.claude/rules/loop.md` — retitle the "Loop cost budgets" section to make its scope explicit:
      these ceilings (16 concurrent / 1,000 total / "Large workflow" warning / `small`-`medium`-`large`
      config) describe **the Workflow tool only.** They do not govern ad hoc `Agent` dispatch.
- [ ] Add a short three-row table distinguishing the systems, each with a `SOURCES.md` anchor:

  | System | Limit | Env var / control |
  |---|---|---|
  | Workflow tool | 16 concurrent, 1,000 total per run | `/config` size guideline |
  | Subagent concurrency | 20 | `CLAUDE_CODE_MAX_CONCURRENT_SUBAGENTS` |
  | Subagent nesting depth | 3 (default; was 5) | `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH` |

- [ ] Add one line stating **there is no total-lifetime subagent cap**, and that the widely repeated "the
      200-subagent cap was removed" claim is false — there was never a 200 cap. Put this in the CHANGELOG
      notes too (Task 9.1) so it does not resurface in Wave 8.
- [ ] **Design the doctrine for 3 layers; do not restore 5.** The kit's real topology is
      main → orchestrator (Gru/Dave/Bob) → worker. Three is enough. State that explicitly so a future wave
      does not "fix" it back upward if the platform default moves again.

**Evidence:**
```bash
grep -c "Workflow tool only" templates/.claude/rules/loop.md            # expect 1
grep -c "CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH" templates/.claude/rules/loop.md   # expect 1
grep -rn "200" templates/.claude/rules/ | grep -i subagent               # expect only the debunk line
bash scripts/verify-sources.sh                                           # CITATIONS OK
```
**Commit:** `Wave 7: separate the three limit systems; correct nesting depth 5 -> 3; debunk the 200 cap`

---

### Task 3.2 — The isolation-mechanism decision table (items 4, 7, 18)
**Model:** main session. **Agent:** none — this is the wave's central judgment call.
**Location decision:** `templates/.claude/rules/tool-discipline.md`, replacing the existing
"When to Use Subagents vs. Main Session" table (lines 24-33), which this **supersedes** rather than sits
beside. Two overlapping tables would be worse than one stale one.

- [ ] Replace that section with **"Choosing an isolation mechanism"**:

  | Mechanism | Context it gets | Reach for it when | Cost note |
  |---|---|---|---|
  | Stay in main session | everything | interactive, small, needs live feedback | free |
  | **Fork** (`/subtask`; default in interactive sessions) | full conversation, system prompt, tools, model; **shares the prompt cache** | you need a side quest that must *keep* everything you have established, and you want it cheap | cheapest branch — cache is shared |
  | **Fresh subagent** (`Agent`) | fresh, isolated | you need genuine independence — maker≠checker, or context you want kept *out* | full cold-start tax per child; **state child count first** |
  | **Cross-session message** (`mcp__ccd_session_mgmt__send_message`, `list_sessions`, `@`-mention) | none — a deliberately thin text payload | the other work has its own long-lived session, its own repo, or its own machine state | thin payload is the point |
  | **Workflow tool** | per-agent, orchestrated | >4 children, or the fan-out should be re-runnable and visible in `/workflows` | real caps + budget visibility |

- [ ] Add the **fork-vs-fresh-subagent rule** in one line: *fork when you need the context, fresh subagent when
      you need the independence.* Note explicitly that a fork is **not** a valid maker≠checker checker — it
      inherits the maker's context and therefore inherits the maker's blind spots. This is the single most
      important consequence of fork being on by default, and it protects the kit's core discipline.
- [ ] Add the **MAST inter-agent-misalignment note (item 18)**: cross-session messages carry a thin text
      payload by design, and that thinness is itself the mitigation — MAST's largest hard-to-debug failure
      category is inter-agent misalignment (context collapse, format mismatch when passing messages). Say
      the quiet part: *a thin, explicit payload is safer than a rich, implicit one.* Cite per Task 1.4's
      outcome (qualitatively if the percentages did not verify).
- [ ] Update `tool-discipline.md`'s "Tool Priority Order" item 7 — "Subagents — batch processing, parallel
      research, context offload" — to carry the cost caveat, so the priority list and the new table agree.

**Evidence:**
```bash
grep -c "Choosing an isolation mechanism" templates/.claude/rules/tool-discipline.md   # expect 1
grep -c "When to Use Subagents vs" templates/.claude/rules/tool-discipline.md          # expect 0 (superseded)
grep -c "inherits the maker's blind spots" templates/.claude/rules/tool-discipline.md  # expect 1
wc -l templates/.claude/rules/tool-discipline.md    # expect <= 165 (was 153; net +12 after the replacement)
```
**Commit:** `Wave 7: one isolation-mechanism decision table (fork / subagent / cross-session / workflow)`

---

## Phase 4 — Native tool replacements (items 5, 6)

> Both are **replacements**, not additions. They pay part of the prune tax `kit-maintenance.md` demands.

### Task 4.1 — `Monitor` replaces hand-rolled polling; import "silence is not success"
**Model:** main session. **Agent:** none.

- [ ] `templates/.claude/rules/loop.md`, rule 6 ("Detect a stuck loop") — replace the implied hand-rolled
      polling with the `Monitor` tool for event-driven watching of logs, processes, and WebSockets.
- [ ] Import the discipline that matters more than the tool: **a filter that matches only the happy path
      stays quiet through a crashloop — silence is not success.** Every monitor needs a failure pattern, not
      just a success pattern, and an explicit timeout that is itself a failure.
- [ ] Cross-reference: this is the same principle as `verification.md`'s evidence-over-assertion. A quiet
      monitor is an assertion, not evidence. One line linking them.

**Evidence:**
```bash
grep -c "silence is not success" templates/.claude/rules/loop.md   # expect 1
grep -c "Monitor" templates/.claude/rules/loop.md                  # expect >= 1
```
**Commit:** `Wave 7: loop rule uses Monitor for stuck-loop detection; silence is not success`

---

### Task 4.2 — `EnterWorktree`/`ExitWorktree` replace manual `git worktree` (corrected targets)
**Model:** **Jerry (sonnet)** — mechanical, three files, prose-consistency work is exactly his job.
**Targets are `skills/patterns-guide/SKILL.md`, `docs/Coolest Thing Since Chrystal Ball.md`, and
`templates/.claude/workflows/README.md` — NOT `ROLLBACK.md` / `BACKUP.md`, which never mentioned worktrees.**

- [ ] `skills/patterns-guide/SKILL.md:39-46` — replace the manual `git worktree add ...` block with
      `EnterWorktree` / `ExitWorktree`. **Keep the existing caveat verbatim** — *"worktrees prevent merge
      conflicts but not logical conflicts"* — it is the load-bearing sentence and the tool change does not
      affect it.
- [ ] `docs/Coolest Thing Since Chrystal Ball.md:476-478` — same replacement.
- [ ] `templates/.claude/workflows/README.md:21` — "scope them to a worktree" now names the built-in tool.
- [ ] Note that the `Agent` tool's `isolation: "worktree"` mode already does this for subagents; the built-in
      tools are for the main session. One line so the two are not confused.

**Evidence:**
```bash
grep -rn "git worktree add" skills/ docs/ templates/ | wc -l   # expect 0
grep -rc "EnterWorktree" skills/patterns-guide/SKILL.md        # expect >= 1
grep -c "logical conflicts" skills/patterns-guide/SKILL.md     # expect 1 (caveat preserved)
```
**Commit:** `Wave 7: built-in EnterWorktree/ExitWorktree replace manual git worktree instructions`

---

## Phase 5 — Evidence and evals gaps (items 19, 15)

### Task 5.1 — Judge calibration in `verification.md` (item 19)
**Model:** main session. **Agent:** none.

- [ ] `templates/.claude/rules/verification.md`, immediately after the LLM-as-judge tier — add **one
      paragraph** (target 5-7 lines): the taxonomy correctly ranks LLM-judge weakest, but when you are stuck
      with one, **calibrate it against human labels before trusting it.** Label a sample yourself, measure
      agreement with the judge, and treat the judge's output as usable only on the slices where it agrees;
      re-calibrate when the task shifts. Cite Hamel Husain's `validate-evaluator` skill
      (hamel.dev/blog/posts/evals-skills/, March 2026, with Shreya Shankar) as the source of the method.
- [ ] **Explicitly do NOT adopt the 8-skill package.** Add a one-line note in `docs/optional-integrations.md`
      recording the decision and the reason: the package targets LLM *product* pipelines (RAG, generative
      output); this user's ML work is classical supervised learning with real ground truth, so a calibrated
      judge is a niche fallback, not the main event. **Record the skip, so a future wave does not re-litigate it.**
- [ ] Frame it as filling a hole in an existing lineage — `evals.md` already distils Husain, `measurement.md`
      already cites "Hamel's rule" — not importing a framework.

**Evidence:**
```bash
grep -c "calibrat" templates/.claude/rules/verification.md         # expect >= 1
wc -l templates/.claude/rules/verification.md                      # expect <= 42 (was 34)
grep -c "evals-skills" docs/optional-integrations.md               # expect 1
bash scripts/verify-sources.sh                                     # CITATIONS OK
```
**Commit:** `Wave 7: judge-calibration doctrine in verification.md (Husain); record the 8-skill-package skip`

---

### Task 5.2 — Fold verified MAST findings into the failure-modes skill (item 15)
**Model:** main session. **Agent:** none. **Blocked on Task 1.4's verdict.**

**Placement decision:** `skills/failure-modes/SKILL.md`, not a rule. Reason: MAST is a *catalog of failure
modes with detection signals* — that is precisely what this skill already is, and the skill is invoked
on demand rather than loaded every turn, so a research citation costs nothing until it is needed. Adding
it to an always-loaded rule would spend budget on background material.

- [ ] Add a section **"Independent corroboration (MAST)"** to `skills/failure-modes/SKILL.md` mapping the
      paper's measured modes onto the kit's existing catalog rows:
      Step Repetition → Loop drift / stuck-loop detection; Unaware of Termination Conditions → "write the
      exit condition first"; Disobey Task Specification → evidence-over-assertion / premature done; Loss of
      Conversation History → INVARIANTS + HANDOFF.
- [ ] Quote percentages **only for the items Task 1.4 confirmed.** For anything unverified, state the mapping
      without a number.
- [ ] Add the paper's conclusion — that prompt/orchestration tweaks alone do not fix these failures — as
      independent support for `verification.md`'s *"Rules are advisory; hooks are enforced."* This is the most
      valuable line in the whole item: it is external evidence for a structural choice the kit already made.
      Use the verbatim wording captured in Task 1.4.
- [ ] Add the `SOURCES.md#mast` pointer.

**Evidence:**
```bash
grep -c "MAST" skills/failure-modes/SKILL.md                 # expect >= 1
grep -c "2503.13657" SOURCES.md                              # expect 1
bash scripts/verify-sources.sh; echo "exit=$?"               # CITATIONS OK, exit=0
```
**Commit:** `Wave 7: MAST corroboration mapped onto the failure-modes catalog (verified claims only)`

---

## Phase 6 — Hooks

### Task 6.1 — SessionStart exit-condition warning (item 16)
**Model:** main session writes it; **Phil (sonnet)** tests it. Cheap, precise, targets a real gap.

- [ ] Extend `hooks/session-context.sh`: in the existing `if [ -n "$PLAN_FILE" ]` block, after printing the
      plan head, grep the **whole** plan file (not just the head) for `Done when|Exit condition|exit condition`.
      If absent, print a visible warning: `⚠ ACTIVE PLAN HAS NO "Done when" / EXIT CONDITION — write one before executing.`
- [ ] Mirror the change in `hooks/session-context.ps1` — the two must not drift. This is a recurring hazard
      with a Bash/PowerShell pair; make parity part of the verification, not an afterthought.
- [ ] Phil tests all three states in a scratch dir: plan with "Done when" → no warning; plan without → warning;
      no plan file → no warning and no error.

**Why this one is worth it:** it targets MAST's measured termination-condition failure mode with a grep, and
it enforces a `loop.md` rule that currently nothing checks. Rules are advisory; hooks are enforced.

**Evidence:**
```bash
mkdir -p /tmp/w7/.claude/plans && cd /tmp/w7
printf '# Test plan\nsome text\n' > .claude/plans/a.md
bash ~/.claude/hooks/session-context.sh | grep -c "NO \"Done when\""      # expect 1
printf '# Test plan\n## Done when\nall green\n' > .claude/plans/a.md
bash ~/.claude/hooks/session-context.sh | grep -c "NO \"Done when\""      # expect 0
cd - && rm -rf /tmp/w7
bash scripts/verify-hooks.sh                                              # HOOK PARITY OK
```
**Commit:** `Wave 7: SessionStart warns when the active plan has no exit condition (sh + ps1 parity)`

---

### Task 6.2 — Fan-out reminder hook (item 17) — DOWNSCOPED, CONDITIONAL, AND OPTIONAL

> **I disagree with this item as specified, and I recommend not building the `UserPromptSubmit` version.**
>
> Three reasons:
> 1. **The trigger is wrong.** Keywords `spawn`, `parallel`, `agents`, `fan out` fire on *talking about*
>    fan-out, not *doing* it. In this repo specifically — a kit whose entire subject matter is agents — the
>    hook would fire on a large share of every session's prompts. That is the definition of wallpaper, and
>    the brief already anticipates this risk.
> 2. **It is redundant with a rule that is already always-loaded.** Task 2.1 puts the fix in
>    `~/.claude/rules/loop-cost-discipline.md`, which loads on every turn of every project. Injecting the
>    same text again via a keyword hook adds noise, not enforcement.
> 3. **There is no evidence the existing `plan-router.sh` earns its keep.** Adding a second
>    `UserPromptSubmit` injector before measuring the first compounds an unmeasured bet.
>
> **Better trigger, if you want a hook at all:** `PreToolUse` matched on the `Agent` tool. It fires exactly
> when a dispatch actually happens — never when someone merely says "agents" — and it can *block* (exit 2)
> rather than merely remind. That is a real enforcement point instead of a reminder.

**Build only if the user opts in, and only after verification:**

- [ ] **Verify feasibility first (mandatory, same pattern as Wave 6's Gap B):** fetch the hooks docs and
      confirm (a) `PreToolUse` matchers accept the `Agent` tool name, and (b) the payload exposes enough of
      the dispatch to be useful. **If the payload cannot see the dispatch, this is not buildable as designed
      — stop, record the limitation, ship nothing.** Do not guess the payload shape.
- [ ] If feasible: `hooks/guard-fanout.sh` — non-blocking on the first dispatch of a session (prints the
      estimate-before-dispatch reminder), and escalating only if a session exceeds 4 `Agent` dispatches, at
      which point it prints the "route this through the Workflow tool" message. Use the existing
      `subagent-audit.sh` log as the counter — it already records dispatches, so no new state file.
- [ ] **Wire the evaluation in before shipping it**, per the brief's own concern: add `guard-fanout` as a tag
      in `.claude/session-metrics.md` and commit to a keep/cut decision at the next monthly review under
      `measurement.md`. A hook with no evaluation path is exactly the kind of accretion `kit-maintenance.md`
      exists to prevent.
- [ ] If the user declines: record the decision and the reasoning in the CHANGELOG's Notes so Wave 8 does not
      re-propose it blind.

**Evidence (if built):** dispatch counter test — 1st dispatch prints the reminder; 5th prints the escalation;
`bash scripts/verify-hooks.sh` → `HOOK PARITY OK`.
**Commit:** `Wave 7: PreToolUse(Agent) fan-out budget reminder (opt-in)` — or the decision note.

---

## Phase 7 — README reframing (user requirement A)

### Task 7.1 — Reframe the premise
**Model:** main session drafts the wording (it is voice, and it is the user's voice); **Jerry (sonnet)**
sweeps the rest of the file for the same stale premise.

Proposed replacements — **these are drafts for the user to approve or overwrite; the voice is his, not mine:**

- [ ] **Line 5** — currently *"Built from a real production Claude Code project (June 2026)."*
      → **"How I actually use Claude Code, as of August 2026. Built from a real production project and
      revised whenever the platform moves under it."**
      *Why:* keeps the credibility of "real project," adds the dated-snapshot honesty, and sets the
      expectation that the kit is maintained rather than finished.

- [ ] **Line 11** — currently *"Claude Code sessions forget context between sessions. Plans die. Next session
      starts blank."*
      → **"Context does not carry itself. Claude Code now has real continuity primitives — sessions can even
      message each other — but none of them decide what is worth carrying, or prove that last session's work
      actually held. This kit is the discipline layer: what gets written down, what gets re-verified, and what
      gets pruned."**
      *Why:* this is the honest version. The platform closed the mechanical gap; the judgment gap is the part
      that was always the real content, and it is the part that does not expire.

- [ ] **Heading at line 9** — "The Core Problem This Solves" → **"What This Is"**. The section is no longer
      claiming a platform defect, so the heading should stop promising one.
- [ ] **Line 13** — currently *"**This kit fixes that** by structuring…"* → drop "fixes that"; state what it
      does: structures CLAUDE.md, META_ARCHITECTURE.md, INVARIANTS.md and `.claude/rules/` so the decisions
      worth keeping are the ones that load automatically.

### Task 7.2 — Sweep the rest of the README for the same premise
**Model:** Jerry (sonnet). Mechanical consistency sweep with a named list of targets.

- [ ] **Line 158 section, "How Context Carries Forward Between Sessions"** — the mechanics described here are
      still accurate (hook, path-scoped rules, INVARIANTS-in-full), so **do not rewrite it.** Add one sentence
      noting cross-session messaging as a *sibling* mechanism for live session-to-session handoff, distinct
      from the file-based continuity this section describes. Keeping these separate is the point — one is
      durable state, the other is a live message.
- [ ] Line 21 and line 103: "keep under 200 lines" → **90**, matching `kit-maintenance.md` (see Task 8.1).
- [ ] **Line 65: fix the broken link** — `Coolest Thing Since Crystal Ball.md` → `Coolest Thing Since Chrystal Ball.md`
      (or rename the file and fix the reference; renaming is cleaner but touches git history for a 759-line
      doc — **recommend just fixing the README reference**).
- [ ] Add the new files to the Contents tree: `SOURCES.md`, `INVARIANTS.md`, `global-rules/`, `scripts/`,
      and any new hook.
- [ ] Update the rules list in the Contents block if any rule was renamed by the prune pass.

**Evidence:**
```bash
grep -c "sessions forget context" README.md          # expect 0
grep -c "as of August 2026" README.md                # expect 1
grep -c "Chrystal" README.md                         # expect 1 (link now matches the file on disk)
grep -c "200 lines" README.md                        # expect 0
for f in $(grep -oE '\(docs/[^)]+\)' README.md | tr -d '()'); do test -f "$f" || echo "BROKEN: $f"; done   # expect no output
```
**Commit:** `Wave 7: README reframed as a dated snapshot of practice; fix stale premise, budgets, broken link`

---

## Phase 8 — The prune pass (user requirement D)

> `kit-maintenance.md`: the kit must not only grow. Apply its own test to each candidate —
> **"would removing this cause Claude to make a mistake?"** These candidates were found by reading the
> current files, not guessed.

### Task 8.1 — Execute the prune
**Model:** main session (each call is a judgment). **Agent:** none.

| Candidate | Evidence | Test result | Action |
|---|---|---|---|
| `session-workflow.md` "Context Management" (≈lines 95-101) duplicates `tool-discipline.md` "Context Budget Awareness" (lines 47-58) — near-verbatim | both read in full | Removing **one** causes no mistake; keeping both invites drift | **CUT from `session-workflow.md`;** replace with a one-line pointer to `tool-discipline.md` |
| `tool-discipline.md` "When to Use Subagents vs. Main Session" table | superseded by Task 3.2 | Removing causes no mistake — the replacement is strictly more complete | **REPLACED** (already counted in Task 3.2) |
| `loop.md` hand-rolled polling language in rule 6 | superseded by `Monitor` | Removing causes no mistake | **REPLACED** (Task 4.1) |
| Manual `git worktree` blocks (3 files) | superseded by built-in tools | Removing causes no mistake | **REPLACED** (Task 4.2) |
| "5 levels deep" in Bob and Dave | factually wrong | Keeping causes a mistake | **CUT** (Task 2.2) |
| Three conflicting CLAUDE.md line budgets (200 / 80 / ~90) | README:21, README:103, `templates/CLAUDE.md` footer, `kit-maintenance.md` | Conflicting numbers cause a mistake | **RECONCILE to ~90 everywhere** |
| `automation.md`'s Python scheduling + state-file code blocks (122 lines) | file is `paths:`-scoped | It costs **zero tokens** unless a matching file is touched, and the blocks are load-bearing when it does load | **KEEP** — the honest answer. Do not prune for the sake of a number. |
| `docs/Coolest Thing Since Chrystal Ball.md` (759 lines) | not auto-loaded; on-demand reference | Removing would lose real content | **KEEP** |

- [ ] Execute the CUT and RECONCILE rows. The REPLACED rows land with their own tasks.
- [ ] Record the **net line delta** for the wave. Target: net additions to always-loaded files ≤ +30 lines
      across `global-rules/` + `templates/.claude/rules/`. If the wave exceeds that, cut more before shipping —
      **this is a hard gate, not a guideline.**

**Evidence:**
```bash
grep -c "## Context Management" templates/.claude/rules/session-workflow.md    # expect 0
grep -rn "200 lines" README.md templates/CLAUDE.md | wc -l                     # expect 0
wc -l templates/.claude/rules/*.md global-rules/*.md   # compare to Task 1.1 baseline; net <= +30
```
**Commit:** `Wave 7: prune pass — cut duplicated context guidance, reconcile CLAUDE.md line budgets`

---

## Phase 9 — Close out

### Task 9.1 — Version, changelog, docs sync
**Model:** **Jerry (sonnet)** — this is exactly his job (reflect reality, never invent).

- [ ] `VERSION` → `1.4.0`.
- [ ] Prepend a `## [1.4.0] — 2026-08-19 (Wave 7 — Doctrine Refresh)` entry with Added / Changed / Fixed /
      Notes. The **Notes** block must carry, explicitly:
      - the sourcing statement (every claim traced to a dated primary source in `SOURCES.md`);
      - the MAST verification outcome from Task 1.4, including anything that stayed unverified;
      - **the 200-subagent-cap debunk**, so it does not resurface;
      - the deferred items (8, 9, 10) and why;
      - the Task 6.2 decision (built / declined) and the reason.
- [ ] Update `META_ARCHITECTURE.md` if the project keeps one for the kit itself; if not, say so rather than
      inventing one.
- [ ] Optionally correct the Wave 5 changelog date if 2026-07-13 is right (see repo finding 7) — one edit, or
      leave it and note the discrepancy. Do not half-fix it.

**Evidence:** `cat VERSION` → `1.4.0`; `head -30 CHANGELOG.md` shows all five Notes bullets.
**Commit:** `Wave 7: bump to 1.4.0, changelog, docs sync`

---

### Task 9.2 — Feynman gate (before HANDOFF)
**Model:** main session. **Human-in-the-loop.**

- [ ] Invoke `/feynman-explainer` on two things and explain them to the user without jargon:
      1. **The three limit systems** — if this cannot be explained in three plain sentences, Task 3.1's table
         is not clear enough and goes back for another pass.
      2. **Fork vs. fresh subagent vs. cross-session message** — the test is whether the user can pick the
         right one for a new scenario the plan never mentioned.
- [ ] If either explanation needs the doc open to make sense, the doc is wrong. Revise, then re-gate.
      **Exit condition: two clean explanations with the files closed. Cap: 2 revision passes**, then escalate
      the unclear section to the user rather than looping.

---

### Task 9.3 — Independent review (maker ≠ checker)
**Model:** **Bob (opus), one dispatch, zero children.**

- [ ] Dispatch `bob-verifier` with: `git diff v1.3.1..HEAD`, this plan file, and `INVARIANTS.md`.
      Criteria: *"Verify Wave 7 delivered each task as planned; check that every numeric claim added has a
      SOURCES.md entry; check sh/ps1 hook parity; report only correctness and requirement gaps."*
- [ ] **Explicit dispatch constraint in the prompt: no child agents.** Bob's own prompt now carries a
      default-zero-children rule (Task 2.2) — this dispatch is the first live test of it, so state it and
      then check whether he honoured it. If he spawns children anyway, Task 2.2's wording failed and needs
      another pass. *That is a real test of this wave's central fix, not ceremony.*
- [ ] Address anything real Bob finds. Ignore style nitpicks per his own discipline section.

**Evidence:** paste Bob's verdict (`✅ Verified` / `❌ Gaps`) plus the `subagent-audit.sh` log line count for
this dispatch (expect 1 — Bob only, no children).

---

### Task 9.4 — Re-verify invariants, install, merge
**Model:** main session.

- [ ] Re-verify all four invariants with pasted evidence; flip each to `✅ holds`:
```bash
./install.sh --dry-run >/dev/null && git status --porcelain | wc -l   # INV-01 -> 0
bash scripts/verify-hooks.sh                                          # INV-02 -> HOOK PARITY OK
pre-commit run --all-files                                            # INV-03 -> pass
bash scripts/verify-sources.sh                                        # INV-04 -> CITATIONS OK
```
- [ ] Full install test into a throwaway HOME:
```bash
HOME=/tmp/w7-install bash install.sh >/dev/null
ls /tmp/w7-install/.claude/agents/*.md | wc -l    # expect 9
ls /tmp/w7-install/.claude/rules/*.md | wc -l     # expect 2  <-- NEW in this wave
ls /tmp/w7-install/.claude/hooks/ | wc -l         # expect 11 (or 12 if Task 6.2 shipped)
ls /tmp/w7-install/.claude/skills/ | wc -l        # expect 8
rm -rf /tmp/w7-install
```
- [ ] Secret guard still blocks a planted test key (regression check on `guard-secrets.sh`).
- [ ] Write `.claude/HANDOFF.md`; append one row to `~/.claude/session-metrics.md` tagged
      `loop-cost-discipline`, `planning`, `verification`.
- [ ] Merge to master `--no-ff`, tag `v1.4.0`, push master + tag. **Never push to master directly** — the
      merge is the gate.
- [ ] Run `install.ps1` to make it live on this machine. **This wave is not done until the global rule is
      installed** — the whole point of Task 2.1 is that it fires everywhere.

---

## Done when

All of the following are true and evidenced:

1. `cat VERSION` → `1.4.0`; tag `v1.4.0` exists and is pushed.
2. `grep -rn "5 levels deep" .` returns **zero** hits outside `docs/superpowers/plans/` (historical plans stay as written).
3. `global-rules/loop-cost-discipline.md` contains the estimate-before-dispatch section, **and** a fresh
   install writes it to `~/.claude/rules/` — verified in a throwaway HOME.
4. `templates/.claude/agents/dave-researcher.md` requires a stated child count before any dispatch and caps
   ad hoc fan-out at 3-4.
5. `templates/.claude/rules/tool-discipline.md` contains exactly one isolation-mechanism table, including the
   line that a fork is not a valid maker≠checker checker.
6. `bash scripts/verify-sources.sh` exits 0 — every numeric limit claim in shipped doctrine has a dated
   `SOURCES.md` entry.
7. `bash scripts/verify-hooks.sh` exits 0 — hook parity holds, `.sh` and `.ps1` in sync.
8. SessionStart warns on a plan file with no exit condition; no warning when one exists (both states tested).
9. `README.md` contains no "sessions forget context" premise, no "200 lines" budget, and no broken `docs/` link.
10. Net line growth across always-loaded files (`global-rules/` + `templates/.claude/rules/`) is **≤ +30**
    against the Task 1.1 baseline.
11. All four invariants read `✅ holds` with pasted evidence.
12. Bob returned `✅ Verified` **with zero child agents in the audit log.**
13. `install.ps1` has been run; `~/.claude/rules/loop-cost-discipline.md` contains the new section.

Any red item blocks the merge.

---

## What defers, and why

| Item | Verdict | Reason |
|---|---|---|
| **#8 automation-surface taxonomy** (CronCreate / Routines / Workflow / Desktop Scheduled Tasks) | **Wave 8** | This is the largest single piece of new writing in the brief — four surfaces with different durability, quota tiers, and trigger models, **plus** a rule-placement restructure, because `automation.md`'s `paths:` scoping means it will not load when the user is *choosing* a surface. Placement is the hard part and it is genuinely unsolved: the decision content probably belongs in an unconditionally-loaded file while the implementation content stays path-scoped, which means splitting the rule. That is a design decision, not an edit, and it deserves its own wave rather than being rushed in behind eleven other items. |
| **#9 fourth autonomy rung for off-machine Routines** | **Wave 8, with #8** | Strictly downstream of #8's taxonomy — you cannot write the rung until the surfaces are named. Doing it now means writing it twice. |
| **#10 discover-on-demand vs. curated roster** | **Blocked — needs `/the-fool` with the user** | This is a genuine philosophical fork, not a doc update. `ListSkills`/`SearchSkills` bet on discovery; `tool-discipline.md`'s roster-bloat rule bets on curation; `kit-maintenance.md`'s skill-overlap audit is built entirely on the curation premise. Picking one silently would quietly invalidate an existing rule. **Per Phase C of the planning rule, I will not draft on unproven footing** — run `/the-fool` on it with the user and plan the outcome afterward. Worth noting: the user's `~/.claude/skills/` already holds **90+ skills**, mostly the `gsd-*` family, which is empirical evidence the curated-roster rule is already not being followed at the global layer. That fact should be on the table when the decision is made. |
| **#17 as specified** | **Downscoped to conditional Task 6.2** | See the argument in Task 6.2. Wrong trigger, redundant with an always-loaded rule, and unmeasured. |

---

## Applicability pass (nothing silently skipped)

### Thinking skills
| Capability | Applies? | Reason |
|---|---|---|
| `thinking-partner` | **Not in Wave 7** | The problem space is explored — findings are verified and primary-sourced. Required *before* Wave 8 can plan item #10. |
| `the-fool` | **Yes — deferred item #10** | Discover-on-demand vs. curated roster is exactly a major design decision. **Human-in-the-loop, not role-played.** Blocks #10 from entering any wave. |
| `socratic-examiner` | **Yes — optional, on this plan** | If the user wants the plan stress-tested before approving. Human-in-the-loop. |
| `assumption-archaeologist` | **Yes — on Task 7.1** | The README reframe is literally an assumption-excavation job: "what did we assume was permanently broken that isn't?" Run with the user if the proposed wording does not land. |
| `patterns-guide` | **Yes — passively** | It is an *edit target* (Task 4.2), not a process step. |
| `feynman-explainer` | **Yes — Task 9.2** | Mandatory gate before HANDOFF. Two named subjects, 2-pass cap. |
| `failure-modes` | **Yes — Task 5.2 target** | Receives the MAST corroboration. Also the escape hatch if Phase 3 starts spinning. |

### Domain skills
| Capability | Applies? | Reason |
|---|---|---|
| `labarr-ml` | **No** | No modeling, forecasting, or analytics in this wave. Markdown, shell, and judgment. |
| `sql-pro` | **No** | No SQL anywhere in the kit. |
| `pandas-pro` | **No** | No dataframes. |
| `debugging-wizard` | **Conditional** | Only if Task 6.1's hook or Task 1.2's verifier scripts misbehave in a non-obvious way. Do not pre-invoke. |
| `claude-api` | **No** | No API integration — this wave is about Claude Code's own surfaces, which is a different subject. |
| `stop-slop` | **Yes — light** | Its density test is the right check on every paragraph added in Phases 2-5. The kit's own rule already cites it. |
| `session-workflow` | **Yes** | Governs the whole session; also an edit target in Task 8.1. |

### Agents (routing recommendations — text, not dispatches)
| Agent | Applies? | Where, and at what model |
|---|---|---|
| **Bob** (opus) | **Yes — Task 9.3** | Final independent review. **One dispatch, zero children** — and honouring that is itself a test of Task 2.2. |
| **Phil** (sonnet) | **Yes — Tasks 1.2, 6.1** | Writes and runs the two verifier scripts and the hook tests. TDD: plant a failure, confirm exit 1, then confirm exit 0. Sonnet is adequate — these are small deterministic scripts. |
| **Jerry** (sonnet) | **Yes — Tasks 4.2, 7.2, 9.1** | Mechanical consistency sweeps and doc sync with a named target list. Cheapest adequate model; the judgment (what the README *should say*) stays in the main session. |
| **Stuart** (haiku) | **Optional — at most one dispatch** | A "find every occurrence of X" sweep before Phase 8 if the prune list needs widening. Everything currently in the plan was already found by direct grep, so **probably not needed.** Do not dispatch on spec. |
| **Dave** (opus) | **NO — deliberately not used** | Task 1.4 is one PDF from one known URL. Dispatching the research agent for it would repeat the exact failure this wave exists to fix, and his prompt is mid-repair. **Main session, one `WebFetch`.** This is the plan practising what it preaches. |
| **Kevin** (opus) | **No** | No auth, no data handling, no dependency changes, nothing client-facing. `pre-commit`/gitleaks (INV-03) covers the only security surface this wave touches. |
| **Mel** (opus) | **No** | No UI. |
| **Carl** (opus) | **No** | No batch of model/ML outputs to grade. `evals.md` is an *edit target* (Task 2.3), which is not the same as needing the judge. |
| **Gru** | **In use** | This plan. Hands to Bob per the rubric. |

### Rules (as constraints on this wave)
| Rule | Applies? | Constraint imposed |
|---|---|---|
| `planning.md` | **Yes** | The rubric this plan is graded against; Phase E below. |
| `invariants.md` | **Yes** | Forces Task 1.2 (the kit has no INVARIANTS.md) and the Phase 9 re-verify. |
| `verification.md` | **Yes** | Every phase carries command + expected output. Also an edit target (Task 5.1). |
| `evals.md` | **Yes** | Supplies the regression-case mechanism for Task 2.3 — reused, not reinvented. |
| `loop.md` | **Yes** | Edit target (Tasks 3.1, 4.1). The Feynman gate's 2-pass cap is its exit-condition-first rule applied to this plan. |
| `tool-discipline.md` | **Yes** | Primary edit target (Task 3.2) and the source of the model-routing calls above. |
| `measurement.md` | **Yes** | Task 9.4's metrics row; Task 6.2's evaluation commitment. |
| `session-workflow.md` | **Yes** | Session protocol + prune target (Task 8.1). |
| `kit-maintenance.md` (global) | **Yes — hard gate** | Line budgets and the ≤ +30 net-growth ceiling in Task 8.1. |
| `loop-cost-discipline.md` (global) | **Yes — primary target** | Task 2.1. Also governs this wave's own agent spend: ≤4 dispatches total (Phil ×2, Jerry ×3 batched, Bob ×1). |
| `ml-discipline.md` | **No** | Path-scoped, no ML files touched. |
| `automation.md` | **No this wave** | Path-scoped; its restructure is deferred item #8. |

### Hooks
| Hook | Applies? | Reason |
|---|---|---|
| `session-context.sh` / `.ps1` | **Yes — edit target** | Task 6.1. Parity between the two is verified, not assumed. |
| `plan-router.sh` | **Yes — indirectly** | Task 6.2 argues against adding a sibling before this one is measured. |
| `guard-secrets.sh` | **Yes — passively** | INV-03 regression check in Task 9.4. |
| `guard-verdict.sh` | **Yes — passively** | Fires on Bob in Task 9.3; his `✅ Verified` marker must appear or the hook blocks. |
| `subagent-audit.sh` | **Yes — as evidence** | Its log is how Task 9.3 proves Bob spawned zero children, and the counter Task 6.2 would reuse. |
| `guard-readonly-bash.sh` | **No** | No read-only reviewer runs Bash mutations here. |
| `post-edit-format.sh` | **Yes — passively** | Fires on every markdown edit; no-op-safe. |
| `stop-verify.sh` | **No** | Opt-in; not enabled on this repo. |
| `log-instructions-loaded.sh` | **Optional evidence** | Its log can independently confirm the new global rule loads after Task 9.4's install. Cheap corroboration. |
| **New: fan-out guard** | **Conditional** | Task 6.2, opt-in only, verify-first. |

---

## Self-audit against `.claude/rules/planning.md`

| Rubric item | Status | Evidence |
|---|---|---|
| Triage done | **PASS** | Phase 0 table; decomposed into 6 sub-projects, 3 deferred with reasons. |
| Context read | **PASS** | All 10 template rules, 9 agent files, hooks, installers, README, CHANGELOG, Wave 5/6 plans, global rules, live `~/.claude/`. Produced 7 findings that changed the brief. |
| Explore-first if unexamined | **PASS** | Item #10 explicitly blocked pending `/the-fool` with the user rather than drafted on. |
| Applicability decisions, nothing skipped | **PASS** | Four tables covering every thinking skill, domain skill, agent, rule, and hook — each with a reason, including every "No." |
| Skills as named checkpoints | **PASS** | `/feynman-explainer` (9.2), `/the-fool` (deferred #10), `assumption-archaeologist` (7.1), `stop-slop` (Phases 2-5), `socratic-examiner` (optional on this plan). |
| Dialogic skills human-in-the-loop | **PASS** | All four marked "with the user"; none role-played. Task 7.1's wording is explicitly the user's call. |
| Agent routing per risky phase | **PASS** | Bob 9.3, Phil 1.2/6.1, Jerry 4.2/7.2/9.1; Dave/Kevin/Mel/Carl each excluded with a reason. Dave's exclusion is itself a substantive call. |
| Invariants captured + re-verified | **PASS** | Four seeded in Task 1.2, re-verified in Task 9.4 with commands. INV-04 makes requirement B machine-checkable. |
| Evidence-based verification per phase | **PASS** | Every task carries a runnable command block with expected output. No "done" claims. |
| Git discipline | **PASS** | Feature branch, commit per task, `--no-ff` merge, tag, never push to master. |
| TDD | **PASS** | Task 1.2 plants a failure and confirms exit 1 before confirming exit 0; Task 6.1 tests all three hook states before shipping. |
| Explicit "Done when" | **PASS** | 13 checkable criteria, each a command or a boolean. |
| Dependency ordering | **PASS** | 1.3 (global-rules install) precedes 2.1 (writes into it). 1.4 (MAST gate) precedes 5.2 (quotes it). 1.5 (SOURCES.md) precedes 3.1 (cites it). 3.2 supersedes a section, so it follows 3.1's corrections. 8.1 counts deltas from 1.1's baseline. No task depends on a later one. |
| Loops have exit conditions written first | **PASS** | Feynman gate: 2 clean explanations, cap 2 passes. Task 1.2's script tuning: exits when planted failure is caught and real corpus passes. |
| Feynman gate before HANDOFF | **PASS** | Task 9.2, before 9.4's HANDOFF. |
| No placeholders | **PASS** | Every file path, line number, command, and proposed wording is concrete. README replacements are drafted in full, not described. |
| Per-task model delegation | **PASS** | Stated per task; judgment stays in the main session, mechanical work goes to sonnet/haiku, and Dave (opus) is deliberately declined for a task he would nominally own. |
| Goal-backward: does this achieve the stated goal? | **PASS** | Goal = doctrine matches reality + a real brake on uncosted fan-out. Corrections: 3.1, 2.2. Brake: 2.1 (global, always loaded) + 2.2 (the prompt that caused it) + 2.3 (pinned regression) + 9.3 (live test of whether the brake holds). Reproducibility: 1.3 — without which the brake would not survive a reinstall. That last one is the difference between a fix and a note. |
| Proportionate to a doctrine refresh | **PASS** | 8 of 19 items ship, 4 defer with reasons, 1 is argued against. No rewrite. |

**Self-audit verdict: green.** One caveat the user should weigh: this plan is 9 phases for a "refresh," and
Phase 1 is entirely groundwork (invariants, scripts, global-rules tracking, SOURCES.md) that ships no doctrine.
That is defensible — Task 1.3 in particular is load-bearing, since without it the wave's main fix is untracked —
but if the wave needs to be smaller, **Phase 1 + Phase 2 alone are a coherent, shippable v1.3.2** and everything
else can follow. Say the word and I will cut it that way.

---

## Independent check (maker ≠ checker)

My self-audit is not the final word. **Recommend this plan go to `bob-verifier` for a fresh-eyes pass against
`.claude/rules/planning.md`** before any execution — specifically to check the dependency ordering in Phase 1,
whether the Task 6.2 recommendation-against is argued or merely asserted, and whether the "Done when" criteria
are all genuinely machine-checkable. Per the hard constraints on this planning session, that dispatch is a
**recommendation, not something I performed** — the user triggers it.

---

## Dynamic Workflow candidate

**Not this wave.** The one recurring pattern here — "sweep N files for a stale claim, then fix each" (Tasks 4.2,
7.2, 8.1) — is 3-8 files, which is under the threshold where a workflow beats direct edits. Building a workflow
for it would contradict Task 2.1's own rule about cold-start tax.

**Genuinely worth saving later:** the *wave close-out* pattern — re-verify all invariants → install into a
throwaway HOME → count agents/hooks/skills/rules → secret-guard regression → Bob review. That runs identically
at the end of every wave, is currently retyped by hand each time, and is 5-6 deterministic steps plus one agent.
A `.claude/workflows/close-out-wave.js` would pay for itself by Wave 9. **Flagged, not built** — ask for it when
you want it.

---

## Running Notes

_(Executor: append findings after each phase. If the session ended right now, could someone start Phase N+1
from this file alone? That is the test.)_

- **Phase 1:** Baseline: VERSION 1.3.1, 10 hooks (plan said 11), 9 agents, 9 skills, rules 738 lines. Gru's repo findings all confirmed: ROLLBACK/BACKUP never mentioned worktrees; global rules untracked and not installed; Dave's prompt was the proximate cause. `verify-sources.sh` immediately found a file the plan missed — `gru-planner.md:80` also quotes the Workflow caps. **MAST gate corrected two circulating numbers** and gained category FC3 entirely.
- **Phase 2:** Brake landed in three places. `5 levels deep` now returns zero kit-wide. Global rule addition trimmed 19→15 lines after overshooting the ≤14 budget.
- **Phase 3:** INV-04 went green here. Deliberately designed for 3 nesting layers rather than restoring 5.
- **Phase 4:** Both items were replacements, paying part of the prune tax. Worktree caveat preserved verbatim.
- **Phase 5:** MAST placed in the `failure-modes` skill (on-demand), not a rule — a research citation should not cost tokens every turn.
- **Phase 6:** SessionStart check tested across 4 states × 2 shells. **PowerShell hooks use `Write-Host`, which bypasses the pipeline — they cannot be asserted on programmatically.** Verified from visible output instead. `guard-fanout.sh` built after live feasibility check confirmed `PreToolUse` matches `Agent`.
- **Phase 7:** README reframed to a dated snapshot. Also fixed a broken link and three conflicting line budgets.
- **Phase 8:** Found and merged a duplication I had created in Phase 3 (16/1,000 in two loop.md sections). Net +70 → +51. Ceiling breach escalated to the user, who accepted it and chose to raise the ceiling.
- **Phase 9:** **Bob returned 6 gaps with zero children — the Task 2.2 fix works, tested live.** Most serious: my FC1 "correction" (43.8%) contradicted its own itemization (sums to 44.2). Re-verification gave a *third* value (43.9). **The category number is now withheld and the correction retracted** — mode-level figures are stable and kept. Also fixed: `guard-fanout` counter raced and silently undercounted parallel dispatch (the exact incident scenario); the self-reported budget figure omitted the lines the budget rule itself added (+51 → +57); three uncited Workflow numbers; missing measurement path; missing README hook entries.
