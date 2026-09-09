# Phase 1a - Anthropic Changelog Sweep (May-Sept 2026)

> Compiled 2026-09-08. Covers the weekly whats-new digests for weeks 19-34 (May 4 - Aug 21,
> 2026), the underlying reference docs for the highest-priority items, and anthropic.com/engineering
> and claude.com/blog for posts since May 2026. Scope and priorities as directed in this phase's task.
> Per standing rule, every claim below is cited to the URL actually read. Anything from a search
> snippet rather than a full fetch is marked NOT INDEPENDENTLY VERIFIED.

---

## 1. New capabilities Daniel is not using

Bar was 5 or more. This clears it several times over; the list below is filtered to what
plausibly changes something in this kit, not a full feature dump.

| # | Capability | What it is | Why it matters here | Bucket |
|---|---|---|---|---|
| 1 | Dynamic workflows (/workflows, ultracode keyword, /deep-research) | A JS orchestration script Claude writes and a runtime executes across up to 1,000 subagents/run (16 concurrent), resumable, with built-in adversarial cross-checking and unverified-claim labeling. [docs/en/workflows] | This is Anthropic's own answer to exactly the failure this kit was built to guard against: distrust agent self-reports. /deep-research fans out sources, cross-checks claims, and reports unverified ones as unverified instead of refuted -- the same behavior dave-researcher's own instructions describe by hand. Direct fit for "heavy subagent user, peak accuracy." | Build -- pilot on a kit audit (e.g. hook-wiring across all 5 projects) before extending more ad-hoc Agent fan-out |
| 2 | /goal | Sets a completion condition; a fast model re-evaluates after every turn and Claude keeps working until it holds, is judged impossible, or hits an unrecoverable error. Complementary to auto mode (auto removes per-tool prompts; goal removes per-turn prompts). [docs/en/goal] | Direct fit for "maximum automation." Verifiable end-states like "scripts/verify-kit.sh exits 0" or "every hook in settings.json is wired" are exactly the shape /goal wants. | Build -- try on verify-kit.sh convergence and client automation tasks with a hard pass/fail check |
| 3 | Agent view (claude agents) | One dashboard for every background session: dispatch, filter (s:blocked), peek, JSON scripting (claude agents --json), PR/MR badges, pin/rename/reorder. [docs/en/agent-view] | Directly answers the stated pain of not knowing what's possible, for a heavy subagent user running parallel sessions across 5 projects without a single view of what's blocked on him. | Build -- adopt as the default way to run/monitor parallel sessions instead of separate terminals |
| 4 | Fork mode (default-on in interactive sessions; /subtask) | Claude can spawn a fork subagent that inherits the entire conversation and prompt cache instead of restarting cold. [whats-new/2026-w33; docs/en/sub-agents] | loop-cost-discipline's "Parallelize Only When Work > Cold-Start Tax" reasoning assumes every subagent re-pays a context tax. A fork doesn't -- it shares the parent's cache. That changes the math for small side-tasks. See conflict 6 below. | Doctrine change -- the cold-start-tax heuristic needs a fork-mode carve-out |
| 5 | Parameter-level deny/ask rules -- Tool(param:value), e.g. Agent(model:opus), Agent(isolation:worktree), Bash(run_in_background:true), plus Agent(AgentName) to deny specific named subagents and Cd(path) to fence /cd targets. [docs/en/permissions] | Deny/ask rules match on any top-level scalar input field of a built-in tool (not just the primary content field), enforced by Claude Code itself -- tier 1 in this kit's own tier model, not a hook or a rule. The tier model says doctrine belongs as low as it will go. Some of what agent-ownership-enforcement or fan-out-capping currently do via hook may be expressible as a permission deny rule instead -- literally impossible for Claude to violate. | Doctrine change -- audit current hooks against this; push down what fits |
| 6 | /doctor full checkup | Now diagnoses and offers to fix: unused skills/MCP servers/plugins weighed against context cost, duplicate CLAUDE.md content, trimmable content Claude could derive from the codebase, slow hooks. Reports first, asks before changing anything. [whats-new/2026-w28] | This is a large fraction of the manual "Quarterly Garbage-Collection Pass" in kit-maintenance.md, shipped as a command. | Config change / doctrine change -- run /doctor as the first step of each quarterly GC pass |
| 7 | /usage attribution + /insights | /usage breaks recent plan usage down by skill, subagent, plugin, and individual MCP server, flags behaviors 10% or more of usage (long context, cache misses), and lists heaviest /loop or scheduled tasks. /insights separately analyzes up to 200 recent sessions and writes an HTML report on friction points and usage suggestions to ~/.claude/usage-data/report.html. [docs/en/costs] | Directly relevant to the monthly session-metrics.md review rule -- this is close to what that log is manually trying to approximate, generated for free. | Config change -- cross-check /insights output against the manual log before the next monthly review |
| 8 | Concise output style | Built-in output style: leads with the result, skips preamble and narration, does the work as thoroughly as Default, keeps full detail on errors, security, and destructive-action confirmations. Set via /config or the outputStyle setting. [whats-new/2026-w34] | Daniel's own stated pain, verbatim: Claude bloats replies. This is a one-line config fix. | Config change -- trivial, high confidence, do this first |
| 9 | Cross-session messaging (SendMessage, ListAgents, @mention) | Claude Code sessions on the same machine can message each other directly, or you can @name a session from the prompt. Auto mode blocks a relayed message from carrying user authority. [whats-new/2026-w32, w33] | For parallel work across the 5 active projects, a session touching a shared dependency can now tell a sibling session directly instead of Daniel manually relaying. | Build -- worth a trial across two of the active client repos before trusting it broadly |
| 10 | 1M-token context (Opus 5 / Sonnet 5) | Both current default models run with a 1M-token context window on Max/Team/Enterprise/API. [whats-new/2026-w27, w30] | Not "unused" in the sense of the model -- Daniel is already on current models -- but the 1M window itself may not be deliberately exploited; worth checking whether /context shows it's actually available in his sessions vs. defaulting to a smaller window. | Config change -- verify, don't assume |
| 11 | /design skill (research preview) | Publishes an editable artboard canvas built on artifacts from a UI brief; pick an option, have Claude implement it. [whats-new/2026-w34] | Possible fit for Betsey Brown Travel or Caregiver Club client-facing UI work. | Build -- low-cost trial on a small client UI task |
| 12 | Skill context:fork + disallowed-tools frontmatter | A skill can run in the background as a fork by default, and skills/commands can strip tools from the model while active. [whats-new/2026-w22, w30] | Relevant to authoring the 92 existing skills -- heavy ones could run backgrounded by default instead of blocking the main turn. | Config change -- review a handful of the heaviest skills for this frontmatter |

