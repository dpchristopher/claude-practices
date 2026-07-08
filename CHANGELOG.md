# Changelog

All notable changes to claude-practices. Versions follow semver-ish intent:
minor = new capability, patch = fix/cleanup.

## [1.0.0] — 2026-06-29 (Wave 3 — Loop Discipline & Finale)
### Added
- `loop` rule — self-correction loop discipline built on native `/goal` + `/rewind`: exit-condition-first, maker≠checker, state-on-disk, L1→L2→L3 autonomy ladder, stuck-loop detection, loops open PRs (never auto-merge).
- `docs/optional-integrations.md` — opt-in Graphiti (temporal memory) and Playwright/browser-verify (UI self-check) patterns, with the don't-install-the-kitchen-sink caution.
- `@`-import / leanness guidance in the `CLAUDE.md` template.

### Notes
- Completes the back-half hardening roadmap (Waves 0–3): clean-up → continuity/invariants → verification/evals → loops. The kit now covers planning AND the back half (verification, evals, self-correction, articulation).

## [0.4.0] — 2026-06-29 (Wave 2 — Verification & Evals)
### Added
- `verification` rule — evidence over assertion, verification taxonomy (rules > visual > LLM-judge), the trust-then-verify failure mode.
- `evals` rule — binary pass/fail, read-traces-to-saturation, regression-cases-from-failures, data flywheel.
- Carl (evals-judge) agent — binary pass/fail grader; the checker, never the maker.
- Verification hooks: `guard-secrets.sh` (PreToolUse, blocks writes to secret files, allows `.env.example`/`.template`/`.sample`), `post-edit-format.sh` (PostToolUse, no-op-safe auto-format), `stop-verify.sh` (opt-in Stop hook).
- `.gitattributes` enforcing LF on shell scripts (cross-platform safety).

### Changed
- `settings.json` now wires the secret-write guard and formatter hooks by default (Stop hook opt-in).
- Install scripts copy ALL `hooks/*` (so future hooks need no install-script edits).

## [0.3.0] — 2026-06-29 (Wave 1 — Back-Half Foundation)
### Added
- `INVARIANTS.md` ledger template + `invariants` auto-load rule (cross-session contract tracking).
- `feynman-explainer` skill — comprehension gate completing the thinking trio.
- Minion agents in `templates/.claude/agents/`: Bob (verifier), Kevin (security-reviewer), Stuart (explorer/Haiku), Dave (researcher/Opus), Phil (test-author).
- `settings.json` template — deny secrets, allow safe git commands.
- Windows-native `session-context.ps1` hook sibling.
- MANDATORY/ON-DEMAND Reading Order index at the top of the `CLAUDE.md` template.
- Light vs heavy research rubric in `tool-discipline.md`.

### Changed
- SessionStart hook now loads `INVARIANTS.md` in full; install scripts carry both hooks.
- Session-end discipline now re-verifies affected invariants and runs the Feynman gate.

## [0.2.0] — 2026-06-29 (Treaty of Versailles)
### Changed
- Normalized all skills to `skills/<name>/SKILL.md` directory form.
- Replaced hand-copy README blocks with idempotent `install.sh` / `install.ps1`.
- Single source of truth for the skills tables (methodology → `session-workflow` skill; applicability → `META_ARCHITECTURE.md`).
- Framed Python tooling in `tool-discipline.md` as a swappable default.

### Added
- `VERSION` and this changelog.

### Notes
- Foundation for back-half hardening (Waves 1–3): INVARIANTS.md, feynman-explainer,
  Minion-themed agents, verification/evals rules, native-/goal loop discipline.
  See `docs/superpowers/specs/2026-06-29-claude-practices-hardening-design.md`.

## [0.1.0] — prior
- Initial kit: templates, thinking trio, session-workflow, init, labarr-ml, SessionStart hook.
