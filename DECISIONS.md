# Decisions

> Why the kit is the way it is. `CHANGELOG.md` records **what** changed; this records **why**,
> and what was rejected, so a decision is not re-litigated by someone who never saw the reason.
>
> Newest first. Each entry: the decision, the reason, what was rejected, and what would reverse it.
> A decision with no reversal condition is a belief, not a decision.

---

## D-016 · The missed-close detector filters kit artifacts in the hook, and reads the commit graph
**2026-09-13**

**Decided:** (1) measure staleness by non-merge commits after the last commit that touched
`HANDOFF.md`, not by comparing commit dates to the file's mtime; (2) exclude files the kit's own
hooks generate from the uncommitted-files check, inside the hook itself.
**Reason — the graph:** `/code-review` found the mtime version had two defects. GNU-only
`stat -c` fell back to epoch 0 on failure, reporting every commit in history as missed work on
macOS; and PR merge commits landing after the grace window counted as missed work — measured on
this repo, 6 real commits became 9. The graph needs no clock, and `--no-merges` removes the merges.
**Reason — the filter:** the `feynman-explainer` gate, on its first run after zero runs in 39
sessions, found that in 6 of 8 repos on this machine `.claude/` is not gitignored, so
`precompact-state.md` and `orchestration-log.txt` are permanently untracked. The detector would
have fired every session — the exact wallpaper failure it exists to avoid. Six test cases and
`/code-review` both missed it.
**Rejected:** adding `.claude/` entries to the `.gitignore` of six repos, two of them client repos.
That fixes it per repo and silently breaks again in the next repo that lacks the entry. One filter
in the hook fixes it everywhere.
**Known and not fixed here:** those artifacts still pollute `git status` in the same six repos.
That is a separate problem from the detector and is carried forward.
**Reverse if:** a kit hook starts writing a new artifact into `.claude/` — add it to
`KIT_ARTIFACTS`, or the detector returns to firing every session.

## D-015 · Delete beast mode; make session-workflow §9 the single close-out spec
**2026-09-13**

**Decided:** delete `/beast-mode`. Reduce `/session-close` to a trigger over `session-workflow` §9
plus a report, restating none of §9's steps.
**Reason — beast mode:** every piece of it already existed. Gru's plan carries tasks, owners,
done-when commands, mutation tests, commits, and a dependency graph marking which tasks run in
parallel. The go-ahead gate is a global hard rule; pausing at decisions is marked in the plan;
the 3-attempt cap is `loop-cost-discipline.md`; verifying agent claims is `output-accuracy.md`;
running tasks through agents is `superpowers:subagent-driven-development`. Beast mode was a second
copy, not a layer — and it had already contradicted the plan it executed, specifying conventional
commits where the plan specified `session-workflow`'s format. It also ran tasks strictly in
sequence, discarding the parallelism Gru's dependency graph designed.
**Reason — session-close:** its first version re-listed §9 and silently overrode two steps,
swapping `/code-review` for `bob-verifier` and changing the commit format. Two specs for one job
drift. §9 now carries the two steps that were genuinely new (dispatch `jerry-docs` for docs; record
decisions in `DECISIONS.md`) and session-close points at it.
**This is D-012 being right.** D-012 said not to build beast mode until a Gru plan had been run by
hand, because automating a process never performed means guessing what it needs. It was superseded
the same afternoon, and the build guessed wrong in exactly the way D-012 predicted.
**To execute a Gru plan now:** say "execute the plan." `subagent-driven-development` runs it; the
plan carries everything else.
**Reverse if:** a Gru plan is executed by hand and a concrete, recurring gap appears that neither the
plan format nor existing skills cover.

## D-014 · Remove the verification-routing guard the same day it was added
**2026-09-13**

**Decided:** remove Rule 2 from `guard-agent-ownership.sh`, which blocked `general-purpose` when a
task's leading verb was verify/review/audit/validate/confirm.
**Reason:** `bob-verifier` reviewed the branch and found it built on a misread of the data. 25 of
the 29 cases came from one session — a `/code-review` run, which dispatches `general-purpose`
reviewers by design. It would also have blocked the superpowers spec reviewer that `/beast-mode`
depends on, and redirected `dave-researcher`'s web fact-checks to `bob-verifier`, which has no web
tools. Excluding the one skill-driven session leaves 4 cases in 3 sessions.
**Rejected:** narrowing the rule to change-review phrasing — still a blocking guard justified by
four cases, with a false-positive profile nobody has measured.
**The lesson:** the same error as the retracted "4× over-count" earlier that day — generalising
from a single session. Two instances in one day of one reasoning error.
**Reverse if:** verification dispatched to `general-purpose` is shown, across several sessions and
excluding skill-driven runs, to be skipping review that should have happened.

## D-012 · Don't build beast mode or session-close until a Gru plan has been run by hand
**2026-09-13** · *Superseded same day by D-013*

**Decided:** defer both. **Reason:** there was exactly one Gru plan and it had never been
executed. Automating a process never performed means guessing what it needs.
**Superseded because** Daniel chose to bake both in to some extent now. The concern stands and is
recorded so the first real run is treated as the calibration it is.

## D-013 · Build session-close and beast mode now, thinly, and calibrate on first use
**2026-09-13**

**Decided:** build both as composition over existing parts, not new capability. Session-close
wires `session-workflow` §9 into one command. Beast mode executes a Gru plan through existing
maker/checker agents.
**Reason:** every piece exists (`jerry-docs`, `feynman-explainer`, `bob-verifier`,
`subagent-driven-development`, the Workflow tool). The gap is that the checklist is never run —
`feynman-explainer` has zero invocations in 39 sessions.
**Rejected:** new agents for either job — the Agent-Creation Gate in `kit-maintenance.md`.
**Reverse if:** the first real run of either shows the thin version cannot do the job.

