# Phase 1d — GC Pass: Kit Inventory

> Generated 2026-09-08, per `~/.claude/rules/kit-maintenance.md` (the GC pass definition) and
> the capability research brief at `docs/research/2026-09-08-capability-research-brief.md`.
> Constraints honored: read + write ONE new file (this one), no existing files modified, no git
> writes, Drive/Asana/email/LinkedIn untouched.
>
> **The honest constraint, stated up front:** `~/.claude/session-metrics.md` has 14 rows, 6 of
> them `AUTO-STUB` placeholders with the judgment fields left as `?` — effectively ~8 real
> data points. That is far too sparse to prove disuse of anything on its own, and no
> recommendation below rests on "it never appears in that log." Every cut candidate is backed by
> a mechanical signal pulled from a different, much larger source: the full
> `~/.claude/projects/*/**.jsonl` transcript corpus (every tool call and skill/agent dispatch
> ever made on this machine), file mtimes, hook state files, and cross-checking every
> settings.json this machine actually has (global + 5 project-level). Where a claim rests on
> that corpus, the exact grep/count is shown so it can be re-run next month.

---

## 1. Counts

### By source

| Source | Skills | Agents | Hooks | Notes |
|---|---:|---:|---:|---|
| Kit (`claude-practices`, per `.claude-practices-install-manifest.txt`) | 9 | 10 | 12 | Named-persona agents (Bob/Carl/Dave/Gru/Jerry/Kevin/Mel/Otto/Phil/Stuart) |
| GSD (`get-shit-done`, third-party, separate installer/cache at `~/.cache/gsd/`) | 68 | 24 | 9 | Installed **directly into** `~/.claude/skills/`, `~/.claude/agents/`, `~/.claude/hooks/` — not a "plugin" in the `enabledPlugins` sense, but a fully separate product sharing the same directories as the kit |
| Other/legacy, present but not in the kit manifest | ~17 | 0 | 1 (`session-context.ps1`, counted once already above) | `docx`, `pptx`, `xlsx`, `mcp-builder`, `mcp-developer`, `frontend-design` (kit copy), `skill-creator` (kit copy), `claude-api`, `debugging-wizard`, `labarr-ml`, `outside-the-box`, `pandas-pro`, `sql-pro`, `stop-slop`, `the-fool`, `web-scraper-main`, `daniel-context` — old mtimes (Mar 5 / Apr 8 2026), not written by the kit installer, provenance unclear (see §5) |
| **Total in `~/.claude/skills/`** | **94** | — | — | `ls ~/.claude/skills \| wc -l` = 94; `grep -c '^gsd-'` = 68; remainder = 26 |
| **Total in `~/.claude/agents/`** | — | **34** | — | 24 `gsd-*.md`, 10 named-persona `.md` (confirmed via `ls`) |
| **Total in `~/.claude/hooks/`** | — | — | **22** | 9 `gsd-*`, 13 kit/legacy (`ls ~/.claude/hooks \| wc -l` = 22) |

Plugins are enumerated separately in §4 since they don't live in these directories.

### Templates and kit's own repo (`C:\Dev\claude-practices`)

- `skills/` — 10 entries (9 skill dirs + 1 stray `failure-modes-SKILL.md` file sitting next to
  the `failure-modes/` directory — see §4 orphans)
- `templates/.claude/agents/` — 10 files, exact match to the kit's 10 deployed agents
- `templates/.claude/rules/` — 13 rule files
- `hooks/` (repo source) — 13 files, exact match to the 12 kit hooks in `~/.claude/hooks/` plus
  `guard-fanout.sh` (13 total; the manifest's "12" count above excludes `guard-fanout.sh` because
  it predates the current manifest generation — both counts are internally consistent, see raw
  `ls` output). GSD's 9 hooks are **not** in this repo — confirming GSD is a separate product,
  not something `claude-practices` installs.

### `.planning/` directories (GSD project markers)

`find C:/Dev C:/Clients -type d -iname ".planning"` (depth 5, then depth 8 on `C:/Dev`) —
**zero results**, anywhere. No project on this machine has ever been initialized as a GSD
project.

---

## 2. Cut candidates

Each entry states the evidence, then the counter-argument. None of these cite the
session-metrics log as their evidence.

### 2a. The entire GSD apparatus (68 skills, 24 agents, 9 hooks) — strong evidence, but a scoped recommendation

