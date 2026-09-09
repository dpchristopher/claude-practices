# Phase 1c — "Which of these rules are still TRUE?"

> Audit date 2026-09-08. Auditor: Bob (fresh context, adversarial). Scope: the 9 hard rules in
> `~/.claude/CLAUDE.md`, the 3 global rules in `~/.claude/rules/`, the **13** rules in
> `templates/.claude/rules/` (the task said 10; there are 13), `INVARIANTS.md`, and `SOURCES.md`
> citation-to-claim matching.
>
> Method: every referenced path resolved on disk; every invariant command executed; the two
> invariant scripts **mutation-tested** in an isolated copy of the repo to answer "can this check
> actually fail?"; deployed `~/.claude/settings.json` compared against `templates/.claude/settings.json`
> and against `hooks/`. No web access — anything requiring `code.claude.com` is filed UNVERIFIABLE,
> not guessed.
>
> Precedent being applied: `verification.md`'s "Rules are advisory; hooks are enforced" was wrong
> for months. The generalized defect is **a check or claim that cannot observe the thing it is
> about.** Three more instances of that exact defect are below.

---

## FALSE

### F1 — INV-01's verification command watches a directory `install.sh` never writes to
`INVARIANTS.md:16` · `install.sh:13`

The invariant: *"Both installers are idempotent, and a dry run writes nothing."*
The command: `./install.sh --dry-run && git status --porcelain | wc -l` → `0`.

`install.sh:13` sets `DEST="$HOME/.claude"`. Every write in the script targets `$DEST` —
`$DEST/skills`, `$DEST/hooks`, `$DEST/agents`, `$DEST/rules` (lines 41, 49, 56, 62). Nothing is
written into the repo. `git status --porcelain` is run **in the repo**. It is structurally
incapable of observing a write to `C:\Users\dpchr\.claude`.

So if `--dry-run` were broken and copied all 13 hooks, 10 skills, and 34 agents into `~/.claude`,
this command still prints `0` and INV-01 still reports `✅ holds`. This is INV-02's original
disease verbatim — a check that compares the repo to itself and never reads the deployed state.

Two further defects in the same line:
- `| wc -l` swallows the exit status. `wc` always exits 0, so the pipeline never fails. It is not
  a pass/fail gate; it prints a number a human must notice.
- It does not test idempotence at all. `INVARIANTS.md:16` concedes this — *"Idempotence checked
  separately by installing twice and diffing the manifest"* — i.e. by a manual procedure that is
  not encoded in the command and therefore will not be repeated.

**Should say instead:** snapshot the real target and diff it.
`before=$(find ~/.claude -type f -newermt '-1 min' | wc -l); ./install.sh --dry-run; MANIFEST_BEFORE=$(md5sum ~/.claude/.claude-practices-install-manifest.txt)` — or more simply, a `scripts/verify-install.sh` that (a) hashes `~/.claude` before and after `--dry-run` and fails on any delta, and (b) runs the installer twice and diffs the manifest ignoring line 1. Until that exists, INV-01's status should be `⚠ unverified`, not `✅ holds`.

### F2 — INV-04's check cannot fail on any file that actually quotes a limit number
`INVARIANTS.md:19` · `scripts/verify-sources.sh:42`

The invariant: *"Every platform limit number quoted in shipped doctrine has a dated entry in
`SOURCES.md`."* The check (`verify-sources.sh:42`) is `grep -q "SOURCES\.md" "$f"` — **file-level**.
Any file containing the string `SOURCES.md` anywhere passes for every number in it.

Mutation test, run in an isolated copy:

```
### MUTATION 1: fabricated limit injected into loop.md (which HAS a SOURCES.md pointer)
  appended: "A workflow supports 99 concurrent agents and 4 levels deep."
  CITATIONS OK
  exit=0                       <-- fabricated numbers pass

### MUTATION 2: same text injected into ml-discipline.md (NO SOURCES.md pointer)
  FAIL: templates/.claude/rules/ml-discipline.md quotes a limit number with no SOURCES.md pointer:
      126:Use 99 concurrent agents.
  exit=1
```

Census of which doctrine files the check has any grip on:

