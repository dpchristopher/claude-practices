# Wave 1 — Back-Half Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add the durable cross-session invariant ledger, the comprehension gate, the three tuned Minion agents, and the secrets-deny settings — the back-half foundation the kit was missing.

**Architecture:** Markdown + shell, no application code. "Tests" are verification checks (grep/cat/run-into-throwaway-dir). Each task: define check → observe current state → make change → re-run check → commit. Agents and settings ship as kit templates under `templates/.claude/` so they travel per-project.

**Tech Stack:** Bash, PowerShell, Markdown, Git, Claude Code agent/hook/settings formats.

**Source spec:** `docs/superpowers/specs/2026-06-29-claude-practices-hardening-design.md` §6 (+ §6.5).

**Branch:** `feature/wave-1-back-half` (already checked out). Repo: `C:/Users/dpchr/OneDrive/Desktop/claude-practices`.

**Interview decisions (locked):** Bob checks all four (tests+output, invariants re-verified, scope match, edge cases). Kevin enforces all four (no secrets, no PII, secure data handling, dependency/supply-chain). Agents live in `templates/.claude/agents/`.

---

## File Structure (what this wave touches)

**Created:**
- `templates/INVARIANTS.md` — the contract-ledger template
- `templates/.claude/rules/invariants.md` — auto-load rule explaining the ledger discipline
- `hooks/session-context.ps1` — Windows-native hook sibling
- `skills/feynman-explainer/SKILL.md` — comprehension-gate skill
- `templates/.claude/agents/bob-verifier.md`, `kevin-security.md`, `stuart-explorer.md`
- `templates/.claude/settings.json` — deny secrets / allow safe commands

**Modified:**
- `hooks/session-context.sh` — load `INVARIANTS.md` in full
- `install.sh`, `install.ps1` — also install the `.ps1` hook sibling
- `templates/.claude/rules/tool-discipline.md` — add the light/heavy research rubric (§6.5)
- `skills/session-workflow/SKILL.md` — session-end discipline: re-verify invariants + Feynman gate
- `README.md`, `CHANGELOG.md`, `VERSION` — document + bump to 0.3.0

---

## Task 1: `INVARIANTS.md` template + auto-load rule

**Files:**
- Create: `templates/INVARIANTS.md`
- Create: `templates/.claude/rules/invariants.md`

- [ ] **Step 1: Create `templates/INVARIANTS.md`**

```markdown
# System Invariants — [Project Name]

> Durable contracts that must ALWAYS hold. Unlike HANDOFF.md (last session), this is
> the standing list of things a later session must not break. Loaded in full at every
> session start. When you touch an area an invariant constrains, re-verify it before
> writing HANDOFF — with evidence, not assertion.
>
> Status: `✅ holds` (verified) · `⚠ unverified` (newly added, not yet proven) · `❌ broken` (known regression)

| ID | Invariant (plain language) | Area it constrains | How to verify | Status |
|----|----------------------------|--------------------|---------------|--------|
| INV-01 | [e.g. OAuth protects all /api/* routes] | [auth layer] | [e.g. `curl -I /api/x` returns 401 unauthenticated] | ⚠ unverified |
| INV-02 | [contract] | [area] | [command/check] | ⚠ unverified |

## Notes
- Add an invariant the moment a cross-cutting contract is established (auth, data integrity, perf budget, external API shape).
- Number monotonically (INV-01, INV-02…); never reuse an ID.
- If an invariant is intentionally retired, strike it through and note why — don't delete the row.
```

- [ ] **Step 2: Create `templates/.claude/rules/invariants.md`**

