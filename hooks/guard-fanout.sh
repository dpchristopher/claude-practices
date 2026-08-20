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
# WIRING (opt-in — not enabled by default):
#   { "hooks": { "PreToolUse": [ { "matcher": "Agent",
#       "hooks": [{ "type": "command", "command": "bash ~/.claude/hooks/guard-fanout.sh" }] } ] } }

set -uo pipefail

THRESHOLD=4          # the cap stated in loop-cost-discipline.md is 3-4 children
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
echo x >> "$COUNTER" 2>/dev/null || true
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
    "permissionDecisionReason": "Agent dispatch #$COUNT this session. loop-cost-discipline.md caps ad hoc fan-out at $THRESHOLD children; past that, route through the Workflow tool (visible spend in /workflows, real caps). State the child count and per-child budget, or confirm this dispatch is deliberate."
  }
}
EOF
exit 0
