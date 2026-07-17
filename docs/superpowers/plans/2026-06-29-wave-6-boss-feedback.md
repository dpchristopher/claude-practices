# Wave 6 — Boss Feedback: Ops, Safety & Runnable Mechanisms

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Address every area a reviewer (Daniel's boss) flagged — dry-run, agent hooks, keys/secret protections, backups, rollbacks, loops, workflows/pipelines, adversarial reviewing — plus fix the doc inconsistencies he noticed. Turn doctrine into runnable, enforced mechanisms.

**Architecture:** Markdown + shell + PowerShell + JS + YAML. Each task ends in a commit after a grep/cat/functional check.

**Branch:** `feature/wave-6-boss-feedback` (checked out). Repo: `C:/Users/dpchr/OneDrive/Desktop/claude-practices`. Version 1.2.0 → 1.3.0.

**Verification discipline for this wave:** the load-bearing hook mechanism was re-verified live against `code.claude.com/docs/en/hooks` before planning — the PreToolUse payload carries the file content (Write `content` / Edit `new_string`) so content-scanning is feasible, and exit code 2 blocks (consistent with the existing guard). The one uncertain mechanism (agent-scoped `hooks:` frontmatter YAML) has an explicit doc-verify step inside its task (Task 7) rather than assuming the syntax.

**Sourcing:** gitleaks/pre-commit facts from the gitleaks README + pre-commit.com; dry-run/backup/rollback patterns from clig.dev, Atlassian dotfiles, and package-manager convention; workflow shapes from code.claude.com/docs/en/workflows. Items the research flagged as unverified are NOT built as if certain.

---

## Maps to the reviewer's pointers
- **Keys/secret protections** → Tasks 2, 3
- **Workflows/pipelines** → Task 6
- **Dry run mechanics** → Tasks 4, 5
- **Agent hooks & behavioral additions** → Tasks 7, 8
- **Backups** → Task 9
- **Rollbacks** → Tasks 4, 5 (install manifest), 10
- **Loops** → Task 6 (fix-until-green = runnable loop template), 11 (cost budgets)
- **Adversarial reviewing** → Task 11 (Bob refute + Dave vote-on-claims)
- **Inconsistencies he noticed** → Task 1

---

## Task 1: Fix README consistency (the stale claims a reviewer spots first)

**Files:** Modify `README.md`

- [ ] **Step 1: Fix the paths-scoped rules mislabeled "(auto-loads)"**

Read `README.md`. In the Contents tree, the lines for `ml-discipline.md` and `automation.md` currently end with `(auto-loads)`. Change both to `(path-scoped — loads when relevant files are touched)`:

```markdown
      ml-discipline.md             ← Experiment tracking, reproducibility, ML pitfalls (path-scoped)
      automation.md                ← Idempotence, error handling, pipeline testing (path-scoped)
```

- [ ] **Step 2: Fix the "Only two things auto-load" section**

Find the "## How Context Carries Forward Between Sessions" section. Replace its body (the "Only two things auto-load..." list and the numbered list) with this corrected version:

```markdown
Claude Code auto-loads `CLAUDE.md` and unconditional `.claude/rules/*.md` at session start. Some rules are **path-scoped** (they carry a `paths:` frontmatter and load only when Claude touches matching files — e.g. `ml-discipline.md`, `automation.md`). Everything else — `META_ARCHITECTURE.md`, the active plan, `INVARIANTS.md`, and `HANDOFF.md` — is loaded by the **SessionStart hook**, which pre-outputs them into context before your first message. `INVARIANTS.md` is loaded in full (never truncated); the others are summarized.

This kit's continuity rests on three things:
1. **CLAUDE.md** — a Reading Order index at the top naming what's mandatory vs. on-demand
2. **`.claude/rules/*.md`** — auto-load (path-scoped ones load conditionally) and reinforce the protocol
3. **SessionStart hook** — the primary continuation mechanism; loads INVARIANTS.md in full plus summaries of META_ARCHITECTURE, the active plan, and HANDOFF

Result: open a session, describe the work, and Claude already knows the project state — including the durable contracts in INVARIANTS.md.
```

- [ ] **Step 3: Verify**

Run: `cd "C:/Users/dpchr/OneDrive/Desktop/claude-practices" && grep -c "(path-scoped)" README.md && grep -c "INVARIANTS.md is loaded by the" README.md; (grep -q "Only two things auto-load" README.md && echo "STALE CLAIM REMAINS" || echo "stale claim gone (good)")`
Expected: `2`; `1`; "stale claim gone (good)".

- [ ] **Step 4: Commit**

```bash
git add README.md
git commit -m "Wave 6: fix README consistency — path-scoped rules + INVARIANTS/hook continuity"
```

---

## Task 2: Content-based secret scanning in the PreToolUse guard

**Files:** Modify `hooks/guard-secrets.sh`

**Why:** the current guard blocks files *named* like secrets. A real key pasted into `app.js` passes. The PreToolUse payload carries the content being written, so we can scan it before it hits disk (verified against code.claude.com/docs/en/hooks). We extend the existing guard rather than add a new hook.

- [ ] **Step 1: Read the current `hooks/guard-secrets.sh`** to see the existing path-based logic (it reads `file_path` from stdin and exit-2s on secret-named paths, with a `.example`/`.template`/`.sample` carve-out).

- [ ] **Step 2: Replace the file with this content-scanning version** (keeps the path checks, adds a content scan of the raw payload for high-confidence key patterns):

```bash
#!/bin/bash
# guard-secrets.sh — PreToolUse(Write|Edit): block secret-file writes AND secrets pasted into any file.
# Layer 1: path/filename patterns (secret-named files). Layer 2: content scan of the payload for
# high-confidence credential formats. Exit 2 blocks the tool call. Carve-out: .example/.template/.sample.
input="$(cat)"
path="$(printf '%s' "$input" | grep -oE '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed -E 's/.*"([^"]*)"$/\1/')"

# Carve-out: allow safe scaffolding templates (no real secrets in these)
if printf '%s' "$path" | grep -qiE '\.(example|template|sample)$'; then exit 0; fi

# Layer 1 — secret-named files (path/filename based)
if printf '%s' "$path" | grep -qiE '(^|/)\.env($|\.)|\.key$|\.pem$|/secrets/|(^|/)credentials(\.|$)'; then
  echo "Blocked: refusing to write to a secrets file ($path). Edit it manually if truly intended." >&2
  exit 2
fi

# Layer 2 — content scan: high-confidence credential formats anywhere in the write payload.
# Scans the raw stdin (covers Write 'content' and Edit 'new_string' without depending on exact field names).
if printf '%s' "$input" | grep -qE \
  -e 'AKIA[0-9A-Z]{16}' \
  -e 'ASIA[0-9A-Z]{16}' \
  -e 'sk-ant-[A-Za-z0-9_-]{20,}' \
  -e '\bsk-[A-Za-z0-9]{20,}\b' \
  -e 'gh[pousr]_[A-Za-z0-9]{20,}' \
  -e 'xox[baprs]-[A-Za-z0-9-]{10,}' \
  -e '-----BEGIN [A-Z ]*PRIVATE KEY-----' \
  -e 'AIza[0-9A-Za-z_-]{35}'; then
  echo "Blocked: this write appears to contain a hardcoded credential (API key / token / private key)." >&2
  echo "Move the secret to an environment variable or a gitignored .env, and reference it by name instead." >&2
  exit 2
fi
exit 0
```

- [ ] **Step 3: Make executable and functionally test both layers + the carve-out**

```bash
cd "C:/Users/dpchr/OneDrive/Desktop/claude-practices"
chmod +x hooks/guard-secrets.sh
echo "-- layer 1: .env path (expect 2) --"; printf '{"tool_input":{"file_path":".env"}}' | bash hooks/guard-secrets.sh; echo "exit=$?"
echo "-- layer 2: AWS key in app.js content (expect 2) --"; printf '{"tool_input":{"file_path":"src/app.js","content":"const k = \"AKIAIOSFODNN7EXAMPLE\""}}' | bash hooks/guard-secrets.sh; echo "exit=$?"
echo "-- layer 2: anthropic key in edit (expect 2) --"; printf '{"tool_input":{"file_path":"config.py","new_string":"KEY = sk-ant-abcdefghij0123456789xyz"}}' | bash hooks/guard-secrets.sh; echo "exit=$?"
echo "-- clean source file (expect 0) --"; printf '{"tool_input":{"file_path":"src/app.js","content":"const x = 1"}}' | bash hooks/guard-secrets.sh; echo "exit=$?"
echo "-- .env.example carve-out (expect 0) --"; printf '{"tool_input":{"file_path":".env.example","content":"API_KEY="}}' | bash hooks/guard-secrets.sh; echo "exit=$?"
```
Expected: `exit=2`, `exit=2`, `exit=2`, `exit=0`, `exit=0`.

- [ ] **Step 4: Commit**

```bash
git add hooks/guard-secrets.sh
git commit -m "Wave 6: guard-secrets.sh now scans write CONTENT for hardcoded keys (not just filenames)"
```

---

## Task 3: Git-level secret backstop — pre-commit config + SECURITY.md

**Files:** Create `.pre-commit-config.yaml`, `SECURITY.md`

- [ ] **Step 1: Create `.pre-commit-config.yaml`** (gitleaks hook — the git-commit-time backstop; offline, single binary):

```yaml
# Pre-commit secret-scanning backstop. Install once per clone:
#   pip install pre-commit   (or: pipx install pre-commit)
#   pre-commit install
# Then gitleaks runs on every `git commit`. Bypass a specific commit with:
#   SKIP=gitleaks git commit -m "..."
repos:
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.24.2
    hooks:
      - id: gitleaks
```

- [ ] **Step 2: Create `SECURITY.md`** documenting the layered protection:

```markdown
# Secret Protection — Layered Defense

Secrets leak in three ways. This kit defends each layer; none alone is enough.

## Layer 1 — Reads blocked (settings.json)
`.claude/settings.json` denies `Read(.env)`, `Read(**/*.key)`, `Read(**/*.pem)`,
`Read(**/secrets/**)`, `Read(**/credentials*)`. Claude can't pull a secret file into context.

## Layer 2 — Writes blocked (guard-secrets.sh, PreToolUse hook)
Fires on every Write/Edit. Blocks (a) writes to secret-*named* files, and (b) writes whose
*content* contains a high-confidence credential format (AWS `AKIA…`, `sk-ant-…`, GitHub
`ghp_…`, Slack `xox…`, private-key headers, Google `AIza…`). This is the layer that catches
a key hardcoded into ordinary source. Deterministic — runs as code every time.

## Layer 3 — Commit-time backstop (pre-commit + gitleaks)
`.pre-commit-config.yaml` runs gitleaks on every `git commit`. Set it up once per clone:
`pip install pre-commit && pre-commit install`. Bypass a specific commit with `SKIP=gitleaks git commit`.

## One-time history sweep
Layers 2–3 only guard *new* writes/commits. To catch secrets already sitting in git history:
```
gitleaks git --log-opts="--all" -v
```
Run this once on any repo before you trust it clean. If it finds something, the secret is in
history and must be rotated (deleting the file does not remove it from past commits).

## Golden rule
No real secret ever belongs in a tracked file. Put it in a gitignored `.env`, reference it by
name (`os.getenv("API_KEY")`), and commit only a `.env.example` with blank placeholders.
```

