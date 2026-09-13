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

# --- Rule 2: verification work goes to bob-verifier, not the catch-all --------------
# Added 2026-09-13. Measured across 41 sessions: 29 of 146 main-session general-purpose
# dispatches were verification tasks ("Verify: ...", "Review ..."). That is not just a routing
# miss - guard-verdict.sh enforces a verdict marker only on NAMED checker agents and exits 0
# for everything else, so verification sent to general-purpose silently skipped the verdict
# gate. The kit's maker!=checker enforcement was being bypassed by agent choice.
#
# Matches on the LEADING verb of the task description only, which is what made the
# classification honest - a task that merely *mentions* something was verified is not a
# verification task. Omitted subagent_type means general-purpose, so it is covered too.
desc="$(printf '%s' "$input" | grep -oE '"description"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed -E 's/.*"([^"]*)"$/\1/' | tr '[:upper:]' '[:lower:]')"
first="$(printf '%s' "$desc" | awk '{print $1}' | tr -d ':,.')"

if [ -z "$agent" ] || [ "$agent" = "general-purpose" ]; then
  case "$first" in
    verify|review|audit|validate|confirm|re-verify|reverify)
      echo "Blocked: this is a verification task ('$first ...') dispatched to general-purpose. Use bob-verifier. guard-verdict.sh enforces a verdict marker only on named checker agents, so verification sent to general-purpose skips the maker!=checker gate entirely. Re-dispatch with subagent_type=bob-verifier." >&2
      exit 2 ;;
  esac
fi

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