| File | limit-number hits | SOURCES.md pointers | Check has teeth? |
|---|---|---|---|
| `templates/.claude/rules/loop.md` | 2 | 1 | **no** |
| `templates/.claude/rules/tool-discipline.md` | 1 | 3 | **no** |
| `templates/.claude/agents/dave-researcher.md` | 1 | 1 | **no** |
| `global-rules/loop-cost-discipline.md` | 1 | 2 | **no** |
| `templates/.claude/rules/ml-discipline.md` | 1 | 0 | yes |

Four of the five files that quote limit numbers — including `loop.md`, where *every* platform
limit in the kit lives — are green by construction. The one file the check can fail on
(`ml-discipline.md`) quotes no platform limits at all; its single hit is an ML-workflow phrase.
**INV-04 is currently passing on exactly the files where it has no ability to fail.**

`INVARIANTS.md:19` discloses the mechanism in its note (*"file-level, not per-number"*) — but the
Status column asserts `✅ holds` against the **stated** invariant, which is per-number. Wave 8
and Wave 9 both dropped fabricated statistics; this check would not have caught either of them,
because both lived in files that already carried a pointer.

**Should say instead:** either (a) narrow the invariant statement to what is tested — *"Every
doctrine file that quotes a platform limit carries a SOURCES.md pointer"* — and drop the `✅` to
reflect that it is a weak proxy; or (b) make the check line-level: require the SOURCES pointer
within N lines of the hit, or inside the same `##` section. (b) is the version worth having.

### F3 — `/code-review` does not exist on this machine
`~/.claude/CLAUDE.md:28` · `templates/.claude/rules/session-workflow.md:81` · `templates/.claude/rules/tool-discipline.md:119`

Three separate live rules instruct Claude to run `/code-review`:
- `CLAUDE.md:28` — *"Significant code written | `/code-review`"*
- `session-workflow.md:81` — *"Run `/code-review` if any significant code was written"* (a Session
  End step, i.e. it should fire every session)
- `tool-discipline.md:119` — `/code-review    # run the skill`, inside the pre-merge git block

There is no `code-review` skill in `~/.claude/skills/` (only `gsd-code-review`, a different
GSD-owned command). The `code-review` plugin exists **only** in the uninstalled marketplace cache
(`plugins/marketplaces/claude-plugins-official/plugins/code-review`); it is absent from both
`installed_plugins.json` and `enabledPlugins`. No enabled plugin ships a `code-review` command
(searched all of `plugins/cache/*/commands/`). The invocation is unresolvable.

**Should say instead:** either install the plugin, or repoint all three sites at what exists —
`superpowers:code-reviewer` (agent, enabled) or the kit's own `bob-verifier`. A rule that has told
Claude to run a nonexistent command at every session end is a rule that has been silently failing
open for as long as it has existed.

### F4 — `/superpowers:brainstorming` resolves to a deprecated no-op command
`~/.claude/CLAUDE.md:14` and `:37`

`CLAUDE.md:37`: *"**START:** invoke `/session-workflow` + `/superpowers:brainstorming`. Both. That
order. Every session."* This is the highest-frequency instruction in the kit.

In superpowers 5.0.7 the *command* is `brainstorm`, not `brainstorming`, and its entire body is:

```
description: "Deprecated - use the superpowers:brainstorming skill instead"

Tell your human partner that this command is deprecated and will be removed in the next
major release. They should ask you to use the "superpowers brainstorming" skill instead.
```

The working thing is the **skill** at `superpowers/5.0.7/skills/brainstorming`. Written with a
leading slash in an "Invoke" column, the rule points at the deprecated surface, and the nearest
matching command is a no-op that only prints a deprecation notice.

**Should say instead:** `superpowers:brainstorming` **skill** (explicitly not the deprecated
`/superpowers:brainstorm` command).

### F5 — `bob-verifier.md` cites a source that says the opposite thing it is cited for
`~/.claude/agents/bob-verifier.md:50` · contradicts `SOURCES.md:15-25` and `SOURCES.md:45-46`

> *"state the child count and the per-child budget first, and **cap it at 3** (source:
> `SOURCES.md#subagent-limits`)."*

