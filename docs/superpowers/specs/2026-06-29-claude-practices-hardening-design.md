# claude-practices Back-Half Hardening — Design

> **Status:** Draft for review · **Date:** 2026-06-29 · **Repo:** `github.com/dpchristopher/claude-practices`
> **Session:** *Treaty of Versailles* (1919 — closing out the front half, hardening the terms)

---

## 1. Problem

The kit is strong on the **front half** — cross-session continuity (SessionStart hook + HANDOFF.md), planning discipline, skills-first protocol, the thinking trio. It is weak on the **back half**:

1. **Verification** — work gets marked done without evidence it actually works end-to-end.
2. **Evals** — no systematic pass/fail discipline.
3. **Self-correction loops** — no structured refinement / "knowing when the agent is looping uselessly."
4. **Articulation** — no comprehension gate; decisions and handoffs aren't pressure-tested for understanding.

**The driving scar:** on a 75k-file codebase, system-level invariants drift across sessions. OAuth was added to a data platform weeks ago; a later session touching adjacent code broke it because **nothing persistent recorded that contract.** HANDOFF.md captures *what happened last session* (transient). Nothing captures *what must always be true* (durable).

A secondary problem surfaced during the audit: the kit's own architecture has **duplication debt** (single-source-of-truth violations) and **inconsistent skill staging** that will make every future addition more expensive.

---

## 2. Goals & Non-Goals

**Goals**
- A durable, auto-loaded record of system invariants that survives across sessions.
- Verification as an evidence-backed discipline, enforced where it must happen.
- A first systematic evals doctrine.
- A comprehension/articulation gate completing the thinking trio.
- A loop discipline that builds *on* native Claude Code primitives rather than reinventing them.
- Reusable, committed `.claude/agents/` and `settings.json` that operationalize the existing hard rules.
- A cleaner kit architecture (one source of truth per concept) so future growth is cheap.

**Non-Goals**
- Multi-agent SDLC frameworks (BMAD) — overkill for a solo operator.
- Spec-Kit-style slash-command workflows — redundant with existing plan/execute + GSD.
- External infra (Graphiti, Opik) as core requirements — documented as optional later.
- Re-implementing iteration loops / rollback that Claude Code now ships natively (`/goal`, `/rewind`).

---

## 3. Design Principles (this kit's own doctrine, applied to itself)

- **Single source of truth** — each concept lives in exactly one canonical file; others link to it.
- **Evidence over assertion** — nothing is "done" without pasted command output / observable proof.
- **Maker ≠ checker** — the agent that does the work does not grade it.
- **YAGNI** — start with the simplest structure that solves today's problem; graduate only when the need is real.
- **Lean always-load surface** — every-session files (CLAUDE.md, rules) stay small so rules don't get lost.
- **Build on the platform** — prefer native CC features (`/goal`, `/rewind`, hooks, settings permissions) over hand-rolled equivalents.

---

## 4. Sequencing — three waves, clean-up first

Work is staged so each step is independently verifiable. **The clean-up pass lands and is verified before any new capability is added,** so new files are built on a deduplicated base.

### Wave 0 — Architecture clean-up (do first, commit alone)
### Wave 1 — Real-pain fixes + cheap wins
### Wave 2 — Enforcement + evals
### Wave 3 — Loop discipline + polish

---

## 5. Wave 0 — Architecture Clean-Up

**0.1 Normalize skill staging.** Convert all flat `skills/*-SKILL.md` files (`thinking-partner`, `socratic-examiner`, `assumption-archaeologist`, `patterns-guide`) into the directory form `skills/<name>/SKILL.md`, matching `session-workflow/`, `labarr-ml/`, `init/`.

**0.2 Install scripts.** Replace the hand-copy README blocks with `install.sh` (bash) and `install.ps1` (PowerShell) that register skills + the hook idempotently. README points to the scripts.

**0.3 Kill the triplicate tables (single source of truth).** The skills toolkit table currently appears in `global-CLAUDE.md`, `META_ARCHITECTURE.md`, and `rules/session-workflow.md`. Designate the **`session-workflow` SKILL** as canonical for *methodology*, and the **`META_ARCHITECTURE.md` Toolkit table** as canonical for *which skills apply to a given project*. The rule file and global file link to these rather than restating them. Resolve the SKILL-vs-rule duplication of session-workflow content the same way: the rule becomes a thin pointer to the skill.