**Evidence (four independent signals, not one):**
1. Zero `.planning/` directories anywhere on the machine (§1) — the one condition
   `guard-agent-ownership.sh` (`C:\Users\dpchr\.claude\hooks\guard-agent-ownership.sh`) checks
   before letting a `gsd-*` agent through (`[ -d ".planning" ] && exit 0`, else block).
2. Zero real `gsd-*` agent dispatches. `grep -rho '"subagent_type":"[^"]*"' ~/.claude/projects/`
   across the entire transcript corpus returns 208 general-purpose, 115 dave-researcher, 60
   bob-verifier, 19 Explore, 10 gru-planner, 7 stuart-explorer, 6 claude-code-guide, 5
   kevin-security, 4 phil-test-author, 4 mel-design, 4 jerry-docs, 3 carl-evals — **and no
   `gsd-*` entry at all.**
3. Zero literal `/gsd-*` slash-command invocations. `grep -rho '"content":"/gsd-[a-z-]*'` = 0
   matches; `grep -rho '<command-name>/gsd-[a-z-]*'` = 1 match, and tracing it
   (`C:\Users\dpchr\.claude\projects\...\bfac4616.../subagents/agent-ac209d3c....jsonl`) shows it
   is this GC-pass session's own bash command quoting the search pattern back at itself — i.e.
   the true count is 0. (Caution for next month: a naive `grep '/gsd-plan-phase'` against the
   transcripts returns hundreds of hits, but those are path-fragment matches — e.g.
   `.claude/skills/gsd-plan-phase/SKILL.md` in a directory listing — not invocations. Use the
   `<command-name>` or literal-content anchors above, not a bare substring search.)
4. GSD is itself stale: `~/.cache/gsd/gsd-update-check.json` →
   `{"installed":"1.34.2","latest":"1.42.3","checked":1788921663}` — 8 minor versions behind,
   and every `gsd-*` file's mtime is frozen at `2026-04-08 11:12` (install day), vs. the kit's
   own files which show today's date from this session's maintenance work. Nobody has touched
   or updated it in 5 months.

**Counter-argument:** GSD is a real, actively-developed third-party framework (its own
changelog is 8 versions ahead), installed deliberately, and the ownership hook
(`guard-agent-ownership.sh`) already does exactly what `kit-maintenance.md` asks — it fences
GSD's agents off from the named-persona agents rather than letting them collide, and gets out
of the way *inside* a real GSD project. If Daniel ever wants to run a GSD-managed project, all
68 skills are one `.planning/` directory away from being "legitimate" again per the hook's own
logic. Uninstalling GSD outright is a bigger, harder-to-reverse action than this GC pass should
take unilaterally.

**Recommendation is therefore split, not a flat cut:**
- **Skills and agents (68 + 24): leave installed, but this is a "why do we have this"
  question for Daniel, not silently defensible dead weight.** They cost nothing at rest (no
  hook fires unless invoked) and deleting them loses the option.
- **Hooks (9): these are NOT free.** `gsd-context-monitor.js`, `gsd-prompt-guard.js`,
  `gsd-read-guard.js`, `gsd-workflow-guard.js`, and `gsd-validate-commit.sh` are wired to
  `PostToolUse`/`PreToolUse` on `Bash|Edit|Write|MultiEdit|Agent|Task` **globally** — they run on
  every single tool call in every session, GSD project or not, and have been doing so for 5
  months with zero payoff since no project has ever used GSD. This is the one piece of the GSD
  apparatus with a real, ongoing, machine-wide cost regardless of intent-to-keep-optionality. If
  keeping GSD "just in case," disabling its 9 hooks specifically (not uninstalling the
  skills/agents) removes the tax while preserving the option to re-enable them the day a GSD
  project actually starts.

### 2b. `skill-creator` (kit copy) — moderate evidence, clean merge available

**Evidence:** `diff ~/.claude/skills/skill-creator/SKILL.md` against the plugin's
`~/.claude/plugins/cache/claude-plugins-official/skill-creator/340e33aef211/skills/skill-creator/SKILL.md`
shows the two are near-identical (same structure, same eval-loop description) except the
plugin version has newer content the kit copy lacks (an "Updating an existing skill" section,
minor wording fixes) — the plugin copy is the actively-maintained upstream, the kit copy is a
stale fork. `grep` across the full Skill-invocation record (`"name":"Skill"..."input":
{"skill":"..."}`) shows **zero invocations of `skill-creator` under either name**, ever.