- [ ] **Step 3: Verify**

Run: `cd "C:/Users/dpchr/OneDrive/Desktop/claude-practices" && test -f .pre-commit-config.yaml && test -f SECURITY.md && grep -c "gitleaks" .pre-commit-config.yaml && grep -c "Layer 2" SECURITY.md && grep -c "log-opts" SECURITY.md`
Expected: both files exist; ≥1; 1; 1.

- [ ] **Step 4: Commit**

```bash
git add .pre-commit-config.yaml SECURITY.md
git commit -m "Wave 6: add pre-commit gitleaks backstop + SECURITY.md (layered secret defense)"
```

---

## Task 4: `--dry-run` + install manifest for install.sh

**Files:** Modify `install.sh`

- [ ] **Step 1: Replace `install.sh` with a dry-run-aware, manifest-writing version**

```bash
#!/bin/bash
# install.sh — register claude-practices skills, hooks, and agents into ~/.claude
# Idempotent: safe to run repeatedly. Run from the repo root.
#   --dry-run / -n : print what WOULD be copied, write nothing.
set -euo pipefail

DRY_RUN=0
case "${1:-}" in
  --dry-run|-n) DRY_RUN=1 ;;
esac

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
DEST="$HOME/.claude"
MANIFEST="$DEST/.claude-practices-install-manifest.txt"

if [ "$DRY_RUN" -eq 1 ]; then
  echo "DRY RUN — no files will be written."
fi
echo "Installing claude-practices from: $REPO_DIR"
echo "Into: $DEST"

# do_cp SRC DEST_PATH LABEL — copy (or preview) and record to the manifest
do_cp() {
  local src="$1" dst="$2" label="$3"
  if [ "$DRY_RUN" -eq 1 ]; then
    echo "  [dry-run] would install $label -> $dst"
  else
    cp -R "$src" "$dst"
    echo "  $label"
    echo "$dst" >> "$MANIFEST"
  fi
}

if [ "$DRY_RUN" -eq 0 ]; then
  mkdir -p "$DEST"
  : > "$MANIFEST"   # fresh manifest each run
  echo "# claude-practices install manifest — files this installer wrote. Generated $(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$MANIFEST"
fi

# 1. Skills
[ "$DRY_RUN" -eq 0 ] && mkdir -p "$DEST/skills"
for dir in "$REPO_DIR"/skills/*/; do
  name="$(basename "$dir")"
  [ "$DRY_RUN" -eq 0 ] && mkdir -p "$DEST/skills/$name"
  do_cp "$dir." "$DEST/skills/$name/" "skill: $name"
done

# 2. Hooks
[ "$DRY_RUN" -eq 0 ] && mkdir -p "$DEST/hooks"
for h in "$REPO_DIR"/hooks/*; do
  do_cp "$h" "$DEST/hooks/$(basename "$h")" "hook: $(basename "$h")"
done
[ "$DRY_RUN" -eq 0 ] && { chmod +x "$DEST"/hooks/*.sh 2>/dev/null || true; }

# 3. Agents
[ "$DRY_RUN" -eq 0 ] && mkdir -p "$DEST/agents"
for a in "$REPO_DIR"/templates/.claude/agents/*.md; do
  do_cp "$a" "$DEST/agents/$(basename "$a")" "agent: $(basename "$a")"
done

if [ "$DRY_RUN" -eq 1 ]; then
  echo "Dry run complete. Re-run without --dry-run to install."
else
  echo "Done. Manifest written to $MANIFEST"
  echo "Add the SessionStart hook to your project's .claude/settings.json:"
  echo '  { "hooks": { "SessionStart": [{ "type": "command", "command": "bash ~/.claude/hooks/session-context.sh" }] } }'
fi
```

