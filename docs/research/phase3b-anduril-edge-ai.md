# Phase 3b — Anduril / Palmer Luckey: does anything transfer to a one-person shop on a laptop?

> Scope per the research brief: web research only, public sources only, one new file. See
> `docs/research/2026-09-08-capability-research-brief.md` Phase 3b for the framing question.

---

## 1. Verdict — up front

**Mostly no.** Anduril and Palmer Luckey publish a large volume of content, but it is almost
entirely product marketing, recruiting copy, and geopolitical argument. **Neither Anduril's
blog, its public GitHub org, nor Palmer Luckey's own essays and interviews contain
engineering detail about how they build, quantize, verify, or trust AI models.** No published
model sizes, no quantization numbers, no latency budgets, no described verification
methodology, no documented human-in-the-loop design beyond marketing language like
"human-supervised autonomy."

The one genuine finding is **not AI-specific**: Anduril's public Lattice SDKs and one sample
app reveal a clean **API separation between sensed data and controllable assets** (their
"Entities" vs. "Tasks" APIs), and that sample app demonstrates a real, if thin,
human-in-the-loop pattern — software recommends an action, a human retains execution
visibility and override. That pattern is worth naming for Daniel's kit (Section 3), but it is
a general software-architecture idea, not something specific to edge AI, model verification,
or defense engineering. It could have been found by reading any decent autonomy-system API
doc; Anduril's name attached to it adds nothing.

Everything else asked for in the brief — edge AI engineering specifics, verification-under-
irreversible-error methodology, escalation-threshold design — is **not publicly documented**
by Anduril or Palmer Luckey to any depth. This is a legitimate, low-yield result, exactly as
the brief anticipated ("Low expected yield, cheap to check, worth knowing either way").

---

## 2. What they've actually published

### Anduril's blog and news (blog.anduril.com, anduril.com/news)

- "Anduril Unveils Lattice for Mission Autonomy" — announces Lattice as a "hardware-agnostic,
  end-to-end software platform that enables teams of diverse robotic assets to work together
  under human supervision." Describes the shift from "many operators of one system" to "one
  operator of many systems." No architecture diagram, no model details, no discussion of how
  autonomy decisions are verified before fielding.
  Source: https://blog.anduril.com/anduril-unveils-lattice-for-mission-autonomy-8e0c5fa0e94b
  (exact publish date not verified from available page content; contemporary coverage on
  Breaking Defense dates this to 2023: https://breakingdefense.com/2023/05/andurils-new-tech-could-allow-single-operator-to-control-hundreds-of-autonomous-systems/)
- "In the 21st Century, the Department of Defense Must Think Software-First" — argues for a
  software-first defense acquisition model. Page returned HTTP 403 to direct fetch (Medium-hosted,
  blocks automated retrieval); content only available second-hand via search snippet, so treat
  its specifics as **not verified**.
  URL: https://blog.anduril.com/in-the-21st-century-the-department-of-defense-must-think-software-first-36802bd4be65
- Lattice product pages describe autonomy features (target ID, multi-asset orchestration,
  signature management) in capability-list form, not implementation form.
  Source: https://www.anduril.com/lattice/mission-autonomy

### Anduril's public GitHub (github.com/anduril, 17 public repos)

This is the most concrete, verifiable material Anduril publishes, and it is **integration
tooling, not AI/ML engineering**:

- `lattice-sdk-python`, `lattice-sdk-cpp`, `lattice-sdk-rust`, `lattice-sdk-javascript`,
  `lattice-sdk-java`, `lattice-sdk-go` — client SDKs for the Lattice API (REST/gRPC). The
  Python SDK README covers installation, async support, pagination, error handling — no
  design philosophy, no autonomy content. Full API reference is gated behind
  https://developer.anduril.com/ (not publicly crawlable without a developer account —
  **not verified** what it contains).
  Source: https://github.com/anduril/lattice-sdk-python
- `sample-app-auto-reconnaissance` — a runnable demo with three components: a simulated
  track publisher, a simulated commandable asset, and a control-logic program that watches
  the "Entities API" (streamed sensor/track data) and, when a non-friendly track comes within
  a threshold distance of an asset, issues an "Orbit" task via the "Tasks API." The task
  executes but remains visible/interruptible through the Lattice UI — i.e., the software
  recommends and initiates, a human retains visibility and override, execution isn't a black
  box. This is the one concrete, inspectable artifact in the entire search.
  Source: https://github.com/anduril/sample-app-auto-reconnaissance
- `jetpack-nixos` — a NixOS module for NVIDIA Jetson devices (their most-starred public repo,
  463 stars). Confirms they run Jetson-class edge hardware, but the repo itself is packaging
  glue, not a disclosure of model architecture or inference strategy.
  Source: https://github.com/anduril (org listing)

No public repo contains model weights, training code, quantization scripts, or benchmark
numbers.

### Palmer Luckey's own writing and interviews

