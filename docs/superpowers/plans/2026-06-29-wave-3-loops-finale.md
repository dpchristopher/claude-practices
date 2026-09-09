# Wave 3 — Loop Discipline & Finale Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add self-correction loop discipline (built *on* native Claude Code primitives, not reinventing them), document the optional infra integrations, finish the CLAUDE.md leanness pattern, and ship the kit at v1.0.0.

**Architecture:** Markdown only this wave (one rule, two docs, template + version edits). No application code. "Tests" are grep/cat checks. Each task ends in a commit.

**Tech Stack:** Markdown, Git.

**Source spec:** `docs/superpowers/specs/2026-06-29-claude-practices-hardening-design.md` §8 (+ the §8.2 CLAUDE.md `@`-import item still pending).

**Branch:** `feature/wave-3-loops-finale` (already checked out). Repo: `C:/Users/dpchr/OneDrive/Desktop/claude-practices`. Version 0.4.0 → 1.0.0 (completes the planned roadmap).

**Key design constraint (from the Wave 1 audit):** Claude Code now ships `/goal` (an evaluator re-checks a stated goal each turn and keeps working until it holds) and `/rewind` (per-change checkpoints/rollback). So the loop rule must *lean on these*, not hand-roll an iteration counter or a rollback mechanism. We supply only the doctrine the platform doesn't.

---

## File Structure (what this wave touches)

**Created:**
- `templates/.claude/rules/loop.md` — self-correction loop discipline (auto-load)
- `docs/optional-integrations.md` — opt-in Graphiti + Playwright/browser-verify patterns

**Modified:**
- `templates/CLAUDE.md` — add an "Imports & Keeping This File Lean" note (`@`-import pattern)
- `README.md`, `CHANGELOG.md`, `VERSION` — document + bump to 1.0.0

---

## Task 1: `loop.md` rule (thin, built on native primitives)

**Files:**
- Create: `templates/.claude/rules/loop.md`

- [ ] **Step 1: Create the rule with EXACTLY this content**

```markdown
# Loop Rule

> Auto-loaded at session start. Governs autonomous / self-correcting loops. The point is
> not to babysit an agent move by move — it is to design a loop that runs without you, then
> trust it because you built the brakes in.

## Lean on native primitives — don't reinvent them
- **`/goal`** is the iteration engine: state a checkable goal and a separate evaluator
  re-checks it each turn, continuing until it holds. Use it instead of hand-rolling a loop.
- **`/rewind`** is the safety net: per-change checkpoints you can roll back to. Use it
  rather than scripting your own undo.

This rule supplies only the discipline the platform does not.

## The seven rules of a loop you can trust
1. **Write the exit condition BEFORE the loop starts.** Concrete and machine-checkable —
   "all tests pass AND lint clean; stop after 2 clean passes." A loop with no defined exit
   burns tokens.
2. **Maker ≠ checker.** The agent doing the work never grades itself. Route checking to a
   fresh-context reviewer (Bob the verifier) or judge (Carl the evals-judge).
3. **State lives on disk, not in context.** Progress, the exit condition, and open work go
   in files (the plan, INVARIANTS.md, HANDOFF) so the loop resumes across sessions.
4. **Earn autonomy in stages: L1 → L2 → L3.** L1 = loop reports, you apply fixes. L2 =
   loop applies fixes, you review each. L3 = unattended. Never start at L3.
5. **Checkpoint per iteration.** Each pass is a git commit — the diff is your audit trail.
   (Rollback itself is `/rewind`; the commits are for the record.)
6. **Detect a stuck loop.** If the same error repeats, or no new commit lands in N
   iterations, STOP and surface to a human. Repetition is not progress.
7. **Loops open PRs; they never auto-merge.** The human merge is the final gate.

## When NOT to loop
A single scoped prompt often beats the whole apparatus. Reach for a loop only when the
goal is objectively checkable and iterative refinement provides measurable value. If you
can describe the fix in one sentence, just make it.
```

- [ ] **Step 2: Verify**