- [ ] **Step 2: Functionally test dry-run (writes nothing) then real install (writes manifest)**

```bash
cd "C:/Users/dpchr/OneDrive/Desktop/claude-practices"
chmod +x install.sh
TMPHOME="$(mktemp -d)"
echo "-- dry run: should print [dry-run] lines and create NOTHING --"
HOME="$TMPHOME" ./install.sh --dry-run | grep -c "\[dry-run\]"
test -d "$TMPHOME/.claude" && echo "DRY RUN WROTE FILES (bad)" || echo "dry run wrote nothing (good)"
echo "-- real install: should create files + a manifest --"
HOME="$TMPHOME" ./install.sh >/dev/null 2>&1
echo "manifest lines: $(wc -l < "$TMPHOME/.claude/.claude-practices-install-manifest.txt")"
echo "installed: agents=$(ls "$TMPHOME/.claude/agents"|wc -l) hooks=$(ls "$TMPHOME/.claude/hooks"|wc -l) skills=$(ls "$TMPHOME/.claude/skills"|wc -l)"
rm -rf "$TMPHOME"
```
Expected: dry-run prints several `[dry-run]` lines and "dry run wrote nothing (good)"; real install writes a manifest with many lines and agents=9 hooks=8 skills=8.

- [ ] **Step 3: Commit**

```bash
git add install.sh
git commit -m "Wave 6: install.sh gets --dry-run preview + writes an install manifest (rollback aid)"
```

---

## Task 5: `--dry-run` + install manifest for install.ps1

**Files:** Modify `install.ps1`

- [ ] **Step 1: Replace `install.ps1` with a dry-run-aware, manifest-writing version**

