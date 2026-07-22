#!/bin/bash
# guard-verdict.sh — SubagentStop gate for checker agents (Bob / Carl / Kevin).
# Fails (exit 2) if a checker agent finishes without emitting its required verdict marker,
# so a checker can never silently return without a pass/fail verdict. Exit 2 BLOCKS the
# stop (fails the gate); exit 0 allows it. Non-checker agents are always allowed.
# Feasibility: the SubagentStop payload carries last_assistant_message (the agent's final
# text) and agent_type; the verdict is matched against the final message ONLY (never the
# whole payload), so path/cwd/session metadata can neither satisfy nor break the gate.
input="$(cat)"
agent="$(printf '%s' "$input" | grep -oE '"agent_type"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed -E 's/.*"([^"]*)"$/\1/')"

# Extract just the final message. The ([^"\\]|\\.)* body spans JSON-escaped quotes inside
# the message and stops at the first UNescaped quote (the real closing quote of the field).
msg="$(printf '%s' "$input" | grep -oE '"last_assistant_message"[[:space:]]*:[[:space:]]*"([^"\\]|\\.)*"' | head -1)"

# Anchors are ASCII on purpose: "Verified" is a substring of "(check) Verified", so the ASCII
# form matches whether the verdict emoji is present, dropped, or JSON-encoded as \uXXXX.
# This avoids false-blocking a correct verdict over emoji encoding/omission.
case "$agent" in
  bob-verifier)   pattern='Verified|Gaps found' ;;
  carl-evals)     pattern='Pass rate|PASS|FAIL' ;;
  kevin-security) pattern='Clear|Findings' ;;
  *) exit 0 ;;  # not a guarded checker — allow
esac

if printf '%s' "$msg" | grep -qE "$pattern"; then
  exit 0
fi
echo "Blocked: $agent finished without its required verdict marker (expected one of: $pattern). A checker must emit a verdict before stopping." >&2
exit 2
