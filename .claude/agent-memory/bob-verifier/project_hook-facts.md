---
name: project-hook-facts
description: Docs-confirmed Claude Code hook facts for this kit's guard hooks, plus the guard-verdict.sh emoji-anchoring fragility to re-check
metadata:
  type: project
---

Facts confirmed against https://code.claude.com/docs/en/hooks (checked 2026-07-22 via claude-code-guide):

- `SubagentStop` input payload DOES carry `agent_type` (agent name slug) and `last_assistant_message` (final assistant text). Common fields also include `effort`, `agent_id`.
- Exit code 2 from a SubagentStop hook BLOCKS the subagent from stopping.
- A hook declared in a subagent's OWN frontmatter fires during that subagent's lifecycle; a `Stop` hook there is auto-converted to `SubagentStop`. So `hooks/guard-verdict.sh` wired as SubagentStop in bob/carl/kevin frontmatter genuinely fires.

**Why:** These were the load-bearing feasibility claims behind Wave 6 Gap B. They check out — the gate is real, not a no-op.

**How to apply / recurring watch-item:** `hooks/guard-verdict.sh` matches verdict markers against the WHOLE stdin payload (not just last_assistant_message), and Bob/Kevin patterns are emoji-anchored (`✅ Verified|❌ Gaps`, `✅ Clear|❌ Findings`). Two fragilities to re-flag if this file changes: (1) whole-payload match can false-PASS if a marker substring (Carl's bare `PASS`/`FAIL`) lands in cwd/transcript_path — low risk since transcript UUIDs are hex; (2) emoji-only anchors false-BLOCK a correct verdict if the model omits the emoji or the payload escapes it as `✅`. ASCII fallback anchors (`Verified|Gaps found`, `Clear|Findings`) would harden both.