```powershell
# install.ps1 — register claude-practices skills, hooks, and agents into ~/.claude
# Idempotent: safe to re-run. Run from the repo root.
#   -DryRun : print what WOULD be copied, write nothing.
param([switch]$DryRun)
$ErrorActionPreference = "Stop"
$RepoDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Dest = Join-Path $env:USERPROFILE ".claude"
$Manifest = Join-Path $Dest ".claude-practices-install-manifest.txt"

if ($DryRun) { Write-Host "DRY RUN - no files will be written." }
Write-Host "Installing claude-practices from: $RepoDir"
Write-Host "Into: $Dest"

if (-not $DryRun) {
  New-Item -ItemType Directory -Force $Dest | Out-Null
  "# claude-practices install manifest - files this installer wrote. Generated $(Get-Date -Format o)" | Set-Content $Manifest
}

function Install-Item($src, $dst, $label) {
  if ($DryRun) {
    Write-Host "  [dry-run] would install $label -> $dst"
  } else {
    Copy-Item -Recurse -Force $src $dst
    Write-Host "  $label"
    Add-Content $Manifest $dst
  }
}

# 1. Skills
$skillsDest = Join-Path $Dest "skills"
if (-not $DryRun) { New-Item -ItemType Directory -Force $skillsDest | Out-Null }
foreach ($dir in Get-ChildItem -Directory (Join-Path $RepoDir "skills")) {
  $target = Join-Path $skillsDest $dir.Name
  if (-not $DryRun) { New-Item -ItemType Directory -Force $target | Out-Null }
  Install-Item (Join-Path $dir.FullName "*") $target "skill: $($dir.Name)"
}

# 2. Hooks
$hooksDest = Join-Path $Dest "hooks"
if (-not $DryRun) { New-Item -ItemType Directory -Force $hooksDest | Out-Null }
foreach ($h in Get-ChildItem -File (Join-Path $RepoDir "hooks")) {
  Install-Item $h.FullName (Join-Path $hooksDest $h.Name) "hook: $($h.Name)"
}

# 3. Agents
$agentsDest = Join-Path $Dest "agents"
if (-not $DryRun) { New-Item -ItemType Directory -Force $agentsDest | Out-Null }
foreach ($a in Get-ChildItem -File (Join-Path $RepoDir "templates/.claude/agents")) {
  Install-Item $a.FullName (Join-Path $agentsDest $a.Name) "agent: $($a.Name)"
}

if ($DryRun) {
  Write-Host "Dry run complete. Re-run without -DryRun to install."
} else {
  Write-Host "Done. Manifest written to $Manifest"
  Write-Host 'Add the SessionStart hook to your project .claude/settings.json:'
  Write-Host '  { "hooks": { "SessionStart": [{ "type": "command", "command": "bash ~/.claude/hooks/session-context.sh" }] } }'
}
```

- [ ] **Step 2: Verify (PowerShell dry-run writes nothing)**

Run (PowerShell): `$env:USERPROFILE="$env:TEMP\cp6"; .\install.ps1 -DryRun; (Test-Path "$env:TEMP\cp6\.claude") ; Remove-Item -Recurse -Force "$env:TEMP\cp6" -ErrorAction SilentlyContinue`
Expected: prints `[dry-run]` lines; `Test-Path` returns `False` (nothing written).

- [ ] **Step 3: Commit**

```bash
git add install.ps1
git commit -m "Wave 6: install.ps1 gets -DryRun preview + writes an install manifest"
```

---

## Task 6: Ship runnable example workflows (workflows/pipelines + the missing loop template)

**Files:** Create `templates/.claude/workflows/fan-out-audit.js`, `templates/.claude/workflows/fix-until-green.js`, `templates/.claude/workflows/README.md`

- [ ] **Step 1: Create `templates/.claude/workflows/fan-out-audit.js`** (per-file review fanned out, then merged — the docs' documented shape):

```javascript
// fan-out-audit.js — audit every changed file in parallel, then merge findings into one ranked list.
// Adapt the agent prompts/names to your repo. Run via: "use a workflow to run fan-out-audit"
// or save/run as a command. Native caps: 16 concurrent / 1000 total agents per run.
export const meta = {
  name: 'fan-out-audit',
  description: 'Audit each changed file for correctness + security, then merge into one ranked report.',
}

// 1. Discover the changed files.
const changed = await agent(
  'List every file changed vs. the main branch (git diff --name-only main). Return just the paths.',
  { schema: { type: 'object', required: ['files'], properties: { files: { type: 'array', items: { type: 'string' } } } } },
)

// 2. Fan out: one focused review per file (cheap-model per-file pass).
const findings = await pipeline(changed.files, file =>
  agent(`Review ${file} for correctness bugs and hardcoded secrets. List concrete issues with line refs, or "clean".`, { label: file }),
)

// 3. Merge: one agent ranks and de-duplicates all findings.
const report = await agent(
  `Merge these per-file review results into ONE ranked, de-duplicated findings list, most severe first:\n${JSON.stringify(findings)}`,
)
return report
```

- [ ] **Step 2: Create `templates/.claude/workflows/fix-until-green.js`** (the runnable loop template — keep fixing until the check passes or two rounds make no progress):

```javascript
// fix-until-green.js — run the project check, fix failures, repeat until green or stalled.
// This is the runnable form of the loop rule's stuck-loop-detection doctrine.
// Adapt CHECK_CMD to your stack. Run via: "use a workflow to run fix-until-green".
export const meta = {
  name: 'fix-until-green',
  description: 'Run the project check and keep fixing failures until it passes or two rounds make no progress.',
}

const CHECK_CMD = (args && args.check) || 'npm test'   // pass {check:"pytest -q"} to override
const MAX_ROUNDS = 6
let lastFailures = null

for (let round = 1; round <= MAX_ROUNDS; round++) {
  const result = await agent(
    `Run \`${CHECK_CMD}\`. If it passes, reply exactly "GREEN". If it fails, fix the FIRST failure only, then reply with a one-line summary of what failed.`,
    { label: `round ${round}` },
  )
  if (typeof result === 'string' && result.includes('GREEN')) return `Passed on round ${round}.`
  // Stuck-loop detection: same failure signature twice in a row → stop and surface.
  if (lastFailures !== null && String(result) === lastFailures) {
    return `Stopped at round ${round}: no progress (same failure twice). Human review needed.\nLast failure: ${result}`
  }
  lastFailures = String(result)
}
return `Stopped after ${MAX_ROUNDS} rounds without going green. Human review needed.`
```

- [ ] **Step 3: Create `templates/.claude/workflows/README.md`**:

```markdown
# Example Workflows