`SOURCES.md#subagent-limits` contains exactly four numbers: concurrent limit **20**; total per
session **no limit**; **nesting depth 3**; fork default on. The only `3` in that anchor is
*nesting depth* — a **depth** figure. Bob's rule is a **breadth** cap. The citation supports the
opposite axis of the claim it is attached to.

This is the specific error `SOURCES.md:45-46` names as a prior kit defect: *"These govern the
Workflow tool only — not ad hoc `Agent` dispatch... Conflating the two was a real defect in the kit
before Wave 7."* And `loop.md:91` independently uses the same 3 for depth (*"Design for 3 layers"*),
so the two rules now read as if one number governs both axes.

Compare the correct handling in the same kit: `dave-researcher.md:36-37` and
`global-rules/loop-cost-discipline.md` both say *"Cap: 3–4 children. More than that goes through
the `Workflow` tool, which has real caps (source: `SOURCES.md#workflow-limits`)"* — there the
citation attaches to the Workflow caps, which the anchor genuinely supports.

Secondary, same file family: `global-rules/loop-cost-discipline.md` — *"Breadth is the constraint,
not depth (source: `SOURCES.md#subagent-limits`)."* That anchor makes no breadth-vs-depth claim;
the finding comes from the internal 2026-08-19 incident, which the very next clause correctly
cites. Drop the SOURCES pointer from that sentence.

**Should say instead (bob-verifier.md:50):** *"cap it at 3–4 children — a kit policy from the
2026-08-19 fan-out incident (`templates/.claude/rules/evals.md`), not a platform limit. Larger
fan-out goes through the `Workflow` tool (source: `SOURCES.md#workflow-limits`)."* Also
reconcile the number: three values are currently in force — Bob says 3, Dave and the global rule
say 3–4, `hooks/guard-fanout.sh:37` defaults to 4.

### F6 — Two path-scoped rules assert they are "auto-loaded at session start"
`templates/.claude/rules/automation.md:1-11` · `templates/.claude/rules/ml-discipline.md:1-11`

Both files open with a `paths:` frontmatter block (`automation.md:2-7` globs `**/pipeline*.py`,
`**/*cron*`, `scripts/**/*`; `ml-discipline.md:2-7` globs `**/*.ipynb`, `experiments/**/*`), which
makes them **conditionally** loaded on file match. Line 11 of each then states *"Auto-loaded at
session start."* A path-scoped rule is by definition not loaded at session start.

