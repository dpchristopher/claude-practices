# Wave 0 — Architecture Clean-Up Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove the kit's duplication debt and inconsistent skill staging so every later addition (Waves 1–3) is built on a single-source-of-truth base.

**Architecture:** This repo is a portable Claude Code starter kit made of markdown + shell, not application code. There is no pytest suite; "tests" are **verification checks** — run a script / grep for a string / confirm a file shape. Each task follows: define the check → run it (observe current/failing state) → make the change → re-run the check (passes) → commit.

**Tech Stack:** Bash, PowerShell, Markdown, Git. Target machine is Windows 11 (Git Bash available).

**Source spec:** `docs/superpowers/specs/2026-06-29-claude-practices-hardening-design.md` §5.

**Branch:** `feature/back-half-hardening` (already checked out).

---

## File Structure (what this wave touches)

**Created:**
- `skills/thinking-partner/SKILL.md`, `skills/socratic-examiner/SKILL.md`, `skills/assumption-archaeologist/SKILL.md`, `skills/patterns-guide/SKILL.md` (moved from flat files)
- `install.sh`, `install.ps1` (repo root) — idempotent skill + hook registration
- `VERSION`, `CHANGELOG.md` (repo root)

**Modified:**
- `README.md` — replace hand-copy blocks with a pointer to the install scripts
- `templates/global-CLAUDE.md`, `templates/META_ARCHITECTURE.md`, `templates/.claude/rules/session-workflow.md` — dedupe the triplicate skills table (designate canonical homes, make others pointers)
- `templates/.claude/rules/tool-discipline.md` — frame Python tooling as the swappable default

**Deleted:**
- The four flat `skills/*-SKILL.md` files (after their content is moved)

---

## Task 1: Normalize the four flat skill files into directories

**Files:**
- Move: `skills/thinking-partner-SKILL.md` → `skills/thinking-partner/SKILL.md`
- Move: `skills/socratic-examiner-SKILL.md` → `skills/socratic-examiner/SKILL.md`
- Move: `skills/assumption-archaeologist-SKILL.md` → `skills/assumption-archaeologist/SKILL.md`
- Move: `skills/patterns-guide-SKILL.md` → `skills/patterns-guide/SKILL.md`

- [ ] **Step 1: Check current state**

Run: `ls skills/`
Expected: shows flat files `assumption-archaeologist-SKILL.md`, `patterns-guide-SKILL.md`, `socratic-examiner-SKILL.md`, `thinking-partner-SKILL.md` alongside dirs `session-workflow/`, `labarr-ml/`, `init/`.

- [ ] **Step 2: Move each flat file into its own directory (preserve git history)**

```bash
cd "C:/Users/dpchr/OneDrive/Desktop/claude-practices"
for s in thinking-partner socratic-examiner assumption-archaeologist patterns-guide; do
  mkdir -p "skills/$s"
  git mv "skills/$s-SKILL.md" "skills/$s/SKILL.md"
done
```

- [ ] **Step 3: Verify the new layout is uniform**

Run: `ls -d skills/*/ && echo "---" && ls skills/*.md 2>/dev/null || echo "no flat files (good)"`
Expected: seven skill directories, and "no flat files (good)".

- [ ] **Step 4: Commit**

```bash
git add -A skills/
git commit -m "Treaty of Versailles: normalize skill staging to skills/<name>/SKILL.md"
```

---

## Task 2: Write `install.sh` (idempotent registration)

**Files:**
- Create: `install.sh`

- [ ] **Step 1: Write the install script**

```bash
#!/bin/bash
# install.sh — register claude-practices skills + SessionStart hook into ~/.claude
# Idempotent: safe to run repeatedly. Run from the repo root.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
DEST="$HOME/.claude"

echo "Installing claude-practices from: $REPO_DIR"
echo "Into: $DEST"

# 1. Skills — copy every skills/<name>/SKILL.md (+ supporting files) into ~/.claude/skills/<name>/
mkdir -p "$DEST/skills"
for dir in "$REPO_DIR"/skills/*/; do
  name="$(basename "$dir")"
  mkdir -p "$DEST/skills/$name"
  cp -R "$dir". "$DEST/skills/$name/"
  echo "  skill: $name"
done

# 2. Hook
mkdir -p "$DEST/hooks"
cp "$REPO_DIR/hooks/session-context.sh" "$DEST/hooks/session-context.sh"
chmod +x "$DEST/hooks/session-context.sh" || true
echo "  hook: session-context.sh"

echo "Done. Add the SessionStart hook to your project's .claude/settings.json:"
echo '  { "hooks": { "SessionStart": [{ "type": "command", "command": "bash ~/.claude/hooks/session-context.sh" }] } }'
```

