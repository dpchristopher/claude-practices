# Wave 5 — Native Platform Features & Elite Practitioner Doctrine

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Adopt verified native Claude Code capabilities (agent memory, path-scoped rules, corrected agent-spawn restriction, Dynamic Workflows, new hook events) plus doctrine from primary-sourced elite practitioners (Simon Willison, Armin Ronacher), all cross-checked against the live docs and the actual current repo state before writing.

**Architecture:** Markdown + JSON + shell, no application code. Each task ends in a commit after a grep/cat/JSON check.

**Tech Stack:** Markdown, JSON, Bash, Git.

**Branch:** `feature/wave-5-native-features` (checked out). Repo: `C:/Users/dpchr/OneDrive/Desktop/claude-practices`. Version 1.1.0 → 1.2.0.

**Sourcing discipline for this wave:** every item below was either (a) independently re-fetched live from `code.claude.com/docs` this session, or (b) sourced from a named practitioner's own dated blog (Simon Willison, Armin Ronacher — primary, first-party). Items resting only on secondary/aggregator sourcing (a `fork: true` skill tip, a "rewind not correct" tip, a 400k-token env var, and everything attributed to Karpathy) were explicitly EXCLUDED from this wave per user decision — do not add them.

---

## File Structure

**Created:**
- `hooks/subagent-audit.sh` — SubagentStop: logs which agent ran, no-op-safe, never blocks
- `hooks/log-instructions-loaded.sh` — InstructionsLoaded: logs which context files loaded, no-op-safe, never blocks

**Modified:**
- `templates/.claude/agents/bob-verifier.md` — memory, nested fan-out, code-quality-degradation check
- `templates/.claude/agents/kevin-security.md` — memory
- `templates/.claude/agents/gru-planner.md` — memory, Dynamic Workflows phase, per-task model delegation
- `templates/.claude/agents/dave-researcher.md` — nested fan-out
- `templates/.claude/settings.json` — autoMemoryEnabled, Agent(Explore) deny, new hooks wired
- `templates/.claude/rules/ml-discipline.md`, `automation.md` — `paths:` frontmatter
- `templates/.claude/rules/loop.md` — per-stage model routing, context-centric decomposition, L3 containment precondition
- `templates/.claude/rules/tool-discipline.md` — roster-bloat doctrine note
- `docs/optional-integrations.md` — Opik skip reaffirmed with updated reasoning
- `README.md`, `CHANGELOG.md`, `VERSION` — document + bump to 1.2.0

---

## Task 1: Agent memory — Bob, Kevin, Gru

**Files:** Modify `templates/.claude/agents/bob-verifier.md`, `kevin-security.md`, `gru-planner.md`

- [ ] **Step 1: Add `memory: project` to Bob's frontmatter**

Read `templates/.claude/agents/bob-verifier.md`. Its frontmatter currently ends `model: opus` then `---`. Change to:

```yaml
---
name: bob-verifier
description: "Bob (verifier) — fresh-context adversarial reviewer. Use before marking work done. Checks a diff against the plan and invariants and reports only correctness gaps."
tools: Read, Grep, Glob, Bash, Agent
model: opus
memory: project
---
```