**0.4 De-Python the portable rules.** In `tool-discipline.md`, frame `pytest`/`pyright`/`pip` as "the Python default — substitute your stack's equivalent," so the kit is honestly portable.

**0.5 Versioning.** Add `VERSION` and `CHANGELOG.md` to the repo root so deployments across projects are traceable.

**Verification for Wave 0:** run `install.sh`/`install.ps1` into a throwaway dir; confirm all skills register and the hook fires with no errors; confirm no concept is now defined in two places.

---

## 6. Wave 1 — Real-Pain Fixes + Cheap Wins

### 6.1 `INVARIANTS.md` (flat file) + hook integration — *the headline fix*
- A single flat `INVARIANTS.md` in the project root (template shipped in `templates/`).
- Format: a table of system contracts, each with an ID, a plain-language statement, the area it constrains, and a status flag (`✅ holds` / `⚠ unverified` / `❌ broken`). New invariants seed as `⚠ unverified` until proven.
- Example row: `INV-01 | OAuth protects all /api/* routes | auth layer | ✅ holds`.
- **Hook change:** `session-context.sh` loads `INVARIANTS.md` **in full** (never truncated) alongside HANDOFF.md. A PowerShell sibling (`session-context.ps1`) is added per Wave 0's portability fix.
- **Session-end discipline** (added to `session-workflow`): before writing HANDOFF, Claude checks which invariants the session's work *could have* affected and re-verifies them with evidence.
- **Rationale for flat over directory:** cross-cutting contracts scale with subsystems (small), not file count. Flat is trivial to `cat` into the hook and to eyeball. Graduate to `specs/` + `archive/` only if the file genuinely becomes unwieldy.

### 6.2 `feynman-explainer` skill — completes the thinking trio
- New `skills/feynman-explainer/SKILL.md`.
- Invoked at two checkpoints: (a) before claiming a task done, (b) when writing HANDOFF.md.
- Forces a plain-language explanation of the change as if to a competent newcomer — no jargon, no hand-waving over "and then it just works." Points where the explanation stalls are logged as **comprehension gaps**, each mapped to a concrete follow-up (read X / test Y / verify invariant Z).
- The simple explanation becomes the HANDOFF body, so HANDOFF quality and comprehension are gated by the same act.
- Hands off to `debugging-wizard` or `labarr-ml` when a gap reveals a real defect.
- Grounded in retrieval-practice research (Karpicke & Blunt 2011, *Science*; Koh/Lee/Lim 2018; Bjork; Ebbinghaus 1885).

### 6.3 Committed `.claude/agents/` — first three
- `verifier.md` — fresh-context adversarial reviewer; checks diff against plan + invariants; **reports only correctness/requirement gaps** with the leniency caveat baked in ("a reviewer asked for gaps will invent them — flag only gaps affecting correctness"). Tools: Read/Grep/Glob/Bash. The maker≠checker leg.
- `security-reviewer.md` — secret/credential hygiene + fiduciary-data checks (serves the trustee/compliance angle). Read-heavy, no Write.
- `explorer.md` — cheap codebase search on `model: haiku` to control cost on large repos.

### 6.4 Committed `.claude/settings.json` — operationalize hard rules
- `deny`: `Read(.env)`, `Read(**/*.key)`, secret paths — keeps secrets out of context entirely (deny-from-any-scope cannot be overridden).
- `allow`: safe repeat commands (lint, test, `git commit`) to cut approval fatigue. Bootstrap with `/fewer-permission-prompts`.

**Verification for Wave 1:** add a deliberately-broken invariant, start a fresh session, confirm the hook surfaces it; invoke `feynman-explainer` on a sample change and confirm gap logging; dispatch `verifier` on a known-flawed diff and confirm it catches the flaw without over-engineering noise; confirm `Read(.env)` is denied.

---

## 7. Wave 2 — Enforcement + Evals

### 7.1 `.claude/rules/verification.md` (auto-load)
- "Evidence over assertion": no "done" without the command run + its output.
- Ranked verification taxonomy: **rules-based > visual > LLM-as-judge** (LLM-judge explicitly noted as least robust).
- The named **"trust-then-verify gap"** failure pattern: plausible-looking implementation that doesn't handle edge cases → always provide a verification path; if you can't verify it, don't ship it.