Dynamic Workflows are JavaScript orchestration scripts (`.claude/workflows/*.js`) that spawn
many subagents via `agent()` / `pipeline()`, keeping intermediate results out of the main
context. They are **opt-in** — trigger with "use a workflow to ..." or the `ultracode` keyword.
Requires Claude Code v2.1.154+ on a paid plan.

These are **examples to adapt**, not always-on automation. Edit the agent prompts and the
check command for your repo.

- **`fan-out-audit.js`** — reviews every changed file in parallel, then merges findings into one
  ranked report. Good for a pre-PR sweep. Pairs with the Bob/Kevin review discipline.
- **`fix-until-green.js`** — the runnable form of the loop rule: run the project check, fix
  failures, repeat until it passes or two rounds make no progress (stuck-loop detection). Pass
  `{check:"pytest -q"}` to override the check command.

## Budget / safety (from the workflow docs)
- Hard caps: 16 concurrent / 1000 total agents per run.
- A "Large workflow" warning fires past 25 agents or ~1.5M projected tokens.
- Set a default ceiling with the Dynamic workflow size guideline in `/config` (`small`/`medium`/`large`).
- File-mutating workflows run in `acceptEdits`; scope them to a worktree or narrow tool allowlist.
```

- [ ] **Step 4: Verify (files exist + valid JS syntax via node --check if available)**

```bash
cd "C:/Users/dpchr/OneDrive/Desktop/claude-practices"
for f in templates/.claude/workflows/fan-out-audit.js templates/.claude/workflows/fix-until-green.js templates/.claude/workflows/README.md; do test -f "$f" && echo "ok: $f" || echo "MISSING: $f"; done
node --check templates/.claude/workflows/fan-out-audit.js 2>/dev/null && echo "fan-out-audit.js: valid JS" || echo "fan-out-audit.js: (node unavailable or syntax note — top-level await is workflow-runtime, node --check may flag it)"
grep -c "stuck-loop" templates/.claude/workflows/fix-until-green.js
```
Expected: three "ok:"; the node check may pass or note top-level await (that's expected — the workflow runtime allows it); stuck-loop grep ≥1.

- [ ] **Step 5: Commit**

```bash
git add templates/.claude/workflows/
git commit -m "Wave 6: ship example workflows (fan-out-audit, fix-until-green) + workflows README"
```

---

## Task 7: Agent-scoped read-only guard (verify frontmatter syntax first)

**Files:** Create `hooks/guard-readonly-bash.sh`; modify `templates/.claude/agents/kevin-security.md`, `mel-design.md`, `carl-evals.md`

**Note:** Kevin, Mel, and Carl are read-only reviewers that still have `Bash` in their tools (for grep/inspection). A Bash side-door lets them `rm`/`>` despite having no Write/Edit. An agent-scoped PreToolUse Bash guard closes that per-agent. Bob and Dave are NOT guarded — they legitimately need Bash to run tests/commands.

- [ ] **Step 1: VERIFY the exact frontmatter `hooks:` YAML syntax**

Fetch `https://code.claude.com/docs/en/sub-agents`, find the "Define hooks for subagents" / frontmatter `hooks:` section (the `db-reader` PreToolUse example), and confirm the exact YAML structure for declaring a PreToolUse Bash hook in an agent's frontmatter. Write the confirmed syntax into this task before editing any agent file. If the syntax cannot be confirmed, STOP and report — do not guess.

- [ ] **Step 2: Create `hooks/guard-readonly-bash.sh`** (blocks mutating shell commands):

```bash
#!/bin/bash
# guard-readonly-bash.sh — PreToolUse(Bash) guard for read-only reviewer agents.
# Blocks obviously state-mutating shell commands. Exit 2 blocks. Read-only inspection passes.
input="$(cat)"
cmd="$(printf '%s' "$input" | grep -oE '"command"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed -E 's/.*"([^"]*)"$/\1/')"
if printf '%s' "$cmd" | grep -qE '(^|[;&| ])(rm|mv|cp|dd|mkfs|chmod|chown|kill|truncate)([ ]|$)|>[^&]|>>|git[[:space:]]+(commit|push|reset|checkout|rm|clean)|npm[[:space:]]+(install|i|publish)|pip[[:space:]]+install'; then
  echo "Blocked: this agent is read-only and may not run state-mutating shell commands ($cmd)." >&2
  exit 2
fi
exit 0
```

- [ ] **Step 3: Add the agent-scoped hook to Kevin, Mel, Carl** using the syntax confirmed in Step 1. (The frontmatter gains a `hooks:` block wiring PreToolUse Bash → `bash ~/.claude/hooks/guard-readonly-bash.sh`. Apply the same block to all three files. Do not alter their existing `name/description/tools/model/memory` fields.)

- [ ] **Step 4: Make executable and functionally test the guard script**