Run: `cd "C:/Users/dpchr/OneDrive/Desktop/claude-practices" && test -f templates/.claude/rules/loop.md && grep -c "exit condition BEFORE" templates/.claude/rules/loop.md && grep -c "Maker ≠ checker" templates/.claude/rules/loop.md && grep -c "/goal" templates/.claude/rules/loop.md`
Expected: exists; 1; 1; ≥1.

- [ ] **Step 3: Commit**

```bash
git add templates/.claude/rules/loop.md
git commit -m "Wave 3: add loop rule (native /goal + /rewind, exit-first, maker≠checker, autonomy ladder)"
```

---

## Task 2: `docs/optional-integrations.md`

**Files:**
- Create: `docs/optional-integrations.md`

- [ ] **Step 1: Create the doc with EXACTLY this content**

```markdown
# Optional Integrations

These are opt-in patterns, NOT part of the core kit. Each adds capability *and* cost
(context, setup, a dependency). **Don't install the kitchen sink** — every MCP server you
add consumes context and can degrade performance. Add one only when a concrete need appears.

---

## Graphiti — temporal memory (optional)
**What:** an open-source temporal knowledge graph (the engine behind Zep). Stores facts
with validity windows — you can ask "what is true now" vs "what was true then" — and ships
an MCP server.

**Why you might add it:** if flat-file continuity (INVARIANTS.md + HANDOFF + the SessionStart
hook) stops scaling — e.g. you need to query the *history* of how a contract changed over
time, not just its current state.

**Why you probably don't yet:** it adds a graph DB + embeddings + an LLM ingestion pipeline.
The kit's markdown continuity works and is zero-infra. Pilot Graphiti as an experiment
before making it core.

**Repo:** github.com/getzep/graphiti

---

## Playwright / browser-verify MCP — UI self-checking (optional)
**What:** an MCP server that lets Claude drive a real browser — navigate, click, screenshot.

**Why you might add it:** it closes the verification loop on visual work. For a dashboard,
Claude can open the page, exercise it as a user, and screenshot proof — satisfying the
"evidence over assertion" rule for UI changes (the strongest verification for visuals).

**Cost / caution:** an MCP server eats context whether or not you use it on a given turn.
Add it on visual-heavy projects; remove it on others. Don't run several browser/automation
MCPs at once.

---

## Rule of thumb
Core kit = zero required infra (markdown + shell + git). Reach for an optional integration
only when a real, recurring need outgrows the simple mechanism — and remove it when it
stops earning its context cost.
```

- [ ] **Step 2: Verify**

Run: `cd "C:/Users/dpchr/OneDrive/Desktop/claude-practices" && test -f docs/optional-integrations.md && grep -c "Graphiti" docs/optional-integrations.md && grep -c "kitchen sink" docs/optional-integrations.md`
Expected: exists; ≥1; 1.

- [ ] **Step 3: Commit**

```bash
git add docs/optional-integrations.md
git commit -m "Wave 3: add optional-integrations doc (Graphiti, Playwright; opt-in only)"
```

---

## Task 3: CLAUDE.md `@`-import / leanness note

**Files:**
- Modify: `templates/CLAUDE.md`

- [ ] **Step 1: Add an imports/leanness section near the end of the template**

Read `templates/CLAUDE.md`. At the END of the file (after the last existing section, before any trailing footer line if present), add this section:

```markdown
---

## Imports & Keeping This File Lean

CLAUDE.md loads every session — only put things here that apply broadly. Move volatile or
occasionally-relevant material (long roadmaps, big reference tables, detailed specs) OUT of
this file and pull it in on demand with an `@`-import:

```
See the roadmap in @docs/roadmap.md and API notes in @docs/api-notes.md
```

`@path` references are read when relevant rather than loaded every turn. The prune test for
anything in this file: *would removing it cause Claude to make a mistake?* If not, cut it or
move it behind an `@`-import. A lean CLAUDE.md is one whose rules actually get followed —
bloat causes rules to be ignored.
```

- [ ] **Step 2: Verify**

Run: `cd "C:/Users/dpchr/OneDrive/Desktop/claude-practices" && grep -c "Imports & Keeping This File Lean" templates/CLAUDE.md && grep -c "@docs/roadmap.md" templates/CLAUDE.md`
Expected: 1; ≥1.