**Counter-argument:** Zero recorded use over the corpus doesn't prove it's never needed —
skill-creation is inherently a rare, bursty task. But since this isn't really a "cut for
disuse" case — it's a duplicate — the disuse finding is secondary to the duplication finding
in §3.

### 2c. `github@claude-plugins-official` — strong evidence (already known-broken)

**Evidence:** The tool-connection system message for this session states the MCP server fails
outright: `Error POSTing to endpoint: bad request: Authorization header is badly formatted`.
Corroborating: `grep -rl '"type":"tool_use"[^}]*"name":"mcp__github"' ~/.claude/projects/` = 0
files, ever — consistent with a server that has never successfully connected.

**Counter-argument:** none really — a plugin that cannot connect provides nothing today. The
only reason not to flip it off is if fixing the auth header is trivial and imminent; otherwise
disabling it costs nothing (it's already contributing nothing) and stops it silently occupying
a plugin slot.

### 2d. `context7`, `claude-md-management`, `claude-code-setup`, `playground` plugins — weak-to-moderate evidence

**Evidence:** `grep -rl '"type":"tool_use"[^}]*"name":"mcp__plugin_context7'
~/.claude/projects/` = 0 files. No `claude-md-management:*`, `claude-code-setup:*`, or
`playground:*` skill name appears anywhere in the full `"name":"Skill"` invocation extraction
(the complete list of every skill ever actually invoked on this machine is in §5's table —
these four are simply absent from it).

**Counter-argument:** this is genuinely closer to the "log is too sparse" trap the brief warns
against, except the corpus here is the *entire* tool-call history, not the 14-row curated log —
a materially stronger denominator. Still, all four are low-cost to keep (no hooks, no
always-loaded rules) and `context7` in particular is the kind of tool that's plausibly useful
the moment a docs-lookup task appears, even if it hasn't yet. **Recommendation: flag, don't
cut** — re-check in 30 days with the same grep; if still zero after two GC passes, that's a
real trend rather than a single snapshot.

### 2e. `pyright-lsp@claude-plugins-official` — evidence is structurally unavailable

**Evidence:** 0 hits for any tool name containing "pyright" in `tool_use` blocks.

**Counter-argument:** this plugin is very likely an LSP integration that runs passively
(diagnostics surfaced to the editor) rather than through discrete tool calls the transcript
would ever record. The zero-count here may be measuring "this kind of plugin doesn't emit tool
calls," not "this plugin is unused." **Do not cut on this evidence — it is the wrong instrument
for this plugin type** (see §5).

---

## 3. Merge candidates

### 3a. MCP-server-building: three overlapping sources, same trigger language

- **`mcp-builder`** (kit skill, `~/.claude/skills/mcp-builder/SKILL.md:2`): *"Use when building
  MCP servers to integrate external APIs or services, whether in Python (FastMCP) or
  Node/TypeScript (MCP SDK)."*
- **`mcp-developer`** (kit skill, `~/.claude/skills/mcp-developer/SKILL.md:2`): *"Use when
  building, debugging, or extending MCP servers or clients that connect AI systems with
  external tools and data sources."*
- **`mcp-server-dev:build-mcp-server`** (plugin,
  `~/.claude/plugins/cache/claude-plugins-official/mcp-server-dev/340e33aef211/skills/build-mcp-server/SKILL.md:3`):
  *"This skill should be used when the user asks to 'build an MCP server', 'create an MCP',
  'make an MCP integration'... It is the entry point for MCP server development."*

All three fire on the identical prompt "help me build an MCP server." None of the three shows a
single confirmed invocation in the full transcript corpus (§2d's method, same null result for
all three names). **Proposed merge:** keep `mcp-server-dev` (it's the actively-maintained
official plugin, explicitly designed as a routing entry point that hands off to
`build-mcp-app`/`build-mcpb` for sub-cases) and retire both kit skills (`mcp-builder`,
`mcp-developer`) — their content is a strict subset of what the plugin's three-skill family
already covers.

### 3b. Adversarial-review skills: `the-fool` vs. `socratic-examiner`

- **`the-fool`** (`~/.claude/skills/the-fool/SKILL.md:6`, metadata `triggers:`): *"play the
  fool, devil's advocate, challenge this, stress test, poke holes, what could go wrong, red
  team, pre-mortem, test my assumptions"*
- **`socratic-examiner`** (`~/.claude/skills/socratic-examiner/SKILL.md`, "Trigger for" list):
  *"Requests to poke holes, push back, play devil's advocate, or steelman/anti-steelman... 'Does
  this hold up?' / 'Am I missing anything?' / 'Challenge this'"*

Both explicitly claim "challenge this," "devil's advocate," and "poke holes" as triggers — a
direct collision on the single most likely user phrasing for this whole category.
`the-fool` additionally claims "pre-mortem" and "red team," which `socratic-examiner` doesn't
name but functionally overlaps with (stress-testing a plan before committing). **Proposed
merge:** sharpen rather than merge — `the-fool` reads as the harsher/structured critique mode
(pre-mortem, red-team, audit evidence) and `socratic-examiner` as the Socratic-questioning mode
(surfacing weaknesses via questions, "not to tear down, but to strengthen"). Repoint the two
`description:` fields so each owns distinct trigger phrases: give "devil's advocate / challenge
this / poke holes" to one (recommend `socratic-examiner`, since it already hedges with "not to
tear down") and reserve "red team / pre-mortem / test my assumptions" for `the-fool`. As written
today, a user typing "challenge this" cannot predict which one fires.

### 3c. Session-record-keeping: three mechanisms doing the same job

- **Manual practice** — global `CLAUDE.md`: *"append one row to `~/.claude/session-metrics.md`"*
  at session end.
- **`session-metrics-stub.sh`** hook (`~/.claude/hooks/session-metrics-stub.sh`, wired to
  `SessionEnd`) — auto-appends an `AUTO-STUB` row with the four judgment columns left as `?`,
  observed live in the log: 6 of `session-metrics.md`'s 14 rows are exactly this stub, never
  filled in.
- **`session-report@claude-plugins-official`** plugin, providing skill
  `session-report:session-report` — same stated purpose (session summary/report) as a plugin
  skill, 0 confirmed invocations.

**Proposed merge:** the stub hook and the plugin skill both exist to reduce the friction of the
manual practice, and neither has closed the gap — the log still has 6 unfilled stub rows. Pick
one mechanism: either wire the plugin skill to actually run at `SessionEnd` and fill the four
judgment fields (closer to the original intent), or drop the plugin and keep the hook +
manual fill, but stop paying for three code paths that all target the same one artifact.

### 3d. `frontend-design` naming collision (not quite duplication)

- Kit's `~/.claude/skills/frontend-design/SKILL.md:3`: *"Create distinctive, production-grade
  frontend interfaces with high design quality... Generates creative, polished code..."*
- Plugin's
  `~/.claude/plugins/cache/claude-plugins-official/frontend-design/340e33aef211/skills/frontend-design/SKILL.md:3`:
  *"Guidance for distinctive, intentional visual design when building new UI or reshaping an
  existing one. Helps with aesthetic direction, typography..."*

These are **not** the same file (unlike `skill-creator`) — genuinely different approaches under
the identical name `frontend-design`. This is a name collision, not a content duplicate: with
both installed, it's ambiguous which "wins" when both are eligible, and the one Skill-tool
invocation logged simply as `"skill":"frontend-design"` (no `plugin:` prefix) cannot be
attributed to either with certainty from the transcript alone. **Proposed fix:** rename the kit
copy (e.g. `frontend-design-build` vs. the plugin's aesthetic-direction focus) or retire it in
favor of the plugin's version, rather than leaving two same-named skills to silently shadow each
other.

---

## 4. Orphans and broken references

| Item | Path | Status | Evidence |
|---|---|---|---|
| `guard-readonly-bash.sh` | `C:\Users\dpchr\.claude\hooks\guard-readonly-bash.sh` | **Orphan** | Referenced by nothing. Confirmed via `grep -l "guard-readonly-bash" $(find ... -iname settings*.json)` across global `~/.claude/settings.json`, all 5 project `.claude/settings.json` under `C:\Dev`, and `C:\Clients` (which has no `.claude/settings.json` at all) — zero matches anywhere. It exists in both `~/.claude/hooks/` and the kit repo's `hooks/guard-readonly-bash.sh`, and is documented in three agent files (`carl-evals.md`, `kevin-security.md`, `mel-design.md`) as if it runs — but no `settings.json` on this machine wires it to any event. |
| `session-context.ps1` | `C:\Users\dpchr\.claude\hooks\session-context.ps1` | **Orphan** | Same check, same result: zero `settings.json` references anywhere. Its sibling `session-context.sh` **is** wired (`SessionStart`, global `settings.json`) — this is very likely a Windows-native PowerShell equivalent that was written and shipped but never actually swapped in, even though this whole machine is Windows. That's the exact "built, then never connected" pattern the capability brief names as the dominant failure mode. |
| `failure-modes-SKILL.md` | `C:\Dev\claude-practices\skills\failure-modes-SKILL.md` | **Likely stray duplicate** | Sits next to the real `skills/failure-modes/` directory (which has its own `SKILL.md` inside it). A loose file with the same content pattern outside its skill directory does not get picked up as a skill by Claude Code's directory-based skill loader — it is inert. Recommend confirming with `diff` against `skills/failure-modes/SKILL.md` and deleting the stray copy (not done here per the read+write-one-file constraint). |
| `subagent-audit.sh` diagnostic output | `C:\Dev\Civ_Project\.claude\orchestration-log.txt` | **Wired and firing, but broken** | The hook *is* mechanically proven to fire (86+ lines written), but its `agent_name` field extraction (`grep -oE '"agent_name"...'`) never matches the real `SubagentStop` payload shape — 3/3 of its own log lines read `agent=unknown`. Compare `guard-verdict.sh` in the same hook family, which reads `"agent_type"` (not `"agent_name"`) from the same event — the two hooks disagree with each other about the field name in the same payload. One of them is wrong. |
| `log-instructions-loaded.sh` diagnostic output | same file, `loaded=` lines | **Wired and firing, but broken** | 86 of 89 total lines in the log are `loaded=(none captured)` — the hook fires on every `InstructionsLoaded` event (proving the event and the wiring both work) but its `"path"` field extraction never matches, so five months of this hook running has produced zero usable diagnostic data. This is a second, independent instance of the exact bug class the capability brief flagged for `subagent-audit.sh` — worth a single fix pass across both rather than two separate ones. |
| `guard-fanout.sh` "opt-in — not enabled by default" comment | `C:\Users\dpchr\.claude\hooks\guard-fanout.sh` (comment block) | **Stale comment, not a functional orphan** | The script's own header comment describes its wiring as optional/opt-in, but the deployed global `settings.json` has it wired unconditionally on every `Agent` PreToolUse call. The comment is simply out of date relative to the deployment — harmless, but another instance of doctrine (in this case, a code comment) not being re-read for truth after the world changed. |
| `productivity:start` | (skill invoked once per transcript grep) | **Dangling reference to a since-removed source** | The full Skill-invocation extraction (§5) shows one historical call to `"skill":"productivity:start"` — a plugin/skill namespace that does not appear anywhere in the current `enabledPlugins` or the current available-skills listing. Either a plugin was later uninstalled/renamed, or this was a typo'd invocation that silently no-op'd. Not independently confirmed which; flagging only. |

**Verified NOT orphaned (checked because they looked suspicious):**
- `stop-verify.sh` — not in global `settings.json`, but confirmed wired at the **project** level
  in all 5 `C:\Dev\*\.claude\settings.json` files (`Stop` hook, identical one-liner in each).
  This matches the capability brief's claim of "stop-verify gating all 5 active projects"
  exactly — real and correctly deployed, just not global.
- `guard-agent-ownership.sh` — wired globally (`PreToolUse`/`Agent`), confirmed by direct read
  of both the hook and the `settings.json` entry; logic verified by reading the script (see §2a).

---

## 5. What signal would we need to decide the undecidable ones?

The instrument used this pass — full-corpus transcript grep for actual `tool_use`/`Skill`
invocations — is meaningfully stronger than the 14-row `session-metrics.md` log, but it still
has real blind spots. Documenting them so next month's pass doesn't over-trust this one:

1. **LSP-style and passive plugins (`pyright-lsp`) are invisible to a tool_use grep by
   design.** They don't get invoked as discrete tool calls; they run continuously in the
   background. **What would fix it:** a way to query whether the LSP client actually attached
   to a session (a connection log, or a "diagnostics surfaced" counter) — this doesn't exist
   today and would need to come from Claude Code's own plugin-runtime logging, not anything
   greppable in `~/.claude/projects/`.

2. **A skill can be genuinely low-frequency-but-valuable** (e.g. `mcp-builder`,
   `skill-creator`) rather than dead. Zero invocations in 5 months is consistent with both "never
   needed" and "needed twice a year, hasn't come up yet." **What would fix it:** a longer
   observation window (the brief's own monthly-recurrence plan helps here) plus a distinction
   this pass couldn't make — was the *opportunity* to use it ever present? That requires
   knowing what kinds of tasks Daniel actually worked on each session, which lives in the
   session content itself, not in a tool-call count. A cheap proxy: grep session prompts (not
   tool calls) for the skill's own trigger keywords, to see how often the *opportunity* arose
   even when the skill didn't fire — that would separate "never came up" from "came up and got
   ignored," which are very different findings.

3. **Provenance of the ~17 "other/legacy" skills (§1) is genuinely unknown from what's on
   disk.** The kit's own install manifest doesn't list them; their mtimes (Mar 5 / Apr 8 2026)
   predate the manifest's generation date; several of them (`docx`, `pptx`, `xlsx`,
   `mcp-builder`, `frontend-design`, `skill-creator`) have exact-name twins under the
   `anthropic-skills:` plugin namespace, which strongly suggests they were installed by an
   older version of the `claude-practices` installer, or copied in manually, before Claude Code
   started shipping these as a bundled default. **What would fix it:** the kit's own git
   history (`git log --diff-filter=A -- skills/docx` etc., in whichever repo originally added
   them) would settle this in minutes — deliberately excluded from this pass by the
   no-git-writes/read-only-except-one-file constraint, but a `git log` is a read, not a write,
   so this is the one piece of homework worth doing as an explicit follow-up rather than
   guessing here.

4. **The rolling `guard-fanout` state directory (`${TMPDIR}/claude-fanout`) only retains
   whatever hasn't been cleaned up**, so a raw file count there tells you activity in the
   current window, not lifetime usage — it's a good "is this hook alive right now" check (it
   is: 4 session-id files present, one from 2026-09-07, one from this session) but a poor
   "how often has this ever fired" check. **What would fix it:** the fanout guard would need to
   append to a durable log on top of (not instead of) its rolling counter if lifetime frequency
   ever becomes a question worth answering.

5. **Full Skill-invocation table from this pass, for the record** (so next month's pass can
   diff against it instead of re-deriving it):

   | Skill | Invocations found |
   |---|---:|
   | `session-workflow` | 9 |
   | `superpowers:brainstorming` | 6 |
   | `superpowers:subagent-driven-development` | 5 |
   | `anthropic-skills:daniel-context` | 4 |
   | `thinking-partner` | 3 |
   | `superpowers:writing-plans` | 3 |
   | `the-fool` | 1 |
   | `superpowers:write-plan` (deprecated alias) | 1 |
   | `superpowers:using-git-worktrees` | 1 |
   | `superpowers:executing-plans` | 1 |
   | `superpowers:dispatching-parallel-agents` | 1 |
   | `stop-slop` | 1 |
   | `productivity:start` (dangling, see §4) | 1 |
   | `loop` | 1 |
   | `local-models` | 1 |
   | `frontend-design` (unscoped — see §3d ambiguity) | 1 |
   | `docx` | 1 |
   | `dataviz` | 1 |
   | `code-review` | 1 |
   | *(everything else — all 68 `gsd-*` skills, `mcp-builder`, `mcp-developer`, `skill-creator`, `debugging-wizard`, `failure-modes`, `feynman-explainer`, `assumption-archaeologist`, `socratic-examiner`, `patterns-guide`, `sql-pro`, `pandas-pro`, `labarr-ml`, `claude-api`, `outside-the-box`, `web-scraper-main`, `xlsx`, `pptx`, all plugin-namespaced skills except those listed above)* | **0** |

   And the agent-dispatch table:

   | Agent | Dispatches found |
   |---|---:|
   | `general-purpose` | 208 |
   | `dave-researcher` | 115 |
   | `bob-verifier` | 60 |
   | `Explore` | 19 |
   | `gru-planner` | 10 |
   | `stuart-explorer` | 7 |
   | `claude-code-guide` | 6 |
   | `kevin-security` | 5 |
   | `phil-test-author` | 4 |
   | `mel-design` | 4 |
   | `jerry-docs` | 4 |
   | `carl-evals` | 3 |
   | `otto-rules` | **0** |
   | *(all 24 `gsd-*` agents)* | **0** |

   `otto-rules` is the one named-persona agent among the kit's 10 with zero recorded dispatches
   — worth a second look next month specifically, since it's the only kit-authored (not GSD)
   agent with this profile, and the "it's rarely needed but valuable" counter-argument that
   protects `mcp-builder` etc. applies less cleanly to a mechanical rule-checker that should, in
   principle, be cheap to invoke often.
