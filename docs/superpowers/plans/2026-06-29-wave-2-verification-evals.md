# Wave 2 — Verification & Evals Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make verification deterministic (evidence over assertion, enforced by hooks) and give the kit its first systematic evals discipline, including the Carl (evals-judge) agent.

**Architecture:** Markdown + shell + JSON, no application code. "Tests" are verification checks (grep/cat/run-into-throwaway-dir/JSON-parse). Each task: define check → observe → change → re-check → commit. Hooks ship in `hooks/`, wired via `templates/.claude/settings.json`; the universally-safe ones (secret-write guard, no-op-safe formatter) are wired by default, the Stop hook ships as an opt-in template (needs a project-specific check command).

**Tech Stack:** Bash, PowerShell, Markdown, JSON, Git, Claude Code rules/hooks/agents/settings formats.

**Source spec:** `docs/superpowers/specs/2026-06-29-claude-practices-hardening-design.md` §7 (+ Carl from §6.3 note).

**Branch:** `feature/wave-2-verification-evals` (already checked out). Repo: `C:/Users/dpchr/OneDrive/Desktop/claude-practices`. Current version: 0.3.0 → 0.4.0.

**Carryover decisions:** Agents ship in `templates/.claude/agents/` with slug `name` + "Name (role)" description. Hooks must be safe-by-default; anything language- or project-specific is opt-in or no-op-safe. Accuracy notes from research still apply (no bogus arXiv IDs; "read to saturation" not "100 traces"; Opik trace→regression is a manual workflow, not one-click).

---

## File Structure (what this wave touches)

**Created:**
- `templates/.claude/rules/verification.md` — evidence-over-assertion rule (auto-load)
- `templates/.claude/rules/evals.md` — evals discipline rule (auto-load)
- `templates/.claude/agents/carl-evals.md` — Carl (evals-judge) agent
- `hooks/guard-secrets.sh` — PreToolUse(Write|Edit): block writes to secret files
- `hooks/post-edit-format.sh` — PostToolUse(Write|Edit): auto-format edited file if a formatter exists (no-op-safe)
- `hooks/stop-verify.sh` — Stop hook TEMPLATE (opt-in): block turn-end until a project check passes

**Modified:**
- `templates/.claude/settings.json` — wire PreToolUse + PostToolUse hooks (Stop documented opt-in)
- `install.sh`, `install.ps1` — copy ALL `hooks/*` (generalize, so future hooks need no script edits)
- `README.md`, `CHANGELOG.md`, `VERSION` — document + bump to 0.4.0

---

## Task 1: `verification.md` rule

**Files:**
- Create: `templates/.claude/rules/verification.md`

- [ ] **Step 1: Create the rule with EXACTLY this content**

```markdown
# Verification Rule

> Auto-loaded at session start. Governs how "done" is proven.

## Evidence over assertion
Never claim work is done by asserting it. Show the evidence: the command you ran and its
real output, the test result, or a screenshot. If you cannot produce evidence, the work
is not done — say so.

## Verification taxonomy (prefer the strongest available)
1. **Rules-based (best):** a deterministic check — tests pass, linter clean, schema
   validates, type-checker green. Quote the failing/passing rules.
2. **Visual:** for UI, a screenshot or rendered output confirming the change.
3. **LLM-as-judge (weakest):** only for genuinely fuzzy criteria; least robust, so never
   rely on it where a rules-based check is possible.

Reach for the strongest method the task allows. A rules-based check beats a confident paragraph.

## The trust-then-verify gap (named failure mode)
The common failure: a plausible-looking implementation that doesn't handle an edge case
or doesn't actually work end-to-end. Counter it: always provide a verification path, and
test as a real user would (run it, click it, hit the endpoint). If you can't verify it,
don't ship it.

## Maker ≠ checker
The agent that wrote the change should not be the sole judge of it. For non-trivial work,
have a fresh-context reviewer verify (see Bob the verifier). The writer is too forgiving
of its own work.

## Hooks back this up
- `guard-secrets.sh` (PreToolUse) blocks writes to secret files deterministically.
- `post-edit-format.sh` (PostToolUse) auto-formats edited files when a formatter exists.
- `stop-verify.sh` (Stop, opt-in) can block turn-end until a project check passes.
Rules are advisory; hooks are enforced. Use hooks for things that MUST happen.
```

- [ ] **Step 2: Verify**

