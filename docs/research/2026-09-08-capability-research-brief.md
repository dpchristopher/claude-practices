# Capability Research Brief — opened 2026-09-08

> Written so this survives context loss. Input: one long session auditing and repairing the
> kit. Purpose: a repeatable monthly sweep that keeps doctrine in sync with what Claude Code
> can actually do, and closes the gap between what Daniel builds and what is possible.

---

## Part 1 — What this session established

### The dominant failure pattern

**Things built correctly, then never connected.** Every significant finding was an instance:

| Built | Connected? |
|---|---|
| 10 kit hooks installed | 2 wired; 8 fired nowhere |
| INV-02 "hooks ↔ settings" invariant | Compared repo files to each other, never read the deployed config — so it passed while 8 hooks were dead |
| Wave 9 accuracy rules | Written to `templates/`, which deploys only via `/init` on a NEW project; that template has never scaffolded one, so they reached zero projects |
| `backup-state.sh` | Omitted the most valuable un-tracked file (`~/.claude/CLAUDE.md`) and defaulted to the same disk it protects |
| `guard-fanout` on probation | Fired 5 times, logged 0 times; its probation clause depended on a manual step nobody performed |
| Client repos | Two repos holding real client data had no secrets guard at all |

**Doctrine quality was never the problem. Delivery was.**

### The wrong-rule finding

`verification.md` asserted *"Rules are advisory; hooks are enforced."* The hooks docs say the
opposite: hooks are best-effort, the **permission system** is the hard gate. The claim had
spread to three live files and loaded every turn for months. It was found by accident, while
chasing something else.

**Implication: nobody has ever read the doctrine asking "is this still true?" A wrong rule that
now fires reliably is worse than a wrong rule that was ignored.**

### The tier model (`docs/mechanizing-doctrine.md`)

1. Permission deny — Claude literally cannot
2. Hook — fires automatically
3. Always-loaded rule — works if Claude reads and obeys
4. Skill/agent — works if *Daniel* remembers

Doctrine belongs as low as it will go. 4 of 9 hard rules were already tier ≤2; 1 moved this
session; 1 is one config line away; 2 need judgment and correctly stay rules.

### Agent reliability, measured

Of three audit subagents run this session: one **reported an edit it never made**; one checked
`.git/hooks/` instead of `core.hooksPath` and concluded 8 repos were unprotected when 6 were
fine. Both were caught only by local re-verification. This produced the "distrust agent
self-reports" rule and should shape how the research below is treated.

### State at close

v1.8.0 · 41/41 on `scripts/verify-kit.sh` · 8 hooks wired · 7 deny rules · `stop-verify` gating
all 5 active projects · `output-accuracy.md` loading globally · `C:\Clients\CLAUDE.md` governing
both client repos · off-disk backup taken.

---

## Part 2 — The machine (bounds Phase 2)

Dell XPS 16 DA16260 · Intel Core Ultra X7 358H, 16C/16T, with NPU · **63.5 GB RAM** ·
Intel Arc B390 **integrated** GPU · 691 GB free.

**No NVIDIA, so no CUDA.** Most local-LLM tooling assumes CUDA. Intel paths: IPEX-LLM,
OpenVINO. The NPU suits sustained low-power small-model work.

Installed models — **all 3–4B, roughly 6 GB total on a 63 GB machine**:

- `Llama-3.2-3B-Instruct-Q4_K_S` (LM Studio)
- `gemma-3-4b-it-Q4_K_M` (LM Studio)
- `phi-4-mini` (Foundry Local, NPU)

**Open question: RAM allows roughly 8–10× larger models. Is the delegation boundary in the
`local-models` skill calibrated to a 3B model when it should assume ~30B?**

---

## Part 3 — Goals and context

- **Goals:** maximum automation, peak accuracy. Doctrine that fires without being remembered.
- **Stated pain, his words:** output is trustworthy but slow; Claude bloats replies; and mainly
  *"a sense of what I see people posting about — cool, difficult tasks I couldn't even imagine
  doing, because I don't know what is fully capable here."* **That third one is the real
  target.** It is a knowledge gap, not a tooling gap.
- **Constraint:** *don't reinvent the wheel* — low odds of beating Anthropic's own team, so find
  what already ships before extending doctrine.
- **Clients:** Betsey Brown Travel (paying). The Caregiver Club (his mother's nonprofit — needs
  Claude implementation and automation of tedious work). Civ_Project is a passion project to
  enhance playing the game.
- **CLOSED TOPIC, do not raise:** API key rotation. Declined repeatedly.
- **Usage limits:** explicitly deprioritized. Doing this well beats doing it cheap.

---

## Part 4 — The plan

**Claude's knowledge cutoff is May 2026; it is now September 2026.** Four months of releases are
unknown to the model while Daniel was actively writing doctrine. That is why Phase 1 goes first,
and why this should recur monthly.

### Phase 1 — Anthropic ground truth (first, cheapest, determines the rest)

- `code.claude.com/docs/en/whats-new/` weekly pages, May → now (~16)
- `anthropic.com/engineering`, `claude.com/blog`
- Docs sections possibly never read: agent teams, channels, agent view, remote control,
  routines / `/schedule`, sandboxing, plugins, output styles, headless, artifacts
- **`github.com/anthropics/claude-code` issues and discussions** — promoted to first-class.
  This is where this session's `SendMessage` answer actually came from, after the docs gave
  nothing and Claude offered a wrong inference. Real users, real failure modes, maintainer
  replies.
