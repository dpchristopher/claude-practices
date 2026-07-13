#!/bin/bash
# subagent-audit.sh — SubagentStop: append a one-line audit record of which agent ran.
# Never blocks (always exit 0). Diagnostic only — an orchestration audit trail.
input="$(cat)"
agent_name="$(printf '%s' "$input" | grep -oE '"agent_name"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed -E 's/.*"([^"]*)"$/\1/')"
[ -z "$agent_name" ] && agent_name="unknown"
mkdir -p .claude 2>/dev/null
printf '%s  agent=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$agent_name" >> .claude/orchestration-log.txt 2>/dev/null
exit 0
