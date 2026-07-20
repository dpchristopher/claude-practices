#!/bin/bash
# guard-verdict.sh — SubagentStop gate for checker agents (Bob / Carl / Kevin).
# Fails (exit 2) if a checker agent finishes without emitting its required verdict marker,
# so a checker can never silently return without a pass/fail verdict. Exit 2 BLOCKS the
# stop (fails the gate); exit 0 allows it. Non-checker agents are always allowed.
# Feasibility: the SubagentStop payload carries last_assistant_message (the agent's final
# text) and agent_type, so the marker can be matched without reading the transcript file.
input="$(cat)"
agent="$(printf '%s' "$input" | grep -oE '"agent_type"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed -E 's/.*"([^"]*)"$/\1/')"
case "$agent" in
  bob-verifier)   pattern='✅ Verified|❌ Gaps' ;;
  carl-evals)     pattern='Pass rate|PASS|FAIL' ;;
  kevin-security) pattern='✅ Clear|❌ Findings' ;;
  *) exit 0 ;;  # not a guarded checker — allow
esac
if printf '%s' "$input" | grep -qE "$pattern"; then
  exit 0
fi
echo "Blocked: $agent finished without its required verdict marker (expected one of: $pattern). A checker must emit a verdict before stopping." >&2
exit 2