```bash
cd "C:/Users/dpchr/OneDrive/Desktop/claude-practices"
chmod +x hooks/guard-readonly-bash.sh
echo "-- rm (expect 2) --"; printf '{"tool_input":{"command":"rm -rf build"}}' | bash hooks/guard-readonly-bash.sh; echo "exit=$?"
echo "-- redirect write (expect 2) --"; printf '{"tool_input":{"command":"echo x > file.txt"}}' | bash hooks/guard-readonly-bash.sh; echo "exit=$?"
echo "-- read-only grep (expect 0) --"; printf '{"tool_input":{"command":"grep -r TODO src/"}}' | bash hooks/guard-readonly-bash.sh; echo "exit=$?"
echo "-- git diff read-only (expect 0) --"; printf '{"tool_input":{"command":"git diff main"}}' | bash hooks/guard-readonly-bash.sh; echo "exit=$?"
echo "-- frontmatter hook present on all three --"; grep -l "guard-readonly-bash.sh" templates/.claude/agents/*.md | wc -l
```
Expected: `exit=2`, `exit=2`, `exit=0`, `exit=0`; frontmatter present in 3 files.

- [ ] **Step 5: Commit**

```bash
git add hooks/guard-readonly-bash.sh templates/.claude/agents/kevin-security.md templates/.claude/agents/mel-design.md templates/.claude/agents/carl-evals.md
git commit -m "Wave 6: agent-scoped read-only Bash guard on Kevin/Mel/Carl (verified frontmatter hooks pattern)"
```

---

## Task 8: Cost-bounding behavioral fields on the cheap agent

**Files:** Modify `templates/.claude/agents/stuart-explorer.md`

- [ ] **Step 1: Add `maxTurns` to Stuart's frontmatter**

Read `templates/.claude/agents/stuart-explorer.md`. Stuart is the Haiku light-lookup agent; a runaway lookup wastes turns. Add `maxTurns: 8` to the frontmatter (after `model: haiku`). Keep all other fields.

- [ ] **Step 2: Verify**

Run: `cd "C:/Users/dpchr/OneDrive/Desktop/claude-practices" && grep -c "maxTurns: 8" templates/.claude/agents/stuart-explorer.md`
Expected: 1.

- [ ] **Step 3: Commit**

```bash
git add templates/.claude/agents/stuart-explorer.md
git commit -m "Wave 6: cap Stuart at maxTurns:8 (bounds cost on the cheap light-research agent)"
```

---

## Task 9: Backup doctrine + backup-state.sh

**Files:** Create `BACKUP.md`, `backup-state.sh`

- [ ] **Step 1: Create `BACKUP.md`**:

```markdown
# Backup — What Git Covers and What It Doesn't

"It's in git" only backs up **committed, pushed** files. Two kinds of kit state are NOT in git
and live only on this machine:

1. **Agent memory** — `~/.claude/agent-memory/<agent>/` and per-project `.claude/agent-memory/`.
   Bob/Kevin/Gru write their own notes here across sessions. Losing it loses institutional memory.
2. **Local runtime state** — `~/.claude/settings.json` edits, `.claude/orchestration-log.txt`,
   and the install manifest.

Committed-and-pushed files (templates, rules, agents, hooks, docs) ARE backed up by the GitHub
remote — that remote *is* your offsite backup. Push after every wave.

## Backing up the un-tracked state
Run `backup-state.sh` (on demand — there's no scheduler) to snapshot the un-tracked precious
paths into a timestamped archive under a directory you choose:
```
./backup-state.sh ~/claude-backups
```
This is a manual discipline, not automation. Run it before anything risky (a big refactor, an
OS reinstall, clearing `~/.claude`).

## Do NOT back up secrets
Never snapshot `.env`, `*.key`, or anything under `secrets/` into a backup archive. The backup
script deliberately skips those patterns.
```

- [ ] **Step 2: Create `backup-state.sh`**:

```bash
#!/bin/bash
# backup-state.sh — snapshot un-git-tracked Claude state (agent memory, logs, local settings).
# Usage: ./backup-state.sh <backup-dir>   (defaults to ~/claude-backups)
set -euo pipefail
BACKUP_DIR="${1:-$HOME/claude-backups}"
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT="$BACKUP_DIR/claude-state-$STAMP.tar.gz"
mkdir -p "$BACKUP_DIR"

CLAUDE="$HOME/.claude"
# Collect precious, un-tracked paths that exist. Skip secret patterns deliberately.
INCLUDE=()
[ -d "$CLAUDE/agent-memory" ] && INCLUDE+=("$CLAUDE/agent-memory")
[ -f "$CLAUDE/settings.json" ] && INCLUDE+=("$CLAUDE/settings.json")
[ -f "$CLAUDE/.claude-practices-install-manifest.txt" ] && INCLUDE+=("$CLAUDE/.claude-practices-install-manifest.txt")
# Per-project orchestration logs under the current dir
[ -f ".claude/orchestration-log.txt" ] && INCLUDE+=(".claude/orchestration-log.txt")

if [ "${#INCLUDE[@]}" -eq 0 ]; then
  echo "Nothing to back up (no agent memory / settings / logs found yet)."
  exit 0
fi

# Exclude secret patterns as a safety net.
tar --exclude='*.env' --exclude='*.key' --exclude='*.pem' --exclude='*secrets*' \
    -czf "$OUT" "${INCLUDE[@]}" 2>/dev/null
echo "Backed up ${#INCLUDE[@]} path(s) to: $OUT"
```

- [ ] **Step 3: Make executable and functionally test**

```bash
cd "C:/Users/dpchr/OneDrive/Desktop/claude-practices"
chmod +x backup-state.sh
TMPBK="$(mktemp -d)"; TMPHOME="$(mktemp -d)"
mkdir -p "$TMPHOME/.claude/agent-memory/bob-verifier"; echo "note" > "$TMPHOME/.claude/agent-memory/bob-verifier/MEMORY.md"
HOME="$TMPHOME" ./backup-state.sh "$TMPBK"
ls "$TMPBK"/*.tar.gz >/dev/null 2>&1 && echo "archive created (good)" || echo "NO ARCHIVE (bad)"
rm -rf "$TMPBK" "$TMPHOME"
```
Expected: "Backed up N path(s)" and "archive created (good)".

- [ ] **Step 4: Commit**