(Note: `Agent` added to `tools` here too — needed for Task 5's nested fan-out. Both changes land in this one edit.)

Then add this line at the very end of the file (after the existing "Report format" section):

```markdown

## Memory
Before reviewing, check your memory for patterns you've seen before in this repo (recurring
gap categories, invariants that break often). After a review, save what you learned — a
recurring gap type, a false-positive pattern to avoid repeating — to keep MEMORY.md useful,
not a transcript. Curate it; don't let it grow unbounded.
```

- [ ] **Step 2: Add `memory: project` to Kevin's frontmatter**

Read `templates/.claude/agents/kevin-security.md`. Change frontmatter to:

```yaml
---
name: kevin-security
description: "Kevin (security-reviewer) — fiduciary-grade security review. Use on changes touching auth, data handling, dependencies, or anything client-facing. Read-only."
tools: Read, Grep, Glob, Bash
model: opus
memory: project
---
```

Add at the end of the file:

```markdown

## Memory
Check your memory for known-insecure sinks and past findings in this repo before reviewing.
After a review, save newly-discovered patterns (a recurring insecure sink, a false-positive
class) — not a transcript of every review.
```

- [ ] **Step 3: Add `memory: project` to Gru's frontmatter**

Read `templates/.claude/agents/gru-planner.md`. Change frontmatter to:

```yaml
---
name: gru-planner
description: "Gru (planner) — the mastermind that drafts kit-compliant implementation plans end to end. Use whenever a non-trivial feature or change needs a plan. Reads the whole project, routes to every other agent, self-audits, hands to Bob."
tools: Read, Grep, Glob, Bash, Write, Agent
model: opus
memory: project
---
```

(`Agent` added here too, needed for Task 3's workflow phase and general orchestration.) Full Gru content changes continue in Task 3 below — do not add a memory paragraph yet, Task 3 covers Gru's remaining edits in one pass to avoid double-editing the same file across tasks.

- [ ] **Step 4: Verify**

Run: `cd "C:/Users/dpchr/OneDrive/Desktop/claude-practices" && grep -c "memory: project" templates/.claude/agents/bob-verifier.md templates/.claude/agents/kevin-security.md templates/.claude/agents/gru-planner.md`
Expected: `1` for each of the three files.

- [ ] **Step 5: Commit**

```bash
git add templates/.claude/agents/bob-verifier.md templates/.claude/agents/kevin-security.md templates/.claude/agents/gru-planner.md
git commit -m "Wave 5: add memory: project to Bob, Kevin, Gru; Agent tool to Bob/Gru"
```

---

## Task 2: Gru — Dynamic Workflows phase + per-task model delegation (Willison)

**Files:** Modify `templates/.claude/agents/gru-planner.md`

- [ ] **Step 1: Add a new Phase I after the existing Phase H (Output)**

Read the current file (already has `memory: project` and `Agent` in tools from Task 1). Append this new section after Phase H's content, before the file ends:

```markdown

## Phase I — Repeatable orchestration → save as a Dynamic Workflow
If this plan's execution pattern will recur (e.g. the maker≠checker fan-out, a security
sweep across many files, a test-then-grade loop), note in your output that it is a
candidate for a saved Dynamic Workflow (`.claude/workflows/*.js`, via `agent()`/`pipeline()`).
Don't build the workflow yourself in this pass — flag it, and let the user ask for one
("use a workflow for this") if they want it saved and rerunnable. Native caps apply: 16
concurrent / 1,000 total agents per run; keep proposed workflows well under that.

## Phase J — Per-task model delegation (not just per-agent)
When routing to an agent in Phase D, don't only rely on that agent's fixed model (Stuart is
always Haiku, Bob is always Opus, etc.) — also judge whether THIS SPECIFIC task within a
phase needs the agent's default model or could run cheaper. Per Simon Willison's working
pattern: keep judgment/synthesis at the top, delegate mechanical/implementation sub-steps to
the cheapest adequate model, and always review before commit. State the model choice per
task in the plan, not just the agent name.
```

- [ ] **Step 2: Verify**

Run: `cd "C:/Users/dpchr/OneDrive/Desktop/claude-practices" && grep -c "Phase I" templates/.claude/agents/gru-planner.md && grep -c "Phase J" templates/.claude/agents/gru-planner.md && grep -c "Dynamic Workflow" templates/.claude/agents/gru-planner.md`
Expected: 1, 1, ≥1.

- [ ] **Step 3: Commit**

```bash
git add templates/.claude/agents/gru-planner.md
git commit -m "Wave 5: Gru gets Dynamic Workflow awareness (Phase I) + per-task model delegation (Phase J)"
```

---

## Task 3: Bob — nested fan-out + code-quality-degradation check (Ronacher)

**Files:** Modify `templates/.claude/agents/bob-verifier.md`

- [ ] **Step 1: Add a 5th check item**

Read the current file (has `memory: project` + `Agent` tool + Memory section from Task 1). In the "## What you check (all four)" section, change the header to "all five" and add a 5th numbered item after item 4 (Edge cases):

```markdown
5. **Code-quality degradation from long autonomous runs.** On any change that came out of an
   L2/L3 loop, specifically check for: defensive fallbacks used in place of invariants
   (code handling a state that should have been made impossible instead), duplicated logic,
   and over-local reasoning that ignores the wider codebase. This is a named failure
   signature of long unattended runs, not generic code review — flag it as its own category.
   Loops are safest for throwaway artifacts (ports, scans, one-off research); treat lasting,
   load-bearing code from a long autonomous run with extra scrutiny.
```

Change the section header from "## What you check (all four)" to "## What you check (all five)".

- [ ] **Step 2: Add the nested fan-out paragraph**

Add this new section after "## Discipline (do not over-report)" and before "## Report format":

```markdown

## Nested fan-out for large diffs
If a diff spans many files or findings, you may spawn a sub-verifier per finding (nested
subagents, up to 5 levels deep) so per-finding noise never reaches the parent context —
only your synthesized verdict returns. Use this for scale, not to dodge doing the review
yourself.
```

- [ ] **Step 3: Verify**

Run: `cd "C:/Users/dpchr/OneDrive/Desktop/claude-practices" && grep -c "all five" templates/.claude/agents/bob-verifier.md && grep -c "Nested fan-out" templates/.claude/agents/bob-verifier.md && grep -c "defensive fallbacks" templates/.claude/agents/bob-verifier.md`
Expected: 1, 1, ≥1.

- [ ] **Step 4: Commit**

```bash
git add templates/.claude/agents/bob-verifier.md
git commit -m "Wave 5: Bob gets nested fan-out + code-quality-degradation check (Ronacher)"
```

---

## Task 4: Dave — nested fan-out tool access

**Files:** Modify `templates/.claude/agents/dave-researcher.md`

- [ ] **Step 1: Add `Agent` to tools and a fan-out note**

Read the current file. Change the `tools:` line from:
```yaml
tools: Read, Grep, Glob, Bash, WebSearch, WebFetch
```
to:
```yaml
tools: Read, Grep, Glob, Bash, WebSearch, WebFetch, Agent
```

Add this section after "## Discipline" and before "## Report format":

```markdown

## Nested fan-out for multi-source research
For a question spanning many sources, you may spawn a sub-researcher per source or angle
(nested subagents, up to 5 levels deep) so per-source reading doesn't bloat your own
context — only your synthesis returns. Still do the final judgment/recommendation yourself;
don't delegate the synthesis step.
```

- [ ] **Step 2: Verify**

Run: `cd "C:/Users/dpchr/OneDrive/Desktop/claude-practices" && grep -c "Agent$" templates/.claude/agents/dave-researcher.md && grep -c "Nested fan-out" templates/.claude/agents/dave-researcher.md`
Expected: the tools line ends in `Agent` (≥1 match on a line ending Agent); Nested fan-out: 1.

- [ ] **Step 3: Commit**

```bash
git add templates/.claude/agents/dave-researcher.md
git commit -m "Wave 5: Dave gets nested fan-out tool access"
```

---

## Task 5: settings.json — autoMemoryEnabled, Agent(Explore) deny, new hooks wired

**Files:** Modify `templates/.claude/settings.json`

- [ ] **Step 1: Rewrite the file**

Read `templates/.claude/settings.json`. Its current content is:
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
    ],
    "PreToolUse": [
      { "matcher": "Write|Edit", "hooks": [{ "type": "command", "command": "bash ~/.claude/hooks/guard-secrets.sh" }] }
    ],
    "PostToolUse": [
      { "matcher": "Write|Edit", "hooks": [{ "type": "command", "command": "bash ~/.claude/hooks/post-edit-format.sh" }] }
    ],
    "UserPromptSubmit": [
      { "hooks": [{ "type": "command", "command": "bash ~/.claude/hooks/plan-router.sh" }] }
    ]
  }
}
```

Replace the ENTIRE file with:

```json
{
  "autoMemoryEnabled": false,
  "permissions": {
    "deny": [
      "Read(.env)",
      "Read(.env.*)",
      "Read(**/*.key)",
      "Read(**/*.pem)",
      "Read(**/secrets/**)",
      "Read(**/credentials*)",
      "Agent(Explore)"
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
    ],
    "PreToolUse": [
      { "matcher": "Write|Edit", "hooks": [{ "type": "command", "command": "bash ~/.claude/hooks/guard-secrets.sh" }] }
    ],
    "PostToolUse": [
      { "matcher": "Write|Edit", "hooks": [{ "type": "command", "command": "bash ~/.claude/hooks/post-edit-format.sh" }] }
    ],
    "UserPromptSubmit": [
      { "hooks": [{ "type": "command", "command": "bash ~/.claude/hooks/plan-router.sh" }] }
    ],
    "SubagentStop": [
      { "hooks": [{ "type": "command", "command": "bash ~/.claude/hooks/subagent-audit.sh" }] }
    ],
    "InstructionsLoaded": [
      { "hooks": [{ "type": "command", "command": "bash ~/.claude/hooks/log-instructions-loaded.sh" }] }
    ]
  }
}
```

Rationale for each addition: `autoMemoryEnabled: false` keeps INVARIANTS.md/HANDOFF as the single committed memory authority instead of a second, machine-local, uncommitted one (confirmed default-on native feature, code.claude.com/docs/en/memory). `Agent(Explore)` denies the built-in generic Explore agent so orchestration nudges toward the named Minion roster (Stuart/Dave) instead — this is the corrected mechanism for restricting agent spawns (a `deny` rule, not `Agent(x,y)` inside an agent's own `tools:`, which the docs confirm is ignored in a subagent definition). The two new hooks wire Task 6's audit/diagnostic hooks.

- [ ] **Step 2: Verify valid JSON + all keys present**

```bash
cd "C:/Users/dpchr/OneDrive/Desktop/claude-practices"
python -c "
import json
d = json.load(open('templates/.claude/settings.json'))
assert d['autoMemoryEnabled'] is False
assert 'Agent(Explore)' in d['permissions']['deny']
assert 'Read(.env)' in d['permissions']['deny']
assert 'SubagentStop' in d['hooks']
assert 'InstructionsLoaded' in d['hooks']
assert 'SessionStart' in d['hooks']
print('settings ok')
" 2>/dev/null || node -e "
const d = JSON.parse(require('fs').readFileSync('templates/.claude/settings.json'));
if (d.autoMemoryEnabled !== false) throw new Error('autoMemoryEnabled');
if (!d.permissions.deny.includes('Agent(Explore)')) throw new Error('Agent(Explore)');
if (!d.permissions.deny.includes('Read(.env)')) throw new Error('Read(.env)');
if (!d.hooks.SubagentStop || !d.hooks.InstructionsLoaded || !d.hooks.SessionStart) throw new Error('hooks');
console.log('settings ok');
"
```
Expected: "settings ok".

- [ ] **Step 3: Commit**

```bash
git add templates/.claude/settings.json
git commit -m "Wave 5: settings.json gets autoMemoryEnabled:false, Agent(Explore) deny, SubagentStop/InstructionsLoaded hooks wired"
```

---

## Task 6: New hooks — subagent-audit.sh, log-instructions-loaded.sh

**Files:** Create `hooks/subagent-audit.sh`, `hooks/log-instructions-loaded.sh`

- [ ] **Step 1: Create `hooks/subagent-audit.sh`**

```bash
#!/bin/bash
# subagent-audit.sh — SubagentStop: append a one-line audit record of which agent ran.
# Never blocks (always exit 0). Diagnostic only — an orchestration audit trail.
input="$(cat)"
agent_name="$(printf '%s' "$input" | grep -oE '"agent_name"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed -E 's/.*"([^"]*)"$/\1/')"
[ -z "$agent_name" ] && agent_name="unknown"
mkdir -p .claude 2>/dev/null
printf '%s  agent=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$agent_name" >> .claude/orchestration-log.txt 2>/dev/null
exit 0
```

- [ ] **Step 2: Create `hooks/log-instructions-loaded.sh`**

```bash
#!/bin/bash
# log-instructions-loaded.sh — InstructionsLoaded: append which context files loaded.
# Never blocks (always exit 0). Diagnostic only — catches a silently-unloaded INVARIANTS.md etc.
input="$(cat)"
paths="$(printf '%s' "$input" | grep -oE '"path"[[:space:]]*:[[:space:]]*"[^"]*"' | sed -E 's/.*"([^"]*)"$/\1/' | tr '\n' ',')"
[ -z "$paths" ] && paths="(none captured)"
mkdir -p .claude 2>/dev/null
printf '%s  loaded=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$paths" >> .claude/orchestration-log.txt 2>/dev/null
exit 0
```

- [ ] **Step 3: Make executable and functionally test (never blocks, always exit 0)**

```bash
cd "C:/Users/dpchr/OneDrive/Desktop/claude-practices"
chmod +x hooks/subagent-audit.sh hooks/log-instructions-loaded.sh
TMPD="$(mktemp -d)"; cd "$TMPD"
printf '{"agent_name":"bob-verifier"}' | bash "$OLDPWD/hooks/subagent-audit.sh"; echo "audit-exit=$?"
printf '{"path":"CLAUDE.md"}' | bash "$OLDPWD/hooks/log-instructions-loaded.sh"; echo "log-exit=$?"
test -f .claude/orchestration-log.txt && echo "log file created" && cat .claude/orchestration-log.txt
cd "$OLDPWD"; rm -rf "$TMPD"
```
Expected: `audit-exit=0`, `log-exit=0`, "log file created", and the log shows both an `agent=bob-verifier` line and a `loaded=CLAUDE.md` line.

- [ ] **Step 4: Commit**

```bash
git add hooks/subagent-audit.sh hooks/log-instructions-loaded.sh
git commit -m "Wave 5: add subagent-audit.sh and log-instructions-loaded.sh hooks (diagnostic, never block)"
```

---

## Task 7: `paths:` scoping on domain-specific rules

**Files:** Modify `templates/.claude/rules/ml-discipline.md`, `templates/.claude/rules/automation.md`

- [ ] **Step 1: Add `paths:` frontmatter to `ml-discipline.md`**

Read the file. It currently starts directly with `# ML Discipline Rules` (no frontmatter). Insert this frontmatter block as the very first lines, before the `# ML Discipline Rules` heading:

```markdown
---
paths:
  - "**/*.ipynb"
  - "experiments/**/*"
  - "**/*model*.py"
  - "**/*train*.py"
---
```

- [ ] **Step 2: Add `paths:` frontmatter to `automation.md`**

Read the file. It currently starts directly with `# Automation Rules`. Insert this frontmatter block as the very first lines:

```markdown
---
paths:
  - "**/pipeline*.py"
  - "**/*cron*"
  - "**/scheduled*"
  - "scripts/**/*"
---
```

- [ ] **Step 3: Verify**

Run: `cd "C:/Users/dpchr/OneDrive/Desktop/claude-practices" && head -1 templates/.claude/rules/ml-discipline.md && head -1 templates/.claude/rules/automation.md`
Expected: both output `---` (frontmatter delimiter is now the first line of each file).

- [ ] **Step 4: Commit**

```bash
git add templates/.claude/rules/ml-discipline.md templates/.claude/rules/automation.md
git commit -m "Wave 5: paths: scope ml-discipline and automation rules (load only when relevant files touched)"
```

---

## Task 8: loop.md — per-stage model routing, context-centric decomposition, L3 containment (Willison)

**Files:** Modify `templates/.claude/rules/loop.md`

- [ ] **Step 1: Add per-stage model routing as a new numbered item**

Read the current file. In "## The seven rules of a loop you can trust," change the header to "## The eight rules of a loop you can trust" and add a new item 8 after item 7 (Loops open PRs):

```markdown
8. **Route model choice per stage, not just per loop.** A single loop can mix cheap
   mechanical stages (cheap model) with judgment/synthesis stages (strongest model) — state
   the model per stage before running, not just once for the whole loop.
```

- [ ] **Step 2: Add the context-centric decomposition section**

Add this new section after "## The checker must point at the WHOLE check" and before "## When the goal may be impossible":

```markdown

## Split work only where context isolates cleanly
Decompose a multi-agent task by WHERE context can be truly separated, not by problem phase.
A naive plan→implement→test handoff chain shares too much context across steps and degrades
like a telephone game — each handoff loses fidelity. Verification is the classic case that
splits cleanly (a fresh-context checker needs the diff and the spec, nothing else); a
sequential pipeline of loosely-related steps usually does not. Prefer a fresh-context
verifier over a context-passing pipeline whenever the choice exists.
```

- [ ] **Step 3: Add the L3 containment precondition**

Add this new section after "## When NOT to loop" (at the end of the file):

```markdown

## L3 (unattended) requires containment, not just correctness
The autonomy ladder's brakes (exit condition, stuck-loop detection, whole-check gate) govern
CORRECTNESS. Before granting L3, also bound the BLAST RADIUS, independently:
- Network egress limited or sandboxed — an unattended loop should not have open internet
  access it doesn't need.
- Credentials scoped to test/staging, never production, for anything that can write.
- A hard spend cap on anything that can cost money (API calls, cloud resources).
Correctness brakes and containment brakes are separate checks — a loop can be "correct" and
still be dangerous if it runs unsandboxed with production credentials and no spend limit.
Grant L3 only when both are satisfied.
```

- [ ] **Step 4: Verify**

Run: `cd "C:/Users/dpchr/OneDrive/Desktop/claude-practices" && grep -c "eight rules" templates/.claude/rules/loop.md && grep -c "Split work only where context isolates" templates/.claude/rules/loop.md && grep -c "requires containment, not just correctness" templates/.claude/rules/loop.md`
Expected: 1, 1, 1.

- [ ] **Step 5: Commit**

```bash
git add templates/.claude/rules/loop.md
git commit -m "Wave 5: loop.md gets per-stage model routing, context-centric decomposition, L3 containment precondition (Willison)"
```

---

## Task 9: tool-discipline.md — roster-bloat doctrine note (Willison)

**Files:** Modify `templates/.claude/rules/tool-discipline.md`

- [ ] **Step 1: Add a new section**

Read the current file. Add this new section after "## When to Use Subagents vs. Main Session" and before "## Context Budget Awareness":

```markdown

## Every named agent must earn its place
Don't accumulate specialist subagents by role-flavor alone ("we should have an X agent").
A named agent earns its place only via a real context isolation or a distinct model/
permission boundary — e.g. a fresh-context checker (maker≠checker needs separate context to
be honest), a cheaper model for mechanical work, or a narrower tool/permission scope than
the main session. If a "new agent" would just be a prompt variation running in the same
context with the same tools, it should be a skill instead, not an agent.

---
```

- [ ] **Step 2: Verify**

Run: `cd "C:/Users/dpchr/OneDrive/Desktop/claude-practices" && grep -c "Every named agent must earn its place" templates/.claude/rules/tool-discipline.md`
Expected: 1.

- [ ] **Step 3: Commit**

```bash
git add templates/.claude/rules/tool-discipline.md
git commit -m "Wave 5: tool-discipline.md gets roster-bloat doctrine note (Willison)"
```

---

## Task 10: optional-integrations.md — reaffirm Opik skip with updated reasoning

**Files:** Modify `docs/optional-integrations.md`

- [ ] **Step 1: Add a short section**

Read the current file. Add this new section after "## Playwright / browser-verify MCP — UI self-checking (optional)" and before "## Rule of thumb":

```markdown

---

## Opik (LLM observability) — reaffirmed skip
**What it would solve:** "which of my 9 agents caused a bad outcome" in a multi-agent run.

**Why it's still skip (re-checked, not just carried over):** Claude Code's native
`/workflows` progress view now gives per-agent, per-phase tracing for free — token totals,
elapsed time, drill into any agent's prompt/tool calls/result — for the exact "which agent
failed" problem Opik would otherwise solve. Opik's real edge (multi-framework support,
40M-traces/day scale, persistent cross-session trace storage) is an enterprise/high-volume
axis, not a solo-operator one. Revisit only if you leave Claude Code's runtime, or need
durable trace history beyond a single session (native workflow runs are only resumable
within the same session).
```

- [ ] **Step 2: Verify**

Run: `cd "C:/Users/dpchr/OneDrive/Desktop/claude-practices" && grep -c "Opik (LLM observability) — reaffirmed skip" docs/optional-integrations.md`
Expected: 1.

- [ ] **Step 3: Commit**

```bash
git add docs/optional-integrations.md
git commit -m "Wave 5: reaffirm Opik skip with updated reasoning (native workflow tracing)"
```

---

## Task 11: Docs, version bump to 1.2.0, final gate

**Files:** Modify `README.md`, `CHANGELOG.md`, `VERSION`

- [ ] **Step 1: Bump VERSION to 1.2.0** — replace contents with:

```
1.2.0
```

- [ ] **Step 2: Prepend a 1.2.0 entry to CHANGELOG.md** (after header, before `## [1.1.0]`)

```markdown
## [1.2.0] — 2026-06-29 (Wave 5 — Native Platform Features & Elite Doctrine)
### Added
- `memory: project` on Bob, Kevin, Gru — persistent per-agent knowledge across sessions (native subagent memory).
- Gru: Dynamic Workflow awareness (flags repeatable orchestration as a `.claude/workflows/*.js` candidate) and per-task model delegation (Simon Willison).
- Bob and Dave: nested fan-out via the `Agent` tool (5-level-deep subagent spawning).
- Bob: a 5th check — code-quality degradation from long autonomous runs (Armin Ronacher: defensive fallbacks vs. invariants, duplicated logic, over-local reasoning).
- `paths:`-scoped `.claude/rules/`: ml-discipline and automation now load only when relevant files are touched.
- `loop.md`: per-stage model routing, context-centric decomposition doctrine ("split where context isolates, not by problem phase"), and an L3 containment precondition (network/credential/spend bounds, separate from correctness brakes) — all from Simon Willison's agentic-loop writing.
- `tool-discipline.md`: a roster-bloat doctrine note — every named agent must earn its place via context isolation or a permission/model boundary, not role-flavor alone.
- `subagent-audit.sh` and `log-instructions-loaded.sh` hooks — diagnostic audit trail of orchestration runs and loaded context files; never block.
- `settings.json`: `autoMemoryEnabled: false` (keeps INVARIANTS/HANDOFF as the single memory authority over the platform's own auto-memory) and `Agent(Explore)` denied (nudges orchestration toward the named Minion roster).

### Notes
- Sourcing discipline: every item above was independently re-verified against live official docs (code.claude.com/docs) or a named practitioner's own primary-source blog (Simon Willison, Armin Ronacher). Items resting only on secondary/aggregator sourcing were explicitly excluded this wave.

```

- [ ] **Step 3: Update README** — add the new hooks and the paths-scoping note to the Contents tree, matching existing formatting:

```markdown
  subagent-audit.sh                ← SubagentStop: diagnostic orchestration audit trail
  log-instructions-loaded.sh       ← InstructionsLoaded: diagnostic context-load log
```

- [ ] **Step 4: Final Wave 5 verification gate**

```bash
cd "C:/Users/dpchr/OneDrive/Desktop/claude-practices"
echo "=== new files ==="
for f in hooks/subagent-audit.sh hooks/log-instructions-loaded.sh; do test -f "$f" && echo "ok: $f" || echo "MISSING: $f"; done
echo "=== agent memory fields (expect 3) ==="
grep -l "memory: project" templates/.claude/agents/*.md | wc -l
echo "=== settings valid + new keys ==="
python -c "
import json
d = json.load(open('templates/.claude/settings.json'))
assert d['autoMemoryEnabled'] is False
assert 'Agent(Explore)' in d['permissions']['deny']
assert 'SubagentStop' in d['hooks'] and 'InstructionsLoaded' in d['hooks']
print('ok')
" 2>/dev/null || node -e "
const d = JSON.parse(require('fs').readFileSync('templates/.claude/settings.json'));
if (d.autoMemoryEnabled !== false) throw 0;
if (!d.permissions.deny.includes('Agent(Explore)')) throw 0;
if (!d.hooks.SubagentStop || !d.hooks.InstructionsLoaded) throw 0;
console.log('ok');
"
echo "=== rules paths-scoped (expect --- as first line) ==="
head -1 templates/.claude/rules/ml-discipline.md
head -1 templates/.claude/rules/automation.md
echo "=== loop.md doctrine present ==="
grep -c "requires containment" templates/.claude/rules/loop.md
echo "=== install still copies everything (regression check) ==="
TMPHOME="$(mktemp -d)"; HOME="$TMPHOME" ./install.sh >/dev/null 2>&1
echo "agents=$(ls "$TMPHOME/.claude/agents" | wc -l) hooks=$(ls "$TMPHOME/.claude/hooks" | wc -l) skills=$(ls "$TMPHOME/.claude/skills" | wc -l)"
rm -rf "$TMPHOME"
echo "=== version ==="
cat VERSION
echo "=== commit + clean tree ==="
git add -A && git commit -m "Wave 5: docs + bump to 1.2.0" && (test -z "$(git status --short)" && echo clean)
```
Expected: both "ok:"; agent memory count = 3; settings "ok"; both rules files start with `---`; loop.md containment count ≥1; agents=9 hooks=8 skills=8; VERSION 1.2.0; "clean".

---

## Self-Review (completed at authoring)

- **Coverage:** all 14 agreed items map to a task: memory(1) → Task1; Willison per-task model(11)+workflows(5) → Task2; Ronacher check(14)+nested fan-out(8) → Task3; nested fan-out Dave(8) → Task4; autoMemoryEnabled(2)+Agent(Explore) corrected mechanism(4)+hooks wiring(9) → Task5; new hooks(9) → Task6; paths scoping(3) → Task7; per-stage routing(6)+context-centric decomposition(7)+L3 containment(12) → Task8; roster-bloat(13) → Task9; Opik reaffirm(10) → Task10; docs/version → Task11.
- **Placeholders:** none — every edit's exact text is inline.
- **Consistency:** Bob and Gru each get memory+tools changes in Task 1 and further content changes in Tasks 2/3 — sequenced as separate tasks against the SAME file deliberately to avoid two parallel subagents editing one file simultaneously (Task 2/3 must not run concurrently with Task 1 on gru-planner.md/bob-verifier.md; run Task 1 first, then 2 and 3 can proceed once 1 is committed). All other tasks (4, 5, 6, 7, 8, 9, 10) touch disjoint files and are safe to run in parallel with each other and after Task 1.
- **Excluded per user decision:** the three secondary-sourced items (`fork: true`, "rewind not correct," the 400k env var) and everything attributed to Karpathy — confirmed absent from every task above.
