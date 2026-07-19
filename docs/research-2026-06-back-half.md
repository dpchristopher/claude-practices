# Research Dossier: Hardening the Back Half of `claude-practices`

> **Date:** 2026-06-24
> **Purpose:** The repo is strong on planning + continuity (SessionStart hook, HANDOFF.md,
> plan-in-one-session/execute-in-fresh-one, thinking-trio). It is weak on the *back half*:
> verification, evals, self-correction loops, and articulation-as-comprehension-check.
> This dossier captures a two-phase research pass to close those gaps — what was searched,
> what's worth adopting (and why), what isn't (and why), and a recommended path that ties
> each change to a real file in this repo.
> **Method:** 8 parallel research agents, ~20 named sources (phase 1) + 8 open research
> questions (phase 2). Every quote is grounded in a fetched URL; synthesis is labelled as
> such; one widely-repeated "fact" turned out to be a fabricated myth (flagged below).

---

## Build status (updated 2026-07-19)

**Shipped in this pass** — the three genuinely-missing pieces, plus wiring to agents already installed:

- ✅ **Verification rule** → `templates/.claude/rules/verification.md` + hard-rule lines in
  `templates/CLAUDE.md`, `templates/global-CLAUDE.md`, and the live `~/.claude/CLAUDE.md`.
- ✅ **Safe-autonomy rule** → `templates/.claude/rules/safe-autonomy.md` + hard-rule lines in all three.
- ✅ **Measurement** → `templates/.claude/rules/measurement.md`, `templates/.claude/session-metrics.md`,
  live log at `~/.claude/session-metrics.md`, and session-end wiring.

**NOT built as new skills — already present as agents (avoided duplicate-skill rot):**

- `fresh-eyes-review` (proposed #3) → **already installed as the `bob-verifier` agent** (fresh-context
  reviewer, evidence-not-assertions, correctness-gaps-only). The verification rule now *points at it*.
- `evals` (proposed #4) → **already installed as the `carl-evals` agent** (binary pass/fail, clusters
  failures, maker≠checker). The verification rule points at it.
- `feynman-explainer` → already a global skill.

> A prior build had already added an agent crew (bob, carl, kevin, phil, jerry, gru, dave, stuart, mel)
> covering much of this research. Check `~/.claude/agents/` before proposing anything new here.

Everything else below (Tier 2–3) remains a **backlog menu**, not built.

---

## TL;DR

1. **Build the measurement instrument FIRST.** The single highest-leverage finding: you are
   about to add ~18 practices with no way to know which earn their keep. No external source
   measures this — you must self-define a lightweight session-metrics log + monthly review.
   Everything else is premature without it.
2. **The richest sourced wins** are a verification rule, a fresh-eyes reviewer skill, an evals
   skill (Hamel discipline), and a safe-autonomy/blast-radius rule (first-party Anthropic).
3. **Three gaps are genuinely empty in the literature** (measurement of your own kit, kit
   decay/GC, most failure-mode recovery) — your instinct that "the literature skews
   aspirational" was correct. We self-define those, labelled as conventions not evidence.
4. **One myth caught:** the Feynman "you remember 10% of what you read / 90% of what you teach"
   statistic is fabricated (the NTL "Learning Pyramid"). Any skill we build must exclude it or
   it discredits itself.
5. **Don't cram it all in.** ~18 distinct changes is too much for one pass — and the kit's own
   likely failure mode is *over-process*. Recommended first PR: the instrument + four Tier-1
   items. The rest becomes a documented backlog.

---

## Part 1 — What was searched

### Phase 1 — the named sources (from `research-prompt-for-claude.md`)
- **Tier 1 (Anthropic eng + named individuals):** Effective harnesses for long-running agents;
  Claude Code best practices; Effective context engineering; Building agents with the Agent SDK;
  Building effective agents; Hamel Husain's three evals posts.
- **Tier 2 (spec-driven + loop engineering):** GitHub Spec Kit; BMAD-METHOD; OpenSpec;
  cobusgreyling/loop-engineering; Addy Osmani "Self-Improving Coding Agents."
- **Tier 3 (papers, learning, observability):** Agent-in-the-Loop (arXiv:2510.06674); LLMLOOP
  (arXiv:2603.23613); the Feynman Technique; Graphiti; Opik; two community best-practice repos.

