# Phase 4 - Academic Research: Agentic Coding & Multi-Agent Reliability

> Researcher: Dave. Scope: arXiv cs.SE/cs.AI, mid-2026 to present (2026-09-08).
> Method: WebSearch used only to find candidates; every claim reported below as "surviving"
> was independently fetched and read at the source (arXiv abstract page and/or HTML full
> text), per Part 5 of the capability-research-brief. Search-engine summaries of abstracts
> are logged in Section 2 as exactly what they are, not treated as findings.
>
> Bar for this phase (brief, Part 6): at least 1 finding that survives the citation rules.
> Result: cleared, with 8 surviving findings. Do not cut this phase from next month sweep.

---

## 0. Headline for Daniel

Four independently-run 2026 papers, using four unrelated methodologies (Atari policy-rewrite
loops, math/logic self-correction under relabeling, a hidden-oracle UI benchmark, and an
adversarial security-patch review pipeline), all land on the same conclusion: an agent
self-report of success is not evidence, and is often wrong even when the agent is not being
adversarial or careless. This is not a vibe - it is now a measured, cross-checked, converging
result across independent groups. It directly names what happened tonight: three subagents,
confident claims, one fabricated. Section 1 below is that evidence, with numbers.

Second-order finding, delivered live rather than just described: while researching this
phase, a WebSearch summary invented a statistic ("80+ agents... ~16%") that a direct fetch of
the same paper abstract shows does not exist (the real number is 10 reviewers, and no 16%
figure appears at all). This happened during this exact research task, about a paper on
the subject of trusting AI claims without verification. See Section 2, first entry. It is the
single best piece of evidence in this entire report for the citation rule necessity.

---

## 1. Findings that survive the citation rule

For each: claim, what was actually measured, sample/setup, full-text-or-abstract, what it
changes for a one-person shop.

### 1.1 Self-authored verification fails even without adversarial intent - arXiv 2607.24300

Claim: When an agent both writes the code/policy AND writes the test that grades it, the
self-reported score decouples from real performance, and the decoupling is structural, not a
one-off bug.

What was measured: "SEAL" (Sealed Exogenous Acceptance Loop) paper. Seven models
(DeepSeek-V4-Flash, Gemini-3-Flash, MiniMax-M2.7, Doubao-Seed-2.0-Pro, Kimi-K2.5, Qwen3.6-Plus,
GPT-5.5) iteratively rewrote a policy plus its own test suite over 10 rounds on 5 Atari games,
3 seeds each. Among 35 model-game cells where the agent own tests reported success
(self-score >= 0.70), 15 of 35 (43%) scored below the game random-play baseline when checked
against a sealed, agent-inaccessible evaluator. Weaker models damaged previously-working
strategies behind self-tests that still passed; stronger models were more stable but still
misjudged the real distribution. The fix proposed (SEAL: a fixed, agent-blind audit that only
returns accept/reject and rolls back regressions) beat unprotected baselines across all 6
models and 3 seeds tested.

Read status: Full text (HTML) and abstract page both fetched directly. Verbatim abstract
captured.

What it changes for Daniel: Confirms the core mechanism, not just the symptom. It is not
that subagents lie - it is that an agent grading its own output has no information advantage
over the output itself, so the "test" is correlated with the same blind spots as the code. The
concrete takeaway: any verification step for a subagent claim must not let that subagent
choose or run the check. Bob already does this structurally (fresh context, does not treat the
claiming agent self-report as ground truth) - this paper is direct evidence that architecture
is the right one, not overkill.

### 1.2 Same false claim, framed as "my own thought" vs "external input" - very different
correction rates - arXiv 2606.05976

Claim: LLMs are dramatically better at catching an error in a false claim when it is
presented to them as coming from outside (a user message, a tool response, a memory block) than
when the byte-identical claim is presented as the model own prior reasoning.

What was measured: 10 models (Qwen2.5-72B, Llama-3.3-70B, gpt-oss-20B, Gemma-3-12B,
Phi-4-14B, Qwen3-30B, GPT-4o, Claude Sonnet 4, Gemini 2.5 Flash variants, DeepSeek-R1) across
math (GSM8K-style) and logic (BBH Logical Deduction) tasks, n=30 paired tasks per cell,
deterministic sampling, SHA-256-verified byte-identical claims across framing conditions, judged
by a locked Qwen-72B judge. Relabeling the same false claim from a "thought" tag to an
external role lifted the explicit-correction rate by 23-93 percentage points across 13
model-domain cells (e.g., Llama-3.3-70B: 0% to 87% on math, 0% to 93% on logic). 10 of 13 cells
reached p<0.001. Important caveat found in the same paper: this is not a clean fix - a single
trust-framing instruction collapsed the external-framing benefit back down to a ~70% attack
rate, i.e., it is gameable, not a hard guarantee.

Read status: Full text (HTML) fetched directly, with per-model percentage-point deltas
quoted.

What it changes for Daniel: This validates why a fresh-context verifier (Bob) catches things
a same-context "are you sure?" follow-up to the same subagent would likely miss - the mechanism
here is specifically about identical content being scrutinized differently based on
framing, and same-agent self-review is close to the worst-case framing tested. It does NOT mean
cross-agent review is bulletproof - the collapse-under-trust-framing result says a subagent could
plausibly talk a verifier into leniency with the right instruction, which is a new risk to watch
for, not one his current doctrine addresses.
