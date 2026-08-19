# Handoff — Close the 3 Wave 6 gaps (paste into a FRESH Claude Code session)

Paste everything below the line into a new session opened in the `claude-practices` repo.

---

You are working in `C:/Users/dpchr/OneDrive/Desktop/claude-practices`. The repo is at **v1.3.0** (tagged, in sync with GitHub) after "Wave 6." Three small gaps were deliberately deferred and I want them closed now. **Keep this cheap:** do the trivial edits directly in the main session — do NOT spawn a subagent for a one-line frontmatter change. Only Gap B and Gap C warrant an agent. Start by creating a branch: `git checkout master && git pull && git checkout -b feature/wave-6-gap-closure`.

## Gap A — add `effort` to the heavy agents (trivial, do directly)
Add an `effort:` field to the frontmatter of `templates/.claude/agents/dave-researcher.md` and `templates/.claude/agents/gru-planner.md` so they reason harder than the session default.
- FIRST verify valid values: fetch `https://code.claude.com/docs/en/sub-agents`, confirm the allowed `effort` values (e.g. low/medium/high/max) and exact field name. Do not guess.
- Then add `effort: high` (or the highest documented sensible value) to both agents' frontmatter, keeping all other fields.
- Commit: `git add templates/.claude/agents/dave-researcher.md templates/.claude/agents/gru-planner.md && git commit -m "Wave 6 gap: effort:high on Dave and Gru (heavy reasoning agents)"`

## Gap B — enforced verdict gate on the checker agents (VERIFY FEASIBILITY FIRST)
Goal: make maker≠checker *enforced*, not just instructed — a hook that fails if Bob/Carl/Kevin finish WITHOUT emitting their required verdict.
- **Verify first (mandatory):** fetch the hooks docs (`https://code.claude.com/docs/en/hooks`) and the sub-agents "Stop hook" behavior. Confirm whether a frontmatter `Stop` hook (which converts to `SubagentStop`) receives the agent's final message/transcript in its stdin payload so a script can check it for a required verdict string, and whether exit code 2 (or the JSON block form) actually blocks the agent from finishing. **If the Stop hook cannot see the agent's output, this gate is not buildable as designed — STOP, report that, and do not ship a hook that can't work.** Do not guess the payload shape.
- **If feasible:** create `hooks/guard-verdict.sh` that reads the payload, and if the agent's required verdict marker is absent, exit 2 with a reminder. Required markers: Bob → "✅ Verified" or "❌ Gaps"; Carl → "Pass rate" or "PASS"/"FAIL"; Kevin → "✅ Clear" or "❌ Findings". Wire it into the frontmatter of `bob-verifier.md`, `carl-evals.md`, `kevin-security.md` using the SAME verified frontmatter-hooks YAML syntax already used for the read-only guard in those/sibling files (`hooks: > <Event>: > - matcher/hooks: > - type: command > command: bash ~/.claude/hooks/guard-verdict.sh`). Functionally test the script (verdict present → exit 0; absent → exit 2). Commit.
- **If NOT feasible:** document it as a known limitation in `SECURITY.md` or a short note, commit that, and move on. Honesty over a broken gate.

## Gap C — fresh-context Bob review (the belt-and-suspenders finish)
The Wave 6 final review was done controller-side under usage limits, not by a fresh-context reviewer. Now do it properly.
- Dispatch the `bob-verifier` agent (subagent_type: `bob-verifier`) to review the full v1.3.0 change plus the gap-closure edits: give it `git diff v1.2.0..HEAD` and the criteria "verify Wave 6 delivered its 8 areas correctly and the gap-closure edits are sound; report only correctness/requirement gaps." Address anything real it finds.

## Finish
- Run a quick gate: installers still work (`./install.sh --dry-run` writes nothing; real install into a throwaway HOME gives 9 agents / correct hook count / 8 skills), secret-content scan still blocks a test key, clean tree.
- Bump `VERSION` to **1.3.1** (patch — closing gaps), prepend a short `## [1.3.1]` CHANGELOG entry, commit.
- Merge to master (`--no-ff`), tag `v1.3.1`, push master + tag: `git push origin master && git push origin v1.3.1`.
- Run `install.ps1` to make it live on this machine.

**Cost discipline:** this whole thing should be a handful of edits + one review agent. Don't parallelize trivial edits; don't re-plan the kit.