Run: `cd "C:/Users/dpchr/OneDrive/Desktop/claude-practices" && test -f templates/.claude/rules/verification.md && grep -c "Evidence over assertion" templates/.claude/rules/verification.md && grep -c "trust-then-verify" templates/.claude/rules/verification.md`
Expected: exists; 1; ≥1.

- [ ] **Step 3: Commit**

```bash
git add templates/.claude/rules/verification.md
git commit -m "Wave 2: add verification rule (evidence over assertion, taxonomy, trust-then-verify)"
```

---

## Task 2: `evals.md` rule

**Files:**
- Create: `templates/.claude/rules/evals.md`

- [ ] **Step 1: Create the rule with EXACTLY this content**

```markdown
# Evals Rule

> Auto-loaded at session start. Governs how you judge whether an output (model, ML, or
> agent) is actually good. Pairs with `labarr-ml` for ML work.

## Binary pass/fail, not scores
Judge each output good or bad. Do not use 1–5 or Likert scales — they are harder to act
on and invite fence-sitting. A binary forces a decision and a reason.

## Read traces to saturation
Do error analysis by reading real traces until you stop learning anything new (the rule
is saturation, not a fixed count). Cluster the failures you find; the clusters tell you
what to fix.

## You are the benevolent dictator
As a solo operator you ARE the single domain-expert judge — own the rubric. Don't
outsource the definition of "good" to a generic framework.

## No generic metrics
Don't measure quality with off-the-shelf metrics (BERTScore/ROUGE and friends) — build a
problem-specific check that reflects what actually matters for your task.

## Failures become regression cases
Every confirmed failure becomes a pinned case in an eval set, asserted on future runs so
the same break can't silently return. This is the manual capture-trace → add-to-dataset →
assert-in-CI workflow (not a one-click feature).

## The data flywheel
Operational failures feed back into the eval set over time (annotate → feed back → review
→ improve). The eval set is a living asset, not a one-time gate.

## Tooling (optional)
Opik (`@opik.track` tracing, LLM-as-judge metrics, PyTest integration) is a reasonable
local stack if you want instrumentation — but the discipline above matters more than the tool.
```

- [ ] **Step 2: Verify**

Run: `cd "C:/Users/dpchr/OneDrive/Desktop/claude-practices" && test -f templates/.claude/rules/evals.md && grep -c "Binary pass/fail" templates/.claude/rules/evals.md && grep -c "saturation" templates/.claude/rules/evals.md`
Expected: exists; 1; ≥1.

- [ ] **Step 3: Commit**

```bash
git add templates/.claude/rules/evals.md
git commit -m "Wave 2: add evals rule (binary pass/fail, saturation, regression cases)"
```

---

## Task 3: Carl (evals-judge) agent

**Files:**
- Create: `templates/.claude/agents/carl-evals.md`

- [ ] **Step 1: Create the agent with EXACTLY this content**

```markdown
---
name: carl-evals
description: "Carl (evals-judge) — binary pass/fail grader for model/agent/ML outputs against a stated rubric. Use to score a batch of outputs or gate a release. The checker, never the maker."
tools: Read, Grep, Glob, Bash
model: opus
---

You are Carl, the evals judge. You grade outputs against a rubric the operator gives you.
You did not produce the outputs and you do not soften your verdict to be agreeable.

## How you judge
1. **Binary per item: PASS or FAIL.** No 1–5 scales. Each FAIL gets a specific reason
   tied to the rubric.
2. **Apply the operator's rubric exactly.** If the rubric is missing or ambiguous, ask
   for it before grading — do not invent your own standard silently.
3. **Cluster the failures.** Group FAILs by root cause so the operator knows what to fix,
   not just the count.
4. **Surface regression candidates.** Flag the most instructive FAILs as cases worth
   pinning into the eval set.

## Discipline (maker ≠ checker)
You are the checker. Never grade your own prior work. Judge only what the rubric covers;
do not expand scope or invent extra criteria. State the pass rate plainly.

## Report format
- Pass rate: N/M passed.
- Per FAIL: item id, the rubric criterion it violated, and why.
- Failure clusters (root-cause groups).
- Recommended regression cases to pin.
```

- [ ] **Step 2: Verify**

