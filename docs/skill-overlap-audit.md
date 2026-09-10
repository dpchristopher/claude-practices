# Skill-Overlap Audit — 2026-09-09

> `kit-maintenance.md` requires this during a GC pass: *"List skills/agents whose trigger
> conditions overlap. Resolve each pair: merge them, or sharpen descriptions so each owns a
> distinct trigger."* This is the first time it has been run with usage data rather than guesses.

Usage counts below are from `scripts/usage-report.sh` over 39 main sessions, 2026-08-22 onward.
**A zero is a question, not a verdict** — frequency is not value.

---

## The honest constraint: most of these cannot be merged

Four of the six overlapping skills are **plugin-provided or third-party**. You cannot merge what
you do not own. For those, the only available resolution is to decide which one owns the trigger
and to stop treating the others as options.

| Skill | Lives where | Invocations |
|---|---|---|
| `the-fool` | `~/.claude/skills` (kit-local, not in the repo) | 1 |
| `socratic-examiner` | kit repo + installed | **0** |
| `assumption-archaeologist` | kit repo + installed | **0** |
| `mcp-builder` | `~/.claude/skills` | **0** |
| `mcp-developer` | `~/.claude/skills` | **0** |
| `frontend-design` | kit-local **and** `claude-plugins-official` plugin — name collision | 1 |

---

## Overlap 1 — the challenge/critique cluster

`the-fool`, `socratic-examiner`, and `assumption-archaeologist` all claim adjacent triggers.
`socratic-examiner` lists *"Am I missing anything?"* and `assumption-archaeologist` lists *"What
am I missing?"* — near-verbatim.

**Measured reality: 1 invocation across all three, in 39 sessions.** The cluster is not competing
for work; it is not getting any.

**Resolution — owners, by the distinct question each actually answers:**

| Skill | Owns | Distinct trigger |
|---|---|---|
| `socratic-examiner` | A position already formed, before committing | *"Here's my plan / I've decided — does this hold up?"* |
| `assumption-archaeologist` | A plan that looks fine but rests on something unexamined | *"What am I taking for granted?"* |
| `the-fool` | Structured adversarial exercises — pre-mortem, red team, evidence audit | *"Run a pre-mortem"* / *"red team this"* |

Not merged, deliberately: they are genuinely different moves. But the near-duplicate phrasings
in the descriptions are the reason none of them fires reliably — the trigger is ambiguous, so
nothing wins. **The fix is sharper descriptions, not fewer skills.**

**Do not cut any of the three on a zero count.** `assumption-archaeologist` and
`socratic-examiner` are two of the three skills the public repo is described by. A skill that
exists for rare, high-stakes moments is supposed to be rare.

## Overlap 2 — the MCP cluster

`mcp-builder`, `mcp-developer`, and the `mcp-server-dev` plugin all answer "build an MCP server."
**All at zero invocations.**

**Resolution:** `mcp-server-dev` (the official plugin) owns this. It is maintained by someone
else, which is the whole argument — see `Build for Rebuilding` and the don't-reinvent-the-wheel
constraint. The two kit-local copies are candidates for removal at the next GC pass, flagged
here rather than cut now because zero-use plus never-needed is not yet evidence either way.

> DEPRECATED (2026-09): `mcp-builder` and `mcp-developer` superseded by the `mcp-server-dev`
> plugin — remove after 2026-12 unless an MCP build in the interim shows the plugin insufficient.

Per `kit-maintenance.md`'s deprecate-don't-silently-delete rule, with a removal date.

## Overlap 3 — `frontend-design` name collision

Exists **both** kit-local and as a `claude-plugins-official` plugin, with genuinely different
content. A name collision is worse than a duplicate: there is no way to tell from an invocation
which one ran.

**Resolution:** the plugin owns the name. The kit-local copy should be renamed if it holds
anything worth keeping, or dropped. **Needs a content comparison first** — not done here, because
deleting the wrong one loses work. Carried forward.

## Overlap 4 — three session-record mechanisms

`.claude/HANDOFF.md` (manual, per `session-workflow.md`), `~/.claude/session-metrics.md`
(one row per session), and `.claude/orchestration-log.txt` (hook-written). Plus, as of
2026-09-09, `.claude/precompact-state.md`.

**Not an overlap — four different jobs**, and worth writing down because it looks like one:

| File | Written by | Answers |
|---|---|---|
| `HANDOFF.md` | Claude, manually | *What was I doing and what is next?* |
| `session-metrics.md` | `session-metrics-stub.sh` + you | *Which practices earn their keep?* |
| `orchestration-log.txt` | `subagent-audit.sh`, `log-instructions-loaded.sh` | *Which agents ran, what loaded?* |
| `precompact-state.md` | `precompact-handoff.sh` | *What was the mechanical state before context was lost?* |

Three of the four are now automatic. `HANDOFF.md` is the one that still depends on remembering —
and the usage report measured how that goes: the kit's "every session, no exceptions" start
protocol fired in **9 of 39 sessions**.

---

## The finding that outranks every overlap above

**`session-workflow` fired 9 times in 39 sessions. `superpowers:brainstorming` fired 6.**
`CLAUDE.md` says: *"invoke `/session-workflow` + `/superpowers:brainstorming`. Both. That order.
Every session."*

That is ~23% and ~15% compliance on the most emphatically worded rule in the kit. No amount of
sharpening skill descriptions addresses it, because the problem is not ambiguity — it is that a
tier-3 rule depends on remembering.

**This is a tier-demotion candidate, not a wording problem.** A `SessionStart` hook could inject
the protocol's content directly, or print a reminder that is hard to ignore. That is the same
move that fixed everything in Tier 1, and it is the obvious next target.

Recorded here rather than acted on, because it changes how every session starts and that is
Daniel's call.