### 7.2 Verification hooks
- **PostToolUse** matcher `Edit|Write` → auto-format/lint after every edit (deterministic where a rule is only advisory; serves "No AI Slop").
- **PreToolUse** matcher `Bash|Write` → guardrail blocking writes to protected paths / commits of `.env` (exit code 2 blocks).
- **Stop hook** (optional, project-by-project) → blocks turn-end until the project check passes. Ships as a template, not always-on.

### 7.3 `.claude/rules/evals.md` (auto-load)
- Binary pass/fail, never 1–5 scales.
- Read traces **to saturation** ("until you stop learning") — not a fixed count.
- The solo operator is the single benevolent-dictator judge — own the rubric.
- No generic metrics (BERTScore/ROUGE) — build a problem-specific check.
- Every confirmed failure becomes a pinned regression case.
- Data-flywheel note: operational failures feed back into the eval set (Agent-in-the-Loop, arXiv:2510.06674).
- Optional tooling appendix: Opik (`@opik.track`, LLM-judge, PyTest) — described as a *manual* trace→regression workflow, not a one-click feature.

**Verification for Wave 2:** trigger PostToolUse lint on a deliberately-unformatted edit; attempt a `.env` write and confirm the PreToolUse guard blocks it; dry-run the evals rule against a sample output set.

---

## 8. Wave 3 — Loop Discipline + Polish

### 8.1 `.claude/rules/loop.md` — thin, built on native primitives
- **Leans on native `/goal` + auto mode** for the iteration engine rather than scripting a counter.
- Doctrine the platform doesn't supply: exit condition written **before** the loop starts; maker≠checker; state on disk; the **L1 report → L2 assisted-fix → L3 unattended** autonomy ladder (never start unattended); stuck-loop detection (same error repeats → stop, surface to human); loops open PRs, never auto-merge.
- Git checkpoints retained for **audit trail**; rollback delegated to native `/rewind`.

### 8.2 CLAUDE.md `@`-import split
- Template CLAUDE.md splits always-load design rules from reference material (e.g. roadmap tables) moved behind `@docs/roadmap.md`. Keeps the every-session surface lean.

### 8.3 Optional infra (documented, not required)
- Short `docs/optional-integrations.md` covering Graphiti (temporal memory) and Playwright/browser-verify MCP (UI self-checking) as opt-in patterns, with the explicit "don't install the kitchen sink — each MCP server costs context" warning.

**Verification for Wave 3:** run a bounded `/goal` loop end-to-end at L1; confirm the CLAUDE.md split still loads design rules every session.

---

## 9. What We Deliberately Skip (and why)

| Skipped | Why |
|---|---|
| BMAD-METHOD | Multi-agent persona SDLC; overkill for solo. Maker/checker gives the benefit. |
| Spec Kit slash-command workflow | Redundant with plan/execute + GSD. Took the constitution idea (→ INVARIANTS). |
| EARS notation | Heavyweight; "write testable, unambiguous criteria" captures intent. (And it's *not* a Spec Kit feature.) |
| `.claude/commands/` directory | Deprecated — merged into skills. Author macros as skills. |
| Output styles | Removed from CC — migrated to skills. |
| Hand-rolled iteration loop / checkpoint-rollback | Native `/goal` and `/rewind` now ship this. |
| Graphiti / Opik as core | Infra cost; documented as optional only. |

---

## 10. Accuracy Notes (carried from research, to avoid propagating errors)

- **`arXiv:2603.23613` is bogus.** LLMLOOP is real but ICSME 2025 (Tool Demo track), no confirmed arXiv ID. Cite by venue, not that number.
- **"~100 traces"** is community gloss; Hamel Husain's actual rule is "read to saturation."
- **Opik "failing trace → regression test"** is a manual workflow, not a built-in.
- **Cherny / Karpathy loop quotes** verified authentic (June 2026 / Mar 2026 respectively).
- **"Best MCP servers for solo devs" ranking** is community opinion; the context-cost warning and Context7/Playwright value are official.

---

## 11. Open Questions

*(none currently blocking — flat-file vs directory and clean-up sequencing resolved in §6.1 and §4)*
