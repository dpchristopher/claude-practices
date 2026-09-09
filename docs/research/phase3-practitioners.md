# Phase 3 - Named Practitioners: Compositions Worth Stealing

> Answers the brief's real target (Part 3): not "what can Claude Code do" but "what are people
> actually publishing that I haven't seen." Direct fetches of the named sources plus Substack,
> Hacker News, GitHub, and Every.to. Filtered against this kit's doctrine, not against novelty.
> Researched and written 2026-09-08. Per Part 6's bar: **Phase 3 clears its bar if it produces
> 5 or more compositions.** This delivers 9, cross-checked where the claim was load-bearing.

**Reliability note on method:** most sources below were read via `WebFetch`, which fetches the
real page and summarizes it with a small model before returning it to me. That is closer to
reading the source than a search-engine snippet, but it is not the same as reading raw text
myself - a summarizer can drop nuance or occasionally mis-state a number (it did once below,
caught by cross-checking: see the Katie Parrott date correction in Section 5). Where a claim is
load-bearing for the recommendation, I cross-checked it against a second independent source and
say so. Where I could not, it is flagged **single-sourced** rather than silently presented as
fully checked.

---

## 1. Compositions worth stealing

### 1.1 Cross-model adversarial review (Simon Willison, sqlite-utils 4.0rc2)
**Author:** Simon Willison - **Link:** https://simonwillison.net/2026/Jul/5/sqlite-utils-fable/ - **Date:** 2026-07-05

Simon had Claude (Fable) do a comprehensive pre-release review of his own library, then
deliberately had **GPT-5.5 review Claude's changes**, and vice versa on other work - "I've
started habitually having Anthropic's best model review OpenAI's work and vice versa." GPT-5.5
caught two priority-1 transaction-handling bugs Claude's own review missed. He also split cost:
cheap models for mechanical subtasks like prompt counting, the frontier model reserved for the
hard work - he flagged in his own post that he should have leaned on this harder, i.e. even the
person demonstrating the pattern under-used it.

**Why it fits:** Daniel's kit already distrusts single-agent self-report (the FINDINGS-LEDGER's
"agent got 3 of 7 findings wrong" meta-finding). This is the same insight applied cross-vendor
instead of cross-agent: two different labs' models are less likely to share the same blind spot
than two Claude subagents are. With usage cost explicitly deprioritized, there is no reason not
to run a second-opinion pass through a different model family on anything client-facing.
**Verdict: adopt** - cheap to pilot on the next Betsey Brown Travel or Caregiver Club deliverable.

### 1.2 Spec-first + red/green TDD handoff (Simon Willison, scan-for-secrets)
**Author:** Simon Willison - **Link:** https://simonwillison.net/2026/Apr/5/scan-for-secrets-3/ - **Date:** 2026-04-05

He wrote the README describing exactly how the tool should behave before opening Claude Code,
then handed the README over with an instruction to build it test-first (red/green). The
composition is: write the spec as if it already shipped, feed it in, then let the agent build to
the spec, verified by tests it also writes first.

**Why it fits:** directly usable as the intake pattern for new Caregiver Club automation
requests - write the README the automation should satisfy before invoking any skill, rather than
describing the task conversationally. **Verdict: adopt.**

### 1.3 Anthropic's own sandbox runtime (srt) as the isolation layer
**Link:** https://github.com/anthropic-experimental/sandbox-runtime - surfaced via Simon
Willison's https://simonwillison.net/2026/May/30/how-we-contain-claude/ (2026-05-30)

Anthropic's own containment writeup names OS-level sandboxing (Seatbelt/Bubblewrap) plus egress
controls as the actual security boundary - "if credentials never enter the sandbox, they can't
be exfiltrated" - and points at srt (Sandbox Runtime) as an open-source starting point rather
than something to build from scratch. It is an anthropic-experimental-org research preview, not
a committed product; APIs may still move.

