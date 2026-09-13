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

# --- Rule 2 was REMOVED 2026-09-13, same day it was added. Kept as a note on purpose. ---
# It blocked general-purpose dispatches whose leading verb was verify/review/audit/validate/
# confirm, on the grounds that 29 of 146 such dispatches skipped guard-verdict.sh (which only
# guards named checker agents). bob-verifier's review of the branch found it was built on a
# misread of the data:
#   * 25 of the 29 came from ONE session - a /code-review run, which dispatches general-purpose
#     reviewers by design. One skill doing its job was read as a pattern across the work.
#   * superpowers' spec reviewer dispatches general-purpose "Review spec compliance for Task N".
#     /beast-mode is built on that skill; the rule would have broken it.
#   * dave-researcher's nested "Verify <fact>" web checks would have been redirected to
#     bob-verifier, which has no WebSearch or WebFetch.
#   * Ordinary implementation briefs ("Review and fix the parser", "Confirm the build passes then
#     deploy") were blocked.
# Excluding the one skill-driven session leaves 4 cases across 3 sessions: too few to justify a
# blocking guard with that false-positive profile. See DECISIONS.md D-014. Same error as the
# retracted "4x over-count" earlier that day - generalising from a single session.

# --- Rule 1: GSD agents only inside a GSD project -----------------------------------
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
