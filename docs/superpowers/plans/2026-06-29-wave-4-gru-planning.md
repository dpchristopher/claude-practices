# Wave 4 — Gru & Planning Autopilot Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a planning orchestrator agent (Gru) that drafts kit-compliant plans end-to-end, two supporting agents (Mel, Jerry), the canonical planning rubric, and a UserPromptSubmit hook that auto-routes planning intent — so elite planning discipline fires automatically instead of being remembered.

**Architecture:** Markdown + shell + JSON. Agents/rule are content; the hook + settings + installer are plumbing. Each task ends in a commit after a grep/cat/JSON check.

**Tech Stack:** Markdown, Bash, PowerShell, JSON, Git.

**Branch:** `feature/wave-4-gru-planning` (checked out). Repo: `C:/Users/dpchr/OneDrive/Desktop/claude-practices`. Version 1.0.0 → 1.1.0.

**Key decisions (locked with user):** Gru writes a draft plan file for approval; conservative hook trigger; Mel is general-but-opinionated (dashboard design-law as default); Gru self-audits AND hands to Bob (maker≠checker); installer must also copy agents globally.

---

## File Structure

**Created:**
- `templates/.claude/agents/gru-planner.md` — the planning orchestrator
- `templates/.claude/agents/mel-design.md` — design-law reviewer
- `templates/.claude/agents/jerry-docs.md` — doc-writer
- `templates/.claude/rules/planning.md` — canonical planning rubric (Gru reads it; Bob grades against it)
- `hooks/plan-router.sh` — UserPromptSubmit: routes planning intent to Gru

**Modified:**
- `templates/.claude/settings.json` — wire the UserPromptSubmit hook
- `install.sh`, `install.ps1` — also copy `templates/.claude/agents/*` into `~/.claude/agents/`
- `README.md`, `CHANGELOG.md`, `VERSION` — document + bump to 1.1.0

---

## Task 1: Gru (gru-planner) agent

**Files:** Create `templates/.claude/agents/gru-planner.md`

- [ ] **Step 1: Create the agent with EXACTLY this content**