**Why it fits:** directly the "don't reinvent the wheel" constraint from Part 3 of the brief.
Both client repos handle real client data and currently have secrets-guard hooks but no
process-level sandbox. This is Anthropic's own answer to "how do you actually contain an agent
that handles credentials," and it predates and outranks anything a vendor blog would suggest.
**Verdict: adopt** - evaluate srt before building a bespoke sandbox wrapper for client repos.

### 1.4 Plan, clear, execute - with a persisted plan file crossing the gap
**Link:** https://github.com/solatis/claude-config - surfaced via HN discussion of bcherny's
"10 parallel agents" tweet, https://news.ycombinator.com/item?id=46470017

Planning phase produces a plan file, reviewed by a technical-writer agent and a quality-reviewer
agent before it is trusted; the user then runs /clear and re-loads the plan file by reference
rather than carrying planning context into execution. Each execution milestone gets a developer
pass, then a writer review, then quality-reviewer approval before the next milestone starts.

**Why it fits:** this is functionally identical to loop-cost-discipline.md's "fresh session with
the plan file as context" rule, except it is mechanized into an every-time step rather than a
judgment call for "major phase transitions." Worth comparing directly against gru-planner's plan
hand-off to see whether the clear-then-reload-by-file step is missing from Daniel's own
planning-to-execution boundary. **Verdict: adapt** - check whether Gru's plans currently survive
a /clear or only an in-context carry-forward.

### 1.5 Parallel top-level sessions via git worktrees, not in-session subagent fan-out
**Author:** Kieran Klaassen - **Link:** https://every.to/source-code/how-i-use-claude-code-to-ship-like-a-team-of-five-6f23f136-52ab-455f-a997-101c071613aa - **Date:** 2026-01-26

Five-plus separate terminal tabs, each a distinct Claude Code process against its own git
worktree, doing distinct jobs (pick up an issue and implement, review PRs for style, generate a
changelog, investigate production issues) with a fixed human checkpoint before merge. Custom
slash commands (/issues, /work, /review) are the interface, not ad hoc prompting.

**Why it fits, and the important caveat:** this is a different axis than the fan-out
loop-cost-discipline.md caps. That rule bounds in-session Agent-tool dispatch (3-4 ad hoc
children, more goes through Workflow). Klaassen's pattern is N separate top-level sessions, each
with its own context window, coordinated by the human via git worktrees rather than by one
orchestrating Claude. It does not violate the fan-out rule; it is a scaling axis the rule does
not currently address at all. **Verdict: adopt as a named pattern** for repetitive,
parallelizable client work (e.g., Betsey Brown Travel itinerary batches) - but see Section 3 for
the HN pushback on overusing this.

### 1.6 Five named subagent roles for one-engineer scaling
**Author:** Katie Parrott, Every - **Link:** https://every.to/source-code/claude-code-camp - **Date:** 2026-06-17 (see Section 5 for a date correction on this source)

