# Optional Integrations

These are opt-in patterns, NOT part of the core kit. Each adds capability *and* cost
(context, setup, a dependency). **Don't install the kitchen sink** — every MCP server you
add consumes context and can degrade performance. Add one only when a concrete need appears.

---

## Graphiti — temporal memory (optional)
**What:** an open-source temporal knowledge graph (the engine behind Zep). Stores facts
with validity windows — you can ask "what is true now" vs "what was true then" — and ships
an MCP server.

**Why you might add it:** if flat-file continuity (INVARIANTS.md + HANDOFF + the SessionStart
hook) stops scaling — e.g. you need to query the *history* of how a contract changed over
time, not just its current state.

**Why you probably don't yet:** it adds a graph DB + embeddings + an LLM ingestion pipeline.
The kit's markdown continuity works and is zero-infra. Pilot Graphiti as an experiment
before making it core.

**Repo:** github.com/getzep/graphiti

---

## Playwright / browser-verify MCP — UI self-checking (optional)
**What:** an MCP server that lets Claude drive a real browser — navigate, click, screenshot.

**Why you might add it:** it closes the verification loop on visual work. For a dashboard,
Claude can open the page, exercise it as a user, and screenshot proof — satisfying the
"evidence over assertion" rule for UI changes (the strongest verification for visuals).

**Cost / caution:** an MCP server eats context whether or not you use it on a given turn.
Add it on visual-heavy projects; remove it on others. Don't run several browser/automation
MCPs at once.

---

## Rule of thumb
Core kit = zero required infra (markdown + shell + git). Reach for an optional integration
only when a real, recurring need outgrows the simple mechanism — and remove it when it
stops earning its context cost.
