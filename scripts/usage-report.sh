#!/bin/bash
# usage-report.sh — what is ACTUALLY used, measured from the transcript corpus.
#
# WHY THIS EXISTS
# `measurement.md` asks for one hand-written metrics row per session. After months the log
# held 11 rows — far too sparse to prune anything with. The 2026-09-08 GC pass found 14
# skills and agents with zero mentions in it and correctly refused to cut a single one,
# because "absent from an 11-row log" is not evidence of disuse.
#
# The transcript corpus at ~/.claude/projects/*/**.jsonl is the better instrument: it records
# every actual Skill invocation and Agent dispatch, whether or not anyone remembered to write
# a row. This turns "which of my 92 skills earn their keep" from a guess into a count.
#
# WHAT IT CANNOT TELL YOU — read before trusting a zero:
#   * A count of 0 means "not invoked in the corpus window", NOT "useless". A skill that
#     fires twice a year for something important is indistinguishable here from a dead one.
#     Frequency is not value. Use this to find candidates, then judge each one.
#   * The corpus only reaches back as far as the retained transcripts (printed below).
#   * Skills loaded automatically by path-matching or triggered implicitly may not appear as
#     an explicit invocation.
#
# Usage: bash scripts/usage-report.sh [days]     (default: all retained history)
set -uo pipefail

CORPUS="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/projects"
DAYS="${1:-0}"

[ -d "$CORPUS" ] || { echo "No transcript corpus at $CORPUS"; exit 1; }

if [ "$DAYS" -gt 0 ] 2>/dev/null; then
  FILES=$(find "$CORPUS" -name "*.jsonl" -mtime "-$DAYS" 2>/dev/null)
  WINDOW="last $DAYS days"
else
  FILES=$(find "$CORPUS" -name "*.jsonl" 2>/dev/null)
  WINDOW="all retained history"
fi

COUNT=$(printf '%s\n' "$FILES" | grep -c . )
# Most transcripts are SIDECHAINS (subagent runs), not sessions. Reporting the raw file count
# as "sessions" overstates the denominator by roughly 12x and makes per-session compliance look
# far worse than it is. Counted separately on purpose.
MAIN=$(printf "%s\n" "$FILES" | grep . | while read -r f; do head -1 "$f" 2>/dev/null | grep -q "\"isSidechain\":true" || echo x; done | grep -c .)
OLDEST=$(find "$CORPUS" -name "*.jsonl" -printf '%T@\n' 2>/dev/null | sort -n | head -1 | cut -d. -f1)
[ -n "$OLDEST" ] && OLDEST=$(date -d "@$OLDEST" +%Y-%m-%d 2>/dev/null || echo "?")

echo "════════════════════════════════════════════════════════"
echo " Usage report — $WINDOW"
echo " $COUNT transcripts ($MAIN main sessions, $(( COUNT - MAIN )) subagent runs)"
echo " oldest retained ${OLDEST:-?}"
echo "════════════════════════════════════════════════════════"

# --- counts: delegated to the JSON parser -----------------------------------
# These sections used to grep raw transcripts for "subagent_type" and "skill". That missed
# every Agent call with no subagent_type field (20 of 480) and could not separate main-session
# dispatches from nested ones. usage_count.py parses the JSON and dedupes by tool-use id.
python "$(dirname "$0")/usage_count.py" "$DAYS"

# --- installed but never seen ------------------------------------------------
echo
echo "── Installed but NOT seen in the corpus ──"
echo "   (a candidate list, NOT a cut list — see the header)"
SEEN=$(python "$(dirname "$0")/usage_count.py" "$DAYS" 2>/dev/null | grep -E '^\s+[0-9]+\s' | awk '{print $2}' | sed 's/.*://' | sort -u)
echo "  skills:"
for d in "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"/skills/*/; do
  [ -d "$d" ] || continue
  n=$(basename "$d")
  printf '%s\n' "$SEEN" | grep -qx "$n" || echo "    $n"
done
echo "  agents:"
for f in "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"/agents/*.md; do
  [ -f "$f" ] || continue
  n=$(basename "$f" .md)
  printf '%s\n' "$SEEN" | grep -qx "$n" || echo "    $n"
done

echo
echo "Frequency is not value. A zero here is a question, not a verdict."