## D-011 · Fable is for long unattended chains, not the default model
**2026-09-12**

**Decided:** Opus stays the working tier. Reach for Fable deliberately.
**Reason:** Fable's measured edge is agentic, not code quality — Terminal-Bench 4.0 is +13.8 points
over Opus, CursorBench only +3.4 ([Anthropic, Introducing Claude Fable 5.1](https://www.anthropic.com/claude-fable-and-mythos-5-1): Terminal-Bench 4.0 55.8% vs 42.0%; CursorBench 3.2.0 73.4% vs 70.0%). It wins when a long chain must recover from failure without a
human, and barely matters when someone is watching. Fable also consumes session limits faster.
**Rejected:** switching the default, and upgrading `bob-verifier` — Bob's 2026-09-08 failures were
looking-in-the-wrong-place errors, not reasoning errors.
**Reverse if:** an A/B on a Civ overnight sweep shows no reduction in interventions.

## D-010 · No Team seat for client work
**2026-09-09**

**Decided:** stay on the existing Max subscription for client work.
**Reason:** Daniel declined further spend. There is no written agreement with the paying client,
so no confidentiality term exists for consumer-tier processing to conflict with.
**Known cost, stated:** Anthropic's DPA covers only Claude for Work and the API. Client data is
processed under consumer terms.
**Reverse if:** any client signs an agreement with confidentiality or third-party terms.

## D-009 · Retire the numeric fan-out cap
**2026-09-09**

**Decided:** replace "cap ad-hoc fan-out at 3–4 children" with structure, depth, and
verification-capacity constraints. Detail: `docs/fan-out-constraints.md`.
**Reason:** the cap came from one incident (2026-08-19). A literature sweep found no validated
optimal N in either direction. It gated correct work twice in 48 hours.
**Rejected:** raising the number — that keeps an unevidenced figure and just moves it.
**Reverse if:** a burst failure like 2026-08-19 recurs under the new rules.

## D-008 · Split tier 1: static deny rules are hard, Auto Mode is not
**2026-09-09**

**Decided:** Auto Mode's classifier is not tier 1 in `docs/mechanizing-doctrine.md`.
**Reason:** static `deny` rules block in every mode including `bypassPermissions`. Anthropic stated
Auto Mode is *"a best-effort classifier, not a security guarantee"* after a demonstrated ~80% bypass.
**Reverse if:** Anthropic documents Auto Mode as an enforcement boundary.

## D-007 · Drop the "40% context budget" figure
**2026-09-09**

**Decided:** do not adopt it.
**Reason:** it appeared in a description of this repo but exists nowhere in the repo — no source,
no rationale. A number that sounds authoritative and traces to nothing is the same shape as the
fabricated statistics Waves 8 and 9 caught. Daniel does not want it.
**Reverse if:** a measured basis for a specific threshold appears.

## D-006 · Remove the GSD hooks, keep the GSD skills and agents
**2026-09-09**

**Decided:** unwire all 8 GSD hooks; leave the plugin's skills and agents installed.
**Reason:** measured — `gsd-context-monitor.js` matched effectively every tool call at 859ms per
invocation, and all GSD hooks self-gate on a `.planning/` directory that exists nowhere. ~1s per
Bash call and ~3.5s per Write/Edit for zero benefit. Skills and agents cost nothing at rest.
**Reverse if:** a project adopts GSD and creates `.planning/`.

## D-005 · Write the mutation test before trusting a check
**2026-09-09**

**Decided:** no invariant or verification script is trusted until it has been made to fail.
**Reason:** three of four invariants could not fail. INV-01 watched the repo while the installer
wrote to `~/.claude`; INV-02 compared repo files to each other; INV-04 asked whether a file cited
a source, not whether a number did. The first fix to INV-01 had the same blindness.
**Reverse if:** never. This one is load-bearing.

## D-004 · Keep personal skills out of this repo
**2026-09-09**

**Decided:** `local-models` and `daniel-context` never enter `claude-practices`.
**Reason:** the repo is public. One names this machine's hardware and paths; the other is
personal context. `local-models` was nearly committed by accident.
**Reverse if:** a genericised version is written that names no machine or person.

## D-003 · Rules that must apply everywhere go in `global-rules/`
**2026-09-09**

**Decided:** `templates/` holds only project-scoped material.
**Reason:** `templates/` reaches nothing until `/init` scaffolds a project, which has never happened.
Wave 9 put four rules there and they reached zero projects.
**Reverse if:** `/init` becomes routinely used and projects are scaffolded from the template.

## D-002 · Hooks are automation, not enforcement
**2026-09-08**

**Decided:** anything that must never happen uses a static permission `deny` rule. Hooks are for
things that should happen automatically.
**Reason:** the kit asserted "hooks are enforced" for months. The hooks documentation says hooks
are best-effort — matchers miss, hooks time out.
**Reverse if:** Claude Code documents hooks as guaranteed.

## D-001 · Distrust agent self-reports
**2026-09-08**

**Decided:** a subagent's report is a claim, not a result. Re-verify anything load-bearing.
**Reason:** in one session, one audit agent reported an edit it never made; another checked the
wrong mechanism and concluded 8 repos were unprotected when 6 were fine; a third got 3 of 7
highest-severity findings wrong, two of which would have caused harmful fixes. Four independent
2026 papers converge on the same finding.
**Reverse if:** never, as a default. Relax per-agent only with a measured track record.
