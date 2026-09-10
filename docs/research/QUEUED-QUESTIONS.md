# Queued Questions — not yet researched

> Things Daniel asked to look at later. Kept out of `FINDINGS-LEDGER.md` because that file
> indexes *findings*; this one holds *questions*.

---

## Q-1 · npmjs.com — worth learning to navigate, or irrelevant to this stack?

**Asked 2026-09-09.** Daniel is vetting a batch of GitHub tools people are hyping on social
media, deciding what earns a place in the doctrine versus what is noise. Vetted so far:

| Tool | Verdict he reached |
|---|---|
| `cathrynlavery/diagram-design` | Real, well-maintained, worth installing |
| `volcengine/OpenViking` | Real but heavy infra, sandbox only |
| `cactus-compute/needle` | Real but irrelevant — edge/IoT, wrong stack |
| DHH's `omarchy` | Real but a full OS swap, not a doctrine item |
| `NVIDIA-NeMo/Switchyard` | Real but pre-alpha, not production-ready |

**His question, verbatim:** is npmjs.com itself something to know how to navigate for evaluating
tools like these going forward — checking package health, maintenance status, download counts
before adding something to doctrine? Or mostly irrelevant, since these tools are Python/Rust/
skill-based rather than npm packages?

**He wants an honest read, not a hedge.**

Worth covering when answered:
- What npm actually is, and what the registry does and does not tell you
- Which of the health signals (weekly downloads, last publish, dependents, maintainer count,
  provenance/attestations) are real signal versus vanity
- Whether Claude Code's own ecosystem touches npm at all — plugins, MCP servers, hooks. Several
  of his wired hooks are `node` scripts, and `gsd-*.js` hooks run under Node, so the answer may
  be less "irrelevant" than the framing assumes. **Verify before asserting either way.**
- The generalizable version: what is the right vetting checklist for *any* tool before it enters
  doctrine, regardless of registry? That is the durable answer; npm is one instance of it.
- Whether this belongs as a skill or a rule, given `kit-maintenance.md`'s Agent-Creation Gate
  already governs adding things.

---

## Q-2 · The public repo description does not match the repo

**Found 2026-09-09 while checking context for Q-1.** Daniel described
`dpchristopher/claude-practices` as containing "CLAUDE.md and META_ARCHITECTURE.md templates,
plus three skills: thinking-partner, socratic-examiner, and assumption-archaeologist," with core
principles "Skills First, Context Budget (keep the main session under 40%, offload batch work to
subagents), and Plan → Fresh Session."

Checked against the actual repo:

- **Repo is PUBLIC** — confirmed via `gh repo view`. Worth remembering when writing anything into
  it.
- **Nine skills ship, not three:** `assumption-archaeologist`, `failure-modes`,
  `feynman-explainer`, `init`, `labarr-ml`, `patterns-guide`, `session-workflow`,
  `socratic-examiner`, `thinking-partner`.
- **"Keep the main session under 40%" is not in the repo.** `grep -rn "40%"` across
  `docs/`, `templates/.claude/rules/`, and `global-rules/` returns nothing. "Context Budget"
  exists as a concept in `tool-discipline.md` and older docs, but **no 40% threshold is written
  anywhere.**
- "Plan → Fresh Session" does exist, as `loop-cost-discipline.md`'s "Fresh Session vs. /compact".

**Not necessarily a problem** — this may be how he pitches it verbally, or a description written
against an older version. But two things follow:

1. If he describes the repo this way to other people, the public README should match, or the
   description should change.
2. **The 40% figure appears to have no source.** It reads like a real rule but is not in the
   doctrine. Either it should be written down with a rationale, or it should stop being cited.
   This is the same shape as the fabricated statistics Waves 8 and 9 caught — a number that
   sounds authoritative and traces to nothing.

---

## Q-3 · Should the vetting method itself become doctrine?

Implied by Q-1 rather than asked directly. Daniel is already running an informal evaluation
process on hyped tools and reaching sensible verdicts (real-but-wrong-stack, real-but-pre-alpha,
real-but-too-heavy). That process is not written down anywhere.

Given `kit-maintenance.md`'s Agent-Creation Gate governs what may be *added*, a companion
"how to vet an external tool before adopting it" rule may be the missing half — and it would
generalize past npm to GitHub repos, plugins, MCP servers, and skills.