---

## 2. Conflicts with existing doctrine

| # | Finding | Detail | Action needed |
|---|---|---|---|
| 1 | Auto mode is now the default permission mode on Pro/Max/Team as of August 14, 2026, unless you had already set your own default. [whats-new/2026-w32] | This is not the same thing as bypassPermissions (the hard rule's "permission prompts disabled" language). Auto mode still runs a background classifier that blocks destructive/suspicious actions and explicitly blocks destructive git and relayed SendMessage calls without user authority. But it is a step toward less prompting, on Anthropic's timeline, not Daniel's. | Check what defaultMode Daniel's actual Desktop sessions are running today -- the switch may have already landed silently on a machine that never explicitly opted in. |
| 2 | TaskCreate/TaskUpdate/TodoWrite are removed by default on Opus 4.8, Sonnet 5, Fable 5, Mythos 5, and later models -- CLAUDE_CODE_ENABLE_TODO_TOOLS=1 re-enables them. [whats-new/2026-w33] | This is the exact shape of the "8 hooks fired nowhere" failure pattern documented in Part 1 of the research brief, but for a new reason: if any of the ~20 kit hooks match on TodoWrite/TaskCreate/TaskUpdate tool calls, those hooks may be silently firing zero times right now on current models. | Must-check: grep the hooks for TodoWrite/TaskCreate/TaskUpdate matchers; confirm the env var is set if the kit depends on those tools. |
| 3 | Deny rules provably outrank hooks, confirmed in the permissions doc itself: hook decisions don't bypass permission rules; a matching deny rule blocks the call, and a matching ask rule still prompts even when the hook returned allow. [docs/en/permissions] | This corroborates, with a second independent citation, the tier-model finding already established in the brief (permission deny > hook > rule > skill/agent) and the correction of verification.md's wrong claim that hooks are enforced and rules are advisory. No new conflict, but strengthens the case that verification.md's fix should stay fixed. | No action beyond confirming the correction already made is durable. |
| 4 | Nested-subagent depth default has changed since the w24 digest's own headline. The digest (Jun 8-12) said subagent chains are capped at five levels deep. The current reference doc says the default is now 3 layers (CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH), with 5 layers having been the default only from v2.1.172-v2.1.216, briefly dropped to 1 layer in v2.1.217-218, and settled at 3 as of v2.1.219. [docs/en/sub-agents] | The master research brief itself (this task's own input) states "5 levels" as current fact -- it's now stale, an instance of exactly the drift this whole sweep exists to catch. Any doctrine assuming 5-level nesting should assume 3 unless the env var is explicitly raised. | Doctrine correction: update anywhere in the kit that assumes 5-level nesting. |
| 5 | /fork doesn't mean what a doctrine written before July 2026 would expect. Before w29 (mid-July), /fork triggered an in-conversation forked subagent. As of w29, /fork instead copies the whole session into a new background row in agent view, and the old in-conversation behavior is now /subtask. [whats-new/2026-w29] | Any reference to /fork in the kit predating July 2026 is now describing the wrong command. | Doctrine correction -- grep for /fork references and redirect to /subtask where the in-conversation behavior was intended. |
| 6 | Fork mode changes the cold-start-tax math that loop-cost-discipline.md's "Parallelize Only When Work > Cold-Start Tax" section relies on. [docs/en/sub-agents] | The rule assumes every subagent re-pays a context tax (re-reading files, re-deriving context). A fork subagent inherits the full conversation and prompt cache, so that tax is largely paid once. The heuristic isn't wrong for ordinary Agent-tool subagents, but it's now imprecise as written -- it doesn't distinguish forks from fresh spawns. | Doctrine change -- add a fork-mode carve-out to the cold-start-tax heuristic. |
| 7 | Overlap candidate: Kevin (security-reviewer) vs. the Claude Security plugin and security-guidance plugin. Anthropic ships both a security-guidance plugin (pattern check on each edit plus model review each turn plus deeper agentic review on commit/push) [whats-new/2026-w22] and a separate claude-security plugin (multi-agent: architecture mapping, threat model, vulnerability hunt, independent review of every finding, timestamped report directory, scoped to whole repo or a diff/PR/commit) [whats-new/2026-w30]. | Not confirmed as a duplicate without reading Kevin's actual definition (out of scope for this phase -- web-reading only), but this is exactly the shape of overlap kit-maintenance.md's Skill-Overlap Audit exists to catch. | Flag for the next Skill-Overlap Audit, not an immediate change. |
| 8 | /ultraplan is removed (Aug 2026) -- the command, and the ultraplan trigger keyword, no longer exist; use plan mode or Claude Code on the web instead. [whats-new/2026-w32] | The word ultracode (workflows) is unrelated and easy to confuse with the retired ultraplan. If any doctrine references /ultraplan, it's dead. | Discard any reference; note the naming collision risk with ultracode when writing new doctrine. |
| 9 | Default permission mode relabeled "Manual" across CLI, --help, VS Code, JetBrains, and desktop (default and manual both work as the flag value). [whats-new/2026-w27] | Minor, but exactly the class of drift the brief flagged: doctrine text that quotes exact UI strings can go stale silently. | Doctrine correction -- low priority, fix opportunistically if any doc quotes "default mode" as a literal label. |