```markdown
# Invariants Rule

> Auto-loaded at session start. Governs the system invariant ledger (`INVARIANTS.md`).

## What INVARIANTS.md is
A durable list of contracts that must always hold across sessions. HANDOFF.md says what
happened last session; INVARIANTS.md says what must never break. The SessionStart hook
loads it in full.

## When to ADD an invariant
The moment a cross-cutting contract is established: authentication/authorization, data
integrity guarantees, performance budgets, the shape of an external API you depend on,
or any behavior whose breakage would not be obvious from a local diff. Seed it as
`⚠ unverified` until you have proven it once.

## When to RE-VERIFY invariants
Before writing HANDOFF at session end, identify which invariants the session's work
*could* have affected and re-verify them — running the "How to verify" command and
pasting the result. Evidence over assertion. Flip status to `✅ holds` or `❌ broken`.

## Hard line
A session that touched an invariant's area and did NOT re-verify it is not done.
Never mark work complete on top of an unverified invariant you may have disturbed.
```

- [ ] **Step 3: Verify**

Run: `cd "C:/Users/dpchr/OneDrive/Desktop/claude-practices" && test -f templates/INVARIANTS.md && test -f templates/.claude/rules/invariants.md && grep -c "INV-01" templates/INVARIANTS.md && grep -c "RE-VERIFY" templates/.claude/rules/invariants.md`
Expected: both files exist; one match each.

- [ ] **Step 4: Commit**

```bash
git add templates/INVARIANTS.md templates/.claude/rules/invariants.md
git commit -m "Wave 1: add INVARIANTS.md ledger template + auto-load rule"
```

---

## Task 2: Hook integration — load invariants in full + PowerShell sibling

**Files:**
- Modify: `hooks/session-context.sh`
- Create: `hooks/session-context.ps1`
- Modify: `install.sh`, `install.ps1`

- [ ] **Step 1: Confirm current hook does not load invariants**

Run: `grep -c "INVARIANTS" hooks/session-context.sh || echo 0`
Expected: `0`.

- [ ] **Step 2: Add an INVARIANTS block to `hooks/session-context.sh`**

Insert this block immediately BEFORE the "Last session handoff" block (the `if [ -f ".claude/HANDOFF.md" ]` section). Invariants load in FULL (never truncated):

```bash
# System invariants — load in full (durable contracts, never truncate)
if [ -f "INVARIANTS.md" ]; then
  echo ""
  echo "## SYSTEM INVARIANTS (INVARIANTS.md — full; these must NOT break)"
  cat "INVARIANTS.md"
fi
```

- [ ] **Step 3: Create `hooks/session-context.ps1` (Windows-native equivalent)**

```powershell
# session-context.ps1 — SessionStart context loader (Windows-native sibling of session-context.sh)
Write-Host "==========================================================="
Write-Host "SESSION CONTEXT"
Write-Host "==========================================================="

function Show-Head($file, $title, $n) {
  if (Test-Path $file) {
    Write-Host ""; Write-Host "## $title"
    Get-Content $file -TotalCount $n
  }
}

Show-Head "CLAUDE.md" "PROJECT RULES (CLAUDE.md - first 80 lines)" 80
Show-Head "META_ARCHITECTURE.md" "ARCHITECTURE SNAPSHOT (META_ARCHITECTURE.md - first 120 lines)" 120

$plan = Get-ChildItem ".claude/plans/*.md" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if ($plan) { Write-Host ""; Write-Host "## ACTIVE PLAN ($($plan.Name))"; Get-Content $plan.FullName -TotalCount 50 }

if (Test-Path "INVARIANTS.md") {
  Write-Host ""; Write-Host "## SYSTEM INVARIANTS (INVARIANTS.md - full; these must NOT break)"
  Get-Content "INVARIANTS.md"
}

if (Test-Path ".claude/HANDOFF.md") {
  Write-Host ""; Write-Host "## LAST SESSION - BLOCKERS & NEXT ACTION (.claude/HANDOFF.md)"
  Get-Content ".claude/HANDOFF.md"
} else {
  Write-Host ""; Write-Host "## HANDOFF"; Write-Host "WARN HANDOFF not found - new project or first session."
}

Write-Host ""
Write-Host "==========================================================="
Write-Host "CONTEXT LOADED. MANDATORY: 1) flag stale context 2) /session-workflow 3) /superpowers:brainstorming"
Write-Host "==========================================================="
```

