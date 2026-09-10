#!/bin/bash
# subagent-audit.sh — SubagentStop: append a one-line audit record of which agent ran.
# Never blocks (always exit 0). Diagnostic only — an orchestration audit trail.
#
# FIXED 2026-09-09: this hook fired correctly for months and logged nothing usable.
# All 89 lines of the log read "agent=unknown". It grepped for "agent_name", a field
# that does not exist in the payload. The documented fields are `agent_type` (the agent's
# name, e.g. "bob-verifier") and `agent_id` (unique per subagent call).
# See https://code.claude.com/docs/en/hooks — common input fields.
# A hook that runs and records garbage is worse than one that does not run: it looks
# like coverage.
input="$(cat)"

field() {
  printf '%s' "$input" \
    | grep -oE "\"$1\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" \
    | head -1 | sed -E 's/.*"([^"]*)"$/\1/'
}

agent_type="$(field agent_type)"
agent_id="$(field agent_id)"
session="$(field session_id)"

# If neither identifying field is present, record the payload's top-level keys instead of
# a bare "unknown" — that way the log itself tells you what the real shape is.
if [ -z "$agent_type" ] && [ -z "$agent_id" ]; then
  keys="$(printf '%s' "$input" | grep -oE '"[a-z_]+"[[:space:]]*:' | tr -d '":' | tr '\n' ',' | sed 's/,$//')"
  agent_type="UNPARSED(keys=${keys:-none})"
fi

mkdir -p .claude 2>/dev/null
printf '%s  agent=%s id=%s session=%s\n' \
  "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "${agent_type:-?}" "${agent_id:-?}" "${session:-?}" \
  >> .claude/orchestration-log.txt 2>/dev/null
exit 0