- **Required outputs:** (a) what ships that the doctrine duplicates, contradicts, or ignores;
  (b) capabilities never touched; (c) **what questions should we now be asking that we weren't** —
  the guard against freezing the question list before knowing what exists.

### Phase 2 — Local models on THIS hardware (parallel with 1; no overlap)

Intel IPEX-LLM, OpenVINO GenAI, llama.cpp SYCL/Vulkan backends, Foundry Local, LM Studio.

- Largest genuinely useful model at 63 GB, and at what tokens/sec?
- NPU vs iGPU vs CPU per task type
- Is the `local-models` delegation boundary calibrated to the wrong model size?
- What does a non-CUDA machine actually give up?

### Phase 3 — Named practitioners (after 1, so novelty is distinguishable from noise)

People: **Simon Willison** (simonwillison.net), **Geoffrey Huntley** (ghuntley.com),
**Jesse Vincent / obra** (blog.fsck.com — wrote the `superpowers` plugin in use here),
**Hamel Husain** (hamel.dev, already in SOURCES), **Thorsten Ball** (registerspill),
**Armin Ronacher** (lucumr.pocoo.org), plus whoever Phase 1 surfaces as currently active
Anthropic voices — to be found, not recalled, since recalled names predate the cutoff.

Places: **Substack** (where the long-form posts Daniel describes usually land), **Hacker News**
(comments over posts), **GitHub** (`awesome-claude-code`, shipped plugins and skills), Lobsters,
conference talks with transcripts.

### Phase 3b — Anduril / Palmer Luckey (Daniel's request; genuinely adjacent)

Defense tech is one of the few fields doing serious **edge** AI: models on constrained hardware,
offline, no cloud round-trip — structurally the same problem as Phase 2. Anduril engineering
posts, Palmer's own writing and interviews, Anduril public repos.

Framing question: **what transfers to a one-person shop on a laptop?** Low expected yield, cheap
to check, worth knowing either way.

### Phase 4 — Academic

arXiv cs.SE / cs.AI: agentic coding, multi-agent reliability, SWE-bench-adjacent work. MAST is
already cited; the question is what has landed since. Held to `SOURCES.md` confidence tiers —
**an abstract read via search summary is not a citation** (Waves 8 and 9 both dropped numbers
for exactly this reason).

### Phase 5 — Client-facing

What Claude Code–based consultancies actually deliver; nonprofit-automation patterns for The
Caregiver Club. Expected to be the thinnest phase.

### Then make it recur

`/schedule` or the scheduled-task tooling, monthly, feeding `SOURCES.md` and this brief.
A one-time sweep decays; a recurring one compounds.

---

## Part 5 — Standing rules for this research

1. **Named sources beat topic searches.** A broad "best practices" crawl returns vendor blogs
   and influencer content. Fetch known-good authors directly.
2. **Product docs outrank vendor blogs.** Established this session: the startup guide said to
   use hooks as hard gates; the hooks docs said otherwise. Docs won.
3. **An unread citation does not ship.** Search-engine summaries of abstracts are not sources.
   Say "not independently verified," or leave it out.
4. **Distrust agent self-reports.** Re-verify anything load-bearing locally before acting.
5. **Every finding must answer: does this change what Daniel does on Monday?** If not, it is
   trivia, however interesting.

---

## Part 6 — How the phases are judged, filtered, and landed

### Every phase runs. The bar is per-phase, never global.

A single project-wide quota would let Phase 1 satisfy it and cause Phases 2–5 to be skipped —
which would be backwards, since the later phases carry the material Phase 1 structurally cannot
produce. So:

- Each phase has its own bar, and **a phase that clears its bar does not cancel any other phase.**
- The bar is a **quality check on that phase's approach**, not a stopping condition. If a phase
  returns little, that is itself a finding: cut it from *next* month's sweep, do not skip it now.

Per-phase bars:

| Phase | Clears its bar if it produces |
|---|---|
| 1 — Anthropic ground truth | ≥5 capabilities not currently used, plus every conflict with existing doctrine |
| 2 — Local models | A concrete model + backend recommendation with measured tokens/sec on this machine |
| 3 — Practitioners | ≥5 *compositions* (not features) worth stealing |
| 3b — Anduril / edge AI | An honest yes/no on whether anything transfers |
| 4 — Academic | ≥1 finding that survives the citation rules above |
| 5 — Client-facing | ≥2 patterns applicable to Betsey or The Caregiver Club |

### Phase 1 hunts for compositions, not just feature lists

Docs enumerate capabilities. They do not show what people *build* from them, and the gap
between "SessionEnd hooks exist" and "someone wired one that does X" is the entire thing Daniel
is chasing. So Phase 1 must also sweep cookbook-style docs, shipped plugins and skills on
GitHub, and worked examples — not only the reference pages.

### The filter is the doctrine, not novelty

Do **not** filter on "would this impress Claude." Claude is a biased instrument here: things
that read as mundane to it may be exactly what Daniel has never seen. The correct test is
**"does this help *this* kit, these projects, or these clients?"** — judged against the doctrine
in this repo, which is in context. When in doubt, include it.

### Every finding lands somewhere

Findings that sit in a document and die are the exact failure this session was spent repairing.
Each one is filed as exactly one of:

1. **Doctrine change** — a rule added, corrected, or retired (with what it displaces)
2. **Config change** — hook, permission, setting, plugin
3. **Build** — a thing to make, with a one-line reason
4. **Discarded** — with the reason, so it is not rediscovered next month

A finding with no destination is not a finding.