- [ ] **Step 4: Update `install.sh` to also copy the `.ps1` hook**

In `install.sh`, after the line that copies `session-context.sh`, add:

```bash
cp "$REPO_DIR/hooks/session-context.ps1" "$DEST/hooks/session-context.ps1"
echo "  hook: session-context.ps1"
```

- [ ] **Step 5: Update `install.ps1` to also copy the `.ps1` hook**

In `install.ps1`, after the `Copy-Item` for `session-context.sh`, add:

```powershell
Copy-Item -Force (Join-Path $RepoDir "hooks/session-context.ps1") (Join-Path $hooksDest "session-context.ps1")
Write-Host "  hook: session-context.ps1"
```

- [ ] **Step 6: Verify (bash hook loads invariants; install carries both hooks)**

```bash
cd "C:/Users/dpchr/OneDrive/Desktop/claude-practices"
grep -c "INVARIANTS.md" hooks/session-context.sh        # expect >=1
test -f hooks/session-context.ps1 && echo "ps1 hook present"
TMPHOME="$(mktemp -d)"; HOME="$TMPHOME" ./install.sh >/dev/null 2>&1
ls "$TMPHOME/.claude/hooks/"                              # expect both .sh and .ps1
rm -rf "$TMPHOME"
```
Expected: grep ≥1, "ps1 hook present", both hook files listed.

- [ ] **Step 7: Functional check — hook surfaces a seeded invariant**

```bash
cd "C:/Users/dpchr/OneDrive/Desktop/claude-practices"
TMPD="$(mktemp -d)"; cp templates/INVARIANTS.md "$TMPD/INVARIANTS.md"
(cd "$TMPD" && bash "$OLDPWD/hooks/session-context.sh" | grep -q "SYSTEM INVARIANTS" && echo "INVARIANTS SURFACED" || echo "FAILED")
rm -rf "$TMPD"
```
Expected: "INVARIANTS SURFACED".

- [ ] **Step 8: Commit**

```bash
git add hooks/session-context.sh hooks/session-context.ps1 install.sh install.ps1
git commit -m "Wave 1: hook loads INVARIANTS.md in full + Windows-native hook sibling"
```

---

## Task 3: `feynman-explainer` skill

**Files:**
- Create: `skills/feynman-explainer/SKILL.md`

- [ ] **Step 1: Create the skill**

```markdown
---
name: feynman-explainer
description: Use as a comprehension gate before marking work done and when writing HANDOFF. Forces a plain-language explanation of a change as if teaching a competent newcomer; points where the explanation stalls are logged as comprehension gaps. Completes the thinking trio.
triggers:
  - before marking a task done
  - writing HANDOFF
  - do I actually understand this
  - explain this simply
  - comprehension check
---

# Feynman Explainer

A comprehension gate. You do not understand a change until you can explain it simply.
This skill turns that test into a step you actually run.

## When to invoke
1. **Before claiming a task done** — articulate what changed and why it works.
2. **When writing HANDOFF.md** — the explanation becomes the HANDOFF body.

## The procedure
1. **Explain the change in plain language**, as if to a competent newcomer to this
   codebase. No jargon, no hand-waving over "and then it just works." Cover: what
   changed, why, and how you know it works.
2. **Mark every stall.** Wherever you reach for jargon, get vague, or can't say *why*
   something works — that is a **comprehension gap**, not a wording problem.
3. **Map each gap to a concrete follow-up:** read file X / run test Y / re-verify
   invariant Z. A gap is not closed by rephrasing; it is closed by going and checking.
4. **If a gap reveals a real defect**, hand off: `/debugging-wizard` for code,
   `/labarr-ml` for an ML issue.
5. **The simple explanation, with gaps resolved, is the HANDOFF body.** HANDOFF quality
   and comprehension are gated by the same act.

## The test
If you cannot explain why the change works without jargon, you have not verified it —
you have only produced something that looks right. Close the gap before "done."

## Why it works (research-backed)
Explaining-to-teach forces retrieval, which builds understanding far better than
re-reading (Karpicke & Blunt 2011, *Science*; learning-by-teaching as retrieval
practice, Koh/Lee/Lim 2018). The discomfort of articulating simply is the signal
(Bjork's desirable difficulty), and without it most of what you "learned" decays
(Ebbinghaus, 1885).

## Place in the trio
`thinking-partner` (explore) → `socratic-examiner` (stress-test) →
`assumption-archaeologist` (excavate premises) → **`feynman-explainer`** (prove you
understand what you built). The first three precede building; this one gates "done."
```