```bash
git add BACKUP.md backup-state.sh
git commit -m "Wave 6: backup doctrine + backup-state.sh for un-tracked agent memory/local state"
```

---

## Task 10: Rollback procedure (ROLLBACK.md)

**Files:** Create `ROLLBACK.md`

- [ ] **Step 1: Create `ROLLBACK.md`**:

```markdown
# Rollback — Undoing a Bad Update

Three layers of undo, smallest to largest.

## 1. Within a session — `/rewind`
Claude Code checkpoints before each change. `/rewind` restores code, conversation, or both to
an earlier point. First reach for this when a change in the current session went wrong.

## 2. Source code — git
Every wave is committed and tagged (`v1.2.0`, `v1.3.0`, …). To go back to a prior version of
the KIT itself:
```
git checkout v1.2.0        # inspect / build from an earlier version
git revert <sha>           # undo a specific committed change, keeping history
```

## 3. The global install — the install manifest
`git checkout` changes the repo, but the kit also *copied files into* `~/.claude`. Checking out
an old tag does not remove what a newer `install.sh` already wrote there. To roll the global
install back cleanly:
1. `git checkout v1.2.0` (the version you want).
2. Re-run the installer: `./install.sh` (or `.\install.ps1`). It's idempotent and overwrites the
   global copies with the older version's files. Preview first with `./install.sh --dry-run`.
3. The installer writes `~/.claude/.claude-practices-install-manifest.txt` listing exactly what
   it placed — use it to see (or manually remove) files a newer version added that the older one
   doesn't ship.

## What is preserved across a rollback
Your **agent memory**, `HANDOFF.md`, `INVARIANTS.md`, and project files are NOT touched by the
installer — it only writes skills/hooks/agents into `~/.claude`. A rollback changes the tooling,
not your project state. (Back up memory separately — see `BACKUP.md`.)

## Tagging discipline
Tag each wave at merge so "the previous version" is always an addressable thing:
```
git tag v1.3.0 && git push origin v1.3.0
```
```

- [ ] **Step 2: Verify**

Run: `cd "C:/Users/dpchr/OneDrive/Desktop/claude-practices" && test -f ROLLBACK.md && grep -c "install manifest" ROLLBACK.md && grep -c "/rewind" ROLLBACK.md`
Expected: exists; ≥1; ≥1.

- [ ] **Step 3: Commit**

```bash
git add ROLLBACK.md
git commit -m "Wave 6: add ROLLBACK.md (rewind / git tags / install-manifest rollback procedure)"
```

---

## Task 11: Doctrine tweaks — Bob refute, Dave vote-on-claims, loop cost budgets

**Files:** Modify `templates/.claude/agents/bob-verifier.md`, `dave-researcher.md`, `templates/.claude/rules/loop.md`

- [ ] **Step 1: Reframe Bob "review → refute"**

Read `templates/.claude/agents/bob-verifier.md`. In the opening paragraph ("You are Bob, the verifier..."), add a sentence making the mandate adversarial: after the existing first sentence, add:

```markdown
Your job is to *try to refute* the claim that the work is done — actively look for the input or
state that breaks it, don't just read it approvingly. (Per the discipline you already follow:
report only gaps that affect correctness or the stated requirements — a reviewer who invents
style nitpicks is noise.)
```

- [ ] **Step 2: Add vote-on-claims protocol to Dave**

Read `templates/.claude/agents/dave-researcher.md`. In the "## Discipline" section, add this bullet:

```markdown
- **Cross-check every material claim; label survivors and casualties.** For a claim that
  matters to the recommendation, confirm it against a second source. Drop claims that don't
  survive cross-checking. A claim you cannot verify is labeled **"unverified"** in the output —
  never silently asserted as fact, and never counted as refuted just because you couldn't check it.
```

- [ ] **Step 3: Add concrete cost budgets to loop.md**

Read `templates/.claude/rules/loop.md`. Add this section after the "## L3 (unattended) requires containment, not just correctness" section (end of file):

```markdown

## Loop cost budgets (concrete numbers, not just "watch it")
When a loop runs as a Dynamic Workflow, real ceilings apply — use them as the budget:
- Hard caps: 16 concurrent agents, 1,000 total per run.
- A "Large workflow" warning fires past 25 agents or ~1.5M projected tokens — treat it as a stop-and-check.
- Set a default ceiling with the Dynamic workflow size guideline in `/config` (`small` <5, `medium` <15, `large` <50 agents).
- A Stop-hook loop is force-ended after 8 consecutive blocks — don't rely on it as your only brake.
- Watch spend live in `/workflows` (per-agent token totals) and the `SubagentStop` audit log.
State the intended agent-count and model-per-stage budget BEFORE starting an unattended loop.
```

- [ ] **Step 4: Verify**

Run: `cd "C:/Users/dpchr/OneDrive/Desktop/claude-practices" && grep -c "try to refute" templates/.claude/agents/bob-verifier.md && grep -c "Cross-check every material claim" templates/.claude/agents/dave-researcher.md && grep -c "Loop cost budgets" templates/.claude/rules/loop.md`
Expected: 1, 1, 1.

- [ ] **Step 5: Commit**

```bash
git add templates/.claude/agents/bob-verifier.md templates/.claude/agents/dave-researcher.md templates/.claude/rules/loop.md
git commit -m "Wave 6: Bob review->refute, Dave vote-on-claims, loop.md concrete cost budgets"
```

---

## Task 12: Docs, version bump to 1.3.0, install-script README update, final gate

**Files:** Modify `README.md`, `CHANGELOG.md`, `VERSION`

- [ ] **Step 1: Bump VERSION to 1.3.0** — replace contents with:

```
1.3.0
```

- [ ] **Step 2: Prepend a 1.3.0 entry to CHANGELOG.md** (after header, before `## [1.2.0]`)

