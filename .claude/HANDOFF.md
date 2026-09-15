# HANDOFF — 2026-09-14 (gru-lite)

## Completed
- **gru-lite built, merged (PR #22), and installed.** Plain version: Gru writes good plans but is
  too expensive for small tasks, and work done without Gru came out noticeably worse. gru-lite keeps
  the cheap habits that probably carry Gru's quality — check the one assumption that could sink the
  task, write "done when" as a runnable command, write tests first — and drops the expensive parts
  (a cold agent re-reading everything, a kit-wide checklist, a plan file). It runs in the main
  conversation. Decision record: D-017.
- **Bob only when the change is risky, and risk is computed.** `skills/gru-lite/review-triggers.sh`
  looks at the git diff: big (over 100 lines or 3 files), in a risky place (hooks, auth, settings…),
  inside an invariant's scope, confirmable only by judgment, a rough build, or unmeasurable → Bob.
  Otherwise no Bob. Every decision and outcome is logged to `~/.claude/gru-lite-log.md`.
- **It fires without being remembered.** `plan-router.sh` now adds a one-line triage when a message
  asks for a change (trivial / gru-lite / Gru). On 300 real past prompts it fires on 22 (7%), about
  17 of them real requests. Questions, discussion, and harness notifications stay silent.
- **Gru's Phase 0** now points small single-subsystem work to gru-lite instead of planning it.
- **How we know it works:** 63 behavioural tests in throwaway repos; every trigger, router branch,
  and fix mutation-tested (undo it → a test goes red). Installed copies tested too. HOOK PARITY OK,
  CITATIONS OK, INSTALL OK, gitleaks clean.
- **Reviews earned their cost on the build itself:** the build's own triggers sent Bob — two passes,
  14 gaps. The worst were three separate ways the script said "no review" when it had actually
  failed to measure. Session-close `/code-review` then found 2 more (globs with extensions never
  matched; a recorded base never expired). All fixed, test-first or mutation-confirmed.

## Blockers / didn't work
- **Public-repo slip (needs Daniel):** `git add -A` swept another session's untracked research files
  (`docs/research/2026-09-14-personal-*`, `2026-09-15-grok-bots-*`) and its `.gitignore` edit into
  the first push of PR #22. Removed from the branch within a minute; `master` never had them. GitHub
  keeps orphan commit `90c7ff5` reachable from the PR — a full purge is a GitHub Support request only
  Daniel can file. Those files are still uncommitted on disk, untouched, for that session to handle.
- **Feynman gaps, stated honestly:**
  1. gru-lite's full workflow (`start` → build → `check` → `outcome`) has never run on a real task. This
     build used `--base master` directly. The first real task is the calibration.
  2. Gru's new Phase 0 redirect has not been exercised.
  3. The Bash tool here starts in the OneDrive copy, not a repo; the skill now says to `cd` into the
     project in the same call. Resolved in docs; not yet seen in live use.
- Bob did not see the last round of small fixes (N1–N4, CR1–CR2) — stopped at two passes per the loop
  cap. They are tested and mutation-confirmed.

## Next action (priority 1)
- Use gru-lite on the next small/medium task in any project. Afterwards, judge the output against a Gru
  plan's, and note whether the router triage showed up and whether `review-triggers.sh` decided sensibly.
- After 10–15 logged tasks, read `~/.claude/gru-lite-log.md`: cut triggers that never find anything,
  add one for anything that slipped through.
- Carried forward: click "Run now" on `monthly-kit-sweep` before Oct 1; kit artifacts pollute
  `git status` in 6 repos; `session-context.ps1` drift; Civ verification plan unexecuted.

## Test state
- `bash scripts/test-gru-lite.sh` → 63 passed, 0 failed (repo and installed copies).
- `verify-hooks.sh` HOOK PARITY OK · `verify-sources.sh` CITATIONS OK · `verify-install.sh` INSTALL OK.
- `verify-kit.sh` (full, 43 checks) not re-run this session — it runs every project's stop gate and is slow.