- [ ] **Step 2: Verify**

Run: `test -f skills/feynman-explainer/SKILL.md && grep -c "comprehension gap" skills/feynman-explainer/SKILL.md && grep -c "name: feynman-explainer" skills/feynman-explainer/SKILL.md`
Expected: file exists; ≥1 and 1.

- [ ] **Step 3: Commit**

```bash
git add skills/feynman-explainer/SKILL.md
git commit -m "Wave 1: add feynman-explainer skill (comprehension gate, completes trio)"
```

---

## Task 4: Bob (verifier) agent

**Files:**
- Create: `templates/.claude/agents/bob-verifier.md`

- [ ] **Step 1: Create the agent**

```markdown
---
name: bob-verifier
description: "Bob (verifier) — fresh-context adversarial reviewer. Use before marking work done. Checks a diff against the plan and invariants and reports only correctness gaps."
tools: Read, Grep, Glob, Bash
model: opus
---

You are Bob, the verifier. You review a change with fresh eyes — you did not write it
and you do not trust the implementer's report. Verify by reading code and running checks,
not by accepting claims.

## What you check (all four)
1. **Tests ran, with evidence.** Did the implementer actually run the relevant tests and
   show real output? If a "done" claim has no pasted command + output, that is a gap.
   Re-run the tests yourself when you can.
2. **Invariants re-verified.** For any invariant in INVARIANTS.md whose area this change
   touches, confirm it still holds — run its "How to verify" command. A disturbed-but-
   unverified invariant is a gap.
3. **Scope match.** The change does exactly what the plan/spec asked — no missing
   requirements, and no unrequested extras / over-engineering.
4. **Edge cases.** Flag plausible inputs or states the change does not handle (the
   trust-then-verify gap: plausible-looking code that breaks on an edge case).

## Discipline (do not over-report)
A reviewer asked to find gaps will invent them. Flag ONLY gaps that affect correctness,
the stated requirements, or an invariant. Do not invent style nitpicks, speculative
abstractions, or defensive code for cases that cannot occur. If the work is sound, say so.

## Report format
- ✅ Verified — or — ❌ Gaps found
- For each gap: file:line, which of the four categories, and the specific problem.
- End with the single highest-priority fix.
```

- [ ] **Step 2: Verify**

Run: `test -f templates/.claude/agents/bob-verifier.md && grep -c "name: bob-verifier" templates/.claude/agents/bob-verifier.md && grep -c "model: opus" templates/.claude/agents/bob-verifier.md`
Expected: exists; 1 and 1.

- [ ] **Step 3: Commit**

```bash
git add templates/.claude/agents/bob-verifier.md
git commit -m "Wave 1: add Bob (verifier) agent"
```

---

## Task 5: Kevin (security-reviewer) agent

**Files:**
- Create: `templates/.claude/agents/kevin-security.md`

- [ ] **Step 1: Create the agent**

