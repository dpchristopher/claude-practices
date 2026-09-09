# Phase 2 — Local Models on This Hardware

> Researched 2026-09-08. Machine: Dell XPS 16, Intel Core Ultra X7 358H (Panther Lake, 16C/16T,
> NPU), 63.5 GB RAM, **Intel Arc B390 integrated GPU** (12 Xe3 cores, shares system RAM), 691 GB
> free, Windows 11. Currently installed: Llama-3.2-3B (LM Studio, Vulkan), gemma-3-4b-it (LM
> Studio, disqualified - see C:\Dev\Local_Models\README.md), phi-4-mini (Foundry Local, NPU).
>
> Constraint honored: web research only, no installs, no downloads, no edits to existing files.
> This is the one new file this phase writes.

---

## 1. Recommended setup

**Keep the current two-tier setup. Add a third tier: LM Studio + a 20-32B GGUF model on the
Arc B390 iGPU (Vulkan), for batch calls where a 3B model's accuracy ceiling is the actual
problem - not for anything synchronous or chat-shaped.**

| Tier | Backend | Model | Role |
|---|---|---|---|
| Fast/default | LM Studio, Vulkan, Arc B390 iGPU | Llama-3.2-3B (unchanged) | One-step extraction/classification, ~2s/call |
| NPU-isolated | Foundry Local, ONNX Runtime GenAI | phi-4-mini (unchanged) | Same as above, but concurrency-safe with GPU-heavy work |
| New: capable/slow | LM Studio, Vulkan, Arc B390 iGPU | gpt-oss-20b-Q4 (OpenAI, American-lab-compliant) or Qwen2.5-32B-Q4_K_M (if that rule is relaxed for local-only inference - see Section 5) | Batch calls where the 3B's failure modes (chained inference, longer effective context) are the actual bottleneck, and 30-90s/call is acceptable |