---

## 3. Compositions and worked examples worth stealing

1. Warp's two-skill self-improvement loop. [claude.com/blog/how-warp-builds-self-improving-agents-on-claude, Aug 26 2026]
   An inner/base skill does the actual work (e.g. code review); a separate outer/improver skill runs on a schedule, reads accumulated human feedback captured where the work already happens (PR comments), summarizes it into a structured format, and proposes small, focused, human-reviewable edits to the base skill's file. Feedback capture is made effortless by living in the existing workflow rather than a separate form.
   Why it's worth stealing: it's a direct, literal answer to "doctrine that fires without being remembered" -- a scheduled process that keeps a skill in sync with reality instead of assuming a human will notice drift. Could be piloted on one or two of the 92 skills, using bob-verifier findings or session-metrics.md entries as the feedback source instead of PR comments.
   Verdict: adapt.

2. Anthropic's own field-marketer composition (Adam Ward). [claude.com/blog/how-an-anthropic-field-marketer-uses-claude-code-to-send-weekly-personalized-updates-to-every-sales-rep, Aug 24 2026]
   MCP-connected BigQuery (fed by HubSpot, Clay, Salesforce) feeding personalization logic that pulls CRM territory plus Slack account updates, delivered via Slack. Built incrementally: piloted with 10 reps, then explicit content rules were extracted from what went wrong (nine content rules -- e.g. don't fabricate URLs, filter mismatched recommendations) rather than designed up front. Generalized to other teams (BDRs, CS, alliances) by changing a single CRM relationship field.
   Why it's worth stealing: the pattern -- pilot small, harvest concrete failure modes into an explicit numbered rule list, then generalize by parameterizing one join field -- maps directly onto both Betsey Brown Travel (personalized client itinerary updates) and The Caregiver Club (personalized volunteer/donor updates), which is exactly the tedious-work automation The Caregiver Club needs.
   Verdict: adopt as a template for the next client automation build.

3. Dynamic workflows' built-in adversarial-verification pattern. [docs/en/workflows]
   The docs' own worked example: "use a workflow to audit every route handler under src/routes/ for missing authentication checks, and adversarially verify each finding before reporting it." This is a first-class runtime feature, not a manually-written pattern -- independent agents check each other's findings before anything reaches the report, and an unverifiable claim is labeled unverified rather than counted as refuted.
   Why it's worth stealing: it directly targets Part 1's two worst agent-reliability failures (an agent reporting an edit it never made; an agent checking the wrong artifact and concluding 6 protected repos were unprotected). A workflow built for "audit every hook's wiring across all 5 projects, verify each finding against the deployed config, not the repo file" would be the mechanized version of the exact re-verification step Part 1 says had to be done by hand.
   Verdict: adopt for the next cross-project audit.

4. The Claude Security plugin's own internal pipeline. [whats-new/2026-w30]
   Map architecture, build a threat model, hunt vulnerabilities, independently review every finding, write to a timestamped report directory, scope to whole repo or a branch diff, a PR, or a single commit.
   Why it's worth stealing: a clean, named reference architecture for any multi-agent review pipeline (not just security) -- worth comparing Kevin's actual structure against this shape during the overlap audit flagged in section 2.
   Verdict: adapt as a template, pending the overlap check.

5. /goal plus auto mode, used together, are explicitly documented as complementary rather than redundant: auto mode removes per-tool-call prompts within a turn, /goal removes the need to re-prompt after each turn. [docs/en/goal] The docs' own two-line recipe (/goal with a verifiable condition, run in auto mode) is a ready-made unattended-task template.
   Verdict: adopt for tasks with a hard pass/fail check (e.g. all tests in test/auth pass and lint is clean).

---

## 4. What questions should we now be asking that we weren't?

1. Are any of the ~20 kit hooks matching on TodoWrite, TaskCreate, or TaskUpdate -- and if so, are they silently dead right now on Opus 4.8 / Sonnet 5 sessions unless CLAUDE_CODE_ENABLE_TODO_TOOLS=1 is set?
2. What permission mode do Daniel's actual Desktop sessions start in today -- has the August 14 auto-mode-default switch already changed the baseline silently, and does the "explicit per-session go-ahead" hard rule for unattended loops still bind the same way under auto mode as it does under bypassPermissions?
3. Which of the fan-out-capping, agent-ownership-enforcement, or secrets-guarding hooks could move down a tier into a native Tool(param:value), Agent(AgentName), or Cd(path) deny rule now that parameter-level matching exists -- consistent with the kit's own "doctrine belongs as low as it will go" principle?
4. Is dynamic workflows now the better substrate for the kit's heavy cross-project audits than ad-hoc Agent-tool fan-out, given it has native resumability, per-agent cost visibility, and the exact adversarial-verification pattern the kit currently has to enforce by hand?
5. Does Kevin (security-reviewer) meaningfully overlap with the official security-guidance and claude-security plugins enough to retire, merge, or explicitly differentiate one from the others?
6. Should loop-cost-discipline.md's ad-hoc fan-out cap (3-4 children) explicitly reference the Workflow tool's own size guidelines (small/medium/large, i.e. fewer than 5/15/50 agents) as the named "larger goes through the Workflow tool" destination, rather than leaving that pointer generic?
7. Should the monthly session-metrics.md review be cross-checked against, not replaced by, /insights' auto-generated friction-point report and /usage's attribution-by-skill/subagent/plugin breakdown?
8. Should /doctor's automatic unused-skill/MCP/plugin detection and slow-hook flagging become the first step of the quarterly kit-maintenance GC pass, with human judgment applied only to what it surfaces?
9. Now that fork mode shares the full parent context and prompt cache, does the cold-start-tax reasoning in loop-cost-discipline.md still apply the same way to a forked subagent as to a freshly spawned one, or does the rule need an explicit fork-mode exception?
10. Does any part of the kit still reference the retired /ultraplan command, the pre-July /fork behavior (now /subtask), or the "5 levels" of subagent nesting (now default 3)?

---

## 5. Sources

Weekly whats-new digests (code.claude.com/docs/en/whats-new), all fetched 2026-09-08:

- Week 19, May 4-8, 2026: https://code.claude.com/docs/en/whats-new/2026-w19
- Week 20, May 11-15, 2026: https://code.claude.com/docs/en/whats-new/2026-w20
- Week 21, May 18-22, 2026: https://code.claude.com/docs/en/whats-new/2026-w21
- Week 22, May 25-29, 2026: https://code.claude.com/docs/en/whats-new/2026-w22
- Week 23, Jun 1-5, 2026: https://code.claude.com/docs/en/whats-new/2026-w23
- Week 24, Jun 8-12, 2026: https://code.claude.com/docs/en/whats-new/2026-w24
- Week 25, Jun 15-19, 2026: https://code.claude.com/docs/en/whats-new/2026-w25
- Week 26, Jun 22-26, 2026: https://code.claude.com/docs/en/whats-new/2026-w26
- Week 27, Jun 29-Jul 3, 2026: https://code.claude.com/docs/en/whats-new/2026-w27
- Week 28, Jul 6-10, 2026: https://code.claude.com/docs/en/whats-new/2026-w28
- Week 29, Jul 13-17, 2026: https://code.claude.com/docs/en/whats-new/2026-w29
- Week 30, Jul 20-24, 2026: https://code.claude.com/docs/en/whats-new/2026-w30
- Week 32, Aug 3-7, 2026: https://code.claude.com/docs/en/whats-new/2026-w32
- Week 33, Aug 10-14, 2026: https://code.claude.com/docs/en/whats-new/2026-w33
- Week 34, Aug 17-21, 2026: https://code.claude.com/docs/en/whats-new/2026-w34

(Week 31 was not in the assigned scope list and was not fetched.)

Reference docs, fetched 2026-09-08 for detail behind the priority digest items:

- Dynamic workflows: https://code.claude.com/docs/en/workflows
- /goal: https://code.claude.com/docs/en/goal
- Agent view: https://code.claude.com/docs/en/agent-view
- Sub-agents (fork mode, nesting depth, foreground/background): https://code.claude.com/docs/en/sub-agents
- Permissions (parameter matching, deny/ask precedence): https://code.claude.com/docs/en/permissions
- Costs (/usage, /insights): https://code.claude.com/docs/en/costs

Blog and engineering sources:

- https://anthropic.com/engineering -- checked 2026-09-08. No posts found dated May 2026 or later relating to Claude Code, subagents, orchestration, or hooks. The most recent relevant-adjacent post is "An update on recent Claude Code quality reports," dated 2026-04-23, which predates this sweep's window. This absence is itself the finding: the engineering blog was not a source of new material this cycle.
- https://claude.com/blog -- checked 2026-09-08, index page.
- How an Anthropic field marketer uses Claude Code to send weekly personalized updates to every sales rep -- dated 2026-08-24. Fully fetched and read. https://claude.com/blog/how-an-anthropic-field-marketer-uses-claude-code-to-send-weekly-personalized-updates-to-every-sales-rep
- How Warp builds self-improving agents on Claude -- dated 2026-08-26. Fully fetched and read. https://claude.com/blog/how-warp-builds-self-improving-agents-on-claude
- "New in Claude Managed Agents: dreaming, outcomes, and multiagent orchestration" -- NOT INDEPENDENTLY VERIFIED. A direct WebFetch to the guessed URL 404'd; the summary in section 1's discard list comes from a WebSearch snippet aggregation, not a full read of the primary page. Secondary sources place original publication around 2026-05-06/07 (Code with Claude 2026). Treat every detail about "dreaming" and "outcomes" as unverified until the primary URL (apparently claude.com/blog/new-in-claude-managed-agents) is actually fetched. Important: Claude Managed Agents is a separate hosted-agent product from the Claude Agent SDK line, distinct from Claude Code (the CLI/Desktop product Daniel uses) -- nothing in this item should be treated as a Claude Code capability.

Discarded as out of scope or low relevance for this kit (noted so they aren't rediscovered next month): self-hosted environments / claude self-hosted-runner (enterprise infra, not a one-person-shop fit); GitLab worktree/merge-request integration (Daniel's repos are not on GitLab per anything seen in this sweep); Claude Desktop on Linux; iOS Simulator pane (no iOS client project); requiredMinimumVersion/requiredMaximumVersion managed settings (enterprise fleet management).