```markdown
---
name: kevin-security
description: "Kevin (security-reviewer) — fiduciary-grade security review. Use on changes touching auth, data handling, dependencies, or anything client-facing. Read-only."
tools: Read, Grep, Glob, Bash
model: opus
---

You are Kevin, the security reviewer, working in a fiduciary / wealth-management context
where a leak is a compliance event. You read and report; you never modify code.

## Non-negotiables (all four)
1. **No secrets in code or context.** No API keys, tokens, passwords, or `.env` contents
   committed or hardcoded. Flag any secret that should be an env var / secret store.
2. **No client PII leakage.** No client names, account numbers, balances, SSNs, or other
   PII in logs, commit messages, error output, screenshots, or test fixtures.
3. **Secure data handling.** Flag sensitive financial data stored or transmitted
   unencrypted, weak/again-rolled crypto, or PII written to disk without need.
4. **Dependency / supply-chain.** Flag unpinned dependencies, newly added packages from
   unknown sources, or install steps that fetch+execute remote code.

## Discipline
Flag only real exposure — issues with a plausible path to a leak or compromise. Do not
invent theoretical risks with no attack path. Rank findings by blast radius.

## Report format
- ✅ Clear — or — ❌ Findings
- For each finding: file:line, which non-negotiable, the exposure, and the fix.
- End with the highest-blast-radius item.
```

- [ ] **Step 2: Verify**

Run: `test -f templates/.claude/agents/kevin-security.md && grep -c "name: kevin-security" templates/.claude/agents/kevin-security.md && grep -c "PII" templates/.claude/agents/kevin-security.md`
Expected: exists; 1 and ≥1.

- [ ] **Step 3: Commit**

```bash
git add templates/.claude/agents/kevin-security.md
git commit -m "Wave 1: add Kevin (security-reviewer) agent"
```

---

## Task 6: Stuart (explorer) agent

**Files:**
- Create: `templates/.claude/agents/stuart-explorer.md`

- [ ] **Step 1: Create the agent**

```markdown
---
name: stuart-explorer
description: "Stuart (explorer) — cheap, fast light-research and codebase lookup on a large repo. Use for 'where is X / which file does Y' questions where a wrong answer would be obvious. Read-only."
tools: Read, Grep, Glob
model: haiku
---

You are Stuart, the explorer. You do fast, cheap lookups so heavier models aren't spent
on simple search. You read and report locations and facts; you do not edit.

## What you're for (light research)
- "Where is X defined?" / "Which files reference Y?" / "Does Z exist?"
- Mapping where a feature lives across a large codebase.
- Quick factual answers where a wrong answer would be immediately obvious to the asker.

## What you are NOT for
If the question requires synthesis across many sources, judgment, or a recommendation
whose wrongness would quietly mislead a decision — say so and recommend escalating to a
heavier model. Do not bluff a synthesis you're not suited for.

## Report format
- The answer: file:line references and a one-line each.
- If you could not find it, say where you looked and what you'd try next.
- If the question is actually heavy (not light), say so plainly.
```

- [ ] **Step 2: Verify**

Run: `test -f templates/.claude/agents/stuart-explorer.md && grep -c "name: stuart-explorer" templates/.claude/agents/stuart-explorer.md && grep -c "model: haiku" templates/.claude/agents/stuart-explorer.md`
Expected: exists; 1 and 1.

- [ ] **Step 3: Commit**

```bash
git add templates/.claude/agents/stuart-explorer.md
git commit -m "Wave 1: add Stuart (explorer) agent"
```

---

## Task 7: `settings.json` template — deny secrets / allow safe commands

**Files:**
- Create: `templates/.claude/settings.json`

- [ ] **Step 1: Create the settings template**

```json
{
  "permissions": {
    "deny": [
      "Read(.env)",
      "Read(.env.*)",
      "Read(**/*.key)",
      "Read(**/*.pem)",
      "Read(**/secrets/**)",
      "Read(**/credentials*)"
    ],
    "allow": [
      "Bash(git status)",
      "Bash(git diff:*)",
      "Bash(git log:*)",
      "Bash(git add:*)",
      "Bash(git commit:*)"
    ]
  },
  "hooks": {
    "SessionStart": [
      { "type": "command", "command": "bash ~/.claude/hooks/session-context.sh" }
    ]
  }
}
```

- [ ] **Step 2: Verify it is valid JSON and has the deny rules**