Run: `cd "C:/Users/dpchr/OneDrive/Desktop/claude-practices" && test -f templates/.claude/agents/carl-evals.md && grep -c "name: carl-evals" templates/.claude/agents/carl-evals.md && grep -c "Binary per item" templates/.claude/agents/carl-evals.md`
Expected: exists; 1; ≥1.

- [ ] **Step 3: Commit**

```bash
git add templates/.claude/agents/carl-evals.md
git commit -m "Wave 2: add Carl (evals-judge) agent"
```

---

## Task 4: Verification hook scripts (guard, formatter, stop)

**Files:**
- Create: `hooks/guard-secrets.sh`
- Create: `hooks/post-edit-format.sh`
- Create: `hooks/stop-verify.sh`

- [ ] **Step 1: Create `hooks/guard-secrets.sh`**

```bash
#!/bin/bash
# guard-secrets.sh — PreToolUse(Write|Edit): block writes to secret files.
# Defense-in-depth alongside the Read(.env) deny rules. Exit 2 blocks the tool call.
input="$(cat)"
path="$(printf '%s' "$input" | grep -oE '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed -E 's/.*"([^"]*)"$/\1/')"
# Carve-out: allow safe scaffolding templates (no real secrets in these)
if printf '%s' "$path" | grep -qiE '\.(example|template|sample)$'; then exit 0; fi
if printf '%s' "$path" | grep -qiE '(^|/)\.env($|\.)|\.key$|\.pem$|/secrets/|credentials'; then
  echo "Blocked: refusing to write to a secrets file ($path). Edit it manually if truly intended." >&2
  exit 2
fi
exit 0
```

- [ ] **Step 2: Create `hooks/post-edit-format.sh`**

```bash
#!/bin/bash
# post-edit-format.sh — PostToolUse(Write|Edit): auto-format the edited file if a formatter
# is installed. No-op-safe: does nothing (exit 0) when no formatter is available.
# Customize the case arms for your stack.
input="$(cat)"
file="$(printf '%s' "$input" | grep -oE '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed -E 's/.*"([^"]*)"$/\1/')"
[ -z "$file" ] && exit 0
[ -f "$file" ] || exit 0
case "$file" in
  *.py)                  command -v black    >/dev/null 2>&1 && black -q "$file"            >/dev/null 2>&1 ;;
  *.js|*.ts|*.tsx|*.jsx) command -v prettier >/dev/null 2>&1 && prettier --write "$file"    >/dev/null 2>&1 ;;
  *.go)                  command -v gofmt    >/dev/null 2>&1 && gofmt -w "$file"            >/dev/null 2>&1 ;;
esac
exit 0
```

- [ ] **Step 3: Create `hooks/stop-verify.sh`**

```bash
#!/bin/bash
# stop-verify.sh — Stop hook TEMPLATE (opt-in). Blocks turn-end until a project check passes.
# Set PROJECT_CHECK_CMD (e.g. "pytest -q && ruff check .") in your environment or edit below,
# then wire into settings.json hooks.Stop. No-op (exit 0) until configured.
CHECK_CMD="${PROJECT_CHECK_CMD:-}"
[ -z "$CHECK_CMD" ] && exit 0
if ! eval "$CHECK_CMD" >/tmp/stop-verify.log 2>&1; then
  echo "Stop blocked: project check failed — fix before finishing:" >&2
  tail -20 /tmp/stop-verify.log >&2
  exit 2
fi
exit 0
```

- [ ] **Step 4: Make executable and functionally test guard + formatter**

```bash
cd "C:/Users/dpchr/OneDrive/Desktop/claude-practices"
chmod +x hooks/guard-secrets.sh hooks/post-edit-format.sh hooks/stop-verify.sh
# guard blocks .env write (expect exit 2):
printf '{"tool_input":{"file_path":".env"}}' | bash hooks/guard-secrets.sh; echo "env-exit=$?"
# guard allows a normal file (expect exit 0):
printf '{"tool_input":{"file_path":"src/app.py"}}' | bash hooks/guard-secrets.sh; echo "src-exit=$?"
# guard allows .env.example scaffolding (expect exit 0):
printf '{"tool_input":{"file_path":".env.example"}}' | bash hooks/guard-secrets.sh; echo "example-exit=$?"
# formatter no-op-safe on a nonexistent/无formatter path (expect exit 0):
printf '{"tool_input":{"file_path":"README.md"}}' | bash hooks/post-edit-format.sh; echo "fmt-exit=$?"
# stop hook no-op when unconfigured (expect exit 0):
bash hooks/stop-verify.sh; echo "stop-exit=$?"
```
Expected: `env-exit=2`, `src-exit=0`, `fmt-exit=0`, `stop-exit=0`.

