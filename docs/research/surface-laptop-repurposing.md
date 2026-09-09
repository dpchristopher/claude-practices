# What to do with the idle Surface Laptop 4

Research date: 2026-09-08. Model unknown — could be Intel (i5-1135G7/i7-1185G7) or AMD
(Ryzen 5 4680U/Ryzen 7 4980U), 8/16/32 GB RAM, 13.5" or 15". Findings below are flagged per
variant wherever the answer changes. Ranked by value to a one-person consulting shop with two
clients (Betsey Brown Travel — paying; The Caregiver Club — nonprofit), not by technical
interest.

## 1. Top recommendation, up front

**Turn it into a clean-room client demo and test machine, full stop — and do that before
anything else, regardless of which variant it turns out to be.**

**What it requires:** a factory-reset (or fresh local-account) Windows 11 install, a plain
Claude Code / Claude Desktop install with zero project skills, zero of the 92 skills, zero of
the 34 agents, zero of the 20 hooks that live in Daniel's actual kit. No `CLAUDE.md`, no
`.claude/` directory carried over. That's it — no scheduling, no networking, no Linux, no
model downloads. An afternoon, not a project.

**What it would actually change:** right now there is no way to answer "what does a
non-technical client actually see when they open Claude Code" without mentally subtracting 92
skills, 34 agents, and 20 hooks from what Daniel's own machine shows him — and that subtraction
is exactly the kind of self-report this practice already distrusts (see
`2026-09-08-capability-research-brief.md`, "Agent reliability, measured"). A second machine
running the unmodified default answers that question directly, for real, every time it matters:

- **Building onboarding material for Betsey Brown Travel or The Caregiver Club** — screenshots,
  scripts, "here's what you'll see" walkthroughs — that match what the client's own install will
  show, not Daniel's customized one.
- **Diagnosing "it doesn't do X for me" client complaints** — reproduce on the default install
  first, rather than guessing whether the gap is Claude Code itself or one of Daniel's own 20
  hooks silently doing work the client's install doesn't have.
- **Testing whether a skill/output-style Daniel wants to ship to a client** actually helps a
  default install, versus only working because it's propped up by other doctrine already loaded
  on his machine.

This is the only option on this list that is (a) usable on any hardware variant with zero
caveats, (b) directly revenue/relationship-relevant rather than an internal nice-to-have, and
(c) has no ongoing maintenance, power, or security cost — it can sit closed in a drawer between
uses and still be worth having.

Everything else below is worth doing too (the machine can serve more than one purpose), but if
only one thing gets built, build this one.

## 2. Every option, ranked

### #1 — Clean-room client demo/test machine — see §1. Feasibility: full, any variant, any RAM.

### #2 — Scoped always-on automation node (not a general "agent runner")

**Verdict: worth building, but only for a narrower job than "run Claude Code overnight so the
XPS stays free."** That framing undersells what already exists for free and oversells what the
Surface adds.