```markdown
## [1.3.0] — 2026-06-29 (Wave 6 — Ops, Safety & Runnable Mechanisms)
### Added
- Content-based secret scanning in `guard-secrets.sh` — blocks hardcoded keys pasted into ordinary files, not just secret-named files.
- `.pre-commit-config.yaml` (gitleaks) + `SECURITY.md` — commit-time secret backstop and layered-defense doc with a git-history sweep command.
- `--dry-run` / `-DryRun` on both installers + an install manifest written to `~/.claude` (preview before writing; enables surgical rollback).
- Example Dynamic Workflows: `fan-out-audit.js`, `fix-until-green.js` (the runnable form of the loop rule) + a workflows README.
- Agent-scoped read-only Bash guard on Kevin/Mel/Carl (`guard-readonly-bash.sh`) — closes the Bash side-door on read-only reviewers.
- `maxTurns: 8` on Stuart (bounds cost on the cheap light-research agent).
- `BACKUP.md` + `backup-state.sh` — backs up un-git-tracked agent memory / local state.
- `ROLLBACK.md` — /rewind + git tags + install-manifest rollback procedure.
- Loop cost budgets (concrete agent/token ceilings) in `loop.md`; Bob reframed review→refute; Dave gains a vote-on-claims protocol.

### Fixed
- README consistency: path-scoped rules no longer mislabeled "auto-loads"; the continuity section now correctly describes INVARIANTS.md-via-hook and conditional rule loading.

### Notes
- Addresses reviewer (boss) feedback across all eight areas: dry-run, agent hooks, secret protections, backups, rollbacks, loops, workflows, adversarial reviewing. Load-bearing hook mechanism re-verified live against official docs before building.

```

- [ ] **Step 3: Update README** — in the "### 3. Register skills + hook (one command)" section, note the dry-run option. After the install code blocks, add:

```markdown
Preview what the installer would write first, without changing anything:

```bash
./install.sh --dry-run      # macOS/Linux/Git Bash
```
```powershell
.\install.ps1 -DryRun       # Windows
```
```

Also add `SECURITY.md`, `BACKUP.md`, `ROLLBACK.md`, and `.claude/workflows/` to the Contents tree in sensible spots.

- [ ] **Step 4: Final Wave 6 verification gate**

```bash
cd "C:/Users/dpchr/OneDrive/Desktop/claude-practices"
echo "=== new files present ==="
for f in .pre-commit-config.yaml SECURITY.md BACKUP.md ROLLBACK.md backup-state.sh hooks/guard-readonly-bash.sh templates/.claude/workflows/fan-out-audit.js templates/.claude/workflows/fix-until-green.js; do
  test -f "$f" && echo "ok: $f" || echo "MISSING: $f"; done
echo "=== secret content scan blocks a key (expect 2) ==="; printf '{"tool_input":{"file_path":"a.js","content":"AKIAIOSFODNN7EXAMPLE"}}' | bash hooks/guard-secrets.sh >/dev/null 2>&1; echo "exit=$?"
echo "=== installer dry-run writes nothing ==="; TMPHOME="$(mktemp -d)"; HOME="$TMPHOME" ./install.sh --dry-run >/dev/null 2>&1; test -d "$TMPHOME/.claude" && echo "WROTE (bad)" || echo "clean"; rm -rf "$TMPHOME"
echo "=== install regression (real) ==="; TMPHOME="$(mktemp -d)"; HOME="$TMPHOME" ./install.sh >/dev/null 2>&1; echo "agents=$(ls "$TMPHOME/.claude/agents"|wc -l) hooks=$(ls "$TMPHOME/.claude/hooks"|wc -l) skills=$(ls "$TMPHOME/.claude/skills"|wc -l) manifest=$(test -f "$TMPHOME/.claude/.claude-practices-install-manifest.txt" && echo yes)"; rm -rf "$TMPHOME"
echo "=== README consistency fixed ==="; (grep -q "Only two things auto-load" README.md && echo "STALE" || echo "consistent")
echo "=== version ==="; cat VERSION
echo "=== commit + clean tree ==="; git add -A && git commit -m "Wave 6: docs + bump to 1.3.0" && (test -z "$(git status --short)" && echo clean)
```
Expected: all "ok:" (note guard-readonly + agent-hook files depend on Task 7 completing); secret scan exit=2; dry-run "clean"; real install agents=9 hooks=9 skills=8 manifest=yes; README "consistent"; VERSION 1.3.0; "clean". (Hook count is now 9 — the 8 prior + guard-readonly-bash.sh.)

---

## Self-Review (completed at authoring)
- **Coverage:** every reviewer pointer maps to a task (see "Maps to the reviewer's pointers"). Consistency fixes → Task 1.
- **Verify-first discipline:** the secret-scanner mechanism (PreToolUse carries content; exit 2 blocks) was verified live before planning. The one unverified mechanism (agent-scoped `hooks:` frontmatter YAML) has an explicit doc-verify Step 1 inside Task 7 that halts if the syntax can't be confirmed — no guessing.
- **Placeholders:** none — full content for every script, doc, workflow, and settings change is inline, EXCEPT Task 7 Step 3 (the agent frontmatter block) which is deliberately written after Step 1 confirms the exact syntax.
- **Sequencing:** Tasks 1–6, 8–11 touch disjoint files and are parallel-safe. Task 7 must complete Step 1 (doc verify) before its edits. Task 12's gate assumes hook count 9 (adds guard-readonly-bash.sh) — if Task 7 halts on unverifiable syntax, adjust the gate's hook count and note guard-readonly ships without agent-wiring.
- **Excluded (per research):** a second standing adversarial reviewer (no doc support); agent-teams debate (experimental, can't nest); detect-secrets (overkill for a clean kit).