```bash
cd "C:/Users/dpchr/OneDrive/Desktop/claude-practices"
python -c "import json,sys; d=json.load(open('templates/.claude/settings.json')); assert 'Read(.env)' in d['permissions']['deny']; print('valid json, .env denied')"
```
Expected: "valid json, .env denied". (If `python` is unavailable, use `node -e "JSON.parse(require('fs').readFileSync('templates/.claude/settings.json'))" && echo ok`.)

- [ ] **Step 3: Commit**

```bash
git add templates/.claude/settings.json
git commit -m "Wave 1: add settings.json template (deny secrets, allow safe git)"
```

---

## Task 8: Light/heavy research rubric → `tool-discipline.md` (spec §6.5)

**Files:**
- Modify: `templates/.claude/rules/tool-discipline.md`

- [ ] **Step 1: Append the rubric section at the end of the file**

Add this section to the end of `templates/.claude/rules/tool-discipline.md`:

```markdown
---

## Light vs Heavy Research — Route to the Right Model

**The tell:** if a wrong answer would be immediately obvious, it's light (cheap model /
Stuart-explorer on Haiku). If a wrong answer would quietly mislead a decision, it's heavy
(Opus, or Sonnet for moderate).

| | Light (Stuart / Haiku) | Heavy (Opus, or Sonnet mid) |
|---|---|---|
| Question shape | "Where is X?" "Which file does Y?" | "Best approach across these sources?" "Verify + recommend." |
| Sources | One known place | Many, needs synthesis |
| Output | A fact / path / yes-no | A judgment / ranked recommendation / accuracy verdict |
| Failure cost | Low (obvious if wrong) | High (quietly misleads) |

Route light lookups to `stuart-explorer` to conserve heavier models on a large codebase.
Reserve Opus for synthesis, verification, and recommendations.
```

- [ ] **Step 2: Verify**

Run: `grep -c "Light vs Heavy Research" templates/.claude/rules/tool-discipline.md && grep -c "quietly mislead" templates/.claude/rules/tool-discipline.md`
Expected: 1 and ≥1.

- [ ] **Step 3: Commit**

```bash
git add templates/.claude/rules/tool-discipline.md
git commit -m "Wave 1: add light/heavy research rubric to tool-discipline"
```

---

## Task 9: Session-end discipline — invariants re-verify + Feynman gate

**Files:**
- Modify: `skills/session-workflow/SKILL.md`

- [ ] **Step 1: Locate the Session End section**

Run: `grep -n "Session End" skills/session-workflow/SKILL.md`
Expected: a match for the session-end section heading.

- [ ] **Step 2: Add two steps to the Session End checklist**

In the Session End section of `skills/session-workflow/SKILL.md`, add these two items to the checklist BEFORE the "Write `.claude/HANDOFF.md`" step:

```markdown
- **Re-verify affected invariants:** for any contract in `INVARIANTS.md` whose area this session touched, run its verification and update status with evidence. A disturbed-but-unverified invariant means the session is not done. (See `.claude/rules/invariants.md`.)
- **Feynman gate:** invoke `/feynman-explainer` — explain the session's changes in plain language. Stalls are comprehension gaps; resolve them. The resulting explanation is the HANDOFF body.
```

- [ ] **Step 3: Verify**

Run: `grep -c "Re-verify affected invariants" skills/session-workflow/SKILL.md && grep -c "Feynman gate" skills/session-workflow/SKILL.md`
Expected: 1 and 1.

- [ ] **Step 4: Commit**

```bash
git add skills/session-workflow/SKILL.md
git commit -m "Wave 1: session-end re-verifies invariants + Feynman comprehension gate"
```

---

## Task 10: Docs, version bump, and Wave 1 verification gate

**Files:**
- Modify: `README.md`, `CHANGELOG.md`, `VERSION`

- [ ] **Step 1: Bump VERSION to 0.3.0**

Replace the contents of `VERSION` with:

```
0.3.0
```

- [ ] **Step 2: Prepend a 0.3.0 entry to CHANGELOG.md**

