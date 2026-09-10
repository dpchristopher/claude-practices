# Fan-Out Constraints — the evidence

> Detail extracted from `global-rules/loop-cost-discipline.md` on 2026-09-09, per
> `kit-maintenance.md`: if an always-loaded file exceeds budget, move detail into a doc and link
> it. The operative rules stay in the always-loaded file; the reasoning lives here.

### Three constraints, revised 2026-09-09

The old rule was a flat **numeric breadth cap of 3–4 children**, plus "breadth is the constraint,
not depth." Both parts turned out to be wrong, and the revision is stated with its evidence
because the original had none.

**1. Width is not the constraint, and the numeric cap is retired.**
The 3–4 figure came from a single incident (2026-08-19: one agent spawned 5 uncosted children,
burned a session limit, returned nothing). A literature sweep found **no paper giving a validated
optimal N in either direction** — the cap was neither supported nor refuted, it was simply
unevidenced. It also cost real work twice in 48 hours: `guard-fanout` gated every dispatch in a
long session, and the resulting misdiagnosis burned two wrong answers before the hook was
suspected. A cap with no evidence behind it that fires on correct work is a tax, not a brake.

**2. Structure is the constraint. Give the fan-out a role, not a headcount.**
Two 2026 papers (arXiv 2608.18167, 2607.25656) found a **3-agent setup with an explicit
adversarial/critic role beat a 5-agent baseline**, and that naive multi-agent agreement produces
a "false-consensus" failure. So the question to ask before dispatching is not *how many* but
**does any child disagree with the others by design?** A fan-out of parallel agreeing researchers
is weaker than a smaller one containing a designated dissenter.

**3. Depth IS a constraint, and nothing was watching it.**
Observed 2026-09-08: a dispatched agent spawned four children of its own, returned *"I'll wait
for their completion notifications, then write the synthesis"* as its **final answer**, and
terminated — orphaning all four. No artifact was produced; ~40k tokens bought a progress report.
`guard-fanout` did not catch it, because the brake sits at the parent layer and cannot see a
child fanning out. Hence:

> **A dispatched agent must produce the artifact itself. Delegating is permitted; returning a
> delegation as the deliverable is not.** If an agent may spawn children, it must also wait for
> and synthesize them — otherwise tell it plainly that it may spawn none.

Platform default nesting depth is **3 layers** (`CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH`), which
bounds recursion but does nothing about the failure above: that agent was within depth and still
produced nothing.

**4. The real ceiling is verification capacity.**
Four separate agent self-reports failed local verification in one session, including one that
reported an edit it never made and one whose 3 of 7 highest-severity findings were wrong — two
of which would have caused actively harmful fixes. Four independent 2026 papers converge on the
same finding: an agent's self-report of success is not evidence
(source: `SOURCES.md#abstention-and-citation`; see also `output-accuracy.md`). **Fan out as wide
as you can actually check. Fifty confident claims you cannot verify are worth less than five you
can.**
