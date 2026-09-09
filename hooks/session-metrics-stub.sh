#!/bin/bash
# session-metrics-stub.sh — SessionEnd hook. Appends a PARTIAL metrics row.
#
# Why this exists: measurement.md asks for one row per session, and the log had 10 rows
# after months — too sparse to prune anything with. The 2026-09-08 GC pass found that
# `guard-fanout` had fired 5 times while its probation row said "tag any session where it
# fired"; nothing was ever tagged, so the contract was unresolvable.
#
# The four judgment metrics (goal met / rollback / interventions / friction) are yours and
# stay blank. This hook only fills in what a machine can observe, so the row exists at all.
# Never blocks: always exit 0.
set -uo pipefail
LOG="$HOME/.claude/session-metrics.md"
[ -f "$LOG" ] || exit 0

DATE=$(date +%Y-%m-%d)
CWD=$(basename "$PWD")

# Objective signals, best-effort. Absent evidence -> empty, never a guess.
FANOUT=$(ls "${TMPDIR:-/tmp}/claude-fanout" 2>/dev/null | wc -l | tr -d ' ')
AUDIT="$PWD/.claude/orchestration-log.txt"
AGENTS=$(grep -c . "$AUDIT" 2>/dev/null || echo 0)

printf '| %s | %s | ? | ? | ? | ? | AUTO-STUB — fill in: goal met? / rollback? / interventions / friction. Observed: %s fan-out state dirs, %s orchestration-log lines. | |\n' \
  "$DATE" "$CWD" "$FANOUT" "$AGENTS" >> "$LOG"
exit 0
