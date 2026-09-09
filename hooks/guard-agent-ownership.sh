#!/bin/bash
# guard-agent-ownership.sh — PreToolUse(Agent). Mechanizes the CLAUDE.md rule
# "my named agents win over GSD's; GSD agents are for /gsd-* commands only."
#
# Blocks a direct dispatch of a gsd-* agent in a project that is NOT a GSD project
# (no .planning/ directory). In a real GSD project the gsd-* agents are legitimate,
# so the hook stays out of the way there.
#
# Exit 2 blocks. Everything else passes. Never guesses: no .planning/ check it can
# run means it allows.
set -uo pipefail
input="$(cat)"

# Only care about the Agent tool
printf '%s' "$input" | grep -q '"tool_name"[[:space:]]*:[[:space:]]*"Agent"' || exit 0

agent="$(printf '%s' "$input" \
  | grep -oE '"subagent_type"[[:space:]]*:[[:space:]]*"[^"]*"' \
  | head -1 | sed -E 's/.*"([^"]*)"$/\1/')"

case "$agent" in
  gsd-*) ;;
  *) exit 0 ;;
esac

# In an actual GSD project, gsd-* agents are the right tool.
[ -d ".planning" ] && exit 0

case "$agent" in
  gsd-verifier)          use="bob-verifier" ;;
  gsd-planner|gsd-roadmapper) use="gru-planner" ;;
  gsd-*researcher*)      use="dave-researcher" ;;
  gsd-doc-writer)        use="jerry-docs" ;;
  gsd-security-auditor)  use="kevin-security" ;;
  gsd-code-reviewer)     use="bob-verifier or kevin-security" ;;
  *)                     use="the equivalent named agent (Bob/Gru/Dave/Jerry/Kevin/Mel/Phil/Otto/Stuart/Carl)" ;;
esac

echo "Blocked: '$agent' is a GSD-plugin agent and this is not a GSD project (no .planning/). Use $use instead. See the agent-ownership rule in ~/.claude/CLAUDE.md." >&2
exit 2
