# Mechanizing Doctrine

> Which hard rules can stop depending on Claude reading them, and how to move each one.

A rule works only if Claude reads it and chooses to comply. A hook fires whether or not
anyone remembers. A permission rule cannot be bypassed at all. Push each piece of doctrine
as far down this list as it will go:

| Tier | Mechanism | Strength |
|---|---|---|
| 1 | Static permission `deny` rule | Claude literally cannot. Blocks in **every** mode, including `bypassPermissions` |
| 2 | Hook (`exit 2` blocks) | Fires automatically; best-effort matching, can miss |
| 3 | Always-loaded rule | Works if Claude reads and obeys |
| 4 | Skill / agent | Works if *you* remember to invoke it |

### Auto Mode's classifier is NOT tier 1 — corrected 2026-09-09

The first version of this table said "Permission `deny` rule — Claude literally cannot," which
quietly filed two different mechanisms under one label:

- **Static `deny` rules** in `settings.json` are genuinely hard. The permission docs state they
  "block in every mode, including `bypassPermissions`." Tier 1 is correct for these.
- **Auto Mode's classifier** — the model that decides which actions to allow without prompting —
  is **not** a security boundary. Anthropic said so directly after Johann Rehberger demonstrated
  a ~80%-success bypass: it is *"a best-effort classifier, not a security guarantee."*
  (via Simon Willison, 2026-08-27; cross-checked to The Register, GovInfoSecurity, Cybernews.)

Auto Mode is convenience, not enforcement. It belongs beside tier 2, not tier 1.

**Why this correction matters more than the fix itself:** this document was written to prevent
exactly this error, and made it on its first day. The kit had just spent a session removing the
claim that "hooks are enforced" — a mechanism assumed deterministic that was best-effort — and
then filed a best-effort classifier under "literally cannot." **The failure mode is not any one
wrong rule; it is the reflex to treat a mechanism as harder than it is.** When writing a new
tier-1 claim, the test is: *what is the documented failure mode of this mechanism?* If the answer
is "it can miss," it is not tier 1.

## Current state of the hard rules

| Hard rule | Tier now | Mechanism |
|---|---|---|
| Never commit `.env` or API keys | 1 + 2 | deny rules + gitleaks `core.hooksPath` |
| Log one row per session | 2 | `session-metrics-stub.sh` (SessionEnd) |
| Fan-out cap 3–4 children | 2 | `guard-fanout.sh` |
| Checker agents must emit a verdict | 2 | `guard-verdict.sh` (SubagentStop) |
| My agents win over GSD's | 2 | `guard-agent-ownership.sh` (PreToolUse) |
| Never claim done without evidence | 2 (opt-in) | `stop-verify.sh` — **needs `PROJECT_CHECK_CMD`** |
| Never push directly to main | 3 | rule only — see below |
| Cap refinement loops at ~3 | 3 | judgment; not mechanizable |
| Skills first | 3 | judgment; `plan-router.sh` nudges |

## Known-broken mechanisms — do not build on these

**Subagent-originated `SendMessage` does not reliably work** (2026-09-09). Five or more open or
duplicate issues on `anthropics/claude-code` report subagents unable to originate cross-agent
messages, including with `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` set. The flag is set in this
machine's user settings and enables the **main-session → subagent** direction, which is the case
that matters for asking a finished agent a follow-up. Do not design a workflow that depends on
subagents messaging each other or reporting back mid-run.

Practical consequence: once a subagent finishes, its returned report may be all you get. Prompt
accordingly — require the agent to write its output to a **file**, not just return it. That is
why every research agent in the 2026-09-08 sweep was told to write its own file, and why the
Phase 5 orphans' work was recoverable when their parent terminated without synthesizing.

## Turning on `stop-verify` per project

`stop-verify.sh` blocks turn-end until a project check passes. It is a no-op until
`PROJECT_CHECK_CMD` is set. Set it in the project's own `.claude/settings.json`:

```json
{
  "env": { "PROJECT_CHECK_CMD": "pytest -q" },
  "hooks": {
    "Stop": [{ "hooks": [{ "type": "command", "command": "bash ~/.claude/hooks/stop-verify.sh" }] }]
  }
}
```

Pick a check that is fast and honest for that project — `pytest -q`, `ruff check .`,
`npm test --silent`, or several joined with `&&`. A check that takes a minute will make every
turn feel slow; a check that never fails enforces nothing.

Do **not** set this globally. A repo with no tests would block every turn on a command that
cannot pass.

## Why "never push to main" is still a rule

It could be a deny rule — `Bash(git push origin main:*)` — but a deny is absolute and prompts
for nothing. Doc-only pushes to main (a HANDOFF close-out) are an established, deliberate
practice here, and a deny rule would block them with no approval path. The trade is real in
both directions; it is left as a rule on purpose, not by oversight.

## What cannot move

Cite-or-retract, abstention, distrusting agent self-reports, the GC pass, loop-cost estimation,
fresh-session-vs-`/compact`. These need a judgment a matcher cannot make: whether a claim is
non-obvious, whether a loop has stopped improving, whether a rule still earns its place.
They stay at tier 3, and that is the correct tier for them — not a gap to be closed.