Insert this block immediately after the changelog header paragraph (before the `## [0.2.0]` entry):

```markdown
## [0.3.0] — 2026-06-29 (Wave 1 — Back-Half Foundation)
### Added
- `INVARIANTS.md` ledger template + `invariants` auto-load rule (cross-session contract tracking).
- `feynman-explainer` skill — comprehension gate completing the thinking trio.
- Minion agents in `templates/.claude/agents/`: Bob (verifier), Kevin (security-reviewer), Stuart (explorer/Haiku).
- `settings.json` template — deny secrets, allow safe git commands.
- Windows-native `session-context.ps1` hook sibling.
- Light vs heavy research rubric in `tool-discipline.md`.

### Changed
- SessionStart hook now loads `INVARIANTS.md` in full.
- Session-end discipline now re-verifies affected invariants and runs the Feynman gate.
```

- [ ] **Step 3: Add an INVARIANTS + agents note to README Contents**

In `README.md`, under the `templates/` portion of the Contents tree, add a line for `INVARIANTS.md` and note the `.claude/agents/` directory. Add to the appropriate spot:

```markdown
  INVARIANTS.md                    ← Durable cross-session system contracts (loaded in full)
  .claude/agents/                  ← Bob (verifier), Kevin (security), Stuart (explorer)
  .claude/settings.json            ← Deny secrets, allow safe commands
```

Also add a one-line mention of `feynman-explainer` to the skills list in Contents.

- [ ] **Step 4: Final Wave 1 verification gate**

```bash
cd "C:/Users/dpchr/OneDrive/Desktop/claude-practices"
echo "=== files present ==="
for f in templates/INVARIANTS.md templates/.claude/rules/invariants.md \
         hooks/session-context.ps1 skills/feynman-explainer/SKILL.md \
         templates/.claude/agents/bob-verifier.md templates/.claude/agents/kevin-security.md \
         templates/.claude/agents/stuart-explorer.md templates/.claude/settings.json; do
  test -f "$f" && echo "ok: $f" || echo "MISSING: $f"
done
echo "=== hook loads invariants ==="; grep -c "INVARIANTS.md" hooks/session-context.sh
echo "=== settings valid json ==="; python -c "import json; json.load(open('templates/.claude/settings.json')); print('ok')" 2>/dev/null || node -e "JSON.parse(require('fs').readFileSync('templates/.claude/settings.json'));console.log('ok')"
echo "=== install carries both hooks ==="; TMPHOME="$(mktemp -d)"; HOME="$TMPHOME" ./install.sh >/dev/null 2>&1; ls "$TMPHOME/.claude/hooks/"; rm -rf "$TMPHOME"
echo "=== version ==="; cat VERSION
echo "=== clean tree after commit ==="; git add -A && git commit -m "Wave 1: docs + bump to 0.3.0" && (test -z "$(git status --short)" && echo clean)
```
Expected: all "ok:", grep ≥1, settings "ok", both hooks listed, VERSION 0.3.0, "clean".

---

## Self-Review (completed at authoring)

- **Spec coverage:** §6.1 → Tasks 1,2,9; §6.2 → Tasks 3,9; §6.3 → Tasks 4,5,6 (tuned per interview); §6.4 → Task 7; §6.5 → Task 8; docs/version → Task 10. All covered.
- **Placeholders:** none — every file's full content is inline (agents tuned to the interview answers, not generic).
- **Consistency:** agent `name` fields are slugs (`bob-verifier`/`kevin-security`/`stuart-explorer`) with "Name (role)" in description, matching spec §6.3; hook block is inserted before HANDOFF in both `.sh` and `.ps1`; install scripts updated in Task 2 to carry the `.ps1` hook that Task 10's gate checks for.
- **Note:** Task 9 assumes the Session End section exists in `skills/session-workflow/SKILL.md` (verified present in the repo). If its checklist wording differs, insert the two items adjacent to the HANDOFF step regardless.