Anthropic ships three ways to schedule unattended Claude Code work, and they are not
interchangeable
([Run prompts on a schedule](https://code.claude.com/docs/en/scheduled-tasks)):

| | Cloud Routines | Desktop scheduled tasks | `/loop` in a session |
|---|---|---|---|
| Needs a machine on | **No** | Yes | Yes |
| Local file access | No (fresh git clone) | Yes | Yes |
| Survives your machine being off | Yes | No | No |

**The key finding: cloud [Routines](https://code.claude.com/docs/en/routines) already solve "I
don't want to tie up the XPS," for free, with no second machine at all.** They run on
Anthropic-managed infrastructure, trigger on a schedule/API call/GitHub event, and keep working
with the laptop closed. So the Surface's marginal value is *not* "a free machine to run
background Claude Code on" — it's specifically: **work that needs a real local filesystem**
(client documents outside a git repo, local skills/hooks identical to the main kit, anything
touching software installed only on a machine, not a cloud clone). Given that both clients are a
travel agency and a nonprofit — plausibly dealing with local documents, spreadsheets, or
desktop software rather than clean git repos — that gap is real, not hypothetical.

**What this actually requires, and what breaks:**

- **The machine must stay awake**, not just plugged in. Desktop scheduled tasks explicitly only
  fire "while the desktop app is running and your computer is awake... If your computer sleeps
  through a scheduled time, the run is skipped," with a "Keep computer awake" toggle and the
  note that "closing the laptop lid still puts it to sleep" regardless
  ([Desktop scheduled tasks](https://code.claude.com/docs/en/desktop-scheduled-tasks)). Lid
  must stay open or the setting must override lid-close behavior in Windows power settings
  (not verified whether Windows honors "stay awake" software over a lid-close sleep action on
  this specific hardware).
- **Background sessions (`claude --bg`, agent view) tolerate sleep**, unlike Desktop scheduled
  tasks: "Sessions are preserved when your machine sleeps. Their processes resume on wake,"
  but "Shutting down or restarting your machine stops running background sessions"
  ([Agent View](https://code.claude.com/docs/en/agent-view)). So sleep is fine for this path;
  shutdown is not.
- **Agent View is local-machine-only.** "Sessions are local: background sessions run on your
  machine" — there is no cross-machine agent view. The XPS cannot see or manage the Surface's
  background sessions through `claude agents`; you'd need to be physically at the Surface, or
  reach it another way (see below) (same source).
- **Cross-machine visibility comes from two different features, not agent view:**
  [SendMessage/cross-session messaging](https://code.claude.com/docs/en/agent-view) routes
  machine-to-machine over the Remote Control connection specifically ("Same-machine delivery is
  a local socket... Cross-machine messages travel over the Remote Control connection" — per
  secondary-source synthesis of the feature, shipped v2.1.224, Aug 7 2026; not independently
  read from a primary doc page). Separately, **Remote Control itself makes the Surface a pickable
  device**: "Any machine running `claude remote-control` now shows up as a device card in the
  Claude mobile app's Code tab — tap it, pick a directory, and Claude Code starts a brand-new
  session on that machine directly from your phone"
  ([Simon Willison, 2026-02-25](https://simonwillison.net/2026/Feb/25/claude-code-remote-control/)).
  That's the genuinely useful, slightly unobvious composition: leave the Surface on at home,
  running `claude remote-control`, and dispatch local-filesystem work to it from your phone
  without ever touching its keyboard — a second compute node reachable the same way you'd reach
  the XPS, but that doesn't cost the XPS anything while it works.
- **Auth is per-machine, not a blocker.** You can be logged into the same claude.ai account from
  both machines concurrently; usage limits are pooled at the account level, not per-device, and
  Daniel has already deprioritized usage-limit concerns (per the brief) — but running two active
  machines does draw down the same shared 5-hour usage window faster
  (general community synthesis, not a primary-doc citation — treat as likely true, not
  independently verified against Anthropic's own docs page).
- **Runs natively on Windows, no WSL needed** — "Claude Code runs natively on Windows, no WSL
  required" — which matters because it means Option #3 (Linux) is not a prerequisite for this
  one; keep the Surface on Windows and this works today. One caveat found: a background-session
  cleanup bug exists specifically **on WSL2** (completed sessions won't delete from agent view;
  [GitHub issue #75591](https://github.com/anthropics/claude-code/issues/75591)) — another
  reason not to bother with WSL here.

**Feasibility by variant:** identical regardless of Intel/AMD or RAM size, since this all runs
on Windows. 8 GB is workable but tight if you also want a local model resident (see #3) at the
same time; 16 GB+ is comfortable.

### #3 — Local-model host on the LAN

**Verdict: real but modest — a convenience tier below the XPS, not a replacement for it.**

The mechanism is solid and well-documented: LM Studio's server mode has a one-setting "Serve on
Local Network" toggle that exposes an OpenAI-compatible endpoint on the host's LAN IP instead of
just `localhost`, with an explicit warning to enable authentication once you do
([LM Studio docs](https://lmstudio.ai/docs/developer/core/server/serve-on-network)). Ollama and
llama.cpp's own server mode work the same way. The XPS could point the existing `local-models`
skill's routing at `http://<surface-ip>:1234/v1` instead of (or alongside) its own local LM
Studio instance.

**The honest ceiling is speed, not capability.** Neither CPU family here has a discrete GPU or
CUDA, matching the XPS's own non-CUDA situation, but the XPS at least has an NPU and 63.5 GB of
RAM; the Surface has neither advantage — Tiger Lake's Iris Xe iGPU and Renoir's Vega iGPU are
both too weak for meaningful LLM offload, so this is CPU-only inference on 4-year-old mobile
silicon. General llama.cpp CPU benchmarks put a 7B Q4 model in the **4–15 tok/s** range on modern
CPUs, with a same-era desktop APU (Ryzen 5700G) measured at 11 tok/s CPU-only on Mistral 7B
(sources below). **I could not find a benchmark for the exact chips in this machine** (i5-1135G7
/ i7-1185G7 / Ryzen 5 4680U / Ryzen 7 4980U specifically) — extrapolating down from
desktop-class numbers for weaker, older, lower-power mobile silicon, a realistic estimate is
**roughly 3–8 tok/s for a 7–8B Q4 model and 10–20 tok/s for a 3B model** on either variant, but
**this is an estimate, not a verified measurement** — run `llama-bench` on the actual unit before
relying on it operationally.

RAM ceiling matters less here than it sounds: a 3–8B Q4 model needs roughly 2–6 GB resident, well
within even the 8 GB configuration, so RAM headroom mostly buys you the ability to also run
Windows, a browser, and Claude Code's own background sessions (#2) at the same time, not a bigger
model.

**Value case:** an always-available small-model endpoint the XPS (or a routine, or a client-side
script) can call for cheap classification/extraction work without spinning up LM Studio locally
or waiting on the XPS's own load — useful, but it's a nice-to-have layered on top of #2's "keep
it awake anyway," not a reason to build this machine on its own.

**Feasibility by variant:** works on either CPU family; genuinely CPU-bound either way, so Intel
vs AMD is not the deciding factor here — RAM and idle availability are.

### #4 — A Linux box

**Verdict: technically interesting, not worth it for this shop. Skip unless it's a hobby
project on its own time.**

The `linux-surface` project is real and still active at the project level — commits to the
kernel patch repo as recently as September 3, 2026, and to the main repo in May 2026
(per search synthesis of GitHub commit history; the primary repo page itself failed to render
during this research, so this is not a direct read of the commit log — treat as likely true, not
independently verified). But "the project is alive" and "this specific device variant works well
in 2026" are different claims, and the second one has weak evidence:

- **AMD variant:** the most detailed community status report found for Surface Laptop 4 AMD
  dates to **April 2023** (a discussion thread with no 2025/2026 follow-up found), reporting
  suspend works, keyboard/touchpad work under the Surface kernel, but graphics require
  `amd_iommu=off iommu=off` to avoid screen corruption, and **touchscreen is unsupported**
  pending an SPI-HID driver nobody with hardware access has written
  ([linux-surface/linux-surface discussion #1081](https://github.com/linux-surface/linux-surface/discussions/1081)).
  This matches the brief's warning that AMD variants have notoriously poor Linux support on
  Surface hardware.
- **Intel variant:** documented trade-off is `nomodeset` (stabilizes the system, but breaks
  brightness control) versus not using it (brightness works, stability suffers) — an unresolved
  either/or, not a clean "it just works"
  ([linux-surface wiki, Surface Laptop 4](https://github.com/linux-surface/linux-surface/wiki/Surface-Laptop-4)).
  Wifi is also flagged as potentially unstable on this variant in the same source.
- **AMD RAM ceiling:** AMD configurations of the Surface Laptop 4 topped out at **16 GB**;
  only Intel configurations went to 32 GB
  (general spec-sheet synthesis; not verified against a Microsoft primary source in this
  session). If the unit turns out to be AMD, that's a second, independent reason it can't be the
  "big local model" box regardless of OS.
- **No CUDA either way**, same as the XPS, so Linux buys nothing for local-model throughput that
  Windows doesn't already give you via LM Studio/Ollama (#3) — the entire reason to dual-boot or
  wipe to Linux here would be Linux itself, not any capability gap Windows has.

Given that #1, #2, and #3 all work fine on stock Windows 11, and Linux adds real, still-unresolved
driver risk on top of hardware Daniel needs to actually rely on, this is not worth the setup time
for a business tool. If curiosity wins anyway, do it on a spare partition, not as the only OS,
and expect a weekend, not an afternoon.

### #5 — Monitoring/dashboard display

**Verdict: a real feature, but a bonus on top of #2, not a standalone reason to keep the
machine.**

`claude agents` (Agent View) is a genuine built-in dashboard: "a terminal dashboard for
background Claude Code sessions... shows each row as a full Claude Code conversation that keeps
running with no terminal attached," lets you "reply to agents without attaching to the full
transcript," and is available on Pro/Max/Team/Enterprise/API plans as of Claude Code v2.1.139+
([Claude Code docs, Agent View](https://code.claude.com/docs/en/agent-view)). Since Agent View is
local-machine-only (see #2), the Surface running its *own* `claude agents` full-screen is a
free, always-on view into whatever local-filesystem automation you built in #2 — genuinely
useful as a second-screen "what is my automation node doing" panel, at zero extra setup cost once
#2 exists. It is not, on its own, worth dedicating a laptop to; it only earns its keep riding
along with #2.

### #6 — Honest disposal option: sell it

**Verdict: not the better move here, but the numbers are real, so here they are.** Swappa's
September 2026 pricing shows Surface Laptop 4 resale in the **$300–$470 average** range
depending on configuration — AMD Ryzen 5 units around $288–$369, Ryzen 7 around $387–$402, Intel
i5 around $337–$359, and Intel i7 as high as $567 for higher-storage configurations
([Swappa, Microsoft Surface Laptop 4 pricing](https://swappa.com/prices/microsoft-surface-laptop-4),
accessed 2026-09-08; note the page itself flags this as historical average sale/list price data,
not a live current-inventory quote). That's a real, non-trivial number for a machine that is
currently producing zero value sitting idle. But the case for keeping it is that **option #1
costs an afternoon and has no ongoing cost**, and options #2/#3 cost real but bounded setup time
for automation and a demo/test capability this practice does not currently have any other way to
get — for a one-person shop optimizing for automation and accuracy rather than cash, that beats
$300–$470 once, provided the setup actually gets built and used rather than becoming another
"built correctly, then never connected" entry in the ledger this research brief exists to
prevent. If it's still sitting untouched in three months, sell it then — the resale value doesn't
meaningfully decay faster than that.

## 3. What depends on which config — the question to answer before acting

**The one fact that gates the most decisions: is it Intel or AMD, and how much RAM?** Check
Windows Settings → System → About, or look up the serial number via Microsoft's device page.
That single fact determines:

- **Whether Linux (#4) is even worth attempting.** AMD → skip it, evidence is weak and stale and
  RAM tops out at 16 GB regardless. Intel → marginally more plausible but still has an unresolved
  stability/brightness trade-off as of the most recent source found.
- **Nothing about #1 (demo machine), #2 (automation node), or #3 (LAN model host) changes by
  variant** — all three run on stock Windows 11 regardless of CPU family. RAM matters only in
  that 8 GB is workable-but-tight if you want #2 and #3 running at the same time; 16 GB+ removes
  that concern entirely.

13.5" vs 15" has no bearing on any of the above — it only affects how pleasant #5's dashboard
view is to look at, and even there, either size is fine.

## 4. What I could not verify

- **Exact tokens/sec for the specific chips in this machine** (i5-1135G7, i7-1185G7, Ryzen 5
  4680U, Ryzen 7 4980U) running a 3–8B model via llama.cpp/Ollama/LM Studio. No direct benchmark
  found for any of the four; the §2/§3 estimates are extrapolated down from other CPUs' published
  numbers and should be confirmed with `llama-bench` on the actual hardware before relying on it.
- **Current (2026) real-world Linux stability on this exact device variant.** The linux-surface
  project is active at the project level, but the most detailed community report specific to
  Surface Laptop 4 AMD found in this research is dated April 2023; no 2025/2026 follow-up located.
- **Whether Windows' lid-close sleep behavior can be reliably overridden** for the "keep it awake
  for scheduled tasks" requirement in §2, on this specific hardware — the Claude Code docs note
  the constraint exists but don't cover Windows power-plan configuration specifics.
- **Whether AMD Surface Laptop 4 units really cap at 16 GB RAM** vs. Intel's 32 GB ceiling — based
  on general spec-sheet search synthesis, not a Microsoft primary source read directly in this
  session.
- **Whether cross-session messaging's cross-machine routing over Remote Control** (§2) is
  described that way in Anthropic's own primary documentation — the specific mechanism claim
  came from secondary-source synthesis of the feature, not a page fetched and read directly.
- **Whether logging into the same claude.ai account concurrently on two machines has any friction
  beyond shared usage limits** (device caps, forced logout, etc.) — not found in a primary source.
- **Surface-specific battery-health tooling** (e.g., a Microsoft-provided charge-limit feature,
  as some ThinkPad/Dell tools offer) for a machine kept always-on/plugged-in per §2 — not checked;
  if none exists, general lithium-battery guidance (avoid dwelling at 100%/high heat) applies but
  wasn't verified against a Surface-specific source.

## 5. Sources, with dates

- Anthropic, [Run prompts on a schedule](https://code.claude.com/docs/en/scheduled-tasks) —
  fetched 2026-09-08.
- Anthropic, [Desktop scheduled tasks](https://code.claude.com/docs/en/desktop-scheduled-tasks) —
  fetched 2026-09-08.
- Anthropic, [Automate work with routines](https://code.claude.com/docs/en/routines) — fetched
  2026-09-08.
- Anthropic, [Agent View](https://code.claude.com/docs/en/agent-view) — fetched 2026-09-08.
- Simon Willison, [Claude Code Remote Control](https://simonwillison.net/2026/Feb/25/claude-code-remote-control/) —
  2026-02-25.
- anthropics/claude-code, [Issue #75591 — WSL2 background-session cleanup bug](https://github.com/anthropics/claude-code/issues/75591) —
  search-result synthesis, 2026-09-08.
- linux-surface/linux-surface, [Discussion #1081 — AMD Surface Laptop 4 support](https://github.com/linux-surface/linux-surface/discussions/1081) —
  latest comment dated 2023-04-23, fetched 2026-09-08.
- linux-surface/linux-surface, [Issue #425 — Surface Laptop 4 AMD support request](https://github.com/linux-surface/linux-surface/issues/425) —
  referenced via search, 2026-09-08.
- linux-surface/linux-surface, [wiki: Surface Laptop 4](https://github.com/linux-surface/linux-surface/wiki/Surface-Laptop-4) —
  fetched 2026-09-08.
- linux-surface/linux-surface, [main repo](https://github.com/linux-surface/linux-surface) and
  commit history — search-result synthesis (direct fetch failed to render), 2026-09-08.
- Swappa, [Microsoft Surface Laptop 4 pricing](https://swappa.com/prices/microsoft-surface-laptop-4) —
  fetched 2026-09-08 (site-reported "September 2026" pricing snapshot).
- LM Studio, [Serve on Local Network](https://lmstudio.ai/docs/developer/core/server/serve-on-network) —
  search-result synthesis, 2026-09-08.
- LM Studio, [LM Studio as a Local LLM API Server](https://lmstudio.ai/docs/developer/core/server) —
  search-result synthesis, 2026-09-08.
- General llama.cpp CPU inference benchmarks (Ryzen 5700G ~11 tok/s CPU-only on Mistral 7B; modern
  CPUs broadly 4–15 tok/s on 7B Q4) — aggregated from multiple secondary-source search results,
  2026-09-08; no single primary benchmark page fetched directly, and none found for the exact
  chips in this machine (see §4).
- Community/secondary-source search synthesis on Claude Code cross-session messaging (`SendMessage`,
  shipped v2.1.224, 2026-08-07) and multi-machine login/usage-limit behavior — not independently
  read from a primary Anthropic doc page in this session (see §4).
- `C:\Dev\claude-practices\docs\research\2026-09-08-capability-research-brief.md` — Daniel's goals,
  constraints, and client context (internal document, read at the start of this research).