### Phase 2 — the unsourced gaps (from the 2026-06-24 self-critique email)
Eight open research questions the original prompt never asked: **measurement** (the keystone),
**maintenance/decay**, **failure modes & recovery**, **cost economics**, **safe autonomy /
blast radius**, plus three smaller — **human skill**, **team scale**, **non-coding
generalization**, **domain specificity**.

### The three tweets
Feynman method; Karpathy/Cherny loop engineering; ByteBuilders self-improving agents. **Verdict:
not independent sources** — they're a convergence *signal* that strongly corroborates the
loop/verification core, but introduce nothing the prompt didn't already list. (There was no
fourth tweet.)

---

## Part 2 — What's valuable, and why

### A. The keystone — measurement (self-defined; no source exists)
**Why it matters most:** every other item adds structure; this is the only one that tells you
whether the structure *works*. Without it, in six months you have a 400-line CLAUDE.md and no
idea which lines matter.

- Hamel's "too many metrics, none actionable" trap applies to your *own kit*, not just your code:
  binary over Likert, error-analysis before dashboards, review to saturation.
  ([evals-faq](https://hamel.dev/blog/posts/evals-faq/))
- **No source measures whether a personal practices-kit improves a solo operator's real sessions.**
  Everything found is single-skill benchmarks or team DORA productivity. This is genuinely
  underexplored — self-defining it is correct, not a shortcut.
- **Proposed instrument:** `.claude/session-metrics.md` — one row per session at HANDOFF time
  (~30s): `goal met? (Y/N) · rollback needed? (Y/N) · interventions (count) · friction (1–3) ·
  practices-in-play (tags) · top failure (text)`. **4 metrics, hard cap.** Plus a monthly-review
  rule: error-analysis first → crude before/after by tag → exactly one keep/cut/revise decision.
- **Directly answers** "did the verification rule make sessions better?" → tag sessions where it
  fired; after ~10–15, compare rollback rate + intervention count vs untagged.

### B. Verification & self-correction (richly sourced — the core of the back half)
- **Evidence, not assertions** — *"Have Claude show evidence rather than asserting success: the
  test output, the command it ran and what it returned, or a screenshot."*
  ([CC best practices](https://code.claude.com/docs/en/best-practices))
- **The premature-"done" failure mode**, named verbatim: marks a feature complete *"without
  proper testing… would fail to recognize that the feature didn't work end-to-end."*
  ([harnesses](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents))
- **Fresh-context reviewer subagent** — *"sees only the diff and the criteria you give it, not
  the reasoning that produced the change."* With the anti-over-engineering guardrail you
  specifically wanted: *"A reviewer prompted to find gaps will usually report some… Tell the
  reviewer to flag only gaps that affect correctness or the stated requirements."*
- **The canonical loop** to organize everything around: *gather context → take action → verify
  work → repeat*, with a verification hierarchy — deterministic checks (tests/lint/types) first,
  LLM-judge **last** (*"generally not a very robust method"*).
  ([Agent SDK](https://claude.com/blog/building-agents-with-the-claude-agent-sdk))

### C. Evals discipline (Hamel — pairs with `labarr-ml`)
The five-part spine, all quote-grounded: **binary pass/fail** (*"the difference between 3 vs 4 is
subjective"*); **error analysis is primary** (*"the most important activity in evals"* — 4 steps:
dataset → open code → axial code → saturate); **≥100 traces / stop at ~20-with-nothing-new**; one
domain-expert **"benevolent dictator"**; **no generic metrics** (ROUGE/BERTScore — *"you're doing
it wrong"*). ([needs-evals](https://hamel.dev/blog/posts/evals/),
[evals-faq](https://hamel.dev/blog/posts/evals-faq/),
[llm-judge](https://hamel.dev/blog/posts/llm-judge/))

### D. Safe autonomy / blast radius (first-party Anthropic — work-relevant)
This is the article the email half-remembered, and it's real and quote-rich:
- Thesis: *"Design for containment at the environment layer first, then steer behavior at the
  model layer… The deterministic boundary is what gets hit when everything probabilistic misses."*
- The stat that justifies it: after a phishing injection, *"Across 25 retries… Claude completed
  the exfiltration 24 times"* — model-layer defense failed; only egress-blocking + credential
  isolation contained it.
- `--dangerously-skip-permissions` = *"unsafe in most situations"* / no protection. Auto mode
  cuts toil but has a 17% false-negative rate — *"not a drop-in replacement for careful human
  review on high-stakes infrastructure."*
  ([how-we-contain-claude](https://www.anthropic.com/engineering/how-we-contain-claude),
  [auto-mode](https://www.anthropic.com/engineering/claude-code-auto-mode))
- **Why it's valuable for you specifically:** you run unattended loops *and* work in food
  management/ML with real data. "What can this break and how do I cap it" should be first-class.

### E. The loop CORE + safe-loop mechanics (Osmani + loop-engineering + all 3 tweets converge)
A genuinely supported skeleton (not invented): **define an objectively checkable goal → build the
verifier FIRST, separate from the agent → cap iterations with human-escalation fallback → keep
state in a file outside the conversation.** Plus Osmani's concrete mechanics: per-iteration
checkpoint commits, a `progress.txt` log, iteration cap (~50), stuck-loop detection.
([Osmani](https://addyosmani.com/blog/self-improving-agents/))

### F. Cost economics (refinement curve sourced; subagent economics not)
- SELF-REFINE: ~20% avg gain from iteration, **but gains plateau by ~iteration 3** (FAIR-RAG: 2–3
  is the sweet spot), and *depend entirely on feedback quality* — vague "make it better" decays
  fast; a failing test keeps paying. ([arXiv:2303.17651](https://arxiv.org/abs/2303.17651))
- **Honest flag:** subagent/parallelism break-even and fresh-vs-compact economics have **no
  published numbers** — heuristics only (parallelize only when per-agent work dominates the
  cold-start context tax).

### G. Failure modes & recovery (loops sourced; rest aspirational)
- **Loops are the one well-sourced mode:** the "rule of 3" (same action 3× → stop), fingerprint
  tool calls, hard turn budgets. ([Galileo](https://galileo.ai/blog/agent-failure-modes-guide))
- **Spec-bureaucracy** has the one crisp recovery heuristic: *"if you'd be annoyed to have the
  agent interpret requirements differently, write the spec; if you could fix it in a follow-up
  prompt, skip it."* ([marmelab](https://marmelab.com/blog/2025/11/12/spec-driven-development-waterfall-strikes-back.html))
- Analysis-paralysis, premature-done, reviewer-over-engineering are *named but unquantified* —
  self-defined detection signals.

### H. Feynman / articulation (valuable method — myth excluded)
The 4-step method is sound and maps perfectly to a comprehension-check skill + HANDOFF quality
gate. Grounded in **real** science: retrieval practice (Karpicke & Blunt 2011), desirable
difficulty (Bjork), and a *narrowed* protégé effect (Koh/Lee/Lim 2018 — teaching helps *because*
it forces retrieval). ([fs.blog](https://fs.blog/feynman-technique/))

### I. The "soft" gaps (Anthropic-sourced, lower urgency)
- **Human skill:** Anthropic engineers report shifting *"70%+ to code reviewer/reviser"* — the
  trainable skills are verification design, spec-writing, taste, when-to-intervene.
- **Team scale:** Claude Code's 3-tier settings hierarchy *is* the answer — commit
  `.claude/settings.json` (shared), keep globals personal, git is the anti-drift mechanism.
- **Non-coding:** Anthropic explicitly — Claude Code now powers *"deep research, video creation,
  note-taking."* The plan→act→verify loop is domain-agnostic; for ML the *verify* leg =
  eval/holdout/repro, which `labarr-ml` already owns.

---

## Part 3 — What's NOT valuable, and why

| Source / idea | Verdict | Why |
|---|---|---|
| **BMAD-METHOD** | SKIP | 12-persona agile troupe + 34 workflows is team-scale overkill for a solo op; its one good idea (artifact handoffs) you already have as HANDOFF.md. |
| **Spec Kit `.specify/` scaffold, OpenSpec CLI, loop-engineering npm tools** | SKIP tooling, keep concepts | Adopt the ideas (constitution, archive-on-done, cost-cap); the tooling is redundant with `.claude/plans/`. |
| **Feynman 10%/90% statistic** | HARD SKIP | Fabricated myth (NTL "Learning Pyramid"); using it would discredit the skill. |
| **awattar community repo** | MOSTLY SKIP | Thin restatement of official docs; cherry-pick only `/reviewpr` + `/test` command ideas. |
| **shanraisshan tweet/index bulk** | SKIP the bulk | Mine 3–4 patterns (path-scoped rules, file-size limits, context hygiene); ignore the 83-tweet tips dump. |
| **Context-engineering memory-tool API specifics; "Building effective agents" generalities** | VALIDATE not adopt | These *justify* your existing architecture rather than add to it. |
| **Graphiti / Opik as defaults** | DON'T default-adopt | Real dependencies (graph DB / pip + decorator). Document as *optional graduations* to preserve the kit's flat-file portability. |
| **Subagent/parallelism "break-even" numbers; a published kit-decay study** | DOESN'T EXIST | No source. Don't present heuristics as evidence. |

> **Meta-warning (raised by the research, worth heeding):** this kit already mandates a heavy
> startup ritual. Adding a failure-modes + GC + measurement layer risks *more* process on a kit
> whose own failure mode may be over-process. The cure must not become the disease — the
> failure-modes catalog should list "this kit's own ceremony" as a meta anti-pattern.

---

## Part 4 — Recommendations going forward

Ordered. The email's own advice — *don't cram it all in* — applies to this list.

### Tier 0 — the instrument (do this first, alone)
- **`.claude/session-metrics.md`** + a **monthly-review rule** (new `rules/` entry or
  `/monthly-review` skill). Everything below should be evaluated *by* this once it exists.

### Tier 1 — highest value, well-sourced, low cost (proposed first PR)
- **Verification rule block** → append to `templates/CLAUDE.md` + `templates/global-CLAUDE.md`.
- **`skills/fresh-eyes-review-SKILL.md`** → fresh-context reviewer, correctness-gaps-only.
- **`skills/evals-SKILL.md`** → Hamel discipline, paired with `labarr-ml`.
- **`templates/.claude/rules/safe-autonomy.md`** → blast-radius posture for unattended loops.

### Tier 2 — sourced, fills named gaps (second pass)
- **`skills/failure-modes/SKILL.md`** → anti-pattern → detection → escape (incl. over-process
  meta-warning).
- **`templates/.claude/rules/loop-cost-discipline.md`** + a **safe-loop** section (the loop CORE).
- **`templates/.claude/rules/kit-maintenance.md`** → line budget, quarterly GC, deprecation markers.
- **`skills/feynman-explainer/SKILL.md`** → completes the thinking trio (myth-free).

### Tier 3 — docs + conventions (lower urgency)
- **`docs/operator-skills.md`**, extend **`docs/multi-project-setup.md`** (team scale),
  **`docs/beyond-code.md`**, **`skills/domain-knowledge/SKILL.md.template`** +
  **`docs/encoding-domain-knowledge.md`**.
- OpenSpec-style `plans/active/` vs `plans/archive/<date>-<name>/`; constitution/EARS framing of
  the CLAUDE.md hard-rules; path-scoped lazy rules + CLAUDE.md ≤200-line discipline.

---

## Part 5 — How it ties into the current repo

| Existing file | What changes / what it validates |
|---|---|
| `templates/CLAUDE.md` | Add verification rule block; formalize hard-rules as a "constitution"; adopt ≤200-line discipline. |
| `templates/global-CLAUDE.md` | Mirror the verification block; add monthly-review + safe-autonomy pointers to the toolkit table. |
| `hooks/session-context.sh` | Add a startup smoke-test step; surface `session-metrics.md` + last-reviewed date. |
| `templates/.claude/HANDOFF.md` | Becomes an append-style progress log with typed signals (decisions+rationale / wrong-assumptions / missing-knowledge gaps) — the AITL flywheel. |
| `templates/.claude/rules/` | New siblings: `safe-autonomy.md`, `loop-cost-discipline.md`, `kit-maintenance.md` (+ cross-link `automation.md`, `tool-discipline.md`). |
| `skills/patterns-guide-SKILL.md` | Add the "Verification Ladder" (LLMLOOP's 5 escalating gates) and the loop CORE. |
| `skills/` (thinking trio) | Add `feynman-explainer` as the fourth mode; add `fresh-eyes-review`, `evals`, `failure-modes`. |
| `skills/labarr-ml/` + `rules/ml-discipline.md` | The evals skill pairs here; Opik documented as the optional LLM-eval/observability layer for `claude-api` projects. |
| `templates/META_ARCHITECTURE.md` | Add `last-reviewed` / `status` headers (GC); document Graphiti as the optional memory graduation path. |
| `docs/multi-project-setup.md` | Extend with a "Team Scale" 3-tier ownership table (you + Cody). |
| `README.md` | Add a "Maintenance" + "Known Failure Modes" + "Beyond Code" pointer; acknowledge non-coding generalization. |

---

## Appendix — Source ledger (URLs actually fetched)

**Anthropic:** [harnesses](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents) ·
[CC best practices](https://code.claude.com/docs/en/best-practices) ·
[context engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents) ·
[Agent SDK](https://claude.com/blog/building-agents-with-the-claude-agent-sdk) ·
[building effective agents](https://www.anthropic.com/engineering/building-effective-agents) ·
[how we contain Claude](https://www.anthropic.com/engineering/how-we-contain-claude) ·
[auto mode](https://www.anthropic.com/engineering/claude-code-auto-mode) ·
[how Anthropic teams use Claude Code](https://claude.com/blog/how-anthropic-teams-use-claude-code) ·
[how AI is transforming work at Anthropic](https://www.anthropic.com/research/how-ai-is-transforming-work-at-anthropic) ·
[settings docs](https://code.claude.com/docs/en/settings)

**Hamel Husain:** [needs evals](https://hamel.dev/blog/posts/evals/) ·
[evals FAQ](https://hamel.dev/blog/posts/evals-faq/) · [LLM-as-judge](https://hamel.dev/blog/posts/llm-judge/)

**Spec/loop:** [Spec Kit](https://github.com/github/spec-kit) ·
[BMAD](https://github.com/bmad-code-org/BMAD-METHOD) · [OpenSpec](https://github.com/Fission-AI/OpenSpec) ·
[loop-engineering](https://github.com/cobusgreyling/loop-engineering) ·
[Osmani self-improving agents](https://addyosmani.com/blog/self-improving-agents/)

**Papers/tools:** [AITL arXiv:2510.06674](https://arxiv.org/abs/2510.06674) ·
[LLMLOOP arXiv:2603.23613](https://arxiv.org/abs/2603.23613) ·
[SELF-REFINE arXiv:2303.17651](https://arxiv.org/abs/2303.17651) ·
[Graphiti](https://github.com/getzep/graphiti) · [Opik](https://github.com/comet-ml/opik) ·
[Feynman / fs.blog](https://fs.blog/feynman-technique/)

**Phase-2 (gaps):** [Augment – metrics lie](https://www.augmentcode.com/guides/why-ai-agent-metrics-lie) ·
[DX Core 4](https://getdx.com/research/measuring-developer-productivity-with-the-dx-core-4/) ·
[nathanonn CLAUDE.md](https://www.nathanonn.com/claude-md-highest-leverage-file/) ·
[MindStudio context rot](https://www.mindstudio.ai/blog/what-is-context-rot-claude-code) ·
[Galileo failure modes](https://galileo.ai/blog/agent-failure-modes-guide) ·
[marmelab spec-as-waterfall](https://marmelab.com/blog/2025/11/12/spec-driven-development-waterfall-strikes-back.html) ·
[FAIR-RAG arXiv:2510.22344](https://arxiv.org/pdf/2510.22344) ·
[Hedgineer knowledge layer](https://www.hedgineer.io/content/claude-skills-knowledge-layer/)

> **Honesty notes:** quotes are verbatim from fetched pages. Synthesis/heuristics are labelled.
> The Feynman 10/90 stat is a confirmed myth. EARS is a *requested* (not shipped) Spec Kit
> feature — borrow as a convention. Subagent-economics and kit-decay numbers are unsourced
> heuristics, not evidence.