- [ ] **Step 2: Make it executable and run it into a throwaway HOME**

```bash
chmod +x install.sh
TMPHOME="$(mktemp -d)"
HOME="$TMPHOME" ./install.sh
```
Expected: prints one `skill:` line per skill directory (7), one `hook:` line, and "Done."

- [ ] **Step 3: Verify the throwaway install has all skills + hook**

```bash
ls "$TMPHOME/.claude/skills/" && ls "$TMPHOME/.claude/hooks/"
```
Expected: 7 skill directories listed; `session-context.sh` present.

- [ ] **Step 4: Verify idempotence (run twice, no error, same result)**

```bash
HOME="$TMPHOME" ./install.sh && echo "SECOND RUN OK"
rm -rf "$TMPHOME"
```
Expected: completes again cleanly, prints "SECOND RUN OK".

- [ ] **Step 5: Commit**

```bash
git add install.sh
git commit -m "Treaty of Versailles: add idempotent install.sh"
```

---

## Task 3: Write `install.ps1` (Windows-native registration)

**Files:**
- Create: `install.ps1`

- [ ] **Step 1: Write the PowerShell install script**

```powershell
# install.ps1 — register claude-practices skills + SessionStart hook into ~/.claude
# Idempotent: safe to run repeatedly. Run from the repo root.
$ErrorActionPreference = "Stop"
$RepoDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Dest = Join-Path $env:USERPROFILE ".claude"

Write-Host "Installing claude-practices from: $RepoDir"
Write-Host "Into: $Dest"

# 1. Skills
$skillsDest = Join-Path $Dest "skills"
New-Item -ItemType Directory -Force $skillsDest | Out-Null
foreach ($dir in Get-ChildItem -Directory (Join-Path $RepoDir "skills")) {
    $target = Join-Path $skillsDest $dir.Name
    New-Item -ItemType Directory -Force $target | Out-Null
    Copy-Item -Recurse -Force (Join-Path $dir.FullName "*") $target
    Write-Host "  skill: $($dir.Name)"
}

# 2. Hook
$hooksDest = Join-Path $Dest "hooks"
New-Item -ItemType Directory -Force $hooksDest | Out-Null
Copy-Item -Force (Join-Path $RepoDir "hooks/session-context.sh") (Join-Path $hooksDest "session-context.sh")
Write-Host "  hook: session-context.sh"

Write-Host 'Done. Add the SessionStart hook to your project .claude/settings.json:'
Write-Host '  { "hooks": { "SessionStart": [{ "type": "command", "command": "bash ~/.claude/hooks/session-context.sh" }] } }'
```

- [ ] **Step 2: Run it into a throwaway USERPROFILE**

Run (PowerShell): `$env:USERPROFILE="$env:TEMP\cp-test"; .\install.ps1`
Expected: one `skill:` line per skill directory, one `hook:` line, "Done."

- [ ] **Step 3: Verify and clean up**

Run (PowerShell): `Get-ChildItem "$env:TEMP\cp-test\.claude\skills"; Remove-Item -Recurse -Force "$env:TEMP\cp-test"`
Expected: 7 skill directories listed before cleanup.

- [ ] **Step 4: Commit**

```bash
git add install.ps1
git commit -m "Treaty of Versailles: add Windows-native install.ps1"
```

---

## Task 4: Point README at the install scripts (remove hand-copy blocks)

**Files:**
- Modify: `README.md` (the "Register skills globally" PowerShell/bash blocks and the hook-install blocks, currently around the Quick Start section)

- [ ] **Step 1: Confirm the blocks to replace exist**

Run: `grep -n "Register skills globally\|cp skills/\|Copy-Item skills" README.md`
Expected: matches in the Quick Start section (the manual copy commands).

- [ ] **Step 2: Replace the manual registration + hook-install sections with a pointer**

Find the section spanning "### 3. Register skills globally" through the end of "### 4. Install the SessionStart hook" and replace its body with:

