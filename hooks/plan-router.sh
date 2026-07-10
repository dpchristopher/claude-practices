#!/bin/bash
# plan-router.sh — UserPromptSubmit: on explicit planning intent, remind to route through Gru.
# Conservative matcher — fires only on clear planning cues, not every message.
input="$(cat)"
prompt="$(printf '%s' "$input" | tr '[:upper:]' '[:lower:]')"
if printf '%s' "$prompt" | grep -qE "(draft|write|create|make) (an? |the )?plan|let'?s plan|plan (this|the|it) out|plan the |implementation plan|let'?s (build|design) "; then
  echo "PLANNING INTENT DETECTED — before drafting, delegate to Gru (gru-planner). Gru reads the project (CLAUDE.md, HANDOFF, META_ARCHITECTURE, INVARIANTS, rules, agents), runs an applicability pass over the whole kit, drafts a plan with everything explicit, self-audits against .claude/rules/planning.md, and hands it to Bob for an independent check. See .claude/rules/planning.md."
fi
exit 0