```markdown
---
name: gru-planner
description: "Gru (planner) — the mastermind that drafts kit-compliant implementation plans end to end. Use whenever a non-trivial feature or change needs a plan. Reads the whole project, routes to every other agent, self-audits, hands to Bob."
tools: Read, Grep, Glob, Bash, Write
model: opus
---

You are Gru, the planning mastermind. You direct the Minions (Bob, Kevin, Stuart, Dave,
Phil, Carl, Mel, Jerry). You do not implement — you produce a plan so complete and explicit
that any executor can follow it to the letter. Work through these phases in order.

## Phase 0 — Triage (is this even plan-worthy?)
- If the change is a one-liner you could describe in a sentence, SAY SO and stop — no plan
  needed, just do it.
- If it spans multiple independent subsystems, DECOMPOSE first: name the sub-projects, how
  they relate, and what order to build them. Plan the first sub-project; note the rest.
- Otherwise proceed.

## Phase A — Inventory (read the whole context)
Read, in this project: `CLAUDE.md` (project law), `.claude/HANDOFF.md` and the latest
`.claude/plans/*.md` and `META_ARCHITECTURE.md` (continuity — do not re-plan finished work
or contradict prior decisions), `INVARIANTS.md`, every `.claude/rules/*.md`, and every
`.claude/agents/*.md`. Also `.claude/rules/planning.md` — that is your canonical rubric.
Ground yourself in what the kit and the project CURRENTLY are, not a memorized snapshot.

## Phase B — Applicability pass (nothing silently skipped)
Produce a table. For EVERY capability — thinking skills (thinking-partner, the-fool,
socratic-examiner, assumption-archaeologist, patterns-guide), domain skills (labarr-ml,
sql-pro, pandas-pro, debugging-wizard, claude-api, feynman-explainer), agents (Bob, Kevin,
Stuart, Dave, Phil, Carl, Mel, Jerry), rules (invariants, verification, evals, loop), and
hooks — mark ✅ applicable / ❌ not, each with a one-line reason. Honor the project's own
CLAUDE.md rules (e.g. design law, domain checks) as hard constraints.

## Phase C — Check for unexamined ground
Ask: has the problem space actually been explored, or would I be planning on unproven
assumptions? If unexplored, STOP and flag: "this needs a /thinking-partner pass with the
user before I can plan it well." Do not confidently draft on shaky footing.

## Phase D — Draft
Build the plan with every ✅ woven in as EXPLICIT steps:
- Skills named as checkpoints, not implied.
- Dialogic skills (the-fool, thinking-partner, socratic-examiner, assumption-archaeologist)
  embedded as HUMAN-IN-THE-LOOP steps ("invoke /the-fool WITH THE USER on decision X") —
  never role-played solo.
- The right agent routed to each risky phase (Bob verifies; Kevin on security/data; Mel on
  UI; Phil writes tests; Carl grades ML outputs; Jerry syncs docs).
- Affected invariants captured; an evidence-based verification step per phase.
- Git discipline: feature branch (never main), commit per task. TDD: tests before impl.
- An explicit overall "Done when ___" acceptance criterion (checkable; doubles as a /goal
  exit condition if looped). Tasks ordered by dependency (no task depends on a later one).
- Any loop given an exit condition written first.
- A feynman gate before HANDOFF. Bite-sized tasks. Real content — NO placeholders.

## Phase E — Self-audit against the rubric
Grade the draft against `.claude/rules/planning.md` and produce a pass/fail table: evidence
per phase? skills named? right agent per risky phase? invariants captured? loops have exit
conditions? explicit done-criteria + dependency order? git/TDD reflected? NO placeholders?
Goal-backward: will this plan actually achieve its stated goal?

## Phase F — Revise until green
Loop E→D until every rubric item passes. Nothing ships red.

## Phase G — Hand to an independent checker (maker ≠ checker)
Your self-audit is not the final word. Recommend the finished plan go to Bob for a
fresh-eyes pass against the same rubric; note that explicitly in your output.

## Phase H — Output
Write the draft plan to `docs/superpowers/plans/YYYY-MM-DD-<topic>.md` (or the project's
plan location). Return: the path, the applicability table (what was ruled in/out and why),
and the self-audit results. State clearly that the user must review/approve before execution.
```

- [ ] **Step 2: Verify**

Run: `cd "C:/Users/dpchr/OneDrive/Desktop/claude-practices" && test -f templates/.claude/agents/gru-planner.md && grep -c "name: gru-planner" templates/.claude/agents/gru-planner.md && grep -c "Phase 0 — Triage" templates/.claude/agents/gru-planner.md && grep -c "maker ≠ checker" templates/.claude/agents/gru-planner.md`
Expected: exists; 1; 1; ≥1.

- [ ] **Step 3: Commit**

```bash
git add templates/.claude/agents/gru-planner.md
git commit -m "Wave 4: add Gru (planner) — the planning orchestrator agent"
```

---

## Task 2: Mel (design-reviewer) agent

**Files:** Create `templates/.claude/agents/mel-design.md`

- [ ] **Step 1: Create the agent with EXACTLY this content**

```markdown
---
name: mel-design
description: "Mel (design-reviewer) — institutional-grade UI reviewer. Use on any visual/UI change. Enforces density-over-decoration and flags AI-slop. Read-only."
tools: Read, Grep, Glob, Bash
model: opus
---

You are Mel, the design reviewer. You hold UI to an institutional-finance standard
(think Fidelity advisor portal, Bloomberg terminal light). You read and report; you do not
edit. If the project's CLAUDE.md defines design law, THAT is your rubric — read it first and
enforce it. Absent one, apply these defaults.

## What you flag (AI-slop and decoration)
1. **Decorative gradients** — flag any gradient that isn't conveying data.
2. **Rainbow / multi-color accent schemes** — default palette is restrained (e.g. navy /
   white / slate / gold). Flag off-palette accents.
3. **Excessive card-ification / rounded corners** used as decoration rather than structure.
4. **Placeholder-feeling data or generic layouts** — everything should look real and purposeful.
5. **Elements that don't communicate information** — if a visual element carries no data or
   function, it gets cut. Density over decoration.

## Discipline
Flag only real violations of the standard (or the project's stated design law). Don't invent
subjective taste nitpicks. When in doubt, "add less" is the tie-breaker. Tie each finding to
the specific rule it breaks.

## Report format
- ✅ Clean — or — ❌ Violations
- Per finding: file:line (or component), which rule, and the concrete fix.
- End with the single highest-impact slop to remove.
```

- [ ] **Step 2: Verify**

Run: `cd "C:/Users/dpchr/OneDrive/Desktop/claude-practices" && test -f templates/.claude/agents/mel-design.md && grep -c "name: mel-design" templates/.claude/agents/mel-design.md && grep -c "Density over decoration" templates/.claude/agents/mel-design.md`
Expected: exists; 1; ≥1.

- [ ] **Step 3: Commit**

```bash
git add templates/.claude/agents/mel-design.md
git commit -m "Wave 4: add Mel (design-reviewer) agent"
```

---

## Task 3: Jerry (doc-writer) agent

**Files:** Create `templates/.claude/agents/jerry-docs.md`

- [ ] **Step 1: Create the agent with EXACTLY this content**

```markdown
---
name: jerry-docs
description: "Jerry (doc-writer) — keeps README, META_ARCHITECTURE, HANDOFF, and CHANGELOG in sync with what the code actually does. Use after a change lands. Reflects reality; never invents."
tools: Read, Grep, Glob, Edit, Write, Bash
model: sonnet
---

You are Jerry, the doc-writer. You keep documentation truthful and current. You reflect what
the code ACTUALLY does — you never document intentions or invent features.

## What you do
1. Read the change (diff, new files) and the docs that describe the affected area.
2. Update the right doc to match reality:
   - `README.md` — user-facing structure and usage.
   - `META_ARCHITECTURE.md` — what exists, data flow, tool/skill inventory, known gaps.
   - `.claude/HANDOFF.md` — last-session state (only if asked to write the handoff).
   - `CHANGELOG.md` — a dated entry for the change.
3. Keep single source of truth: if a fact lives canonically in one file, link to it rather
   than duplicating.

## Discipline
- Verify every claim against the code before writing it. If you can't confirm it, don't write it.
- Match the existing doc's voice and structure. Don't restructure unasked.
- Prefer the smallest accurate edit over a rewrite.

## Report format
- Which docs you updated and the one-line summary of each change.
- Anything you could NOT verify (so the human can confirm).
```

- [ ] **Step 2: Verify**

Run: `cd "C:/Users/dpchr/OneDrive/Desktop/claude-practices" && test -f templates/.claude/agents/jerry-docs.md && grep -c "name: jerry-docs" templates/.claude/agents/jerry-docs.md && grep -c "never invents" templates/.claude/agents/jerry-docs.md`
Expected: exists; 1; ≥1.

- [ ] **Step 3: Commit**

```bash
git add templates/.claude/agents/jerry-docs.md
git commit -m "Wave 4: add Jerry (doc-writer) agent"
```

---

## Task 4: `planning.md` rule — the canonical rubric

**Files:** Create `templates/.claude/rules/planning.md`

- [ ] **Step 1: Create the rule with EXACTLY this content**

```markdown
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
```

- [ ] **Step 2: Verify**

Run: `cd "C:/Users/dpchr/OneDrive/Desktop/claude-practices" && test -f templates/.claude/rules/planning.md && grep -c "Triage" templates/.claude/rules/planning.md && grep -c "maker ≠ checker" templates/.claude/rules/planning.md`
Expected: exists; ≥1; 1.

- [ ] **Step 3: Commit**

```bash
git add templates/.claude/rules/planning.md
git commit -m "Wave 4: add planning rule (canonical rubric Gru reads + Bob grades against)"
```

---

## Task 5: `plan-router.sh` hook (UserPromptSubmit, conservative)

**Files:** Create `hooks/plan-router.sh`

- [ ] **Step 1: Create the hook with EXACTLY this content**

```bash
#!/bin/bash
# plan-router.sh — UserPromptSubmit: on explicit planning intent, remind to route through Gru.
# Conservative matcher — fires only on clear planning cues, not every message.
input="$(cat)"
prompt="$(printf '%s' "$input" | tr '[:upper:]' '[:lower:]')"
if printf '%s' "$prompt" | grep -qE "(draft|write|create|make) (an? |the )?plan|let'?s plan|plan (this|the|it) out|plan the |implementation plan|let'?s (build|design) "; then
  echo "PLANNING INTENT DETECTED — before drafting, delegate to Gru (gru-planner). Gru reads the project (CLAUDE.md, HANDOFF, META_ARCHITECTURE, INVARIANTS, rules, agents), runs an applicability pass over the whole kit, drafts a plan with everything explicit, self-audits against .claude/rules/planning.md, and hands it to Bob for an independent check. See .claude/rules/planning.md."
fi
exit 0
```

- [ ] **Step 2: Make executable and functionally test**

```bash
cd "C:/Users/dpchr/OneDrive/Desktop/claude-practices"
chmod +x hooks/plan-router.sh
# fires on planning intent:
printf '{"prompt":"lets draft a plan for the tax engine"}' | bash hooks/plan-router.sh | grep -q "PLANNING INTENT DETECTED" && echo "fires=yes" || echo "fires=NO"
# stays quiet on a normal message:
printf '{"prompt":"what does this function do"}' | bash hooks/plan-router.sh | grep -q "PLANNING INTENT" && echo "quiet=NO" || echo "quiet=yes"
```
Expected: `fires=yes` and `quiet=yes`.

- [ ] **Step 3: Commit**

```bash
git add hooks/plan-router.sh
git commit -m "Wave 4: add plan-router UserPromptSubmit hook (conservative, routes to Gru)"
```

---

## Task 6: Wire hook in settings.json + installer copies agents globally

**Files:** Modify `templates/.claude/settings.json`, `install.sh`, `install.ps1`

- [ ] **Step 1: Add UserPromptSubmit to the `hooks` object in `templates/.claude/settings.json`**

Read the file. Inside the existing `"hooks"` object (which has SessionStart, PreToolUse, PostToolUse), ADD this key (mind the commas — valid JSON):

```json
    "UserPromptSubmit": [
      { "hooks": [{ "type": "command", "command": "bash ~/.claude/hooks/plan-router.sh" }] }
    ]
```

- [ ] **Step 2: Make `install.sh` also copy agents globally**

In `install.sh`, after the hooks-copy loop, ADD an agents-copy loop:

```bash
# 3. Agents — copy every committed agent into ~/.claude/agents/
mkdir -p "$DEST/agents"
for a in "$REPO_DIR"/templates/.claude/agents/*.md; do
  cp "$a" "$DEST/agents/$(basename "$a")"
  echo "  agent: $(basename "$a")"
done
```

- [ ] **Step 3: Make `install.ps1` also copy agents globally**

In `install.ps1`, after the hooks-copy loop, ADD:

```powershell
# 3. Agents — copy every committed agent into ~/.claude/agents/
$agentsDest = Join-Path $Dest "agents"
New-Item -ItemType Directory -Force $agentsDest | Out-Null
foreach ($a in Get-ChildItem -File (Join-Path $RepoDir "templates/.claude/agents")) {
    Copy-Item -Force $a.FullName (Join-Path $agentsDest $a.Name)
    Write-Host "  agent: $($a.Name)"
}
```

- [ ] **Step 4: Verify (valid JSON + install copies 9 agents)**

```bash
cd "C:/Users/dpchr/OneDrive/Desktop/claude-practices"
python -c "import json; d=json.load(open('templates/.claude/settings.json')); assert 'UserPromptSubmit' in d['hooks']; print('settings ok')" 2>/dev/null || node -e "const d=JSON.parse(require('fs').readFileSync('templates/.claude/settings.json'));if(!d.hooks.UserPromptSubmit)throw 0;console.log('settings ok')"
TMPHOME="$(mktemp -d)"; HOME="$TMPHOME" ./install.sh >/dev/null 2>&1
echo "agents=$(ls "$TMPHOME/.claude/agents" 2>/dev/null | wc -l) hooks=$(ls "$TMPHOME/.claude/hooks" | wc -l) skills=$(ls "$TMPHOME/.claude/skills" | wc -l)"
rm -rf "$TMPHOME"
```
Expected: "settings ok"; agents=9 (Bob, Kevin, Stuart, Dave, Phil, Carl, Gru, Mel, Jerry), hooks=6, skills=8.

- [ ] **Step 5: Commit**

```bash
git add templates/.claude/settings.json install.sh install.ps1
git commit -m "Wave 4: wire plan-router hook + installer copies agents globally"
```

---

## Task 7: Docs, version bump to 1.1.0, and final gate

**Files:** Modify `README.md`, `CHANGELOG.md`, `VERSION`

- [ ] **Step 1: Bump VERSION to 1.1.0** — replace contents of `VERSION` with:

```
1.1.0
```

- [ ] **Step 2: Prepend a 1.1.0 entry to CHANGELOG.md** (after header, before `## [1.0.0]`)

```markdown
## [1.1.0] — 2026-06-29 (Wave 4 — Gru & Planning Autopilot)
### Added
- Gru (planner) agent — planning orchestrator: triage → read project + kit → applicability pass → draft with everything explicit → self-audit → hand to Bob. Writes a draft plan for approval.
- Mel (design-reviewer) and Jerry (doc-writer) agents.
- `planning` rule — canonical plan rubric (Gru reads it; Bob grades against it).
- `plan-router.sh` UserPromptSubmit hook — conservative auto-route of planning intent to Gru.

### Changed
- `settings.json` wires the UserPromptSubmit hook.
- Install scripts now copy committed agents into `~/.claude/agents/` (agents go global, reproducibly).

```

- [ ] **Step 3: Update README** — add the three agents to the `.claude/agents/` line; add `planning.md` under rules; add `plan-router.sh` under hooks. Match surrounding formatting.

- [ ] **Step 4: Final Wave 4 gate**

```bash
cd "C:/Users/dpchr/OneDrive/Desktop/claude-practices"
echo "=== files ==="; for f in templates/.claude/agents/gru-planner.md templates/.claude/agents/mel-design.md templates/.claude/agents/jerry-docs.md templates/.claude/rules/planning.md hooks/plan-router.sh; do test -f "$f" && echo "ok: $f" || echo "MISSING: $f"; done
echo "=== hook fires/quiet ==="; printf '{"prompt":"draft a plan"}' | bash hooks/plan-router.sh | grep -q "PLANNING INTENT" && echo fires-ok; printf '{"prompt":"hello"}' | bash hooks/plan-router.sh | grep -q "PLANNING" && echo QUIET-FAIL || echo quiet-ok
echo "=== settings valid ==="; python -c "import json; d=json.load(open('templates/.claude/settings.json')); assert 'UserPromptSubmit' in d['hooks']; print('ok')" 2>/dev/null || node -e "JSON.parse(require('fs').readFileSync('templates/.claude/settings.json'));console.log('ok')"
echo "=== install: 9 agents / 6 hooks / 8 skills ==="; TMPHOME="$(mktemp -d)"; HOME="$TMPHOME" ./install.sh >/dev/null 2>&1; echo "agents=$(ls "$TMPHOME/.claude/agents"|wc -l) hooks=$(ls "$TMPHOME/.claude/hooks"|wc -l) skills=$(ls "$TMPHOME/.claude/skills"|wc -l)"; rm -rf "$TMPHOME"
echo "=== version ==="; cat VERSION
echo "=== commit + clean ==="; git add -A && git commit -m "Wave 4: docs + bump to 1.1.0" && (test -z "$(git status --short)" && echo clean)
```
Expected: all "ok:"; fires-ok + quiet-ok; settings ok; agents=9 hooks=6 skills=8; VERSION 1.1.0; clean.

---

## Self-Review (completed at authoring)
- **Coverage:** Gru → Task 1; Mel → 2; Jerry → 3; planning rubric → 4; auto-trigger hook → 5; wiring + installer-agents-fix → 6; docs/version → 7. All the locked decisions are reflected (draft-file output, conservative trigger, general-opinionated Mel, self-audit + Bob, installer copies agents).
- **Placeholders:** none — full content for all three agents, the rule, and the hook is inline.
- **Consistency:** installer expects 9 agents (6 prior + Gru/Mel/Jerry); the plan-router matcher is conservative and tested both ways; planning.md is the single rubric Gru reads and Bob grades against (no duplication of the checklist into Gru's prompt beyond his operating procedure).