This matters beyond pedantry: `automation.md:96-112` carries the Wave 9 hooks correction (*"Hard
denies belong in the permission system, not in a hook"*) — the single most important doctrinal fix
of the last wave. It is sitting in a file that only loads when someone edits a `pipeline*.py` or a
file under `scripts/`.

**Should say instead:** *"Loaded when you touch matching paths (see frontmatter) — not at session
start."* And move the hooks-vs-permissions correction out of `automation.md` into an
unconditionally-loaded file, since it is a global claim about the platform, not an automation topic.

### F7 — INV-02's first clause is not checked by any of the three directions, and there is a live orphan
`INVARIANTS.md:17` · `scripts/verify-hooks.sh`

The invariant reads: *"**Every file in `hooks/` is installed**, and every hook referenced by
settings or agent frontmatter exists in `hooks/`."* Clause 2 is checked (direction 1, line 26-35).
Clause 1 is checked by nothing. Directions are: referenced→exists, template-wired→deployed,
`.ps1`→`.sh`. None iterates `hooks/` looking for a hook that is wired nowhere.

Mutation test:

```
### MUTATION B: delete a hook the template references
  FAIL: referenced but missing from hooks/: plan-router.sh
  exit=1                                                  <-- direction 1 works

### MUTATION A: unwire guard-secrets.sh from the deployed config
  FAIL: guard-secrets.sh is wired in the template but NOT in the deployed config
  exit=1                                                  <-- direction 3 works (the Wave 9 fix is real)

### MUTATION C: add a hook to hooks/ that is wired nowhere (the original 8-dead-hooks case)
  HOOK PARITY OK
  exit=0                                                  <-- INV-02 still cannot see an orphan

### MUTATION D: move guard-secrets.sh to the wrong event (PreToolUse -> Notification)
  HOOK PARITY OK
  exit=0                                                  <-- wrong-event wiring is invisible
```

Directions 1 and 3 have real teeth — the Wave 9 deployment-parity fix genuinely works, and that is
worth saying. But mutation C is the exact scenario INV-02 was created for, and it still passes.

**And there is a live orphan right now.** `hooks/guard-readonly-bash.sh` appears in
`templates/.claude/settings.json`: no. In the deployed `~/.claude/settings.json`: no. Its only
declared activation path is agent frontmatter (`kevin-security.md:7-11`, `mel-design.md:6-11`,
`carl-evals.md:8-11`) — see U1, which I could not settle locally. If frontmatter hooks do not
fire, all three "read-only" reviewer agents hold `Bash` with no guard, and INV-02 reports green.

**Should say instead:** add direction 4 to `verify-hooks.sh` — for each file in `hooks/`, assert it
appears in `templates/.claude/settings.json`, the deployed `settings.json`, a project
`settings.json`, or an agent frontmatter; fail otherwise, with an explicit allowlist for
deliberate exceptions (`session-context.ps1` is the Windows sibling; `stop-verify.sh` is
per-project by design and is in fact wired in all 5 projects). Also match on event, not just
filename — direction 3's `grep -q "$h" "$DEPLOYED"` only proves the string is somewhere in the file.

---

## STALE

### S1 — `surgical/compare.py` does not exist
`templates/.claude/rules/tool-discipline.md:174`

The Docstrings section cites a concrete exemplar: *"e.g. `surgical/compare.py`'s module docstring
states the core principle — 'when in doubt, report a change'."* `find C:/Dev -path "*surgical/compare.py"`
returns nothing. The rule's only worked example points at a deleted project.

**Should say instead:** replace with a live example from a current repo, or cut the parenthetical
and keep the abstract criterion (*"the governing rule of a whole module isn't inferable from any
single function name"*), which stands on its own.

### S2 — The `templates/` copies of two shared rules are pre-Wave-9, and one of them breaks a pointer inside the template itself
`templates/.claude/rules/loop-cost-discipline.md` · `templates/.claude/rules/kit-maintenance.md`

`global-rules/` and the deployed `~/.claude/rules/` are byte-identical (verified by `diff`, both
files). The `templates/` copies are older:

- `templates/.claude/rules/loop-cost-discipline.md` is missing the entire **"Estimate Breadth
  Before Dispatch — Ad Hoc Fan-Out"** section (15 lines), including the 3–4 child cap and the
  budget-for-the-failure-case rule.
- `templates/.claude/rules/kit-maintenance.md` is missing the **per-wave ≤ +30 line budget** and
  the **Agent-Creation Gate** section; it retains only the older one-bullet form.

The self-inflicted part: `templates/.claude/rules/evals.md:31-35` ships the 2026-08-19 pinned
regression case and says *"Fix lives in `loop-cost-discipline.md` (global) and the fan-out sections
of `dave-researcher.md` / `bob-verifier.md`."* A project scaffolded from `templates/` gets
`evals.md` pointing at a fix that is **absent from the copy of `loop-cost-discipline.md` in its own
rules directory**. The parenthetical "(global)" is doing load-bearing work that a reader of the
scaffolded project cannot act on, because `global-rules/` is a machine-level install, not part of
the scaffold.

**Should say instead:** sync the two template copies to their `global-rules/` counterparts, and add
a `scripts/` check that the shared-name rules do not drift. `output-accuracy.md` has the same
shape — it exists in `global-rules/` but not in `templates/.claude/rules/` at all.

### S3 — All 13 `templates/.claude/rules/*.md` are in force in zero projects
Verified against every project settings file on the machine.

The rules audited here are, with one exception, not loaded anywhere. Checked
`.claude/rules/` in all five projects that carry a `.claude/settings.json`:

| Project | `.claude/rules/` |
|---|---|
| `C:/Dev/claude-practices` | **does not exist** |
| `C:/Dev/Econ Project` | does not exist |
| `C:/Dev/STL_Project` | does not exist |
| `C:/Dev/Wealth Management Dash` | does not exist |
| `C:/Dev/Civ_Project` | exists, but holds 3 project-local files (`lua-xml-patterns.md`, `mod-discipline.md`, `session-workflow.md`) — not the kit set |

This confirms and extends the brief's line 19 finding. It is not only the Wave 9 accuracy rules
that reached zero projects — it is `verification.md`, `loop.md`, `tool-discipline.md`,
`planning.md`, `safe-autonomy.md`, `evals.md`, `measurement.md`, `invariants.md`,
`session-workflow.md`, and the rest. **The kit's own repo does not load its own rules.** The
corrected hooks-vs-permissions claim (`verification.md:51-61`) — the headline fix of the last wave —
is in force nowhere.

**Should say instead:** this is not a wording fix. Either deploy `templates/.claude/rules/` into
the five live projects (a `scripts/deploy-rules.sh` alongside `install.sh`, which currently
installs skills/hooks/agents/global-rules but **not** project rules), or stop calling them
doctrine and call them a scaffold template. Right now the repo maintains 13 always-loaded-in-theory
files that load in practice for nobody, which is why F6, S1 and F3 survived unnoticed: nothing
ever read them at runtime.

### S4 — `automation.md:110-112` points at a correction target that no longer exists
`templates/.claude/rules/automation.md:110-112`

> *"(Source: `SOURCES.md#hooks-are-advisory`. This corrects a line that previously read 'hooks are
> enforced' in `verification.md`.)"*

I grepped every live rule, agent, and global file for the old wording. It survives in exactly two
places, both of which are deliberate historical records: `SOURCES.md:137` and `SOURCES.md:232`.
`verification.md` no longer contains it. **The Wave 9 sweep was complete — no survivors.** That is
a genuine clean result and worth recording.

The stale part is only the forward reference: a reader following that pointer into `verification.md`
finds nothing. Low severity.

**Should say instead:** *"(Source: `SOURCES.md#hooks-are-advisory`; corrected in Wave 9 — see
`SOURCES.md#hooks-are-advisory` for the history.)"* Or cut the second sentence.

---

## UNVERIFIABLE

### U1 — Whether Claude Code honours a `hooks:` key in agent frontmatter — **highest-stakes open question**
`~/.claude/agents/kevin-security.md:7-16` · `mel-design.md:6-11` · `carl-evals.md:8-14` · `bob-verifier.md:7-11`

Four agents declare hooks in YAML frontmatter. `guard-verdict.sh` is *also* wired in the deployed
`settings.json` under `SubagentStop`, so its firing proves nothing about the frontmatter path.
`guard-readonly-bash.sh` is wired **nowhere else** (F7), so it is the clean test case — and I cannot
run it, because my own agent definition (`bob-verifier.md`) does not declare it.

I have circumstantial evidence in both directions and will not guess:
- *For:* `scripts/verify-hooks.sh:26-28` deliberately greps agent frontmatter for hook references,
  so the kit was built assuming it works.
- *Against:* nothing in `~/.claude/telemetry/` or the orchestration logs shows
  `guard-readonly-bash.sh` ever firing, and I ran `rm -rf`, `cp`, `mv`, and `mkdir` freely this
  session without a block (though my own frontmatter does not claim that guard, so this is not
  dispositive).

**Cannot verify locally — needs `code.claude.com/docs/en/sub-agents` (does agent frontmatter
support `hooks:`?).** The stake: if it does not, Kevin, Mel, and Carl are declared read-only,
hold the `Bash` tool, and have no guard — and `verify-kit.sh`'s 41/41 and INV-02's green both
report fine. **Verify this first.** It is the same shape as the hooks-vs-permissions error: a
protection assumed to be deterministic that may not be firing at all.

### U2 — The per-wave "≤ +30 lines" budget is unmeasurable and unmeasured
`~/.claude/rules/kit-maintenance.md:12-16`

> *"Per-wave growth across always-loaded files (`global-rules/` + unconditional `.claude/rules/`):
> aim for **≤ +30 lines**."*

Three problems: "wave" is nowhere defined as a countable unit; nothing measures it (`grep` across
`scripts/` for any line-budget check returns nothing — `verify-kit.sh` checks `CLAUDE.md` only for
the presence of the ownership rule); and no per-wave line counts are recorded anywhere, so the
trend cannot be reconstructed. The rule's own parenthetical concedes the last self-report was wrong
(*"a review caught that its first self-reported figure omitted the lines this very rule added"*) —
which is precisely the failure mode of a self-reported metric with no instrument.

The *sibling* budgets in the same section are verifiable and currently pass: `~/.claude/CLAUDE.md`
is **54 lines** against a ~60 target ✅. (Note the two rule files policing it are 66 lines each, and
the always-loaded total is 217 lines — but no rule sets a budget for those, so this is an
observation, not a violation.)

**Should say instead:** either add the instrument (a `scripts/check-line-budget.sh` that records
always-loaded line count per tagged release into a file, so growth is computed not remembered), or
cut the ≤+30 clause and keep only the two per-file budgets that can be checked. An unfalsifiable
budget cannot be maintained — and by its own admission has already been misreported once.

### U3 — `measurement.md`'s monthly review cannot be executed against its own log
`templates/.claude/rules/measurement.md:51-63` · data at `~/.claude/session-metrics.md`

The rule specifies a three-step monthly review whose step 2 is *"Crude before/after by tag. Compare
goal-met and rollback rates for sessions where a practice fired vs. where it didn't."* That
requires the four metrics to be populated. In the actual log (18 data rows):

- **7 rows are all-`?` auto-stubs**, all dated 2026-09-08, all from `Civ_Project`, six of them
  near-duplicates with identical observed values (*"5 fan-out state dirs, 72 orchestration-log
  lines"*). No human will retro-fill seven identical stubs.
- **2 rows are structurally malformed** — `2026-08-20` and `2026-08-22` have four cells where the
  header defines eight, omitting goal-met, rollback, interventions, and friction entirely.
- That leaves **9 of 18 rows** usable, spread across ~7 weeks, for a comparison that needs
  same-practice sessions on both sides of a tag.

`measurement.md:41-44` claims the SessionEnd stub fixed the sparse-log problem. It is TRUE that
`session-metrics-stub.sh` appends (verified — the 7 stub rows are its output). It is not true that
this made the log reviewable: the stub converted a sparse log into a diluted one. The rule's own
line 43 — *"A sparse log cannot prune anything"* — now applies to its own remedy.

**Should say instead:** the stub should be idempotent per session (one row per session ID, not one
per invocation — six identical `Civ_Project` rows on one day is a bug, not a feature), and the
rule should state what happens to an unfilled stub at review time (excluded from rates, or the
review is blocked). As written, step 2 is a procedure with no executable path.

### U4 — `/goal`, `/rewind`, `/subtask` asserted as native primitives
`templates/.claude/rules/loop.md:7-13` · `templates/.claude/rules/tool-discipline.md:31`

`loop.md:8-11` builds its opening section on two claimed platform features: *"**`/goal`** is the
iteration engine... **`/rewind`** is the safety net: per-change checkpoints."* `tool-discipline.md:31`
similarly asserts *"**Fork** (`/subtask`; on by default in interactive sessions)"*.

There is no `~/.claude/commands/` directory on this machine and none of the three appears in any
enabled plugin's `commands/`. That is expected if they are built-ins, and proves nothing either way.
The fork-default claim *is* backed — `SOURCES.md:24` records it verified 2026-08-19 against the
sub-agents docs — but the `/subtask` **command name** is not in that source table. `/goal` and
`/rewind` have no `SOURCES.md` entry at all, and `loop.md`'s entire "lean on native primitives"
framing collapses if either was renamed or removed in the four months since the May cutoff.

**Cannot verify locally — needs `code.claude.com/docs/en/` slash-command reference.** Given that
this is a whole section of a rule instructing "use it instead of hand-rolling a loop," it should
carry a dated `SOURCES.md` entry like every other platform claim does. Note this is exactly the
class INV-04 was built to catch and structurally cannot (F2): these are named features, not
numbers, so the regex never looks at them.

### U5 — `loop.md`'s version range disagrees with `SOURCES.md`
`templates/.claude/rules/loop.md:81` vs `SOURCES.md:23`

`loop.md:81`: *"Subagent nesting depth | 3 (**was up to 5 before v2.1.219**)"*.
`SOURCES.md:23`: *"3 (was up to 5, unchangeable, **in v2.1.172–216**), default since v2.1.219"*.

"Before v2.1.219" and "in v2.1.172–216" are not the same claim — they differ on 217 and 218, and
"before" also misdescribes the pre-172 state. Low severity; the operative number (3) matches. But
it is a paraphrase that drifted from its own source, which is the mechanism INV-04 exists to
prevent and cannot detect (F2).

**Should say instead:** quote the source range verbatim, or drop the version history from the rule
and leave it in `SOURCES.md` where it is maintained.

---

## VACUOUS

### V1 — `verification.md` duplicates `output-accuracy.md` almost verbatim, and both load
`templates/.claude/rules/verification.md:37-49` vs `~/.claude/rules/output-accuracy.md:8-21`

Two sections — "Cite or retract" and "Say 'I don't know' out loud" — appear in near-identical
wording in both files, citing the same `SOURCES.md#abstention-and-citation` anchor.
`verification.md:41-42` even carries a note explaining the split (*"that rule governs claiming
done, this one governs every claim on the way there"*), and `output-accuracy.md:4` carries the
mirror-image note. Two files each explaining why they are not the other file is the tell.

On the current deployment this is harmless *only because* `verification.md` loads nowhere (S3). If
S3 is fixed — which it should be — this becomes ~13 duplicated lines in the always-loaded budget
that `kit-maintenance.md:12-16` is trying to police.

**Should say instead:** `verification.md` keeps "Evidence over assertion", the taxonomy, judge
calibration, maker≠checker, and the hooks section. It replaces its lines 37-49 with a one-line
pointer: *"Claims made along the way are governed by `output-accuracy.md`."* Net −11 lines from the
always-loaded layer, no doctrine lost.

### V2 — `log-instructions-loaded.sh` is wired, fires, and captures nothing
`hooks/log-instructions-loaded.sh:5-6` · output at `~/.claude/orchestration-log.txt`

Its stated purpose (line 3) is *"Diagnostic only — catches a silently-unloaded INVARIANTS.md etc."*
Every entry in the log is identical:

```
2026-09-09T02:40:53Z  loaded=(none captured)
2026-09-09T02:40:53Z  loaded=(none captured)
2026-09-09T02:40:53Z  loaded=(none captured)
2026-09-09T02:40:53Z  loaded=(none captured)
```

Line 5 greps the hook payload for `"path": "..."` and line 6 falls back to `(none captured)` when
that yields nothing. It has yielded nothing 4 times out of 4. The hook is correctly installed and
correctly wired — and delivers zero signal, so it cannot perform the one job it was written for.
Given that S3 is precisely a "doctrine files silently not loading" problem, this is the hook that
should have caught S3 and did not.

**Should say instead:** fix the payload parse (the `InstructionsLoaded` payload shape needs
confirming against the docs — same fetch as U1), or cut the hook. As it stands it writes a line
per session that no one can act on. Note this hook is also invisible to INV-02's orphan check (F7),
so nothing would have flagged it.

### V3 — `INVARIANTS.md:12`'s framing claim no longer describes the ledger
`INVARIANTS.md:10-12`

> *"These four were chosen because **each is cheaply checkable** and each is something a doctrine
> wave could plausibly break."*

Given F1 (INV-01 checks the wrong directory), F2 (INV-04 cannot fail on the files that matter),
and F7 (INV-02's first clause is unchecked), "each is cheaply checkable" is true of INV-03 only.
The sentence reads as a standard the ledger meets; it currently describes an aspiration.

Low priority on its own — it is a header sentence, not an operative rule — but it should not be
left standing after F1/F2/F7 are fixed or acknowledged, or it becomes the next "hooks are enforced":
a comfortable line that gets read every session and is quietly false.

---

## What is solid — verified, with the evidence

These were tested, not waved through.

| Claim | Verified how |
|---|---|
| **The Wave 9 hooks correction swept cleanly.** No live rule, agent, or global file still says "hooks are enforced" / "rules are advisory". | `grep -rn` across `~/.claude/CLAUDE.md`, `~/.claude/rules/`, `~/.claude/agents/`, `templates/`, `global-rules/`, `README.md`. Two hits, both in `SOURCES.md` (:137, :232) as deliberate history. |
| **`verification.md:51-61`'s hooks claim is now correct** — best-effort, permission system is the gate, blocking hook must `exit 2`. | Matches `SOURCES.md#hooks-are-advisory` (primary product docs, fetched Wave 9). Internally consistent with `automation.md:96-112`. |
| **INV-02's deployment-parity direction genuinely works** — the Wave 9 fix is real, not decorative. | Mutation A: unwiring `guard-secrets.sh` from a copied deployed config produced `FAIL ... wired in the template but NOT in the deployed config`, exit 1. |
| **INV-04 can fail on an uncited file.** | Mutation 2: injected limit number into `ml-discipline.md` (no pointer) → `FAIL`, exit 1. |
| **Zero drift between `hooks/` and deployed `~/.claude/hooks/`.** | `diff` on all 13 files: 13 SAME, 0 DRIFTED, 0 NOTDEPLOYED. |
| **`guard-fanout.sh`'s rolling-window fix is present and deployed.** | `hooks/guard-fanout.sh:37-38` — `THRESHOLD=${CLAUDE_FANOUT_THRESHOLD:-4}`, `WINDOW_SECS=${CLAUDE_FANOUT_WINDOW:-300}`; identical in the deployed copy. The repo's own `8` override is deliberate and documented at `CHANGELOG.md` [1.8.1]. |
| **`stop-verify.sh` gates all 5 projects**, each with a real `PROJECT_CHECK_CMD`. | Read all five `.claude/settings.json`: Civ_Project, claude-practices, Econ Project, STL_Project, Wealth Management Dash — each wires `Stop` → `stop-verify.sh` with a distinct check command. |
| **INV-03 holds and is a real gate.** | `verify-kit.sh` gitleaks passes on all 3 repos; `INVARIANTS.md:18` records the pre-commit hook installed at `.git/hooks/pre-commit`. |
| **`verify-kit.sh` 41/41, `verify-hooks.sh` and `verify-sources.sh` exit 0.** | Executed all three; pasted output. |
| **`~/.claude/CLAUDE.md` is 54 lines**, inside the ~60 budget at `kit-maintenance.md:10`. | `wc -l`. |
| **`SOURCES.md`'s withholding discipline is intact and honest** — MAST FC1 (:108-121), SABER 69.8% (:192-198), DSPy/APE (:200-209), the two unread arXiv abstracts (:245-251) are all correctly flagged or dropped rather than quietly shipped. | Read in full. No fabricated survivor found in the citation ledger itself. This part of the kit is working as designed. |
| **`Monitor` tool exists** as `loop.md:28-29` assumes. | Confirmed present in the live tool environment. |
| All other skills named in `CLAUDE.md:12-31` resolve. | `ls ~/.claude/skills/` — `session-workflow`, `init`, `thinking-partner`, `labarr-ml`, `claude-api`, `pandas-pro`, `sql-pro`, `debugging-wizard`, `the-fool`, `socratic-examiner`, `assumption-archaeologist`, `outside-the-box`, `mcp-builder`, `local-models`, `failure-modes`, `daniel-context`, `stop-slop` all present; `bob-verifier` and `carl-evals` present in `~/.claude/agents/`. Only `/code-review` (F3) and `/superpowers:brainstorming` (F4) fail to resolve. |

---

## The single highest-priority fix

**Settle U1: does Claude Code honour a `hooks:` key in agent frontmatter?**

One doc fetch answers it, and the answer changes the severity of everything else. If frontmatter
hooks do not fire, then `guard-readonly-bash.sh` has never run, and Kevin, Mel, and Carl — the
three agents documented as "Read-only", two of which are pointed at client data and security
review — hold the `Bash` tool with no guard at all, while `verify-kit.sh` reports 41/41 and INV-02
reports `✅ holds`.

That is structurally the same failure as "hooks are enforced": a protection believed to be
deterministic, never observed firing, and invisible to every check the kit has. It is also the
only finding here with a security consequence rather than a hygiene one.

Order after that: **F1** (INV-01 watches the wrong directory) and **F2** (INV-04 cannot fail where
it matters), because an invariant that cannot fail is the defect that let all of the above survive;
then **S3** (13 rules loading in zero projects), because it is the reason nobody noticed.