- "I Saw the Future of War. Now It's Up to Us to Prepare For It." (The Free Press, based on a
  speech at National Taiwan University, delivered Aug 4 2025, published Aug 5 2025) — entirely
  geopolitical: Taiwan, deterrence, "smartest minds" argument for staying in defense work. No
  engineering content.
  Source: https://www.thefp.com/p/palmer-luckey-i-saw-the-future-of-war-taiwan
- Axios Show interview (March 2026) — AI pace of development, China competition, nuclear
  policy. Policy, not engineering.
  Source: https://www.axios.com/2026/03/16/axios-show-palmer-luckey-anduril-ai
- CBS 60 Minutes segment/transcript — Luckey states "all Anduril's weapons have a 'kill
  switch' that allow a human operator to intervene if needed," and describes the Dive XL
  submarine as running its own onboard "brain" rather than being remote-controlled. Beyond
  those two sentences, the transcript contains **no discussion of testing protocols, error
  rates, verification methodology, or engineering safety standards** — confirmed by direct
  reading, not inference.
  Source: https://www.cbsnews.com/news/palmer-luckey-ai-powered-autonomous-weapons-future-of-warfare-60-minutes-transcript
- Fortune (Mar 2026) — Luckey vs. Anthropic's Dario Amodei on whether Pentagon AI use should
  be industry- or government-gated. Pure policy dispute, not engineering.
  Source: https://fortune.com/2026/03/06/palmer-luckey-pentagon-anthropic-debate-dario-amodei-claude-ai/

### Individual Anduril engineers publishing independently

**Not found.** No personal blog, conference talk, or paper by a named Anduril engineer
surfaced in this search discussing model verification, edge deployment, or autonomy design in
technical depth. This is a genuine gap, not just an artifact of search terms — several search
angles (conference talks, GitHub, YouTube technical channels, arXiv) were tried and each
returned either marketing material or unrelated third-party research. Worth re-checking in a
future monthly sweep rather than treating as permanently settled.

### Lattice OS architecture (public documentation)

Publicly described only in outline: a "Lattice Mesh" decentralized data-distribution layer so
frontline units share sensor data without routing through central processing, plus a
REST/gRPC SDK/API layer for third-party integration. This is a systems-architecture claim
from marketing copy, not a technical specification — **not independently verified** beyond
what Anduril states about itself.
Source: https://www.anduril.com/lattice/mission-autonomy, https://blog.anduril.com/anduril-unveils-lattice-for-mission-autonomy-8e0c5fa0e94b

### One tangible edge-AI data point

GeekWire's on-the-ground reporting (2026) describes Anduril's EagleEye heads-up display
system using "machine learning models" to fuse thermal imagery and low-light camera feeds in
real time for a wider field of view than existing night-vision hardware, tested at a physical
range near Carnation, WA. This is the only third-party account in this search that describes
a concrete on-device ML workload (sensor fusion, real-time, embedded) — but it comes with no
model size, latency, or hardware spec, and is a journalist's paraphrase, not a technical
disclosure.
Source: https://www.geekwire.com/2026/inside-andurils-ai-warfighting-buildup-defense-giant-sees-a-path-to-1000-seattle-area-engineers/

---

## 3. Transferable patterns, if any, with specific application

Only one pattern cleared the bar of being (a) concrete, (b) verifiable from a primary source,
and (c) not something already obvious from general software design:

### Pattern: separate "what is observed" from "what can be commanded," and keep execution visible

The `sample-app-auto-reconnaissance` demo (Section 2) splits its world model into an
**Entities API** (a stream of sensed things — tracks, positions — that cannot be commanded)
and a **Tasks API** (commands issued to controllable assets, whose execution status can be
polled/interrupted). The automation layer decides *what task to propose*; a human operator
retains visibility into *whether it's still running* and can intervene.
Source: https://github.com/anduril/sample-app-auto-reconnaissance

**Specific application to Daniel's kit:** this maps loosely onto the existing tier model in
`docs/mechanizing-doctrine.md` (permission deny > hook > rule > skill), but it suggests a
distinction the kit doesn't currently name explicitly: **"things Claude observes/reports"
(read-only findings, like a code-review comment) vs. "things Claude commands"
(file writes, git pushes, agent dispatches)**, with the second category always left
interruptible/visible rather than fire-and-forget. In practice this is already how hooks and
the permission system behave (an "ask" from a hook is exactly this kind of visible,
interruptible checkpoint) — so the honest framing is that Anduril's sample app **confirms an
existing design choice already in the kit**, rather than introducing a new one. It is not
worth writing a new rule over; it's worth noting in a doctrine review that the kit already
independently arrived at the pattern the one inspectable Anduril artifact demonstrates.

No other pattern in this search met the bar. Specifically:

- The "kill switch" language from the 60 Minutes transcript is a marketing-level restatement
  of "there is a way to stop it," not a design worth importing — the kit's permission-deny
  tier already is a stronger, more specific version of that idea.