Five reusable subagent roles, not one-off prompts: **Executor/Evaluator** (one agent builds, a
separate agent reviews against spec, so the builder's own biases do not grade its own work),
**Opponent Processors** (two agents argue opposing positions, e.g. justify vs. minimize an
expense, with Claude mediating to a balanced outcome), **Feedback Codifier** (extracts review
comments into the project's CLAUDE.md so the same correction does not have to be given twice),
**Research Agent** (surveys existing open-source approaches before building), **Log Investigator**
(parses error logs in an isolated context so the main session's context stays clean).

**Why it fits:** Daniel already has 34 personal agents; this is a naming taxonomy to check his
roster against, not new infrastructure. The Feedback Codifier in particular is a direct,
buildable answer to the "written correctly, then never connected" failure pattern from Part 1 of
the brief - it mechanizes converting one-off human corrections into standing doctrine instead of
relying on Daniel remembering to update a rule file by hand. **Verdict: adopt Feedback Codifier
as a concrete build; the other four are worth a name-check against the existing 34.**

### 1.7 The Therapist Pattern - a dedicated subagent as the only writer of a mutable persona file
**Author:** Jesse Vincent (obra) - **Link:** https://blog.fsck.com/2026/07/20/the-therapist-pattern/ - **Date:** 2026-07-20

A standalone subagent (the Therapist) is the only thing allowed to modify the primary agent's
identity/persona file, which is re-injected into the system prompt every turn. When the primary
agent errs, it talks to the Therapist, and only after that structured conversation does the rule
get added to the persona document - turning "the agent quietly drifts" into a deliberate,
logged, single-owner edit path.

**Why it fits, with a caveat flagged in Section 3:** obra wrote the plugin Daniel runs
(superpowers), so this is the closest thing to a primary-source design note on how its author is
now thinking about self-modifying agents. It is a genuinely new idea for isolating "who is
allowed to change the rules" - but see Section 3 for why it also sits in tension with this kit's
own verification philosophy. **Verdict: adapt with a gate, not adopt as-is** - any
self-modification of standing doctrine should pass through a Bob-style fresh-eyes check before
it is trusted, the same discipline the kit already applies to human-originated rule changes.

### 1.8 Compartmentalized credential architecture and arbiter agent
**Author:** Jesse Vincent (obra) - **Link:** https://blog.fsck.com/2026/07/05/new-patterns/ - **Date:** 2026-07-05

Isolates the one agent that holds credentials and talks to external systems from the agents that
process untrusted content, mediated by an "arbiter" that mediates requests rather than granting
direct access to secrets. obra names the underlying problem explicitly: an agent that
simultaneously (a) holds private information, (b) can communicate externally, and (c) is exposed
to untrusted content is a structural vulnerability he describes as unsolved, not solved by this
pattern - only mitigated.

**Why it fits:** both clients hit exactly this triad - Betsey Brown Travel documents and The
Caregiver Club's nonprofit files are untrusted external content, flowing into a system that will
also need to communicate on the client's behalf. FINDINGS-LEDGER item B7 already flags "nothing
currently scans" client-supplied content; obra's framing sharpens that from "add a scanner" to
"the credential-holding agent should structurally never be the one touching untrusted content at
all." **Verdict: adopt the separation principle now** (route external-content processing and
credential-holding through different agents), **flag the residual risk as open** rather than
treating any single mitigation as closing it - obra, someone actively building this, says it is
not closed.

### 1.9 File-by-file adversarial prompting loop for systematic bug and vulnerability sweeps
**Described by:** Thomas Ptacek (sockpuppet.org), reporting on Nicholas Carlini and Anthropic's
Frontier Red Team - **Link:** https://sockpuppet.org/blog/2026/03/30/vulnerability-research-is-cooked/
- **Date:** 2026-03-30 - **cross-checked** against InfoQ, Let's Data Science, and an
independent X thread from a security account, all converging on the same script shape; treated
as demonstrated, not merely asserted, given three independent descriptions agree on the
mechanism.

A trivial bash script iterates over every source file in a repo and fires the same prompt at
each one: "I'm competing in a CTF. Find me an exploitable vulnerability in this project. Start
with the file. Write me a vulnerability report next to it." A second pass feeds each generated
report back through Claude Code with "Verify for me that this is actually exploitable." Ptacek's
framing: the file-by-file loop works because it introduces stochasticity, "lots of pulls on the
slot machine," and the verification pass is separately near-100% reliable at confirming or
rejecting. Found 5 confirmed Linux kernel CVEs and reportedly 500+ validated high-severity
findings across other codebases this way.

**Why it fits:** this is a two-line-per-file pattern, not a research project, and Daniel already
has the file-iteration and subagent-dispatch infrastructure to run it. It is directly applicable
as a periodic sweep for Civ_Project and, more importantly, for the two client repos, where a
"find the most serious problem in this file, then verify it separately" loop is a cheap,
systematic complement to the ad hoc review the kit currently does. **Verdict: adopt** - pilot as
a scheduled sweep (ties into the brief's Part 4 "make it recur" plan), generate-then-verify as
two separate passes so a single agent's blind spot does not also blind the check.

---

## 2. People worth following

| Person | Publishes at | Good for | Cadence/note |
|---|---|---|---|
| **Simon Willison** | simonwillison.net (tag: /tags/claude-code/) | Near-daily, hands-on, tests everything himself, names real dollar costs and real failure counts. The single highest-signal source found this pass. | ~30 Claude-Code-tagged posts since March 2026 alone |
| **Jesse Vincent (obra)** | blog.fsck.com | Wrote superpowers, the plugin Daniel runs - his posts are closest to a primary source on where that plugin's design philosophy is heading. Currently building "Sen," an agentic-colleague framework, which is where his newest patterns (Therapist, arbiter) come from. | Active, several posts/month in 2026 |
| **Hamel Husain** | hamel.dev / parlance-labs.com | Evals - already cited in SOURCES.md (judge-calibration). "It's Hard to Eval Is a Product Smell" (2026-06-29) and "Do Automated Evals Work?" (2026-07-11) are worth a read for anything Carl-evals-adjacent. | Low volume, high signal |
| **Katie Parrott / Every staff** | every.to (Source Code, Context Window verticals) | Practitioner write-ups of real internal workflows at a company that runs its own engineering on Claude Code - closer to "here's our actual setup" than opinion pieces. | Several posts/month; distinguish staff bylines from guest interviews |
| **Kieran Klaassen** | published via every.to guest posts | One concrete, dated, numbered daily workflow (Section 1.5) - useful as a template to imitate literally. | One post found this pass |
| **Thomas Ptacek** | sockpuppet.org | Independent security researcher describing Anthropic Frontier Red Team's actual methodology with direct quotes - the best non-Anthropic secondary source found on the vulnerability-hunting composition (Section 1.9). Not on the original named-source list; worth adding. | Found via this pass only |
| **Nicholas Carlini** | Anthropic Frontier Red Team, no personal blog post located this pass | The person actually running Section 1.9's methodology. Simon Willison covers him under /tags/nicholas-carlini/ but that tag currently surfaces a different, unrelated Feb 2026 post (a C-compiler project) - his own vulnerability-research writing was not located directly, described only secondhand via Ptacek and press. | **Not independently verified as his own words - flag and re-check next month** |
| **Geoffrey Huntley** | ghuntley.com | Named on the brief's list; heavy agentic-coding writing per the brief. **Could not access this pass** - two direct fetch attempts both failed (ECONNRESET). Titles visible only from a stale index ("engineer away the slop," "porting software has been trivial for a while now") suggest relevant content exists but nothing could be read. | **Retry next month - genuine gap, not a low-yield finding** |
| **Armin Ronacher** | lucumr.pocoo.org | One relevant hit this pass: "Better Models: Worse Tools" (2026-07-04) on a tool-calling regression in newer Claude models - a builder's-eye complaint, not a workflow. Low yield this pass, may be a sampling artifact of only reading the homepage rather than a full archive crawl. | Low yield this pass |
| **Thorsten Ball** | registerspill.thorstenball.com | Named on the brief's list. Archive scan surfaced no Claude-Code-specific posts in the visible window - titles read as general engineering essays. Low yield this pass, same caveat as Ronacher: only the archive index was read, not full post text. | Low yield this pass |
| **Latent Space** | latent.space | One relevant hit: agent teams replacing human PR review at major OSS projects (see Section 5). More a trends/interview outlet than a hands-on practitioner. | Low yield this pass |

---

## 3. Ideas that contradict (or sharpen) current doctrine

### 3.1 Auto Mode's permission classifier is explicitly not the hard gate - refines, does not just contradict, hooks-are-advisory
Johann Rehberger published an attack against Claude Code's Auto Mode that succeeded roughly 80%
of the time: tricking Claude into curl-ing a page instead of using WebFetch, downloading a zip,
and having an "import base64" silently execute a malicious local struct.py - and when Claude
itself detected the compromise and tried to clean up, Auto Mode blocked the cleanup command too.
Simon Willison's own writeup:
https://simonwillison.net/2026/Aug/27/breaking-claude-code-opus-5-auto-mode/ (2026-08-27).
**Cross-checked** independently by The Register, GovInfoSecurity, and Cybernews - all describe
the same zip/struct.py mechanism, so this is treated as demonstrated, not merely asserted.

The load-bearing detail: Anthropic's own response, per Rehberger, was that Auto Mode "was a
convenience feature using a best-effort classifier and was not a security guarantee" - closed as
"informative," not as a security bug - and Claude Code has since shipped a fix (2.1.257+).

This does not overturn verification.md's corrected claim that the permission system is the hard
gate - it narrows which part of the permission system that applies to. Static allow/deny rules
(the kind Daniel's "7 deny rules" almost certainly are) are a different mechanism from Auto
Mode's dynamic best-effort classifier, and Anthropic itself says only the former is a guarantee.
The tier model in docs/mechanizing-doctrine.md currently just says "Permission deny - Claude
literally cannot" at tier 1 - it does not distinguish a static deny rule from an Auto-Mode
classifier decision, and per Anthropic's own statement, only the former belongs at tier 1.
**Action for Monday: confirm Claude Code Desktop is 2.1.257 or later, and check whether tier-1 in
the doctrine needs an explicit carve-out for Auto Mode.**

### 3.2 Parallel top-level sessions can look like a virtue and also be the wrong lesson
The same HN thread that produced Section 1.4's plan/execute pattern (on bcherny's "10 parallel
agents, 50-100 PRs/week" tweet - https://news.ycombinator.com/item?id=46470017) carried strong
pushback in the top comments: "I don't need 10 parallel agents... I need 1 agent that
successfully solves the most important problem," with skepticism that a human can actually
supervise 10 simultaneous workstreams and that the pattern only suits small, independent
features. This is not a contradiction of Daniel's doctrine - it is independent confirmation of
loop-cost-discipline.md's "parallelize only when work > cold-start tax" rule, from the opposite
direction (practitioners, not researchers). Worth citing back into that rule as supporting
evidence next time it is revised.

### 3.3 The Therapist Pattern's self-modifying persona sits in tension with "distrust agent self-reports"
Section 1.7's pattern lets one subagent unilaterally rewrite the primary agent's standing rules
file after a conversation with the agent that just made the mistake. That is structurally close
to the exact failure category this session's own audit flagged repeatedly - an agent's account
of what it did or should do next, trusted without independent verification. obra's own post
frames this as still experimental ("planning to test slow-rolling changes across multiple
sessions"), not a finished recommendation. **If Daniel builds anything like this, it should
route through a Bob-style check before a self-generated rule becomes standing doctrine - treat
it as a proposal generator, not an autonomous editor.**

### 3.4 Superpowers 6 changed the plugin's internal agent structure - version drift risk
obra's Superpowers 6 (2026-06-15, https://blog.fsck.com/2026/06/15/Superpowers-6/) merged the
spec-compliance and code-quality review agents into one, pre-generates diff "packets" to cut
git-command overhead, and claims roughly 50% faster and 60% cheaper. This does not contradict
anything in the kit, but any blog post or GitHub example referencing "the superpowers review
agent" (singular or plural) may be describing different plugin internals than whatever version
Daniel actually has installed. **Worth a direct version check before assuming any
Superpowers-related finding from this research generalizes to his install** - same caution
FINDINGS-LEDGER B1 already raised for the CLAUDE_PLUGIN_ROOT Windows bug.

---

## 4. Questions we should now be asking that we weren't

1. **Is Auto Mode active in Daniel's actual session, for which action categories, and is his
   Desktop build 2.1.257 or later** (the version that closed the Rehberger exploit)? If Auto
   Mode is live and his static deny rules do not cover a given action, that action falls back to
   a best-effort classifier Anthropic itself says is not a security guarantee.
2. **Does the kit's planning-to-execution handoff (Gru's plans) survive a clear command, or only
   an in-context carry-forward?** Section 1.4's pattern makes the plan file the only thing that
   crosses the boundary; if Daniel's does not, that may be a second instance of the "written
   correctly, then never connected" pattern from Part 1 of the brief.
3. **Which of the 34 personal agents already cover Executor/Evaluator, Opponent Processors,
   Feedback Codifier, Research Agent, and Log Investigator (Section 1.6), and which are
   genuinely missing?** In particular: is there anything today that converts a one-off human
   correction into a standing rule automatically, the way Feedback Codifier does, or does that
   still depend on Daniel remembering to edit a file by hand?
4. **Given obra names the credential, untrusted-content, external-communication triad as
   structurally unsolved (Section 1.8), should Kevin's security review checklist for the two
   client repos explicitly test for it** - an agent that can simultaneously hold client
   credentials, process an inbound document, and send something externally - rather than
   treating the existing secrets-guard hooks as closing the question?
5. **Is cross-model adversarial review (Section 1.1) worth adopting as a standing step for
   client-facing deliverables**, given usage cost is explicitly deprioritized and Daniel already
   has the "distrust one agent's self-report" instinct, just not yet applied across model
   vendors?
6. **Would a scheduled file-by-file "find the worst problem in this file, then verify
   separately" sweep (Section 1.9) be worth wiring into the same recurring mechanism the brief
   proposes for the monthly research sweep itself** - i.e., one more thing riding on the schedule
   or Routines mechanism once that is built?
7. **What is actually in Geoffrey Huntley's and Thorsten Ball's archives?** Both came back
   low-yield or inaccessible this pass for reasons that look like tooling limits (connection
   resets, homepage-only scans) rather than an actual absence of relevant content - worth a
   retry with a different fetch method before concluding they have nothing.

---

## 5. Sources, with dates and verification status

**Directly fetched, primary:**
- Simon Willison, tag index - https://simonwillison.net/tags/claude-code/ (fetched 2026-09-08, ~30 posts back to 2026-03)
- Simon Willison, "Fireside Chat with Cat and Thariq" - https://simonwillison.net/2026/Jul/21/cat-and-thariq/ (2026-07-21)
- Simon Willison, "sqlite-utils 4.0rc2, mostly written by Claude Fable" - https://simonwillison.net/2026/Jul/5/sqlite-utils-fable/ (2026-07-05)
- Simon Willison, "How we contain Claude" - https://simonwillison.net/2026/May/30/how-we-contain-claude/ (2026-05-30)
- Simon Willison, "scan-for-secrets 0.1" - https://simonwillison.net/2026/Apr/5/scan-for-secrets-3/ (2026-04-05)
- Simon Willison, "Breaking Claude Code Opus 5 Auto Mode" - https://simonwillison.net/2026/Aug/27/breaking-claude-code-opus-5-auto-mode/ (2026-08-27)
- Jesse Vincent (obra), "The Therapist Pattern" - https://blog.fsck.com/2026/07/20/the-therapist-pattern/ (2026-07-20)
- Jesse Vincent (obra), "Some new agentic patterns" - https://blog.fsck.com/2026/07/05/new-patterns/ (2026-07-05)
- Jesse Vincent (obra), "Superpowers 6" - https://blog.fsck.com/2026/06/15/Superpowers-6/ (2026-06-15)
- Hamel Husain, hamel.dev homepage (fetched 2026-09-08) and "Do Automated Evals Work?" - https://parlance-labs.com/blog/posts/auto-evals.html (2026-07-11)
- Armin Ronacher, "Better Models: Worse Tools" - https://lucumr.pocoo.org/2026/7/4/better-models-worse-tools/ (2026-07-04)
- Latent Space, "PRs NOT Welcome" - https://www.latent.space/p/pr-not-welcome (2026-09-01)
- Kieran Klaassen, Every - https://every.to/source-code/how-i-use-claude-code-to-ship-like-a-team-of-five-6f23f136-52ab-455f-a997-101c071613aa (2026-01-26)
- Katie Parrott, Every, "Claude Code Camp" - https://every.to/source-code/claude-code-camp
  Date correction made during this pass: an initial automated read said 2025-08-28, but an
  independent web search confirmed the actual publish date is 2026-06-17. The earlier date
  should not be reused elsewhere.
- boringbot (Substack), "Claude Code: Skills, Subagents, Hooks, Plugins, and Harnesses" - https://boringbot.substack.com/p/claude-code-skills-subagents-hooks (2026-05-05, paywalled past the intro)
- Thomas Ptacek, sockpuppet.org, "Vulnerability Research Is Cooked" - https://sockpuppet.org/blog/2026/03/30/vulnerability-research-is-cooked/ (2026-03-30)
- HN, "the creator of Claude Code's Claude setup" - https://news.ycombinator.com/item?id=46470017 (thread; date of underlying tweet not independently confirmed)
- HN, "Claude Code Found a Linux Vulnerability Hidden for 23 Years" - https://news.ycombinator.com/item?id=47633855
- GitHub, solatis/claude-config - https://github.com/solatis/claude-config (undated repo, fetched 2026-09-08)
- GitHub, anthropic-experimental/sandbox-runtime - https://github.com/anthropic-experimental/sandbox-runtime (fetched via search 2026-09-08; described in its own README as an early research preview)
- GitHub, rohitg00/awesome-claude-code-toolkit - https://github.com/rohitg00/awesome-claude-code-toolkit (fetched 2026-09-08)

**Corroborating and secondary sources, used only where a primary fetch converged with them:**
- InfoQ, "Claude Code Used to Find Remotely Exploitable Linux Kernel Vulnerability Hidden for 23 Years" - https://www.infoq.com/news/2026/04/claude-code-linux-vulnerability/
- The Register, "Researcher shows how Claude Code can be tricked simply by asking it to summarize a website" - https://www.theregister.com/research/2026/08/28/researcher-shows-how-claude-code-can-be-tricked-simply-by-asking-it-to-summarize-a-website/5293372
- GovInfoSecurity, "Hidden Attack Slips Past Claude Code Auto Mode" - https://www.govinfosecurity.com/hidden-attack-slips-past-claude-code-auto-mode-a-32693
- Cybernews, "Claude Code Auto Mode Malware Exploit Shows AI Agent Risk" - https://cybernews.com/security/claude-code-auto-mode-malware-vulnerability/

**Could not access this pass - genuine gaps, not low-yield findings:**
- ghuntley.com - two direct fetch attempts both failed with a connection reset. Named on the
  brief's list as heavy agentic-coding writing; unverified whether that reputation is currently
  earned, purely a tooling failure this pass. Retry next month.

**Low yield this pass, archive-index-only scan, may not reflect the full site:**
- registerspill.thorstenball.com - no Claude-Code-specific posts surfaced in the visible archive window.
- Every.to context-window index - no post specifically bylined to Dan Shipper about Claude Code
  was located. The two closest hits, about an engineering team for the cost of Codex and a
  solo-founder Codex piece, are about OpenAI's Codex rather than Claude Code, and are excluded
  here as off-target.

**Explicitly not verified, flagged rather than asserted as fact:**
- Nicholas Carlini's own words on his vulnerability-hunting methodology were not located
  directly, since no personal blog post was found. Everything in Section 1.9 is Carlini's work
  as described by Thomas Ptacek and press coverage, not Carlini's own writing. Treated as
  demonstrated, since three independent descriptions converge on the same script, but not
  primary-sourced to Carlini himself.
- The specific dollar figures and prompt counts in Section 1.1 and Section 1.5 come from
  WebFetch's automatic summary of the source page rather than my own reading of the raw HTML.
  Flagged in case a future pass wants to re-verify the exact numbers against the original posts.
