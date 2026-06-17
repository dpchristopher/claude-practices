#!/bin/bash
# session-context.sh
# Runs at SessionStart. Outputs key project context so Claude has it from the first message.
# Add to your project's .claude/settings.json:
#   { "hooks": { "SessionStart": [{ "type": "command", "command": "bash ~/.claude/hooks/session-context.sh" }] } }

echo "═══════════════════════════════════════════════════════════"
echo "SESSION CONTEXT"
echo "═══════════════════════════════════════════════════════════"

# CLAUDE.md summary (first 80 lines)
if [ -f "CLAUDE.md" ]; then
  echo ""
  echo "## PROJECT RULES (CLAUDE.md — first 80 lines)"
  head -80 CLAUDE.md
fi

# META_ARCHITECTURE summary (first 120 lines)
if [ -f "META_ARCHITECTURE.md" ]; then
  echo ""
  echo "## ARCHITECTURE SNAPSHOT (META_ARCHITECTURE.md — first 120 lines)"
  head -120 META_ARCHITECTURE.md
fi

# Active plan file — handle multiple plans
PLAN_FILE=""
if [ -d ".claude/plans" ]; then
  PLAN_COUNT=$(ls -t .claude/plans/*.md 2>/dev/null | wc -l)
  if [ "$PLAN_COUNT" -gt 1 ]; then
    echo ""
    echo "## ACTIVE PLANS (${PLAN_COUNT} found — showing most recent)"
    echo "All plans:"
    ls -t .claude/plans/*.md 2>/dev/null | while read f; do
      echo "  - $f"
    done
  fi
  PLAN_FILE=$(ls -t .claude/plans/*.md 2>/dev/null | head -1)
fi
if [ -z "$PLAN_FILE" ] && [ -f "PLAN.md" ]; then
  PLAN_FILE="PLAN.md"
fi

if [ -n "$PLAN_FILE" ]; then
  echo ""
  echo "## ACTIVE PLAN ($PLAN_FILE)"
  head -50 "$PLAN_FILE"
fi

# Last session handoff
if [ -f ".claude/HANDOFF.md" ]; then
  echo ""
  echo "## LAST SESSION — BLOCKERS & NEXT ACTION (.claude/HANDOFF.md)"
  cat ".claude/HANDOFF.md"
else
  echo ""
  echo "## HANDOFF"
  echo "⚠  HANDOFF not found — this may be a new project or first session."
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "CONTEXT LOADED."
echo ""
echo "⚠️  MANDATORY STARTUP — DO THIS BEFORE RESPONDING:"
echo "   1. Ask: does this context look current, or is anything stale?"
echo "   2. Invoke /session-workflow         (protocol + toolkit)"
echo "   3. Invoke /superpowers:brainstorming (explore + plan)"
echo "      Use /session-workflow as your operational reference"
echo "═══════════════════════════════════════════════════════════"