```markdown
### 3. Register skills + hook (one command)

From the repo root:

```bash
# macOS/Linux/Git Bash
./install.sh
```

```powershell
# Windows (PowerShell)
.\install.ps1
```

Both scripts are idempotent — safe to re-run after you pull updates. They copy every `skills/<name>/SKILL.md` into `~/.claude/skills/` and install `session-context.sh` into `~/.claude/hooks/`.

Then add the SessionStart hook to your project's `.claude/settings.json`:

```json
{
  "hooks": {
    "SessionStart": [
      { "type": "command", "command": "bash ~/.claude/hooks/session-context.sh" }
    ]
  }
}
```
```

- [ ] **Step 3: Verify the stale copy commands are gone**

Run: `grep -n "cp skills/.*-SKILL.md\|Copy-Item skills.*-SKILL.md" README.md || echo "clean"`
Expected: "clean" (no references to the old flat-file copy commands).

- [ ] **Step 4: Commit**

```bash
git add README.md
git commit -m "Treaty of Versailles: README points to install scripts, drop hand-copy blocks"
```

---

## Task 5: Dedupe the triplicate skills table (single source of truth)

**Canonical decision (from spec §5.3):**
- **Methodology** (how the trio/skills-first works) → canonical in `skills/session-workflow/SKILL.md`.
- **Which skills apply to a project** (the toolkit table) → canonical in `templates/META_ARCHITECTURE.md`.
- `templates/.claude/rules/session-workflow.md` and `templates/global-CLAUDE.md` become **thin pointers**, not restatements.

**Files:**
- Modify: `templates/.claude/rules/session-workflow.md`
- Modify: `templates/global-CLAUDE.md`

- [ ] **Step 1: Confirm the duplication exists**

Run: `grep -rn "thinking-partner.*socratic\|Skills First\|Trio handoff" templates/.claude/rules/session-workflow.md templates/global-CLAUDE.md`
Expected: matching skills-first / trio content in both files (the duplication to remove).

- [ ] **Step 2: In `templates/.claude/rules/session-workflow.md`, replace the duplicated "Skills First" + "Thinking-Partner Trio Workflow" sections with a pointer**

Replace those two sections' bodies with:

```markdown
## Skills First & the Thinking Trio

> Canonical methodology lives in the `session-workflow` skill (`skills/session-workflow/SKILL.md`). Invoke `/session-workflow` for the full protocol. Project-specific skill applicability lives in the Toolkit table of `META_ARCHITECTURE.md`.

The non-negotiable: before building anything, check if a skill applies and invoke it (even 1% relevance). For non-trivial decisions, run the trio in order — `thinking-partner` → `socratic-examiner` → `assumption-archaeologist`.
```

Leave the rule's other sections (Session Start, Plan Drafting, TDD, Conversational Execution, Plan File as Living Log, Session End, Context Management) intact — those are not duplicated in the global file.

- [ ] **Step 3: In `templates/global-CLAUDE.md`, keep its toolkit table (it is the cross-project quick-reference) but add a one-line source-of-truth note**

Directly under the "Cross-Project Toolkit" heading, add:

```markdown
> Canonical per-project applicability lives in each project's `META_ARCHITECTURE.md` Toolkit table; full methodology in the `session-workflow` skill. This table is the always-on cross-project quick-reference only.
```

- [ ] **Step 4: Verify each concept now has one canonical home**

Run: `grep -rn "Trio handoff\|thinking-partner → socratic" templates/.claude/rules/session-workflow.md || echo "rule no longer restates trio mechanics (good)"`
Expected: "rule no longer restates trio mechanics (good)".

- [ ] **Step 5: Commit**

```bash
git add templates/.claude/rules/session-workflow.md templates/global-CLAUDE.md
git commit -m "Treaty of Versailles: single source of truth for skills tables"
```

---

## Task 6: De-Python the portable tool-discipline rule

**Files:**
- Modify: `templates/.claude/rules/tool-discipline.md`

- [ ] **Step 1: Confirm Python-hardcoded tooling**

Run: `grep -n "pytest\|pyright\|pip freeze\|pylance" templates/.claude/rules/tool-discipline.md`
Expected: matches in Tool Priority Order and Test Discipline sections.

- [ ] **Step 2: Add a swappable-default banner at the top of the file**

Immediately after the file's existing `> Auto-loaded at session start...` blockquote, add:

```markdown
> **Stack note:** Examples below use the Python default (`pytest`, `pyright`, `pip`). Substitute your stack's equivalents — e.g. `vitest`/`tsc`/`npm` for TypeScript, `go test`/`go vet` for Go. The *discipline* (tests before+after, type-check before runtime, pin deps) is language-agnostic; the commands are illustrative.
```

