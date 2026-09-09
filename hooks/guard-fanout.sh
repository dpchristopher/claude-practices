#!/bin/bash
# guard-fanout.sh — PreToolUse(Agent). The enforced form of the fan-out brake.
#
# WHY THIS EXISTS
# 2026-08-19: a researcher agent got a 4-part question, spawned 5 uncosted children,
# consumed an entire session limit, and returned nothing. The rule that would have
# caught it now lives in ~/.claude/rules/loop-cost-discipline.md — but MAST (arXiv
# 2503.13657) measures prompt-level interventions as insufficient on their own, and
# verification.md says: rules are advisory, hooks are enforced.
#
# WHY IT ASKS RATHER THAN BLOCKS
# loop.md's autonomy ladder says never start at L3. This is L2: silent during normal
# use, human-in-the-loop at the threshold. It never hard-denies, because a legitimate
# large fan-out is a real thing — it just should be a decision, not an accident.
#
# WHY IT IS SILENT BELOW THE THRESHOLD
# A hook that fires on every dispatch becomes wallpaper and gets ignored or disabled.
# Fan-out of 1-3 children is normal and correct; there is nothing to say about it.
#
# WHY IT COUNTS A ROLLING WINDOW, NOT THE WHOLE SESSION (fixed 2026-09-08)
# The original counted every dispatch for the life of the session. That is not the
# failure it was built for. The 2026-08-19 incident was a BURST: 5 children at once,
# uncosted. A long session that dispatches 2 agents six separate times, each time
# deliberately, is not that — but the old counter treated them identically and started
# asking on every dispatch forever after. Observed 2026-09-08: a session legitimately
# reached 12 dispatches across hours of sequential work and every further dispatch was
# gated, with no way to clear it short of deleting the state file. One session's counter
# had reached 20.
# A window measures concurrency, which is what "fan-out" actually means.
#
# WIRING (opt-in — not enabled by default):
#   { "hooks": { "PreToolUse": [ { "matcher": "Agent",
#       "hooks": [{ "type": "command", "command": "bash ~/.claude/hooks/guard-fanout.sh" }] } ] } }

set -uo pipefail

THRESHOLD=${CLAUDE_FANOUT_THRESHOLD:-4}   # cap from loop-cost-discipline.md; override per-project
WINDOW_SECS=${CLAUDE_FANOUT_WINDOW:-300}  # rolling window: burst detection, not a session total
PAYLOAD=$(cat)

# Session id, without requiring jq (not guaranteed present cross-platform).
SESSION=$(printf '%s' "$PAYLOAD" | sed -n 's/.*"session_id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
[ -z "$SESSION" ] && SESSION="unknown"

STATE_DIR="${TMPDIR:-/tmp}/claude-fanout"
mkdir -p "$STATE_DIR" 2>/dev/null || exit 0     # never let bookkeeping break a dispatch
COUNTER="$STATE_DIR/$SESSION"

# Append-then-count, NOT read-modify-write. O_APPEND is atomic, so a parallel
# fan-out - the exact 2026-08-19 scenario - is counted correctly. A read-modify-write
# counter silently undercounts concurrent dispatches and never fires, which would
# have made this hook useless against the incident it exists for.
NOW=$(date +%s)
echo "$NOW" >> "$COUNTER" 2>/dev/null || true

# Keep only dispatches inside the window. Rewrite atomically so a concurrent fan-out
# cannot read a half-written file.
TMP="$COUNTER.$$"
awk -v now="$NOW" -v w="$WINDOW_SECS" '$1 ~ /^[0-9]+$/ && (now - $1) <= w' "$COUNTER" > "$TMP" 2>/dev/null   && mv -f "$TMP" "$COUNTER" 2>/dev/null || rm -f "$TMP" 2>/dev/null

COUNT=$(wc -l < "$COUNTER" 2>/dev/null | tr -d ' ')
[ -z "$COUNT" ] && exit 0

if [ "$COUNT" -le "$THRESHOLD" ]; then
  exit 0                                        # normal fan-out: say nothing
fi

# Past the cap. Hand the decision to the human, with the reason the model can act on.
cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "ask",
    "permissionDecisionReason": "$COUNT agent dispatches in the last $((WINDOW_SECS/60)) minutes. loop-cost-discipline.md caps ad hoc fan-out at $THRESHOLD; past that, route through the Workflow tool (real caps, visible spend in /workflows). State the child count and per-child budget, or confirm this burst is deliberate."
  }
}
EOF
exit 0
