# Hardware Options — Closing the Local-AI Gap on the XPS 16

> Researched 2026-09-08 (web research only; no installs, no purchases, no edits to existing
> files — see `2026-09-08-capability-research-brief.md` Part 5 for citation rules honored here).
> Builds on `phase2-local-models.md`: Dell XPS 16, Core Ultra X7 358H, 63.5 GB RAM, **Intel Arc
> B390 integrated GPU, no CUDA**. Chip-matched benchmark: 7B Q4_0 at 19.2 tok/s, 27B Q4_K_M at
> 3.55-4.31 tok/s ([ggml-org/llama.cpp #23313](https://github.com/ggml-org/llama.cpp/discussions/23313)).
> Use case: intermittent batch extraction/classification/summarization for two clients (a paying
> travel agency, a nonprofit) — **not latency-sensitive** — plus finance/analytics work. One-person
> shop; this is a capital-expense decision, not a hobby budget.

---

## 1. Recommendation

**Buy nothing right now. $0.**

The existing machine already clears the actual bar for the stated workload. At the measured
27B Q4_K_M rate of 3.55-4.31 tok/s, a ~150-token structured-extraction call takes ~35-45 seconds
([ggml-org/llama.cpp #23313](https://github.com/ggml-org/llama.cpp/discussions/23313), 2026-06-02
— already cited in `phase2-local-models.md`). A 1,000-document overnight batch at that tier
finishes in roughly 10-12 hours — one overnight window. Since the brief states this work is
explicitly *not* latency-sensitive, there is no unmet need today that spending closes. Every
option evaluated below costs $600-$4,700 to solve a problem — waiting — that the task's own
framing says doesn't matter yet.

**The trigger for revisiting this, and what to buy when it fires:** if batch volume grows past
roughly 2,000-2,500 documents per run (no longer fits one overnight window at current speed), or
Daniel wants the XPS physically free to travel/present while a batch runs, the single best-value
purchase is a **used RTX 3090 (24 GB) in a budget desktop build, ~$1,300-1,650 total**
(card ~$950-1,050 used, per [bestvaluegpu.com](https://bestvaluegpu.com/history/new-and-used-rtx-3090-price-history-and-specs/)
and eBay sold-listing data through 2026-08-22; host build ~$350-600, not independently priced as
a single quote — see §4). That configuration measures at roughly 24-28 tok/s on a 27-34B Q4_K_M
model ([mustafa.net](https://mustafa.net/llm-tokens-per-second-benchmarks/), dated 2026-04-22;
corroborated directionally by [sanj.dev](https://sanj.dev/post/qwen-3-6-27b-dual-rtx-3090-llama-cpp-tuning/),
22.8 tok/s on a *dual*-3090 Qwen3.6-27B setup) — a ~6-7x speedup over the current iGPU at the
exact tier that matters, and the best tokens-per-dollar of every option checked (see §2.3 and the
bandwidth arithmetic there). It beats the Mac Mini and the AMD Strix Halo mini PC on this
specific metric once their headline tok/s claims are cross-checked against their own published
memory bandwidth (§2.2, §2.5) — several of those claims did not survive that check and are
flagged as casualties below, not adopted.

**If a purchase is triggered, fund it partly by selling idle hardware already in inventory**
rather than treating it as a cold $1,300+ outlay: `xbox-repurposing.md` (2026-09-08, same research
pass) already concluded a Series X is worth more sold (~$150-410,
[bankmycell.com](https://www.bankmycell.com/blog/how-much-is-an-xbox-series-x-worth/)) toward a
3090 or Mac mini than kept idle, and reached that conclusion independently of this file. If that
sale happens, net out-of-pocket for the 3090 build drops to roughly $900-$1,500.

**Everything else — eGPU, Mac Mini, DGX Spark, Jetson, cloud rental as a default — is a skip**,
each for a specific, priced reason documented in §2. Cloud rental in particular is not a
"cheaper alternative" here: it is economically dominant on pure $/hour math (§3) but reintroduces
the exact privacy exposure — client data leaving the device — that local models exist to avoid
in the first place. That tension is structural, not a rounding error, and is discussed in §2.4.

---

## 2. Each option, with real prices and benchmarks

### 2.1 eGPU over Thunderbolt — SKIP (works, but expensive and fragile for the money)

- **Does the XPS 16 support eGPU?** Yes, mechanically — it ships with **three Thunderbolt 4
  ports** ([Engadget XPS 16 (2026) review](https://www.engadget.com/computing/laptops/dell-xps-16-2026-review-return-of-the-king-130000906.html);
  [PCWorld XPS 16 (2026) review](https://www.pcworld.com/article/3110951/dell-xps-16-2026-review.html)).
  It has **no discrete GPU option this generation** — Arc B390 integrated only, confirmed by both
  reviews — so an eGPU would be the *only* way to add real dedicated VRAM/bandwidth to this
  specific laptop.
- **TB4, not TB5, matters for bandwidth.** TB4 caps at 40 Gbps vs. a native PCIe 4.0 x16 slot's
  256 Gbps ([bottleneckcalculator.us.com](https://bottleneckcalculator.us.com/knowledge-base/hardware-guides/egpu-bottleneck/)).
  TB5 (80 Gbps, not present on this XPS 16) narrows that gap further but doesn't close it.
- **The bandwidth penalty for LLM inference specifically is smaller than for gaming**, because
  weights live in the eGPU's own VRAM and only token embeddings/output cross the Thunderbolt
  link — inference is VRAM-bandwidth-bound and compute-bound, not link-bandwidth-bound.
  Practical eGPU benchmarks put LLM throughput at **60-75% of native for models under 13B, and
  75-85% for larger, more compute-bound models**
  ([egpu.io forum thread](https://egpu.io/forums/pro-applications/impact-of-egpu-connection-speed-on-local-llm-inference-in-multi-egpu-setups/);
  corroborated directionally by [ai2.work](https://ai2.work/blog/best-egpu-enclosures-for-ai-inference-and-local-llm-workloads),
  secondary aggregator, treat as directional). The real bottleneck shows up at **model load time**
  (multi-GB weight transfer) and large-batch prompt processing, not steady single-call decode.
- **Cost, real numbers:** a working NVIDIA eGPU rig needs an enclosure plus a card.
  - Enclosure: original **Razer Core X, ~$299-350, has a built-in 650W PSU**
    ([Amazon listing](https://www.amazon.com/Razer-Core-Thunderbolt-External-Enclosure/dp/B07CQG2K5K)).
    The newer **Core X V2 is $349.99 but dropped the built-in PSU**
    ([VideoCardz](https://videocardz.com/newz/razer-core-x-v2-now-available-349-99-egpu-enclosure-with-thunderbolt-5);
    [Tom's Hardware](https://www.tomshardware.com/pc-components/gpus/razer-unveils-core-x-v2-egpu-enclosure-with-tb5-bandwidth-costs-usd400-but-no-longer-has-a-power-supply-and-i-o-expansion-requires-a-separate-thunderbolt-5-dock)),
    adding cost/complexity — the original is the better fit here.
  - Card: used RTX 3090 ~$950-1,050 ([bestvaluegpu.com](https://bestvaluegpu.com/history/new-and-used-rtx-3090-price-history-and-specs/),
    Aug 2026 eBay sold data), or a new RTX 4090 (~$1,600-2,000, general market, not independently
    priced here). **Total realistic build: ~$1,300-1,400 for a 3090 rig, ~$2,000-2,400 for a
    4090 rig.**
  - A pre-integrated option exists — the **Gigabyte AORUS RTX 4090 Gaming Box, ~$1,800** — but it
    bundles enclosure and card at a premium versus buying separately
    ([Amazon listing](https://www.amazon.com/GIGABYTE-WATERFORCE-Thunderbolt-GV-N4090IXEB-24GD-External/dp/B0C8LS7PT2)).
- **Driver conflicts with the Arc iGPU:** the conflicts actually documented are **Intel-iGPU +
  Intel-dGPU** pairings — Intel split iGPU/dGPU drivers into separate packages, breaking the
  previously-unified handshake and causing black screens/crashes unless installed in a specific
  order ([Intel Community thread](https://community.intel.com/t5/Graphics/Conflict-of-Intel-iGPU-and-discrete-GPU-on-Windows-11-24-H2/td-p/1648928);
  [dual Arc Battlemage thread](https://community.intel.com/t5/Graphics/Dual-Arc-Battlemage-GPUs-Driver-Support-Not-Combining/td-p/1665160)).
  An **Intel iGPU + NVIDIA eGPU** pairing is a much more common laptop configuration pattern
  (standard hybrid-graphics/Optimus-style setup) and general eGPU/Windows guidance describes it
  as working on TB4/5 laptops without special caveats
  ([egpu.io forums](https://egpu.io/forums/pc-setup/)) — but **no source found tested this exact
  combination (Arc B390 iGPU + NVIDIA eGPU) specifically**. Treat the Intel+Intel conflict
  evidence as *not directly applicable* to an NVIDIA eGPU, but flag the specific combination as
  unverified either way.
- **Verdict: skip.** At $1,300-2,400 for a setup that delivers roughly the same tok/s ceiling as
  buying the same card in a desktop (§2.3) minus the eGPU tax and driver-support uncertainty, this
  option has no advantage over simply building a small desktop around the same card — it exists
  to let you keep the *card* portable, which isn't a stated need here.

### 2.2 Mac Mini as a LAN inference box — SKIP (real gain, but not the best $/performance, and a live-pricing trap)

- **The Mac Mini lineup changed three weeks before this research.** Apple announced new **M6**
  and **M5 Pro** Mac minis on **2026-08-25**, shipping **2026-09-22**
  ([Macworld](https://www.macworld.com/article/2964754/2026-mac-mini-m5-pro-design-specs-release-date.html);
  confirmed directly on [apple.com/shop/buy-mac/mac-mini](https://www.apple.com/shop/buy-mac/mac-mini),
  fetched 2026-09-08). **The M4 Pro is no longer the current model to buy new** — any research or
  advice still pointing at "M4 Pro Mac mini" pricing is already stale. Current configs, per
  Apple's own storefront: M6 (12-core CPU/GPU, 16-64GB, from $899) and **M5 Pro** (15-core
  CPU/16-core GPU/24GB from **$1,699**, or 18-core CPU/20-core GPU/**64GB** — exact 64GB price not
  confirmed, see §4).
- **Memory bandwidth:** M4 Pro was 273 GB/s; **M5 Pro is 307 GB/s**
  ([support.apple.com Mac mini tech specs](https://support.apple.com/en-us/121555); bandwidth
  figures cross-referenced via secondary aggregation, flagged directional). Compare to this
  laptop's Arc B390, whose exact bandwidth is unmeasured/unverified (`phase2-local-models.md`
  §"What could NOT be verified") but is bounded well below either Mac figure by every indirect
  signal in that document.
- **Real tok/s, cross-checked against the chip's own bandwidth spec:** a widely-repeated claim —
  "M5 Pro 48GB, Qwen2.5-32B Q4, 42-50 tok/s" ([contracollective.com](https://contracollective.com/blog/m4-m5-pro-local-ai-inference-mlx-2026))
  — **fails a basic physical plausibility check.** A 32B model at 4-bit is ~18 GB of weights;
  307 GB/s ÷ 18 GB implies a hard ceiling near **17 tok/s** for pure memory-bound decode, before
  any real-world overhead. 42-50 tok/s would require reading the full model roughly 2.5-3x faster
  than the chip's own published bandwidth allows. **This specific figure does not survive
  cross-checking and is discarded, not adopted** — treated as a likely unreliable secondary
  source rather than a verified number. (Also notable: the site's cited "48GB M5 Pro"
  configuration doesn't appear in Apple's current two-tier lineup — 24GB or 64GB only — a second
  reason to distrust the specific claim.)
  - A more physically consistent figure exists for the M4 Pro: **11-14 tok/s on 32B DeepSeek-R1
    at 4-bit** ([popularai.org](https://www.popularai.org/p/mac-mini-llm-performance-in-2026)) —
    273 GB/s ÷ ~18 GB ≈ 15 tok/s theoretical, 11-14 measured ≈ 75-85% efficiency, a believable
    ratio for a GPU-class memory subsystem. **This is the number this report treats as trustworthy**
    for the 27-32B tier; M5 Pro's extra bandwidth would plausibly add a modest ~12% on top
    (~12-16 tok/s), not the 3x jump the discarded claim implies.
  - Gemma-3-27B: reported 8-9 tok/s GGUF / 14-15 tok/s MLX on a 24GB M4 Pro
    ([popularai.org](https://www.popularai.org/p/mac-mini-llm-performance-in-2026)) — same
    order of magnitude, consistent with the bandwidth ceiling.
  - 70B-class: ~12.5 tok/s on a Mac Studio M4 Max ([popularai.org](https://www.popularai.org/p/mac-mini-llm-performance-in-2026)),
    not a Mac mini figure specifically — cited for context only, not adopted as a mini number.
- **LAN serving:** genuinely simple and well-documented. LM Studio's **"Serve on Local Network"**
  toggle exposes an OpenAI-compatible endpoint (`/v1/chat/completions`, etc.) on the Mac's LAN IP;
  the XPS's existing `local-models` tooling could point at it with no code changes beyond the
  base URL ([LM Studio docs, official](https://lmstudio.ai/docs/developer/core/server/serve-on-network)).
  Ollama and llama.cpp's own server mode work the same way. This exact mechanism was already
  independently identified in `surface-laptop-repurposing.md` (§3) for a much weaker CPU-only
  host — it applies here with a real GPU-equivalent unified-memory backend instead.
- **Cost:** M5 Pro 24GB, $1,699 confirmed ([MacRumors](https://www.macrumors.com/2026/09/02/pre-order-discounts-mac-mini/)).
  24GB is thin for a 32B Q4 model (~18GB weights) plus macOS overhead plus KV cache — the 64GB
  config is the one that would actually be usable, and its exact price **could not be confirmed**
  in this pass (Apple's product pages for that SKU returned configuration but not price via
  fetch; estimated $2,299-$2,499 by extrapolation from Apple's usual RAM-tier pricing steps, not
  a quoted number — flagged in §4).
- **Verdict: skip, but not because it doesn't work — because at ~$2,300-2,500 for the useful
  64GB config, it delivers roughly half the tok/s (~12-16) of a $1,300-1,400 used-3090 build
  (~24-28 tok/s, §2.3) for nearly double the price.** If Daniel specifically wants macOS/Apple
  ecosystem for other reasons, or wants a silent, low-power always-on box (Apple Silicon's power
  draw is a real advantage not quantified here — not verified against a specific watt figure in
  this pass), that's a legitimate secondary reason to prefer it anyway; on tok/s-per-dollar alone
  for this workload, it loses to §2.3.

### 2.3 Used/refurb NVIDIA desktop (3090/4090) — the pick, if anything is bought

- **Used RTX 3090 pricing, late 2026:** current eBay sold-listing data puts it around **$972-1,050**
  ([getpcparts.com](https://www.getpcparts.com/market-prices/gpu-graphics-cards/rtx-3090),
  data through 2026-08-22; [bestvaluegpu.com tracker](https://bestvaluegpu.com/history/new-and-used-rtx-3090-price-history-and-specs/)).
  Broader range across condition/seller: $820-$1,900 ([electronics.alibaba.com pricing guide](https://electronics.alibaba.com/question/rtx-3090-price-guide-what-you-should-pay-in-2026)).
  Median used price fell ~32% Jan 2025 → Mar 2026 per the same source — a genuinely falling-price
  market, which favors waiting if there's no urgency (consistent with §1's "buy nothing yet").
- **Complete-system cost is the honest number, not just the card.** No single quoted price for a
  "complete used 3090 gaming PC" was found reliably — listings vary too widely by CPU/RAM/case to
  cite one figure. **Not verified**: treat $1,300-1,650 as a reasoned estimate (card + a budget
  host with adequate PSU/case/RAM), not a quote.
- **Real tok/s, with a source that states its own methodology:**
  [mustafa.net](https://mustafa.net/llm-tokens-per-second-benchmarks/) (dated 2026-04-22, llama.cpp
  b3520, Q4_K_M, 2048 context, stated as "indicative not exact"): RTX 3090 — **95 tok/s @ 7B, 55
  tok/s @ 13B, 28 tok/s @ 34B, 10 tok/s @ 70B (Q2_K)**. RTX 4090 for comparison: 135/78/42/18 tok/s
  at the same tiers. A second, independent source corroborates the 27B-class figure directionally:
  a **dual**-3090 setup measured 22.8 tok/s on Qwen3.6-27B ([sanj.dev](https://sanj.dev/post/qwen-3-6-27b-dual-rtx-3090-llama-cpp-tuning/)) —
  lower than the single-card 34B number above only because of dual-GPU split overhead, not
  because the number is implausible; it supports rather than contradicts the ~24-28 tok/s
  single-card estimate.
- **Bandwidth arithmetic checks out** (unlike the Mac Mini's discarded claim in §2.2): RTX 3090 has
  **936.19 GB/s** memory bandwidth ([gpuzoo.com](https://www.gpuzoo.com/GPU-NVIDIA/GeForce_RTX_3090.html)).
  A 34B Q4_K_M model is ~19-20 GB; 28 tok/s implies ~560 GB/s of effective bandwidth used — a
  believable ~60% real-world efficiency for a discrete GPU. This number **survives cross-check**.
- **Power draw:** peak up to **350-365W under load**, idle **~18W single monitor / ~26W dual
  monitor** ([techbriefly.com](https://techbriefly.com/2024/01/08/rtx-3090-wattage-power-consumption/);
  idle-power behavior corroborated by an [NVIDIA developer forum bug thread](https://forums.developer.nvidia.com/t/bug-report-idle-power-draw-is-astronomical-with-rtx-3090/155632)
  noting some idle-draw anomalies exist on certain driver/display combos — flag as a known
  driver-dependent risk, not a fixed number). Needs a **750W+ PSU**
  ([electronics.alibaba.com](https://electronics.alibaba.com/question/rtx-3090-price-value-guide-is-it-worth-it-in-2026)).
- **Noise: not independently verified.** No specific dB figure was found for a quiet/well-cased
  build; general consensus in the sources reviewed is that a 3090 under sustained inference load
  is audibly louder than a laptop, but no number to cite. If noise matters (e.g., it would sit in
  a living space), this is worth checking against a specific case/cooler before buying — flagged
  as unverified, not dismissed.
- **VRAM ceiling vs. actual use:** 24GB comfortably covers everything in the American-lab-compliant
  20-32B band identified in `phase2-local-models.md` §5 (gpt-oss-20b, Qwen2.5-32B at Q4 if that
  rule is relaxed) with headroom for KV cache. 70B is reachable only at aggressive Q2 quantization
  (~10 tok/s per the table above) — usable for unattended overnight work, degraded quality,
  consistent with the existing doctrine's caution about 70B on this project generally.
- **Verdict: adopt, contingent on the trigger in §1.** Best tokens-per-dollar of every hardware
  option evaluated for the 27-32B tier specifically, reuses the exact toolchain (llama.cpp/LM
  Studio, Vulkan or CUDA path) already validated in `phase2-local-models.md`, and can serve the
  XPS over the LAN via the same LM Studio "Serve on Local Network" mechanism verified in §2.2.

### 2.4 Cloud GPU rental (RunPod, Vast.ai, Lambda) — SKIP as a default; see §3 for the real math

- **RunPod, 2026 rates:** Community Cloud RTX 4090 **$0.34/hr**, Secure Cloud (RunPod's own
  datacenters, single-tenant) RTX 4090 **$0.69/hr**; A100 80GB **$1.19-1.39/hr**; H100 PCIe
  **$2.89/hr** ([runpod.io product page](https://www.runpod.io/product/cloud-gpus);
  [hackceleration.com](https://hackceleration.com/labs/runpod-pricing)).
- **Vast.ai, 2026 rates:** unverified/marketplace tier RTX 4090 from **$0.34/hr**, A100 80GB from
  **$0.50/hr**; verified-datacenter-host tier runs $1.50-1.87/hr for H100
  ([spheron.network comparison](https://www.spheron.network/blog/gpu-cloud-pricing-comparison-runpod-vs-vastai-2026/);
  [madebyagents.com live tracker](https://www.madebyagents.com/hardware/gpu-rental-prices)).
- **This is dramatically cheaper than owning on pure $/hour math — see §3 for the break-even.**
- **The real objection is privacy, not price.** Vast.ai is explicitly a **peer-to-peer marketplace**
  — "individuals and data centers rent excess GPU capacity" to you; strict data-sovereignty
  guarantees are "difficult to guarantee when renting hardware owned by anonymous third-party
  operators" ([runc.ai comparison](https://blog.runc.ai/runpod-vs-vast-ai/);
  [getdeploying.com](https://getdeploying.com/runpod-vast-ai)). RunPod's cheaper **Community
  Cloud** tier shares the physical host with other renters in container isolation, not hardware
  isolation; only its pricier **Secure Cloud** tier (single-tenant, SOC 2 Type II, HIPAA-capable)
  addresses this properly. **Daniel's stated use case is client PII — a paying travel agency and
  a nonprofit's beneficiary data — run through extraction/classification.** The entire reason
  local models are in scope at all (per the brief: "batch/bulk/**private** work offloaded from
  Claude") is to keep that data off third-party infrastructure. Renting a marketplace GPU
  re-introduces exactly that exposure, arguably to a less-vetted party than Anthropic itself.
  This is a structural conflict with the project's own premise, not a minor caveat.
- **Verdict: skip as a standing default for this workload.** Worth reconsidering only for
  something explicitly non-sensitive (e.g., a one-off public-data experiment, or RunPod Secure
  Cloud specifically if the economics of a rare, very large one-time job ever justify the
  per-hour premium over Community Cloud) — not for routine client-document processing.

### 2.5 Purpose-built small AI boxes -- SKIP across the board, for different reasons each

- **NVIDIA DGX Spark -- skip, bad price/performance for this tier.** Price was hiked from
  $3,999 to $4,699 in February 2026 ([TechPowerUp](https://www.techpowerup.com/346833/nvidia-raises-dgx-spark-pricing-to-usd-4-700);
  confirmed listed at $4,699 as of 2026-08-12 per the same source). Its selling point -- 128GB
  unified memory for very large models -- is undercut by its own bandwidth: 273 GB/s, which
  produces ~2.7-3.9 tok/s on 70B models ([mayhemcode.com](https://www.mayhemcode.com/2026/08/why-dgx-spark-runs-70b-llms-at-27.html);
  math confirmed independently: 70GB of FP8 weights divided by 273 GB/s equals about 3.9 tok/s
  theoretical, matching the measured 2.7-3.9 range -- [spark.enverge.ai](https://spark.enverge.ai/blog/dgx-spark-prefill-vs-decode)).
  At the 20-70B range specifically relevant to Daniel, DGX Spark is reported at only 3-10
  tok/s ([apertus.ai](https://apertus.ai/en/blog/nvidia-dgx-spark-review-vs-ai-box/)) -- the same
  order of magnitude as a Mac mini costing half as much, for a device nearly 3x the price. It is
  CUDA-native (no no-CUDA tax), but that advantage does not offset the price/bandwidth mismatch.
- **NVIDIA Jetson AGX Orin / Thor -- skip, wrong market and now more expensive.** Prices were
  hiked in July 2026: AGX Orin Developer Kit went from $1,999 to $3,499, AGX Thor Developer Kit
  went from $3,499 to $5,499 ([VideoCardz](https://videocardz.com/newz/nvidia-raises-jetson-prices-by-up-to-101-agx-thor-now-costs-5499)).
  These are robotics/edge-vision developer kits -- JetPack/Linux-first, not a Windows-native LAN
  server, and priced for a different buyer than a one-person consulting shop doing document
  extraction. Even setting price aside, the software stack (JetPack, ROS-adjacent tooling) adds
  operational complexity with no benefit over LM Studio/Ollama for this specific text-extraction
  workload.
- **AMD Ryzen AI Max+ 395 ("Strix Halo") mini PCs -- closest real competitor to Section 2.3, but
  its headline numbers do not survive cross-check either.** Mini PCs (e.g., GMKtec EVO-X2) run
  $1,499-$2,800 depending on RAM configuration (64-128GB unified)
  ([localaimaster.com](https://localaimaster.com/blog/strix-halo-ai-max-395-guide);
  [gmktec.com](https://www.gmktec.com/products/amd-ryzen%E2%84%A2-ai-max-395-evo-x2-ai-mini-pc)).
  Memory bandwidth: 256 GB/s theoretical, ~215 GB/s measured (about 84% of peak)
  ([chipsandcheese.com](https://chipsandcheese.com/p/amds-chiplet-apu-an-overview-of-strix)).
  A widely-repeated claim -- "dense 7B-30B models hit 40-70 tok/s" ([datahardware.ai](https://datahardware.ai/blog/strix-halo-tokens-per-second-2026))
  -- fails the same bandwidth check as the Mac Mini claim above when applied to the 30B end of
  that range: 215 GB/s divided by ~17GB (30B Q4) is about 12-13 tok/s theoretical ceiling, not
  40-70. That figure almost certainly describes the 7B end of the range, not 30B specifically --
  **discarded for the 27-32B tier, not adopted.** By contrast, the MoE-model claim -- Qwen3-30B-A3B
  (3B active params) at 70-100 tok/s ([runaihome.com](https://runaihome.com/blog/ryzen-ai-max-395-strix-halo-local-llm-2026/))
  -- does survive the check: 3B active weights at Q4 is about 1.7GB, and 100 tok/s implies about
  170 GB/s used, comfortably under the 215 GB/s measured ceiling. **Net: Strix Halo is a real
  option for MoE models specifically, but for dense 27-32B (the tier phase2-local-models.md
  Section 5 identifies as the compliant band) it lands around ~12-13 tok/s -- the same ballpark
  as the Mac Mini, at a similar price, and worse than the used-3090 build in Section 2.3.** Worth
  a second look only if a future doctrine change favors MoE models specifically over dense ones.
- **Intel Arc Pro B60 (24GB) -- the genuinely creative, underrated option; noted, not adopted yet.**
  A real, retail-available discrete Intel workstation GPU, $599-$799
  ([Sparkle launch, VideoCardz](https://videocardz.com/newz/sparkle-offically-launches-arc-pro-b60-at-799-for-consumers);
  Newegg listing at $599.99 per [TechPowerUp](https://www.techpowerup.com/341191/intel-arc-pro-b60-workstation-gpu-spotted-at-usd-599-suggests-non-oem-availability)),
  same Battlemage/Xe2 architecture family as the Arc B390 already in daily use on the XPS --
  meaning the llama.cpp Vulkan/SYCL toolchain already validated in phase2-local-models.md Section
  3 carries over directly, a lower integration-risk profile than any NVIDIA or Apple option.
  456 GB/s memory bandwidth, reported at roughly 25-30% below a single RTX 3090 on llama.cpp
  benchmarks ([bentech.substack.com](https://bentech.substack.com/p/intel-arc-pro-b60-b70-llm-benchmarks)
  -- the most detailed source found, but a Substack post, not independently re-run here). That
  would put it around ~18-22 tok/s at the 27-32B tier -- close to the used-3090 build's ~24-28
  tok/s, at roughly half the card cost ($600-800 vs. $950-1,050), but still needs a host desktop
  (~$400-600, not independently priced), bringing total cost to roughly $1,000-1,400 -- similar
  to or cheaper than Section 2.3, with a lower integration-risk profile precisely because it is
  the same vendor family already in production use. **Not adopted over Section 2.3 only because
  the specific 25-30%-below-3090 figure comes from one aggregator-tier source (Substack, stated
  methodology, but unverified against a second independent benchmark) -- worth a closer look
  if/when the Section 1 trigger actually fires**, as a genuine alternative to the 3090 build, not
  a consolation prize.
- **Tesla P40 (24GB, ~$150-350 used) -- skip, numbers are internally inconsistent and the
  architecture is a known bad fit.** Cheapest 24GB of VRAM available
  ([everylocalai.com](https://everylocalai.com/hardware/nvidia-tesla-p40)), but the claims found
  for it do not hold together: one source claims ~50 tok/s on a 30B model while another (same
  research pass) reports 0.033 tok/s on a 70B Q4_0 model across a 96GB P40 cluster
  ([localaimaster.com](https://localaimaster.com/blog/tesla-p40-local-llm); cross-search
  synthesis). The 30B figure fails a bandwidth check the same way the Mac/Strix Halo claims did --
  P40's ~347 GB/s bandwidth implies a ~20 tok/s ceiling for a 30B Q4 model, not 50 -- and Pascal
  architecture's weak FP16/tensor support is a well-known practical bottleneck for modern
  quantized-inference kernels on this card, independent of raw bandwidth. **Skip**; the VRAM is
  cheap but the compute behind it is not fit for this purpose.

### 2.6 The honest null option -- argued properly, not dismissed

This is the option adopted in Section 1, so the case for it is made there. The core argument,
stated plainly: **the brief that commissioned this research explicitly says the batch work is
not latency-sensitive.** Every other option in this file is, at bottom, a way to make something
faster. If "slower than it could be" is not currently costing Daniel anything -- no missed
deadline, no client waiting, no document backlog that does not fit an overnight window -- then
"faster" has no dollar value to weigh against $600-$4,700 of capital spend. The counter-argument
("but it would feel better to have the fast option") is a real preference, not a business case,
and the brief was explicit about wanting this evaluated honestly rather than talked into a
purchase. The null option costs nothing, ties up no capital, and can be revisited the moment the
actual trigger (batch volume outgrowing an overnight window, or wanting the laptop free during a
run) shows up -- at which point Section 2.3 (or, on closer investigation, Section 2.5's Arc Pro
B60 build) is already scoped and priced, so the decision does not need to be re-researched from
zero.

---

## 3. The break-even math: cloud vs. owning

Using the Section 2.3 used-RTX-3090 build (~$1,400 total, midpoint estimate) against RunPod
Community Cloud's RTX 4090 at $0.34/hr ([runpod.io](https://www.runpod.io/product/cloud-gpus))
-- a faster card than the one being compared, which makes this a conservative (pro-cloud)
comparison:

- Owning also costs electricity: a 3090 under inference load draws up to ~350W
  ([techbriefly.com](https://techbriefly.com/2024/01/08/rtx-3090-wattage-power-consumption/)); at
  the national average residential rate of 18.34 cents/kWh
  ([electricityplans.com, Sept 2026](https://electricityplans.com/average-electricity-bill-usage-rate-by-state/)),
  that is roughly $0.055-$0.064/hr while running -- small next to the $1,400 capital cost, but
  not zero.
- Net hourly savings from owning vs. renting the comparable cloud card: roughly $0.34 minus $0.06,
  about $0.28/hr.
- Break-even: $1,400 divided by $0.28/hr is about 5,000 hours. At different usage intensities:
  - Continuous 24/7 use: ~208 days to break even.
  - 8 hrs/day (heavy, daily use): ~625 days (~1.7 years).
  - 4 hrs/day (moderate): ~1,250 days (~3.4 years).
  - 2 hrs/day (closer to "intermittent batch work" as described): ~2,500 days (~6.8 years).
- **Reading this honestly: for anything short of near-daily, multi-hour usage, cloud rental is
  dramatically cheaper in pure dollar terms than owning.** The case for owning anyway rests
  entirely on the non-dollar factors in Section 2.4 -- data never leaving the device -- not on
  the economics. If that privacy requirement were ever relaxed for a specific non-sensitive job,
  renting would be the correct default, not a compromise.
- For the Mac Mini M5 Pro 64GB (~$2,300 estimated, Section 2.2) against RunPod's A100 80GB
  ($1.19/hr, a closer performance class): $2,300 divided by ~$1.15/hr net is about 2,000 hours
  (~83 days continuous, ~250 days at 8hr/day) -- same conclusion, shorter break-even because the
  closer-matched cloud tier is pricier per hour, but still favors renting for anything but heavy,
  sustained, privacy-neutral use.

---

## 4. What could not be verified

- **The exact 64GB Mac Mini M5 Pro price.** Apple's own product pages for that SKU (fetched
  directly, 2026-09-08) list the configuration but did not render a price in this pass; $2,299-
  $2,499 is an extrapolated estimate from Apple's usual per-tier pricing steps, not a quote.
- **A single, reliable "complete used gaming PC with RTX 3090" price.** Listings vary too widely
  by CPU/RAM/case to cite one number; $1,300-1,650 total (Section 2.3) is a reasoned build
  estimate (card + budget host), not a market quote.
- **Whether an Intel Arc B390 iGPU + NVIDIA eGPU combination has any driver conflict specific to
  this pairing.** The documented conflicts found were Intel-iGPU + Intel-dGPU only; no source
  tested the Arc-iGPU + NVIDIA-eGPU combination directly.
- **Any specific noise (dB) figure for a 3090 under sustained inference load in a well-cased
  build.** General consensus that it is audibly louder than a laptop; no number to cite.
- **The Intel Arc Pro B60's "25-30% below RTX 3090" performance claim**, from a single Substack
  source with a stated methodology but no independent second benchmark found to corroborate the
  exact percentage.
- **This laptop's own LPDDR5x memory bandwidth** (already flagged unverified in
  phase2-local-models.md), which would sharpen every "X times faster than current" multiplier in
  this document if it were known.
- **Whether selling the idle Surface Laptop 4 or either Xbox (per the existing research files) is
  actually on the table right now** -- those files' recommendations are referenced in Section 1
  as relevant prior findings, not confirmed as decisions Daniel has made or intends to make.
- **RTX 3090 idle-power anomalies** on certain driver/display configurations, flagged in one
  NVIDIA developer-forum bug thread -- real but not resolved to a single reliable idle-watt
  figure.

---

## 5. Sources, with dates

- [ggml-org/llama.cpp discussion #23313](https://github.com/ggml-org/llama.cpp/discussions/23313) -- 2026-06-02 (already cited in phase2-local-models.md)
- [Engadget -- Dell XPS 16 (2026) review](https://www.engadget.com/computing/laptops/dell-xps-16-2026-review-return-of-the-king-130000906.html)
- [PCWorld -- Dell XPS 16 (2026) review](https://www.pcworld.com/article/3110951/dell-xps-16-2026-review.html)
- [bottleneckcalculator.us.com -- eGPU Thunderbolt bandwidth reality check](https://bottleneckcalculator.us.com/knowledge-base/hardware-guides/egpu-bottleneck/)
- [egpu.io forum -- eGPU connection speed impact on LLM inference](https://egpu.io/forums/pro-applications/impact-of-egpu-connection-speed-on-local-llm-inference-in-multi-egpu-setups/)
- [ai2.work -- Best eGPU enclosures for AI inference](https://ai2.work/blog/best-egpu-enclosures-for-ai-inference-and-local-llm-workloads) (secondary/aggregator)
- [Amazon -- Razer Core X enclosure listing](https://www.amazon.com/Razer-Core-Thunderbolt-External-Enclosure/dp/B07CQG2K5K)
- [VideoCardz -- Razer Core X V2 launch](https://videocardz.com/newz/razer-core-x-v2-now-available-349-99-egpu-enclosure-with-thunderbolt-5)
- [Tom's Hardware -- Razer Core X V2 review](https://www.tomshardware.com/pc-components/gpus/razer-unveils-core-x-v2-egpu-enclosure-with-tb5-bandwidth-costs-usd400-but-no-longer-has-a-power-supply-and-i-o-expansion-requires-a-separate-thunderbolt-5-dock)
- [Amazon -- Gigabyte AORUS RTX 4090 Gaming Box](https://www.amazon.com/GIGABYTE-WATERFORCE-Thunderbolt-GV-N4090IXEB-24GD-External/dp/B0C8LS7PT2)
- [Intel Community -- iGPU/dGPU driver conflict thread](https://community.intel.com/t5/Graphics/Conflict-of-Intel-iGPU-and-discrete-GPU-on-Windows-11-24-H2/td-p/1648928)
- [Intel Community -- dual Arc Battlemage driver thread](https://community.intel.com/t5/Graphics/Dual-Arc-Battlemage-GPUs-Driver-Support-Not-Combining/td-p/1665160)
- [egpu.io forums -- general PC eGPU setup](https://egpu.io/forums/pc-setup/)
- [Apple -- Mac mini storefront](https://www.apple.com/shop/buy-mac/mac-mini) -- fetched 2026-09-08
- [Macworld -- new Mac mini M6 and M5 Pro](https://www.macworld.com/article/2964754/2026-mac-mini-m5-pro-design-specs-release-date.html)
- [MacRumors -- Mac mini pre-order discounts](https://www.macrumors.com/2026/09/02/pre-order-discounts-mac-mini/)
- [MacRumors -- M6 Mac mini first discounts](https://www.macrumors.com/2026/08/28/m6-mac-mini-first-discounts/)
- [Apple Support -- Mac mini (2024) tech specs](https://support.apple.com/en-us/121555)
- [contracollective.com -- M4/M5 Pro local AI inference benchmarks](https://contracollective.com/blog/m4-m5-pro-local-ai-inference-mlx-2026) (claim discarded on cross-check, see Section 2.2)
- [popularai.org -- Mac mini LLM performance 2026](https://www.popularai.org/p/mac-mini-llm-performance-in-2026)
- [LM Studio -- Serve on Local Network (official docs)](https://lmstudio.ai/docs/developer/core/server/serve-on-network)
- [LM Studio -- LLM API Server (official docs)](https://lmstudio.ai/docs/developer/core/server)
- [getpcparts.com -- used RTX 3090 market price, Aug 2026](https://www.getpcparts.com/market-prices/gpu-graphics-cards/rtx-3090)
- [bestvaluegpu.com -- RTX 3090 price tracker, Sept 2026](https://bestvaluegpu.com/history/new-and-used-rtx-3090-price-history-and-specs/)
- [electronics.alibaba.com -- RTX 3090 price guide 2026](https://electronics.alibaba.com/question/rtx-3090-price-guide-what-you-should-pay-in-2026)
- [mustafa.net -- RTX 4090 vs 3090 tok/s benchmarks](https://mustafa.net/llm-tokens-per-second-benchmarks/) -- dated 2026-04-22
- [sanj.dev -- dual RTX 3090 Qwen3.6-27B tuning](https://sanj.dev/post/qwen-3-6-27b-dual-rtx-3090-llama-cpp-tuning/)
- [gpuzoo.com -- RTX 3090 specs](https://www.gpuzoo.com/GPU-NVIDIA/GeForce_RTX_3090.html)
- [techbriefly.com -- RTX 3090 power consumption](https://techbriefly.com/2024/01/08/rtx-3090-wattage-power-consumption/)
- [NVIDIA developer forums -- RTX 3090 idle power draw bug thread](https://forums.developer.nvidia.com/t/bug-report-idle-power-draw-is-astronomical-with-rtx-3090/155632)
- [electronics.alibaba.com -- RTX 3090 value guide 2026](https://electronics.alibaba.com/question/rtx-3090-price-value-guide-is-it-worth-it-in-2026)
- [runpod.io -- Cloud GPU product/pricing page](https://www.runpod.io/product/cloud-gpus)
- [hackceleration.com -- RunPod real 2026 pricing](https://hackceleration.com/labs/runpod-pricing)
- [spheron.network -- RunPod vs Vast.ai pricing comparison 2026](https://www.spheron.network/blog/gpu-cloud-pricing-comparison-runpod-vs-vastai-2026/)
- [madebyagents.com -- live GPU rental price tracker](https://www.madebyagents.com/hardware/gpu-rental-prices)
- [blog.runc.ai -- RunPod vs Vast.ai price/risk/workload comparison](https://blog.runc.ai/runpod-vs-vast-ai/)
- [getdeploying.com -- RunPod vs Vast.ai](https://getdeploying.com/runpod-vast-ai)
- [TechPowerUp -- NVIDIA raises DGX Spark pricing to $4,700](https://www.techpowerup.com/346833/nvidia-raises-dgx-spark-pricing-to-usd-4-700)
- [mayhemcode.com -- why DGX Spark runs 70B at 2.7 tok/s](https://www.mayhemcode.com/2026/08/why-dgx-spark-runs-70b-llms-at-27.html)
- [spark.enverge.ai -- DGX Spark prefill vs decode / 273 GB/s wall](https://spark.enverge.ai/blog/dgx-spark-prefill-vs-decode)
- [apertus.ai -- local LLMs on DGX Spark, performance test](https://apertus.ai/en/blog/nvidia-dgx-spark-review-vs-ai-box/)
- [VideoCardz -- NVIDIA raises Jetson prices up to 101%](https://videocardz.com/newz/nvidia-raises-jetson-prices-by-up-to-101-agx-thor-now-costs-5499)
- [localaimaster.com -- AMD Ryzen AI Max+ 395 (Strix Halo) guide](https://localaimaster.com/blog/strix-halo-ai-max-395-guide)
- [gmktec.com -- EVO-X2 AI Mini PC product page](https://www.gmktec.com/products/amd-ryzen%E2%84%A2-ai-max-395-evo-x2-ai-mini-pc)
- [chipsandcheese.com -- AMD Strix Halo chiplet APU overview](https://chipsandcheese.com/p/amds-chiplet-apu-an-overview-of-strix)
- [datahardware.ai -- Strix Halo tokens per second 2026](https://datahardware.ai/blog/strix-halo-tokens-per-second-2026) (claim partially discarded on cross-check, see Section 2.5)
- [runaihome.com -- Ryzen AI Max+ 395 for local LLMs 2026](https://runaihome.com/blog/ryzen-ai-max-395-strix-halo-local-llm-2026/)
- [VideoCardz -- Sparkle launches Arc Pro B60 at $799](https://videocardz.com/newz/sparkle-offically-launches-arc-pro-b60-at-799-for-consumers)
- [TechPowerUp -- Intel Arc Pro B60 spotted at $599](https://www.techpowerup.com/341191/intel-arc-pro-b60-workstation-gpu-spotted-at-usd-599-suggests-non-oem-availability)
- [bentech.substack.com -- Intel Arc Pro B60 + B70 LLM benchmarks](https://bentech.substack.com/p/intel-arc-pro-b60-b70-llm-benchmarks)
- [everylocalai.com -- Tesla P40 24GB local AI benchmarks](https://everylocalai.com/hardware/nvidia-tesla-p40)
- [localaimaster.com -- Tesla P40 for local LLMs 2026](https://localaimaster.com/blog/tesla-p40-local-llm)
- [electricityplans.com -- average US electricity rate by state, Sept 2026](https://electricityplans.com/average-electricity-bill-usage-rate-by-state/)
- Internal: C:\Dev\claude-practices\docs\research\phase2-local-models.md -- read at start of this research
- Internal: C:\Dev\claude-practices\docs\research\2026-09-08-capability-research-brief.md -- read at start of this research
- Internal: C:\Dev\claude-practices\docs\research\xbox-repurposing.md -- read during this research, referenced in Section 1
- Internal: C:\Dev\claude-practices\docs\research\surface-laptop-repurposing.md -- read during this research, referenced in Section 2.2