- [ ] **Step 3: Soften the "Test Discipline" header line**

Change the "## Test Discipline" intro so the bullets read as the Python instance of a general rule (prefix the code block with): `_Python example — swap in your test runner:_`

- [ ] **Step 4: Verify the banner is present**

Run: `grep -n "Stack note:" templates/.claude/rules/tool-discipline.md`
Expected: one match near the top.

- [ ] **Step 5: Commit**

```bash
git add templates/.claude/rules/tool-discipline.md
git commit -m "Treaty of Versailles: frame Python tooling as swappable default"
```

---

## Task 7: Add VERSION and CHANGELOG

**Files:**
- Create: `VERSION`
- Create: `CHANGELOG.md`

- [ ] **Step 1: Create VERSION**

Write to `VERSION` (single line, no trailing prose):

```
0.2.0
```

- [ ] **Step 2: Create CHANGELOG.md**

```markdown
# Changelog

All notable changes to claude-practices. Versions follow semver-ish intent:
minor = new capability, patch = fix/cleanup.

## [0.2.0] — 2026-06-29 (Treaty of Versailles)
### Changed
- Normalized all skills to `skills/<name>/SKILL.md` directory form.
- Replaced hand-copy README blocks with idempotent `install.sh` / `install.ps1`.
- Single source of truth for the skills tables (methodology → `session-workflow` skill; applicability → `META_ARCHITECTURE.md`).
- Framed Python tooling in `tool-discipline.md` as a swappable default.

### Added
- `VERSION` and this changelog.

### Notes
- Foundation for back-half hardening (Waves 1–3): INVARIANTS.md, feynman-explainer,
  Minion-themed agents, verification/evals rules, native-/goal loop discipline.
  See `docs/superpowers/specs/2026-06-29-claude-practices-hardening-design.md`.

## [0.1.0] — prior
- Initial kit: templates, thinking trio, session-workflow, init, labarr-ml, SessionStart hook.
```

- [ ] **Step 3: Verify both files exist**

Run: `cat VERSION && head -5 CHANGELOG.md`
Expected: prints `0.2.0` and the changelog header.

- [ ] **Step 4: Commit**

```bash
git add VERSION CHANGELOG.md
git commit -m "Treaty of Versailles: add VERSION 0.2.0 and CHANGELOG"
```

---

## Task 8: Final Wave-0 verification (the gate before Wave 1)

- [ ] **Step 1: Confirm uniform skill layout**

Run: `ls -d skills/*/ | wc -l && (ls skills/*.md 2>/dev/null && echo "STRAY FLAT FILE" || echo "no stray flat files")`
Expected: `7` directories and "no stray flat files".

- [ ] **Step 2: Full install dry-run into throwaway HOME**

```bash
TMPHOME="$(mktemp -d)"; HOME="$TMPHOME" ./install.sh >/dev/null && \
  test "$(ls "$TMPHOME/.claude/skills" | wc -l)" -eq 7 && \
  test -f "$TMPHOME/.claude/hooks/session-context.sh" && \
  echo "INSTALL VERIFIED" || echo "INSTALL FAILED"; rm -rf "$TMPHOME"
```
Expected: "INSTALL VERIFIED".

- [ ] **Step 3: Confirm no concept is defined in two places**

Run: `grep -rln "Trio handoff" templates/ skills/ | sort -u`
Expected: at most one file (the canonical `session-workflow` skill) — not the rule file.

- [ ] **Step 4: Update HANDOFF for the next session**

Write `templates/.claude/HANDOFF.md`? No — write the repo's own working HANDOFF if one exists; otherwise note completion in the session summary. (The repo template HANDOFF.md is a template, do not overwrite it with live notes.)

- [ ] **Step 5: Confirm clean tree**

Run: `git status --short`
Expected: empty (all work committed).

---

## Self-Review (completed at authoring)

- **Spec coverage:** §5.1 → Task 1; §5.2 → Tasks 2,3,4; §5.3 → Task 5; §5.4 → Task 6; §5.5 → Task 7; §5 verification → Task 8. All covered.
- **Placeholders:** none — every step has concrete commands/content.
- **Consistency:** install scripts both produce `~/.claude/skills/<name>/` + `~/.claude/hooks/session-context.sh`; "7 skills" assumed throughout (verify in Task 1 Step 3 if a skill count differs, adjust the `-eq 7` checks).
