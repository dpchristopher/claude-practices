# Phase 1b — Community and Issues Mining

> Sweep of `github.com/anthropics/claude-code` issues, shipped plugins/skills on GitHub, and
> Hacker News threads (2026). Filtered against: does this help THIS kit, these projects, these
> clients (Betsey Brown Travel, The Caregiver Club, Civ_Project)? Not "is this novel."
>
> Distinguish maintainer statements from user claims throughout. Where I could not independently
> verify a claim (couldn't read the primary source, or it came only from a blog/search-summary),
> it's marked **not verified**.

---

## 1. Compositions worth stealing

### 1.1 `disler/claude-code-hooks-mastery` — full 13-event lifecycle reference implementation
https://github.com/disler/claude-code-hooks-mastery

Implements all 13 hook events (Setup, SessionStart, UserPromptSubmit, PreToolUse, PostToolUse,
PostToolUseFailure, PermissionRequest, PreCompact, Notification, Stop, SubagentStart,
SubagentStop, SessionEnd) as one coherent system, not a grab-bag. Three things worth stealing
directly:

- **PostToolUse as a quality gate, not a logger.** A `/plan_w_team` command pairs builder and
  validator agents; PostToolUse hooks run Ruff and a type checker and **block** on failure,
  forcing the agent to fix issues before proceeding — rather than logging the failure for a human
  to notice later. This is the tier-2 (hook, fires automatically) version of what Daniel's
  `output-accuracy.md` rule is currently doing at tier 3 (always-loaded rule, works if Claude
  reads it).
- **PreCompact transcript backup.** Every compaction gets a backup written first — directly
  relevant given Daniel's kit has no PreCompact handling today and long subagent-heavy sessions
  are exactly where compaction-driven context loss bites.
- **UV single-file scripts for hook isolation.** Each hook is a self-contained script with
  embedded dependency declarations (`uv run` style) so hook logic never depends on whatever venv
  happens to be active. Solves a real footgun a Hacker News commenter flagged independently on a
  different hooks package (see §5, HN item on the Python hooks utility): "doing a pip install AND
  running the script in whatever env is active... can easily lead to problems."

### 1.2 `karanb192/claude-code-hooks` — installable hook marketplace, safety/cost/observability/productivity
https://github.com/karanb192/claude-code-hooks

A curated marketplace of 20+ hooks, each a separate installable plugin, each running as its own
process ("so prompt injection cannot bypass them"). The standouts, mapped to gaps this session's
audit found in Daniel's kit:

- **`config-guard`** — blocks the agent from tampering with its own guardrail config
  (settings.json, hooks files, plugin manifests). This is the *actual hook* version of the
  `guard-fanout` probation clause that "fired 5 times, logged 0 times" because its enforcement
  depended on a manual step. A real PreToolUse deny on writes to `.claude/settings*.json` and
  `.claude/hooks/**` would move that rule from tier 4 (works if Daniel remembers) to tier 2
  (fires automatically) — exactly the tier-lowering the brief's mechanizing-doctrine model calls
  for.
- **`protect-secrets`** and **`instructions-audit`** — the first blocks reading/writing/exfiltrating
  `.env`, SSH keys, cloud credentials; the second scans loaded CLAUDE.md files for hidden
  directives (invisible Unicode smuggling, decode-and-execute patterns) and **locks the session**
  if found. This second one is squarely relevant to the two client repos this session found had
  "no secrets guard at all" — Betsey Brown Travel and Caregiver Club content will include
  third-party documents/emails/web content, which is exactly the injection surface
  `instructions-audit` targets.
- **`dead-end-registry`** — remembers reverted approaches and warns before Claude retries them.
  A mechanized version of `loop-cost-discipline.md`'s "kill the loop early if two consecutive
  iterations produce no measurable improvement" — except enforced by a hook instead of relying on
  Claude to remember the rule mid-session.
- **`nerf-receipts`** — a personal flight recorder tracking failure rates, edit churn, and
  tokens-per-task by model version, automatically. Daniel's global rule requires manually logging
  "one row per session to `~/.claude/session-metrics.md`" — this hook does the same job without
  depending on Daniel remembering at session end.
- **`cache-tax`** — warns before cold-starting a lapsed prompt cache "at up to 80x the normal
  read rate." Since usage cost is explicitly deprioritized in the brief ("doing this well beats
  doing it cheap"), this is optional, but the underlying fact (cache misses cost up to 80x) is
  worth knowing regardless of whether the warning hook gets installed. **Not independently
  verified** — the 80x figure is the plugin author's own framing, not confirmed against Anthropic
  pricing docs in this pass.

### 1.3 PreCompact → SessionStart context-handoff family
- https://github.com/who96/claude-code-context-handoff
- https://github.com/mvara-ai/precompact-hook
- https://github.com/u-ichi/compact-plus

Three independent implementations of the same composition: a PreCompact hook captures
state/summary before compaction fires, and a SessionStart hook re-injects it as
`additionalContext` on the next turn. `compact-plus` specifically generates a 10-section state
file before backing up the transcript. This is worth stealing as a pattern (not necessarily one
specific repo's code) because it directly targets the failure mode these authors call
"intelligence degradation after auto-compaction" — which is a plausible root cause for the kind
of context loss that produces exactly the "built correctly, then never connected" pattern this
session's audit found repeatedly, if any of that forgetting happened mid-session rather than
across sessions.

### 1.4 `zircote/claude-team-orchestration` — 7 named orchestration patterns for agent teams
https://github.com/zircote/claude-team-orchestration

Names and packages seven distinct multi-agent patterns as reusable commands: parallel specialists,
pipelines, self-organizing swarms, research+implement, plan approval, refactoring, and an RLM
(Recursive Language Model, arXiv:2512.24601 — **not independently verified**, citation as given by
the repo, not read directly) pattern for chunked analysis of files larger than the context window.
Given Daniel is described as a heavy subagent user with 34 of his own agents plus 24 from GSD,
having named patterns (rather than ad hoc fan-out each time) is itself the value — it turns "how
should I structure this dispatch" into a lookup instead of a fresh decision every time.

**Caveat that matters more than the plugin itself:** this plugin's core mechanism is
SendMessage-based peer coordination between spawned teammates. §2 below documents that
subagent-originated SendMessage is currently broken or inconsistent across at least five open/
duplicate issues on `anthropics/claude-code`. Treat this plugin's "agents self-coordinate via
SendMessage" claims as **aspirational-per-the-docs, not verified-working** until tested locally on
Daniel's installed version — this is precisely the "distrust agent self-reports" caution generalized
to a plugin's own claims about itself.

### 1.5 `mintmcp/agent-security` — secrets scanning as a cross-tool hook
https://github.com/mintmcp/agent-security

A dedicated secrets-scanning hook package that targets **both** Claude Code and Cursor from one
codebase (PreToolUse on Read, `claude-secret-scan --mode=pre`). Worth stealing specifically because
it's written to be tool-agnostic — if Daniel or a client ever mixes editors, the guard travels with
the repo instead of being re-implemented per tool.

### 1.6 The `cygpath` wrapper — a concrete Windows fix for Git-Bash-based hooks
https://github.com/anthropics/claude-code/issues/21878#issuecomment-3854440905

Not a plugin, but a copy-pasteable composition: a community member's workaround for the
`${CLAUDE_PLUGIN_ROOT}` backslash-path bug (see §2) rewrites the hook's `command` field to convert
the path with `cygpath -u` before invoking the real script:

```json
"command": "bash -c 'FIXED_ROOT=$(cygpath -u \"${CLAUDE_PLUGIN_ROOT}\" 2>/dev/null || echo \"${CLAUDE_PLUGIN_ROOT}\"); \"$FIXED_ROOT/hooks/session-start.sh\"'"
```
Reported by the author as tested working with **both superpowers and ralph-loop plugins** on
Windows + Git Bash. This is directly actionable for Daniel today, not a future upgrade — see §4.

---

## 2. Known limitations and gotchas affecting his setup (Windows + Desktop especially)

### Windows / Git Bash path handling
- **`${CLAUDE_PLUGIN_ROOT}` resolves to a Windows backslash path, which Git Bash misreads as
  escape sequences** — breaks every shell-script hook shipped by a plugin, confirmed against the
  **superpowers plugin specifically** (the one in active use per Daniel's global CLAUDE.md).
  Issue [#21878](https://github.com/anthropics/claude-code/issues/21878) (filed against v2.1.23,
  closed 2026-03-05 as stale/inactive — **closed for inactivity, not confirmed fixed**).
  A duplicate, [#22337](https://github.com/anthropics/claude-code/issues/22337), reproduced the
  identical failure against `superpowers@claude-plugins-official v4.1.1` by name, with the error
  `SessionStart:startup hook error` on every startup. Workaround: the `cygpath` wrapper in §1.6.
  **Action item:** check whether Daniel is currently seeing this error on startup (it would show
  as a `SessionStart:startup hook error` line) — if so it's silent right now the same way the
  8-dead-hooks pattern was silent.
- Related, narrower: hooks fail when the Windows user profile path contains spaces
  ([#40084](https://github.com/anthropics/claude-code/issues/40084)) — worth a one-time check of
  the machine's username, not urgent if it doesn't contain a space.

### Claude Code Desktop on Windows — version-specific bugs seen in 2026
These are Desktop-specific (Daniel's literal client), not CLI:
- Process exits with code 1 on every session start —
  [#52766](https://github.com/anthropics/claude-code/issues/52766) (2026-04-24).
- ECONNRESET connection failures introduced by a specific Aug 2026 Desktop update (1.25927.0.0),
  **not fixed** by the immediate follow-up update (1.26832.0.0) —
  [#84818](https://github.com/anthropics/claude-code/issues/84818) (2026-08-07).
- `spawn ENAMETOOLONG` on every chat, Windows-only, works fine on Mac —
  [#72725](https://github.com/anthropics/claude-code/issues/72725) (2026-07-01).
- GPU process crash leaves the main process hung, requiring a full "Repair" via Windows Settings →
  Apps — [#81836](https://github.com/anthropics/claude-code/issues/81836) (2026-07-28).
- Window stays always-on-top with no setting to disable —
  [#87895](https://github.com/anthropics/claude-code/issues/87895) /
  [#88093](https://github.com/anthropics/claude-code/issues/88093) (2026-08-19).
- Bad registry autorun entry — [#51693](https://github.com/anthropics/claude-code/issues/51693).

None of these were confirmed as currently affecting Daniel's install — this is a "check your
version against these issue numbers before they surface mid-client-work" list, not a confirmed
active bug report.

### bypassPermissions is unreliable in ways that specifically hit hook-driven workflows
Meta-issue [#39523](https://github.com/anthropics/claude-code/issues/39523) (opened 2026-03,
maps 12+ duplicates going back to **2025-07**, still open) documents two correlated failure
branches:
1. **Protected directories (`.claude/`, `.git/`, `.vscode/`, `.idea/`) ignore every bypass
   mechanism** — the CLI flag, the settings default, the VSCode setting, and PreToolUse hooks
   returning `permissionDecision: "allow"` are all overridden for these paths. One duplicate,
   [#38543](https://github.com/anthropics/claude-code/issues/38543), is the Windows-specific
   instance: "Bypass mode still prompts for every edit on Windows."
2. **Permission mode spontaneously downgrades mid-session** from bypass to "accept edits,"
   triggered (per one comment, **user claim, not verified**) even by incoming MCP channel
   notifications in multi-session setups.
- Separately, since **2.1.110**, a hook's `PermissionRequest` response with
  `setMode: "bypassPermissions"` is **silently dropped** — the tool call is allowed but the
  session mode never actually changes, with no error surfaced anywhere
  ([#49525](https://github.com/anthropics/claude-code/issues/49525), confirmed by the reporter
  across 2.1.110–2.1.114, and independently re-confirmed by a second user bisecting back to
  2.1.107 as the last known-good version). This is a **maintainer-adjacent** finding in the sense
  that the issue explicitly ties it to a documented 2.1.110 changelog entry about
  `disableBypassPermissionsMode`, but no maintainer reply confirms intent as of this reading.
- A regression in interactive mode: a PreToolUse hook returning `permissionDecision: "allow"` with
  exit 0 (JSON confirmed parsed by the debug log) still shows the native "Do you want to X?"
  prompt anyway, on v2.1.119 — [#52822](https://github.com/anthropics/claude-code/issues/52822).
  The reporter notes this is a regression relative to a previously-fixed issue (#28812, confirmed
  working on v2.1.59), i.e., this specific behavior has broken and been fixed before.

**Net effect for Daniel:** any hook that tries to *grant* bypass or *suppress* a prompt
programmatically is on unstable ground right now — verify locally rather than trusting that a
hook returning `"allow"` or `setMode: bypassPermissions` is actually taking effect.

### Exit code 2 may make Claude stop instead of self-correct
[#24327](https://github.com/anthropics/claude-code/issues/24327): when a PreToolUse hook exits
with code 2 (the documented "blocking error, stderr fed back to Claude" code), Claude Code's
current behavior may be to **stop** rather than read the stderr reason and adapt. If true, any
hook designed as "block with a reason so Claude corrects itself" (which is the phil/otto/bob-style
"deny with reason so Claude can retry" model, and matches the deny-with-reason praise from the HN
thread in §5) may instead just halt the turn — meaning "the hook fired" and "Claude adapted" are
not the same event, and an audit that checks only whether the hook fired (the same category of
mistake the brief's INV-02 finding made) would miss this.

### SessionEnd hooks are killed before non-trivial async work completes
[#41577](https://github.com/anthropics/claude-code/issues/41577): a SessionEnd hook that shells
out to do real work (the reporter's repro calls `claude -p --model haiku` to summarize the
transcript) gets killed when the parent process exits, **even with a 90-second timeout
configured**. Confirmed reproducible by the original reporter; the documented workaround is to
detach the work into a `nohup ... & disown`'d background process, which means the hook has no way
to report errors back and the timeout has to be self-managed inside the detached script.
**Relevant directly:** Daniel's own Session Protocol requires writing `.claude/HANDOFF.md` and
appending to `~/.claude/session-metrics.md` at session end — if either of those is ever driven by
a SessionEnd hook (rather than Claude doing it inline before ending the turn) and that hook does
anything beyond a fast synchronous local file write, it is a candidate for exactly this silent
kill.

### SendMessage from spawned subagents — the exact class of problem tonight's answer came from
Given the brief explicitly flags this ("Tonight's SendMessage answer came from here"), the current
state across open issues is: subagents can **receive** SendMessage but multiple reports say they
cannot reliably **originate** it.
- [#48160](https://github.com/anthropics/claude-code/issues/48160) (2026-04-14): a parent spawned
  four named subagents under `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` with `SendMessage(*)`
  permission; three of four subagents reported `SendMessage` was not in their toolset at all
  (`ToolSearch("select:SendMessage")` returned no match), degrading the team to isolated workers
  needing manual parent-side relay. Auto-flagged by the repo's bot as a likely duplicate of
  [#35240](https://github.com/anthropics/claude-code/issues/35240),
  [#38183](https://github.com/anthropics/claude-code/issues/38183), and a third, indicating this
  has been reported at least four separate times.
- [#42999](https://github.com/anthropics/claude-code/issues/42999): SendMessage silently fails
  when addressed by agent **name** (as documented) — only the agent **ID** actually works, with a
  false-success response on the name path (**user claim**).
- [#78338](https://github.com/anthropics/claude-code/issues/78338) (2026-07-17): queued messages
  in background agents can be dequeued and destroyed before delivery is confirmed, while the
  sender still holds a success result — i.e., a successful-looking send can still be lost.
- [#90481](https://github.com/anthropics/claude-code/issues/90481) (2026-08-28): cross-session
  messaging can become **permanently** disabled after an update, surviving reboot/reinstall
  (**user claim, single report, not corroborated in this pass**).

**Implication for the kit:** the parent-relays-everything pattern Daniel is presumably already
using (since the doc-writing agents, Bob, Gru etc. report back to a human/orchestrator rather than
messaging each other directly) is the currently-robust pattern. Anything betting on peer-to-peer
subagent messaging as designed should be treated as experimental-and-currently-broken, not merely
"advanced."

---

## 3. Capabilities revealed by issues that docs describe poorly or not at all

These came from Anthropic's own internal `hook-development` skill doc
(`plugins/plugin-dev/skills/hook-development/SKILL.md`, in the `anthropics/claude-code` repo
itself — source code, not marketing docs, so treated as closer to ground truth than a blog) plus
patterns visible only by reading multiple bug reports side by side:

- **`permissionDecision` has three values, not two: `allow`, `deny`, and `ask`.** The `ask` value
  forces a user prompt even when the tool would otherwise auto-run — useful as a middle tier
  between silent-allow and hard-deny, and not something the top-level public docs foreground.
  (Its cross-platform reliability is itself in question — see §2's VS Code `"ask"` finding,
  [#13339](https://github.com/anthropics/claude-code/issues/13339), closed but unresolved as to
  whether it generalizes to Desktop.)
- **Exit code semantics are stricter than "0 good, nonzero bad."** Only exit code **2**
  specifically triggers stderr-fed-back-to-Claude as a blocking error; any *other* nonzero exit is
  a non-blocking error that doesn't get the same treatment. Getting this wrong (e.g. exiting 1
  instead of 2) means a hook's rejection reason silently never reaches Claude.
- **Stop and SubagentStop use a different schema than PreToolUse.** PreToolUse uses
  `hookSpecificOutput.permissionDecision`; Stop/SubagentStop instead use a bare
  `{"decision": "approve"|"block", "reason": "..."}`. This is an easy contract mix-up for anyone
  writing hooks across multiple event types — worth a direct check that Daniel's `stop-verify`
  hook (mentioned in the brief's State-at-close as "gating all 5 active projects") uses `decision`
  and not `permissionDecision`, since a field-name mismatch would silently no-op rather than error.
- **Hooks are loaded once at session start; editing hook config requires a full restart to take
  effect.** Not prominently stated in the public hooks reference. This is a second, independent
  candidate explanation (alongside the reload-only-via-`/init` template issue already found) for
  why hook or rule changes might silently fail to reach a running session — worth cross-checking
  against the specific "8 hooks fired nowhere" finding from this session's earlier audit: were any
  of those 8 installed or modified *during* a still-running session rather than picked up at next
  start?
- **All matching hooks for one event run in parallel and cannot see each other's output or
  guarantee ordering.** "Design for independence" is the internal doc's explicit guidance. Any
  hook design that assumes hook A's output is visible to hook B, or that they fire in file order,
  is building on an unsupported assumption.
- **Routines (the `/schedule` / scheduled-cloud-agent mechanism) can combine three trigger modes
  in a single Routine**: a recurring cron cadence, on-demand firing, and wiring to GitHub events
  (PRs, releases) — all three on one Routine object, not three separate configurations. This
  matters directly for the brief's own "Then make it recur" plan (Part 4): a monthly research
  sweep could be one Routine with a cron trigger, rather than a separately-remembered manual
  re-run. **Sourced from a blog summary, not read directly against primary docs — flagging as
  not independently verified in this pass**, but worth confirming directly since it bears on
  Phase 1b's own recurrence plan.

---

## 4. What questions should we now be asking that we weren't?

1. **Is the SendMessage pattern that answered tonight's question actually a supported, working
   path on Daniel's installed version — or did it work by accident, in the same territory as the
   ~5 open/duplicate issues showing subagent-originated SendMessage is broken?** Worth a direct,
   local, minimal repro (spawn one named subagent, have it try to SendMessage back) rather than
   trusting that tonight's success generalizes.
2. **Does Daniel's `stop-verify` hook use the `decision: approve|block` schema, or did it get
   written against the `permissionDecision` schema by analogy with PreToolUse hooks?** A silent
   field-name mismatch here would look identical to "hook fired but did nothing" — the exact
   failure class the whole audit session was about.
3. **Are any of Daniel's hooks relying on `exit 2` + stderr expecting Claude to read the reason
   and self-correct?** If [#24327](https://github.com/anthropics/claude-code/issues/24327) is
   accurate, "the hook fired" and "Claude adapted its behavior" are different events — an audit
   that only checks the former (as INV-02 did for hook-wiring) would repeat the same class of
   mistake for hook *effectiveness*.
4. **Is Daniel currently seeing the Git-Bash `${CLAUDE_PLUGIN_ROOT}` backslash-path bug on any
   plugin hook (superpowers included), and if so, is the `cygpath` wrapper from
   [#21878](https://github.com/anthropics/claude-code/issues/21878#issuecomment-3854440905) worth
   applying now rather than waiting on an upstream fix that's been open in some form since
   2025-07?**
5. **Has anyone verified `setMode: "bypassPermissions"` from a hook is actually taking effect on
   the version Daniel runs?** Per [#49525](https://github.com/anthropics/claude-code/issues/49525),
   this has been silently dropped since 2.1.110 with zero error surfaced — a hook built to grant
   bypass would look correct and simply not work, and nothing in the UI would say why.
6. **Does anything SessionEnd-related in the kit do non-trivial work (an API call, a summarization
   pass, anything beyond a fast local write)?** If so, per
   [#41577](https://github.com/anthropics/claude-code/issues/41577) it may be getting killed
   before completion regardless of a configured timeout — worth checking whether HANDOFF.md /
   session-metrics.md writes happen via hook or via Claude acting inline before the session ends.
7. **Given Agent Teams / peer SendMessage is explicitly experimental and its central mechanism is
   broken in at least four independently-filed ways, should the kit's subagent-heavy design
   (34 personal agents + 24 GSD agents) keep betting on the current "orchestrator relays
   everything" pattern as the stable baseline, rather than building toward peer-to-peer messaging
   that may not be reliable for months?**
8. **Is Claude Code Desktop on Windows — Daniel's literal client — currently hitting any of the
   version-specific 2026 bugs cataloged in §2 (ECONNRESET after an Aug update, ENAMETOOLONG,
   GPU-crash-requiring-Repair), and is his auto-update setting exposing him to regressions faster
   than they can be checked against the issue tracker?**
9. **Does `/schedule`'s ability to combine a cron cadence with a GitHub-event trigger on one
   Routine change how the monthly research sweep (Part 4 of the brief) should be built** — one
   Routine wired to both a monthly cadence and, say, a new Claude Code release tag — instead of a
   plain cron job?
10. **For the two client repos this session found had no secrets guard at all: does
    `instructions-audit`-style CLAUDE.md/prompt-injection scanning belong there specifically,**
    given both clients (a travel agency, a nonprofit) will regularly pull in external documents,
    emails, and web content that a hook-based scan could catch before it ever reaches doctrine?

---

## 5. Sources

GitHub issues, `anthropics/claude-code` (fetched 2026-09-08 via `gh` CLI and WebSearch):
- https://github.com/anthropics/claude-code/issues/13339 — VS Code extension ignores hook `permissionDecision: "ask"` (closed 2025-12)
- https://github.com/anthropics/claude-code/issues/52822 — PreToolUse `allow` doesn't suppress native prompt, v2.1.119 regression
- https://github.com/anthropics/claude-code/issues/49525 — Hook `setMode: bypassPermissions` silently dropped since 2.1.110
- https://github.com/anthropics/claude-code/issues/39523 — [META] bypassPermissions mode fundamentally broken, 9-month trail, 12+ duplicates
- https://github.com/anthropics/claude-code/issues/37181 — Edit tool prompts despite bypassPermissions + `--dangerously-skip-permissions`
- https://github.com/anthropics/claude-code/issues/38148 — Desktop Code tab ignores bypass mode
- https://github.com/anthropics/claude-code/issues/38543 — Bypass mode still prompts for every edit on Windows
- https://github.com/anthropics/claude-code/issues/48160 — Spawned subagents cannot originate SendMessage despite Agent Teams flag + `name=`
- https://github.com/anthropics/claude-code/issues/42999 — SendMessage silently fails when using agent name, only ID works
- https://github.com/anthropics/claude-code/issues/78338 — Background agents drop queued SendMessages
- https://github.com/anthropics/claude-code/issues/90481 — Cross-session messaging permanently disabled after update (user claim)
- https://github.com/anthropics/claude-code/issues/35240 / 38183 — related SendMessage/Agent Teams duplicates
- https://github.com/anthropics/claude-code/issues/29007 — Windows-styled paths in hook commands
- https://github.com/anthropics/claude-code/issues/21878 — Hook scripts fail on Windows: backslash paths misinterpreted by Git Bash (closed as stale 2026-03-05; includes community `cygpath` fix)
- https://github.com/anthropics/claude-code/issues/22337 — SessionStart hook fails on Windows, superpowers plugin specifically (closed as duplicate of #21878)
- https://github.com/anthropics/claude-code/issues/22700 — Hook execution uses `bash` instead of detected full path on Windows
- https://github.com/anthropics/claude-code/issues/40084 — Hooks fail when user profile path contains spaces
- https://github.com/anthropics/claude-code/issues/41577 — SessionEnd hooks killed before async work completes, even with timeout configured
- https://github.com/anthropics/claude-code/issues/24327 — PreToolUse hook exit code 2 causes Claude to stop instead of acting on error feedback
- https://github.com/anthropics/claude-code/issues/24542 — Task subagents silently hallucinate when spawned without required tool access
- https://github.com/anthropics/claude-code/issues/13898 — Custom subagents can't access project-scoped MCP servers, hallucinate instead
- https://github.com/anthropics/claude-code/issues/52766 — Desktop Windows: "process exited with code 1" every session (2026-04-24)
- https://github.com/anthropics/claude-code/issues/84818 — Desktop bundled CLI ECONNRESET after Aug 2026 update, npm CLI unaffected
- https://github.com/anthropics/claude-code/issues/72725 — Desktop `spawn ENAMETOOLONG`, Windows-only
- https://github.com/anthropics/claude-code/issues/81836 — Desktop Windows GPU process crash requires Repair
- https://github.com/anthropics/claude-code/issues/87895 / 88093 — Desktop window always-on-top on Windows
- https://github.com/anthropics/claude-code/issues/51693 — Desktop Windows autorun bad registry entry
- https://github.com/anthropics/claude-code/blob/main/plugins/plugin-dev/skills/hook-development/SKILL.md — Anthropic's internal hook-development skill doc (source-of-truth on schemas/exit codes)

Shipped plugins / skills / marketplaces (fetched 2026-09-08):
- https://github.com/disler/claude-code-hooks-mastery — 13-event hook reference implementation
- https://github.com/karanb192/claude-code-hooks — installable hook marketplace (config-guard, protect-secrets, instructions-audit, dead-end-registry, nerf-receipts, cache-tax, session-logger, auto-stage, format-code, bounty-board)
- https://github.com/who96/claude-code-context-handoff — PreCompact/SessionStart context handoff
- https://github.com/mvara-ai/precompact-hook — LLM-interpreted recovery summaries before compaction
- https://github.com/u-ichi/compact-plus — pre-compaction backup + 10-section state file
- https://github.com/zircote/claude-team-orchestration — 7 agent-team orchestration patterns incl. RLM for oversized-file analysis
- https://github.com/mintmcp/agent-security — secrets-scanning hooks for Claude Code and Cursor
- https://github.com/anthropics/claude-plugins-official — official Anthropic plugin directory

Hacker News (fetched 2026-09-08):
- https://news.ycombinator.com/item?id=47670002 — "Gave my Claude a subconscious memory system" (MCR: pre-prompt + tool-call-interception injection from a markdown vault)
- https://news.ycombinator.com/item?id=48289950 — "Claude Code as a Daily Driver: Claude.md, Skills, Subagents, Plugins, and MCPs" — critical comments on feature fragmentation/bloat, what actually gets invoked vs. installed
- https://news.ycombinator.com/item?id=47895029 — "Tell HN: Claude 4.7 is ignoring stop hooks" — exit-code-2/injection-resistance theory (user claim, not verified), schema-change warning from an experienced user
- https://news.ycombinator.com/item?id=48318978 — Python utility package for Claude Code hooks — hook-ordering question left unanswered by the author; env-isolation criticism
- https://news.ycombinator.com/item?id=47467922 — "Claude Code and the Great Productivity Panic of 2026" (surfaced by search, not read in full this pass)

Not used / low confidence, excluded from findings above:
- A "2026 Claude Code source-code leak" cluster of blog posts (voice mode, daemon mode, 44 hidden
  flags) surfaced by search but not corroborated by any GitHub issue, discussion, or maintainer
  statement in this pass — excluded per the standing rule that an unread/unverified claim does not
  ship. If this resurfaces next month with better sourcing, revisit.
