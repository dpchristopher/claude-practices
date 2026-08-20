# Kit Maintenance Rules

> Auto-loaded at session start. The practices kit rots like any codebase. This is the garbage
> collection that keeps it lean. This rule exists to REMOVE, not add.

---

## The Line Budget

- Global `~/.claude/CLAUDE.md`: keep under ~60 lines. It burns tokens every turn, every project.
- Project `CLAUDE.md`: keep under ~90 lines. Detail belongs in `.claude/rules/*.md`, not inline.
- If a file exceeds budget, move detail into a rule/doc and link it — don't inline it.

Every line in an always-loaded file must earn its place. The test: "would removing this cause
Claude to make a mistake?" If no, cut it.

---

## Quarterly Garbage-Collection Pass

Every ~3 months (or when a file crosses its budget), run the pass:

1. Read `CLAUDE.md` and each rule top to bottom.
2. For each rule ask: "has this fought me, or gone unused, since the last review?"
   - Fought me → revise or cut.
   - Unused → cut. A rule that never fires is dead weight.
3. Prune recall-first, then precision: keep everything that matters, then delete the rest.

Pair this with the measurement log — practices with no positive signal are prune candidates.

---

## Skill-Overlap Audit

Skills and agents accumulate and start to conflict (two tools for one job → inconsistent
firing). During the GC pass:

- List skills/agents whose trigger conditions overlap.
- Resolve each pair: merge them, or sharpen descriptions so each owns a distinct trigger.
- **Before adding any new skill, check `~/.claude/skills/` and `~/.claude/agents/` for one that
  already does the job.** Wire to the existing one instead of duplicating.

---

## Deprecate, Don't Silently Delete

When retiring a rule or skill, mark it before removal:

> DEPRECATED (2026-07): superseded by X — remove after 2026-10.

Give it a removal date. Predictable deprecation beats a rule vanishing mid-project.