- [ ] **Step 3: Commit**

```bash
git add templates/CLAUDE.md
git commit -m "Wave 3: add @-import / leanness guidance to CLAUDE.md template"
```

---

## Task 4: Docs, version bump to 1.0.0, and final gate

**Files:**
- Modify: `README.md`, `CHANGELOG.md`, `VERSION`

- [ ] **Step 1: Bump VERSION to 1.0.0**

Replace the contents of `VERSION` with:

```
1.0.0
```

- [ ] **Step 2: Prepend a 1.0.0 entry to CHANGELOG.md** (after the header paragraph, before `## [0.4.0]`)

```markdown
## [1.0.0] — 2026-06-29 (Wave 3 — Loop Discipline & Finale)
### Added
- `loop` rule — self-correction loop discipline built on native `/goal` + `/rewind`: exit-condition-first, maker≠checker, state-on-disk, L1→L2→L3 autonomy ladder, stuck-loop detection, loops open PRs (never auto-merge).
- `docs/optional-integrations.md` — opt-in Graphiti (temporal memory) and Playwright/browser-verify (UI self-check) patterns, with the don't-install-the-kitchen-sink caution.
- `@`-import / leanness guidance in the `CLAUDE.md` template.

### Notes
- Completes the back-half hardening roadmap (Waves 0–3): clean-up → continuity/invariants → verification/evals → loops. The kit now covers planning AND the back half (verification, evals, self-correction, articulation).

```

- [ ] **Step 3: Update README** — add `loop.md` under the rules listing in the Contents tree, and add `optional-integrations.md` under the `docs/` listing:

```markdown
      loop.md                      ← Self-correction loop discipline (auto-loads)
```
and under docs/:
```markdown
  optional-integrations.md         ← Opt-in Graphiti + Playwright patterns
```

- [ ] **Step 4: Final Wave 3 verification gate**

```bash
cd "C:/Users/dpchr/OneDrive/Desktop/claude-practices"
echo "=== files present ==="
for f in templates/.claude/rules/loop.md docs/optional-integrations.md; do
  test -f "$f" && echo "ok: $f" || echo "MISSING: $f"; done
echo "=== loop rule key content ==="; grep -c "exit condition BEFORE" templates/.claude/rules/loop.md; grep -c "L1 → L2 → L3" templates/.claude/rules/loop.md
echo "=== CLAUDE.md import note ==="; grep -c "Imports & Keeping This File Lean" templates/CLAUDE.md
echo "=== install still copies all hooks (regression) ==="; TMPHOME="$(mktemp -d)"; HOME="$TMPHOME" ./install.sh >/dev/null 2>&1; echo "skills=$(ls "$TMPHOME/.claude/skills" | wc -l) hooks=$(ls "$TMPHOME/.claude/hooks" | wc -l)"; rm -rf "$TMPHOME"
echo "=== version ==="; cat VERSION
echo "=== commit + clean tree ==="; git add -A && git commit -m "Wave 3: docs + bump to 1.0.0" && (test -z "$(git status --short)" && echo clean)
```
Expected: both "ok:"; loop content 1 and 1; import note 1; install copies 8 skills + 5 hooks; VERSION 1.0.0; "clean".

---

## Self-Review (completed at authoring)

- **Spec coverage:** §8.1 (loop rule on native primitives) → Task 1; §8.3 (optional integrations doc) → Task 2; §8.2 (CLAUDE.md `@`-import split) → Task 3; docs/version → Task 4. All covered.
- **Placeholders:** none — full content for the rule, the doc, and the import note is inline.
- **Consistency:** loop rule references Bob (verifier) and Carl (evals-judge) from earlier waves as the "checker" leg, consistent with maker≠checker in `verification.md`; install regression check expects 8 skills (7 from before + feynman from Wave 1 = 8) and 5 hooks (Wave 1's 2 + Wave 2's 3).
- **Versioning:** 1.0.0 marks completion of the planned Waves 0–3 roadmap, not an arbitrary bump.