- "One operator, many autonomous systems" (Lattice's stated design goal) is a fleet-management
  concept for physical assets under adversarial time pressure. It doesn't map onto a
  one-person consulting practice where there is no fleet and no adversary reacting in real
  time.

---

## 4. What does not transfer, and why

- **Edge AI engineering specifics (model sizes, quantization, latency budgets, offline
  operation).** None of this is published. Even the one concrete on-device ML example found
  (EagleEye's sensor-fusion display, Section 2) has no numbers attached. There is nothing here
  to compare against the Phase 2 local-models work — the two problems may be structurally
  similar (constrained hardware, no cloud round-trip) but Anduril's actual numbers are
  classified or simply not released, so the analogy stays theoretical and unfalsifiable from
  public sources.
- **Verification/trust methodology for high-stakes, low-tolerance-for-error decisions.** This
  was the most directly relevant question in the brief (it mirrors Daniel's Phase 1
  verification work), and it returned nothing. No published testing protocol, no error-rate
  disclosure, no description of how a model earns the right to make an unsupervised call.
  Luckey's public statements on this topic are moral/political arguments ("smart weapons vs.
  dumb weapons," "no moral high ground in outsourcing to the less scrupulous") — they argue
  *why* autonomy should exist, not *how* its correctness is established before fielding.
  Importing rhetoric about acceptable risk from a defense-weapons context into a consulting
  kit's hook-threshold design would be a category error: the domains don't share a cost
  function, an adversary model, or a regulatory structure. A wrong Claude Code edit and a
  wrong targeting decision are not the same kind of "expensive."
- **Human-in-the-loop escalation design at the threshold level.** Daniel's kit has a specific
  mechanism (hooks that return "ask" at a defined trigger). Anduril's public material never
  goes below "a human supervises" as a stated principle. There is no published decision tree,
  confidence threshold, or escalation criterion to compare against — so there is nothing to
  transfer beyond the general architectural point already covered in Section 3.
- **Organizational/cultural material** (software-first acquisition, hiring philosophy,
  government-contracting motivations) — real, but has no analog in a one-person shop; it's
  about defense-procurement politics, not AI engineering.

---

## 5. Sources, with dates

| Source | Date | What it contributed |
|---|---|---|
| Anduril, "Anduril Unveils Lattice for Mission Autonomy" (blog.anduril.com) | ~May 2023 (per contemporary Breaking Defense coverage; exact date on Anduril's own page not verified) | Lattice's stated design goal ("one operator, many systems") |
| Breaking Defense, "Anduril's new tech could allow single operator to control 'hundreds' of autonomous systems" | 2023-05 | Corroborating date/context for the Lattice announcement |
| Anduril, "In the 21st Century, the Department of Defense Must Think Software-First" (blog.anduril.com) | Not verified — page returned HTTP 403 to direct fetch; content known only via search snippet | Software-first acquisition argument (not independently confirmed) |
| Anduril, Lattice Mission Autonomy product page | Not dated on page | Marketing-level architecture description (Lattice Mesh, SDK/API) |
| github.com/anduril (org) | Checked 2026-09-08 | Inventory of 17 public repos, all SDKs/samples, no ML code |
| github.com/anduril/sample-app-auto-reconnaissance | Checked 2026-09-08 | The one concrete, inspectable human-in-the-loop pattern found |
| github.com/anduril/lattice-sdk-python | Checked 2026-09-08 | Confirmed README has no architecture/autonomy content; full API reference gated behind developer.anduril.com (not accessed) |
| Palmer Luckey, "I Saw the Future of War..." (The Free Press) | Speech 2025-08-04, published 2025-08-05 | Confirmed geopolitical, not engineering, content |
| Axios, "Anduril's Palmer Luckey talks AI, nukes and Iran" | 2026-03-16 | Confirmed policy focus |
| Fortune, "Palmer Luckey says Silicon Valley has the Pentagon all wrong" | 2026-03-06 | Luckey vs. Amodei policy dispute |
| CBS News, 60 Minutes transcript, Palmer Luckey | Not dated in retrieved excerpt | Direct-read confirmation of "kill switch" quote and absence of testing/verification detail |
| GeekWire, "Inside Anduril's AI warfighting buildup" | 2026 (exact date not captured; URL dated 2026) | Only concrete on-device ML example found (EagleEye thermal/low-light fusion), no numbers |
| developer.anduril.com | Not accessed (gated) | Noted as an unverified gap — full Lattice API reference may contain more detail than the public SDK READMEs; a future sweep could check whether it's accessible without a developer account |

**Confidence note:** several individual claims above are flagged "not verified" because the
source page could not be directly fetched (HTTP 403 on Medium-hosted Anduril blog posts, and
one Forbes article on Palantir/Anduril offline AI that also returned 403) and are reported
only via search-engine snippet. Per the brief's citation rule, these are marked accordingly
rather than presented as confirmed. If a future sweep wants to close this gap, the two
specific URLs worth a manual (browser, not fetch-tool) revisit are:
`blog.anduril.com/in-the-21st-century-the-department-of-defense-must-think-software-first-36802bd4be65`
and `forbes.com/sites/sandycarter/2026/04/06/palantir-and-anduril-build-offline-ai-and-thats-no-edge-case/`.