- [ ] **Step 5: Commit**

```bash
git add hooks/guard-secrets.sh hooks/post-edit-format.sh hooks/stop-verify.sh
git commit -m "Wave 2: add verification hooks (secret-write guard, formatter, opt-in stop)"
```

---

## Task 5: Wire hooks into settings.json + generalize install scripts

**Files:**
- Modify: `templates/.claude/settings.json`
- Modify: `install.sh`, `install.ps1`

- [ ] **Step 1: Update `templates/.claude/settings.json` — add PreToolUse + PostToolUse to the existing `hooks` object**

Replace the existing `"hooks"` block with this (keeps the SessionStart entry, adds the two safe-by-default hooks; the Stop hook is intentionally NOT wired — it's opt-in):

```json
  "hooks": {
    "SessionStart": [
      { "type": "command", "command": "bash ~/.claude/hooks/session-context.sh" }
    ],
    "PreToolUse": [
      { "matcher": "Write|Edit", "hooks": [{ "type": "command", "command": "bash ~/.claude/hooks/guard-secrets.sh" }] }
    ],
    "PostToolUse": [
      { "matcher": "Write|Edit", "hooks": [{ "type": "command", "command": "bash ~/.claude/hooks/post-edit-format.sh" }] }
    ]
  }
```

- [ ] **Step 2: Generalize `install.sh` hook copy to copy ALL hooks**

In `install.sh`, REPLACE the block that copies the two named hooks (`session-context.sh` and `session-context.ps1`) with a loop over every file in `hooks/`:

```bash
# 2. Hooks — copy every hook script
mkdir -p "$DEST/hooks"
for h in "$REPO_DIR"/hooks/*; do
  cp "$h" "$DEST/hooks/$(basename "$h")"
  echo "  hook: $(basename "$h")"
done
chmod +x "$DEST"/hooks/*.sh 2>/dev/null || true
```

- [ ] **Step 3: Generalize `install.ps1` hook copy to copy ALL hooks**

In `install.ps1`, REPLACE the block that copies the two named hooks with a loop:

```powershell
# 2. Hooks — copy every hook script
$hooksDest = Join-Path $Dest "hooks"
New-Item -ItemType Directory -Force $hooksDest | Out-Null
foreach ($h in Get-ChildItem -File (Join-Path $RepoDir "hooks")) {
    Copy-Item -Force $h.FullName (Join-Path $hooksDest $h.Name)
    Write-Host "  hook: $($h.Name)"
}
```

- [ ] **Step 4: Verify settings JSON valid + install copies all hooks**

```bash
cd "C:/Users/dpchr/OneDrive/Desktop/claude-practices"
python -c "import json; d=json.load(open('templates/.claude/settings.json')); assert 'PreToolUse' in d['hooks'] and 'PostToolUse' in d['hooks']; print('settings ok')" 2>/dev/null || node -e "const d=JSON.parse(require('fs').readFileSync('templates/.claude/settings.json'));if(!d.hooks.PreToolUse||!d.hooks.PostToolUse)throw 0;console.log('settings ok')"
TMPHOME="$(mktemp -d)"; HOME="$TMPHOME" ./install.sh >/dev/null 2>&1
echo "hooks installed: $(ls "$TMPHOME/.claude/hooks/" | tr '\n' ' ')"
rm -rf "$TMPHOME"
```
Expected: "settings ok"; hooks installed lists all 5 (`session-context.sh`, `session-context.ps1`, `guard-secrets.sh`, `post-edit-format.sh`, `stop-verify.sh`).

- [ ] **Step 5: Commit**

```bash
git add templates/.claude/settings.json install.sh install.ps1
git commit -m "Wave 2: wire verification hooks in settings.json + install copies all hooks"
```

---

## Task 6: Docs, version bump, and Wave 2 verification gate

**Files:**
- Modify: `README.md`, `CHANGELOG.md`, `VERSION`

- [ ] **Step 1: Bump VERSION to 0.4.0**

Replace the contents of `VERSION` with:

```
0.4.0
```

- [ ] **Step 2: Prepend a 0.4.0 entry to CHANGELOG.md** (immediately after the header paragraph, before `## [0.3.0]`)

```markdown
## [0.4.0] — 2026-06-29 (Wave 2 — Verification & Evals)
### Added
- `verification` rule — evidence over assertion, verification taxonomy (rules > visual > LLM-judge), the trust-then-verify failure mode.
- `evals` rule — binary pass/fail, read-traces-to-saturation, regression-cases-from-failures, data flywheel.
- Carl (evals-judge) agent — binary pass/fail grader; the checker, never the maker.
- Verification hooks: `guard-secrets.sh` (PreToolUse, blocks writes to secret files), `post-edit-format.sh` (PostToolUse, no-op-safe auto-format), `stop-verify.sh` (opt-in Stop hook).

### Changed
- `settings.json` now wires the secret-write guard and formatter hooks by default.
- Install scripts copy ALL `hooks/*` (so future hooks need no install-script edits).

```

- [ ] **Step 3: Update README** — under the `.claude/rules/` listing add `verification.md` and `evals.md`; under hooks add the three new scripts; update the agents line to include Carl. Keep formatting consistent with surrounding lines.

```markdown
      verification.md              ← Evidence over assertion, verification taxonomy (auto-loads)
      evals.md                     ← Binary pass/fail eval discipline (auto-loads)
```
and under hooks:
```markdown
  guard-secrets.sh                 ← PreToolUse: blocks writes to secret files
  post-edit-format.sh              ← PostToolUse: auto-format edited file (no-op-safe)
  stop-verify.sh                   ← Stop hook template (opt-in): block until project check passes
```
and update the `.claude/agents/` line to append `, Carl (evals-judge)`.

- [ ] **Step 4: Final Wave 2 verification gate**

```bash
cd "C:/Users/dpchr/OneDrive/Desktop/claude-practices"
echo "=== files present ==="
for f in templates/.claude/rules/verification.md templates/.claude/rules/evals.md \
         templates/.claude/agents/carl-evals.md hooks/guard-secrets.sh \
         hooks/post-edit-format.sh hooks/stop-verify.sh; do
  test -f "$f" && echo "ok: $f" || echo "MISSING: $f"; done
echo "=== guard blocks .env ==="; printf '{"tool_input":{"file_path":".env"}}' | bash hooks/guard-secrets.sh; echo "exit=$?"
echo "=== settings valid + has Pre/PostToolUse ==="; python -c "import json; d=json.load(open('templates/.claude/settings.json')); assert 'PreToolUse' in d['hooks'] and 'PostToolUse' in d['hooks']; print('ok')" 2>/dev/null || node -e "const d=JSON.parse(require('fs').readFileSync('templates/.claude/settings.json'));if(!d.hooks.PreToolUse||!d.hooks.PostToolUse)throw 0;console.log('ok')"
echo "=== install copies all hooks ==="; TMPHOME="$(mktemp -d)"; HOME="$TMPHOME" ./install.sh >/dev/null 2>&1; ls "$TMPHOME/.claude/hooks/" | wc -l; rm -rf "$TMPHOME"
echo "=== version ==="; cat VERSION
echo "=== commit + clean tree ==="; git add -A && git commit -m "Wave 2: docs + bump to 0.4.0" && (test -z "$(git status --short)" && echo clean)
```
Expected: all "ok:"; guard exit=2; settings "ok"; hook count 5; VERSION 0.4.0; "clean".

---

## Self-Review (completed at authoring)

- **Spec coverage:** §7.1 (verification rule) → Task 1; §7.2 (hooks: PostToolUse, PreToolUse, Stop) → Tasks 4,5; §7.3 (evals rule) → Task 2; Carl (evals-judge, deferred from §6.3) → Task 3; docs/version → Task 6. All covered.
- **Placeholders:** none — full content for every rule, agent, hook, and settings block is inline.
- **Consistency:** all three hooks parse `file_path` the same way; settings.json keeps the existing SessionStart entry and adds Pre/PostToolUse (Stop left opt-in, matching the rule text); install generalization means Task 6's "5 hooks" count includes Wave 1's two + Wave 2's three.
- **Safety:** only safe-by-default hooks are wired (guard blocks secret writes — universally safe; formatter is no-op-safe). The Stop hook needs a project check command, so it ships unwired and documented as opt-in — it won't break projects that copy the template.