**Reasoning:**
- The RAM headroom (63.5 GB) was never the ceiling - it was always going to be compute/memory
  bandwidth on the iGPU. The measured number for a 27B-class model on the exact Xe3 12-core
  iGPU that ships in this chip (Arc B390, confirmed 12 Xe3 cores - see Section 2) is ~3.5-4.3
  tok/s ([ggml-org/llama.cpp discussion #23313](https://github.com/ggml-org/llama.cpp/discussions/23313),
  posted June 2, 2026). That is a real, chip-matched number, not an estimate.
- LM Studio is already installed, already the default backend, and already uses Vulkan on this
  iGPU - no new tooling. Loading a bigger GGUF model is a config change, not an infrastructure
  change.
- Foundry Local cannot be the vehicle for this tier: its catalog is intentionally capped around
  14B ("small enough to distribute to end users," ONNX-only, no GGUF) - confirmed directly on
  Microsoft's own docs (Section 2, Section 4). The 20B entry it does list (gpt-oss-20b) requires
  a Blackwell-class NVIDIA GPU for its accelerated path, which doesn't exist on this machine -
  so even that one entry would silently fall back to CPU/NPU inside Foundry Local. Run gpt-oss-20b
  via LM Studio's GGUF path instead if it's wanted.
- Do not install IPEX-LLM (dead, see Section 2) or attempt Ollama-for-Arc (no official support,
  see Section 2 / Section 4).

---

## 2. Benchmarks table with sources

| Hardware / backend | Model | Quant | Metric | Result | Source | Date |
|---|---|---|---|---|---|---|
| Panther Lake Xe3 iGPU, 12 cores (= this machine's Arc B390) | Llama-2-7B | Q4_0 | tg128 (FP16, FA) | 19.20 tok/s | [ggml-org/llama.cpp #23313](https://github.com/ggml-org/llama.cpp/discussions/23313) | 2026-06-02 |
| Same | Qwen3.6-27B | Q4_K_M | tg128 (FP16, FA off) | 3.55 tok/s (4.31 tok/s FP32) | Same | 2026-06-02 |
| Same | Llama-3.2-1B | Q4_0 | tg128 | 88.7-89.4 tok/s | Same | 2026-06-02 |
| Core Ultra 7 258V Arc iGPU (Lunar Lake, close cousin) | Llama-2-7B | Q4_0 | tg128 | 24.61 tok/s | Same | 2026-06-12 |
| Intel Core Ultra 9 288V, NPU (Lunar Lake) | Llama-3.2-3B / Llama-2-7B int4 | int4 | avg latency | 9.42s (NPU) vs 6.12s (CPU) - NPU 54% slower than CPU | [openvino.genai issue #1882](https://github.com/openvinotoolkit/openvino.genai/issues/1882) | opened 2026 |
| Intel Core Ultra 7, NPU vs iGPU (OpenVINO Model Hub) | DeepSeek-R1-Distill-Llama-8B | INT4 | tok/s | iGPU ~12.8-19.8 tok/s vs NPU ~6.10 tok/s (iGPU roughly 2x NPU; exact figure varied across two search-engine summaries of the same table - not independently fetched, treat range as directional not exact) | [OpenVINO Model Hub / Medium summary](https://medium.com/openvino-toolkit/introducing-openvino-model-hub-benchmark-ai-inference-with-ease-2cd7ad8f5e4d) (fetch blocked, HTTP 403 - search-summary only) | 2026 |
| Discrete Arc B580 (12GB, for context only - not this machine) | 7B | INT4 | tok/s | 15-62 tok/s (IPEX-LLM, now dead - see below) | [compute-market.com](https://www.compute-market.com/blog/best-budget-gpu-for-ai-2026) | 2026 |
| Generic DDR5 laptop CPU, no GPU | Llama-2-70B | Q4_K_M | tok/s | 1-6 tok/s (bandwidth-bound; NOT verified for this exact SKU's memory config) | [InsiderLLM](https://insiderllm.com/guides/cpu-only-llms-what-actually-works/) | 2026 |
| Generic modern CPU (i9/Ryzen 9, DDR5) | 7-14B | Q4_K_M | tok/s | 10-25 tok/s | Same | 2026 |
| Arc 140V (Lunar Lake iGPU, 32GB shared) - secondary/aggregator source, methodology not fully disclosed | Qwen2.5-14B | Q8_0 | tok/s | ~5.2 tok/s | [canitrun.dev](https://canitrun.dev/gpus/arc-140v/) (last refreshed 2026-04-23) | 2026-04 |

**Where it stops being usable:** on the Arc B390 iGPU, 7-8B is comfortable (19-25 tok/s, sub-second
per short call). 27-32B on the same iGPU is ~3.5-4.3 tok/s - usable for a single batch call
(a 150-token structured extraction takes ~35-45s instead of the 3B model's ~2s) but not for a
chat loop or anything synchronous. 70B fits in the 63.5 GB RAM pool arithmetically (~40 GB at
Q4) but at an unverified 1-6 tok/s CPU-bound rate, a single response can take minutes - only
justified for an unattended overnight batch, and that claim is not verified for this exact
machine's memory subsystem.

**No 13-14B number was found measured on this exact iGPU.** The canitrun.dev figure (5.2 tok/s,
Q8_0, on the Lunar Lake Arc 140V, not this machine's Arc B390) is the closest analogue and is
flagged low-confidence - third-party aggregator, "last refreshed" date given but no visible
methodology.

---

## 3. What no-CUDA actually costs

**Confirmed dead:**
- **Intel IPEX-LLM - archived by Intel on 2026-01-28.** Directly from the repo itself: "Intel
  will not provide or guarantee development of or support for this project... This project has
  been identified as having known security issues." ([intel/ipex-llm](https://github.com/intel/ipex-llm))
  This was the primary "make Intel Arc fast" path as recently as 2025. It is gone. Any tutorial
  or blog post recommending it (several turned up in this research, dated 2025 or early 2026) is
  now recommending a dead, security-flagged package.
- **Ollama has no official Intel Arc support.** Confirmed on [docs.ollama.com/gpu](https://docs.ollama.com/gpu):
  the officially supported list is NVIDIA (CUDA), AMD (ROCm), and Apple Metal, plus a generic
  Vulkan fallback described only as "additional GPU support." Community forks
  (ollama-vulkan-arc, ollama-intel-arc) exist but the latter depends on the now-dead
  IPEX-LLM fork, and an LM Studio bug-tracker thread ([#429](https://github.com/lmstudio-ai/lmstudio-bug-tracker/issues/429))
  specifically warns against recommending Vulkan as a "good choice" on Intel integrated graphics
  in some configs. Net: Ollama is not a safe default on this machine without extra, fragile setup.

**Still works, actively maintained:**
- **llama.cpp, Vulkan and SYCL backends** - both alive, both tested on this exact chip class in
  June 2026 (Section 2). Vulkan currently wins prompt-processing by roughly 2x on dense models
  (341 vs 167 tok/s pp on an 80B example); SYCL edges ahead ~6% on token-generation for MoE
  architectures specifically. Default to Vulkan; there's no evidence SYCL is worth the extra
  driver stack for dense 7-32B models on this hardware.
- **LM Studio** - wraps llama.cpp, functioning Vulkan runtime on Intel iGPUs, described in 2026
  comparisons as "often the only option that delivers usable performance" on non-NVIDIA laptops.
  Already the current default here.
- **OpenVINO GenAI / Foundry Local** - Intel/Microsoft's own first-party stack, ONNX-based,
  actively maintained, the only path onto the NPU. Capped by design around 14-20B.

**The concrete cost, stated plainly:**
1. **Fine-tuning is effectively off the table locally.** The LoRA/QLoRA ecosystem (Unsloth,
   bitsandbytes, PEFT) is CUDA-first; the one Intel equivalent (IPEX-LLM) that had fine-tuning
   support is dead. This isn't "harder," it's "not currently a supported path" - a meaningfully
   different statement than the local-models skill's existing caution about not having data yet
   to fine-tune with.
2. **A large fraction of copy-paste local-LLM tutorials will not run as written.** Anything
   assuming "pip install vllm" + CUDA, bitsandbytes 4/8-bit, or a discrete-NVIDIA-only
   flash-attention build either errors out or silently falls back to slow CPU execution. This is
   the actual "tax" - not a missing capability so much as a constant tooling-selection burden
   Daniel doesn't currently pay if he ever follows a generic local-LLM guide from Reddit/HN/a blog.
3. **Throughput ceiling is real and not close.** A used RTX 3090 is reported at ~95 tok/s on a 7B
   model ([runaihome.com](https://runaihome.com/blog/npu-vs-gpu-local-llm-2026/), secondary
   source, treat as directional) versus this machine's measured 19-25 tok/s for the same class -
   roughly 4-5x slower, consistent with the ~4-8x memory-bandwidth gap the same article cites
   (120-256 GB/s shared system RAM vs 936 GB/s dedicated GDDR6X on a 3090).

---

## 4. Is the local-models delegation boundary miscalibrated?

**Partially - the task-shape rules are fine; the model-size assumption is out of date, and a
tier is missing.**

The boundary in C:\Users\dpchr\.claude\skills\local-models\SKILL.md was measured and written
entirely against 3-4B models on this exact machine: Llama-3.2-3B at 2.0-2.1s/call, Phi-4-mini at
8.5-9s/call, both via extraction calls of roughly ~150 output tokens. Every hard-stop cutoff in
that file (the 8K-token context cliff, the chained-inference cliff, the arithmetic cliff) is
sourced from benchmarks of 3-4B-class models (Llama-3.1-8B's NoLiMa result, Phi-3-mini's
GSM-Symbolic degradation, Phi-4-mini's own MATH score). None of those numbers have been
re-measured - by anyone, in this research or in the existing doctrine - for a 20-32B model.

**What this research adds, concretely:**
- The RAM headroom question the brief posed ("is the boundary calibrated to 3B when it should
  assume ~30B?") has a real answer: **RAM was never the constraint. Compute was.** A 27B model
  on this iGPU is measured at ~3.5-4.3 tok/s - for an equivalent ~150-token call, that's
  ~35-45 seconds, an ~18-20x slowdown versus the current 2.1s default, not the "8-10x more
  capacity" framing the brief's open question implied. Bigger model, much slower call - a
  different trade than "just use more RAM."
- The skill currently encodes a binary choice: fast local (3-4B) or Claude. This research
  shows there's a real third point available on this hardware - slow local (20-32B) - that
  the doctrine doesn't represent at all. It sits between the two: probably clears some of the
  current hard-stops the 3-4B models can't (longer effective context, possibly more chained-step
  tolerance) but nobody has measured that; it also costs 30-90s/call, which the existing
  1,000-doc math (currently framed as "~1.5-3h at 5-10s/doc") would turn into ~8-11 hours if
  naively applied at the 30B tier.
- **This is a real gap, not a fix I'm making here.** Per the rehearsal-ladder discipline already
  in the skill (3 cases isn't evidence; ~100 cases needed for +/-8pp), the right next step is an
  A/B/C test - exactly like the one that already produced the current 3B default - run at the
  20-32B tier before any doctrine changes. I have not run that test; I'm flagging that the
  doctrine has no answer for it yet, which it should before anyone routes a task there.

---

## 5. What questions should we now be asking that we weren't

1. **Is there an American-lab-compliant dense model in the 27-32B band at all?** The skill's
   "American labs only" rule (Meta/Microsoft/OpenAI/Google-adjacent) leaves a real hole here:
   Qwen2.5/Qwen3-32B and Gemma-3-27B are the strongest open 27-32B models but are Alibaba/Google
   (Google is arguably American - worth clarifying if the rule means "US company" or "US-only
   frontier lab," since Gemma's exclusion isn't obviously intentional). The one clean fit is
   gpt-oss-20b (OpenAI) - but that's 20B, not 27-32B, and its Foundry Local acceleration path
   assumes NVIDIA hardware this machine doesn't have. Above 20B and below Llama-3.3-70B
   (impractically slow here, per Section 2), there may be no rule-compliant option at all on this
   hardware. Worth resolving before building anything at that tier.
2. **Was the "American labs only" rule written for API-routed inference or for fully local,
   open-weight inference?** Those are different risk profiles - a foreign-lab model run 100%
   on-device, weights never touching a network, doesn't carry the same data-exfiltration logic
   that presumably motivated the rule for anything cloud-routed. Not a recommendation to drop
   the rule - a flag that its rationale hasn't been re-examined for the local-only case.
3. **Should extract.py/ab_test.py grow a third backend for the 20-32B/LM Studio tier**, and
   is the ~35-45s/call cost worth it for the specific failure modes (chained inference, longer
   context) it might fix? This needs its own measured A/B, not an assumption.
4. **Does the NPU's ~8K-token context ceiling** (OpenVINO GenAI NPU plugin release notes,
   [Intel 2025.3 release notes](https://www.intel.com/content/www/us/en/developer/articles/release-notes/openvino/2025-3.html))
   mean "long-document extraction" should be structurally routed away from Foundry Local/NPU by
   design, rather than left ambiguous in the rehearsal ladder?
5. **Now that IPEX-LLM is confirmed dead and Ollama has no official Arc path**, should any
   future reference to either be actively struck from consideration rather than left as
   candidates - this is a case where "the tool people recommend" and "the tool that still exists"
   have diverged since the skill/README were last written (2026-08-23, before the Jan 2026
   archival was likely even reflected in most tutorials still circulating).
6. **Given embeddings/reranking run fine on CPU alone regardless of GPU vendor** (Section 6),
   should the rehearsal ladder's "Econ dashboard - RAG" step move earlier, since it's the one
   pattern here with no backend uncertainty at all?

---

## 6. Embeddings and reranking locally - worth it?

**Yes, unambiguously - and it's the one place in this whole brief where no-CUDA genuinely doesn't
matter.** Embedding and reranking models are small enough (from 4M to ~600M params) that CPU
throughput alone is fine; none of the backend fragmentation in Sections 2-4 applies.

- **Embeddings:** nomic-embed-text-v2 (Nomic AI, a US company - passes the American-labs
  filter; 137M params, 8K context, reported to run well on CPU) or all-MiniLM-L6-v2 (~0.1 GB,
  the minimal option if raw speed matters more than retrieval quality) are the leading 2026 picks
  across multiple secondary sources (convergent but not independently verified against a primary
  benchmark in this pass). BGE-M3 (BAAI, Beijing) is also frequently recommended but is
  **not** American-lab-compliant under the existing rule - flagged, not resolved (see Section 5.2).
- **Reranking:** cross-encoder/ms-marco-MiniLM-L-6-v2 is the standard fast CPU cross-encoder;
  worth adding on top of embeddings for the Civ 6 rules-lookup and econ-dashboard RAG use cases
  specifically, since a reranking pass measurably improves precision at negligible CPU cost.
  Attribution here is murky (community/Sentence-Transformers project) - not cleanly "American lab
  compliant or not," another open question.
- Net: this is a low-risk, high-certainty win relative to everything else in this document, and
  the existing rehearsal ladder already has a slot for it ("Econ dashboard - RAG (different
  pattern: retrieval, not extraction)").

---

## What could NOT be verified

- Exact tokens/sec for NPU vs iGPU on the DeepSeek-R1-Distill-Llama-8B comparison - two
  independent search-engine summaries of the same OpenVINO Model Hub table gave different
  iGPU numbers (12.8 vs 19.8 tok/s); the source page returned HTTP 403 on direct fetch. The
  direction (iGPU beats NPU on this model class) is corroborated by a second, independent
  primary source (the GitHub issue showing NPU 54% slower than CPU), so the qualitative finding
  stands; the exact figure does not.
- Any tokens/sec number for a 13-14B model measured on this machine's specific Arc B390 iGPU -
  none exists yet; the closest analogue (Arc 140V/Lunar Lake, canitrun.dev) is a different chip
  and a lower-confidence aggregator source.
- This machine's exact memory bandwidth (LPDDR5x speed/channel config for the XPS 16 Panther
  Lake SKU) - not found; the CPU-only 70B figures (1-6 tok/s) are generic DDR5-laptop numbers,
  not specific to this SKU.
- Whether Foundry Local's Intel NPU execution provider handles gpt-oss-20b at all (its listed
  GPU requirement is NVIDIA-specific; no NPU/CPU fallback performance data found for that model).
- Intel's own vLLM-for-Arc maturity - mentioned only in passing in one source; not independently
  checked here.

## Sources, with dates

- [ggml-org/llama.cpp discussion #23313 - Performance of llama.cpp on Intel GPU with SYCL backend](https://github.com/ggml-org/llama.cpp/discussions/23313) - data points dated 2026-06-02 through 2026-06-14
- [ggml-org/llama.cpp discussion #12570 - Current status of Intel Arc GPUs for llama.cpp](https://github.com/ggml-org/llama.cpp/discussions/12570)
- [intel/ipex-llm GitHub repo](https://github.com/intel/ipex-llm) - archived notice, 2026-01-28
- [docs.ollama.com/gpu](https://docs.ollama.com/gpu) - official GPU support list, fetched 2026-09-08
- [openvinotoolkit/openvino.genai issue #1882 - NPU slower than CPU/GPU](https://github.com/openvinotoolkit/openvino.genai/issues/1882)
- [Intel OpenVINO 2025.3 release notes](https://www.intel.com/content/www/us/en/developer/articles/release-notes/openvino/2025-3.html)
- [Microsoft Learn - What is Foundry Local?](https://learn.microsoft.com/en-us/azure/foundry-local/what-is-foundry-local) - dated 2026-05-15, updated 2026-08-04
- [Microsoft Learn - Generative small language models in Foundry Local on Azure Local](https://learn.microsoft.com/en-us/azure/azure-sovereign-clouds/private/foundry-local/concept-models) - dated 2026-06-03
- [lmstudio-ai/lmstudio-bug-tracker issue #429](https://github.com/lmstudio-ai/lmstudio-bug-tracker/issues/429)
- [canitrun.dev - Intel Arc 140V model support](https://canitrun.dev/gpus/arc-140v/) - last refreshed 2026-04-23 (secondary/aggregator, lower confidence)
- [runaihome.com - NPU vs Discrete GPU for Local LLMs in 2026](https://runaihome.com/blog/npu-vs-gpu-local-llm-2026/) (secondary/blog, directional)
- [InsiderLLM - CPU-Only LLMs 2026](https://insiderllm.com/guides/cpu-only-llms-what-actually-works/) (secondary/blog, directional)
- [compute-market.com - Best Budget GPU for Local LLM & AI 2026](https://www.compute-market.com/blog/best-budget-gpu-for-ai-2026)
- [wccftech.com - Intel Xe3 / Arc B390 iGPU specs](https://wccftech.com/intel-xe3-shockingly-fast-arc-b390-igpu-on-par-with-60w-rtx-4050-crushes-radeon-890m-mfg-support/) - confirms Arc B390 = 12 Xe3 cores, ships on Core Ultra X7 358H
- OpenVINO Model Hub via Medium summary (fetch blocked, HTTP 403 - cited as search-summary only, not independently read)
- Existing internal sources read for context: C:\Users\dpchr\.claude\skills\local-models\SKILL.md, C:\Dev\Local_Models\README.md, C:\Dev\claude-practices\docs\research\2026-09-08-capability-research-brief.md
