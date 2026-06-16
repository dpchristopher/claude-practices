#!/bin/bash
# session-context.sh
# Runs at SessionStart. Outputs key project context so Claude has it from the first message.
# Add to your project's .claude/settings.json:
#   { "hooks": { "SessionStart": [{ "type": "command", "command": "bash ~/.claude/hooks/session-context.sh" }] } }

echo "═══════════════════════════════════════════════════════════"
echo "SESSION CONTEXT"
echo "═══════════════════════════════════════════════════════════"

# CLAUDE.md summary (first 40 lines)
if [ -f "CLAUDE.md" ]; then
  echo ""
  echo "## PROJECT RULES (CLAUDE.md — first 40 lines)"
  head -40 CLAUDE.md
fi

# META_ARCHITECTURE summary (first 60 lines)
if [ -f "META_ARCHITECTURE.md" ]; then
  echo ""
  echo "## ARCHITECTURE SNAPSHOT (META_ARCHITECTURE.md — first 60 lines)"
  head -60 META_ARCHITECTURE.md
fi

# Active plan file (most recently modified)
PLAN_FILE=""
if [ -d ".claude/plans" ]; then
  PLAN_FILE=$(ls -t .claude/plans/*.md 2>/dev/null | head -1)
fi
if [ -z "$PLAN_FILE" ] && [ -f "PLAN.md" ]; then
  PLAN_FILE="PLAN.md"
fi

if [ -n "$PLAN_FILE" ]; then
  echo ""
  echo "## ACTIVE PLAN ($PLAN_FILE)"
  head -30 "$PLAN_FILE"
fi

# Last session handoff
if [ -f ".claude/HANDOFF.md" ]; then
  echo ""
  echo "## LAST SESSION — BLOCKERS & NEXT ACTION (.claude/HANDOFF.md)"
  cat ".claude/HANDOFF.md"
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "CONTEXT LOADED."
echo ""
echo "⚠️  MANDATORY STARTUP — DO THIS BEFORE RESPONDING:"
echo "   1. Invoke /session-workflow         (protocol + toolkit)"
echo "   2. Invoke /superpowers:brainstorming (explore + plan)"
echo "   Both skills. That order. Every new project or session."
echo "═══════════════════════════════════════════════════════════"
