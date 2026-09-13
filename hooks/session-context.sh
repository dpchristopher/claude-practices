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

  # Exit-condition check. Greps the WHOLE plan, not just the head shown above.
  # MAST measures "unaware of termination conditions" at 12.4% of multi-agent
  # failures; loop.md already requires an exit condition, but nothing checked it.
  if ! grep -qiE "done when|exit condition" "$PLAN_FILE"; then
    echo ""
    echo "⚠ ACTIVE PLAN HAS NO \"Done when\" / EXIT CONDITION — write one before executing."
  fi
fi

# System invariants — load in full (durable contracts, never truncate)
if [ -f "INVARIANTS.md" ]; then
  echo ""
  echo "## SYSTEM INVARIANTS (INVARIANTS.md — full; these must NOT break)"
  cat "INVARIANTS.md"
fi

# --- Missed-close detector -------------------------------------------------
# Added 2026-09-13. This hook used to end by asking Claude "does this context look current,
# or is anything stale?" - a question that depends on being remembered, and in the session
# this was written it was not asked. Staleness is computable, so compute it and print a FACT.
# Silent when clean: a warning that fires every session becomes wallpaper and gets ignored.
#
# Deliberately NOT checked: whether the last session-metrics row still has "?" fields. The
# SessionEnd stub writes "?" every session by design, so that signal would fire every time.
STALE=""
if git rev-parse --git-dir >/dev/null 2>&1; then
  # 1. Work committed after the handoff was last updated => the handoff was not refreshed.
  #
  #    PRIMARY method, when HANDOFF.md is tracked: count NON-MERGE commits in the graph after
  #    the last commit that touched it. Exact, and independent of clocks and file timestamps.
  #    Revised 2026-09-13 after /code-review found two defects in a first version that compared
  #    commit dates against the file's mtime plus a 300s grace window:
  #      * `stat -c %Y` is GNU-only. Its `|| echo 0` fallback made H_MTIME epoch 0, so on
  #        macOS every commit in history was reported as missed work, every session.
  #      * The kit's workflow is branch -> PR -> merge. A merge commit landing after the grace
  #        window was counted as missed work; on this repo it inflated 6 real commits to 9.
  #    --no-merges excludes merge commits; the graph removes the clock entirely.
  if [ -f ".claude/HANDOFF.md" ]; then
    N_AFTER=""
    H_WHEN=""
    if git ls-files --error-unmatch ".claude/HANDOFF.md" >/dev/null 2>&1; then
      H_COMMIT=$(git log -1 --format=%H -- ".claude/HANDOFF.md" 2>/dev/null)
      if [ -n "$H_COMMIT" ]; then
        N_AFTER=$(git rev-list --no-merges --count "${H_COMMIT}..HEAD" 2>/dev/null)
        H_WHEN=$(git log -1 --format='%ci' "$H_COMMIT" 2>/dev/null | cut -c1-16)
      fi
    else
      # FALLBACK, handoff not tracked: compare against the file's mtime. Portable stat, and if
      # neither form works, SKIP the check - an unknown timestamp must never become epoch 0.
      H_MTIME=$(stat -c %Y ".claude/HANDOFF.md" 2>/dev/null || stat -f %m ".claude/HANDOFF.md" 2>/dev/null)
      if [ -n "$H_MTIME" ] && [ "$H_MTIME" -gt 0 ] 2>/dev/null; then
        GRACE=${CLAUDE_HANDOFF_GRACE_SECS:-300}
        N_AFTER=$(git log --no-merges --since="@$(( H_MTIME + GRACE ))" --oneline 2>/dev/null | wc -l | tr -d ' ')
        H_WHEN="file mtime $(date -d "@$H_MTIME" '+%Y-%m-%d %H:%M' 2>/dev/null || date -r "$H_MTIME" '+%Y-%m-%d %H:%M' 2>/dev/null || echo unknown)"
      fi
    fi
    if [ -n "$N_AFTER" ] && [ "$N_AFTER" -gt 0 ] 2>/dev/null; then
      STALE="${STALE}   - ${N_AFTER} commit(s) made after HANDOFF.md was last updated (${H_WHEN}).
     The handoff below does NOT reflect that work. Latest: $(git log -1 --no-merges --format='%h %s' 2>/dev/null | cut -c1-70)
"
    fi
  fi
  # 2. Uncommitted files present before any work this session => left behind.
  #
  #    Excludes files the KIT'S OWN HOOKS generate. Found by the feynman-explainer gate on its
  #    first run (2026-09-13): precompact-handoff.sh writes .claude/precompact-state.md and
  #    subagent-audit.sh / log-instructions-loaded.sh write .claude/orchestration-log.txt. In 6
  #    of 8 repos on the machine that built this, .claude/ is not gitignored, so those files are
  #    permanently untracked and this check would have fired EVERY session - the wallpaper
  #    failure the detector exists to avoid. Neither the six test cases nor /code-review caught
  #    it. Filtering here fixes it once, independent of any repo's .gitignore.
  #    Only work the USER left behind should count.
  KIT_ARTIFACTS='\.claude/(precompact-state\.md|orchestration-log\.txt|monthly-reports/)'
  DIRTY_LIST=$(git status --porcelain 2>/dev/null | grep -vE "$KIT_ARTIFACTS")
  N_DIRTY=$(printf '%s' "$DIRTY_LIST" | grep -c . 2>/dev/null)
  if [ "${N_DIRTY:-0}" -gt 0 ]; then
    STALE="${STALE}   - ${N_DIRTY} uncommitted file(s) left from a previous session:
$(printf '%s\n' "$DIRTY_LIST" | head -5 | sed 's/^/       /')
"
  fi
fi
if [ -n "$STALE" ]; then
  echo ""
  echo "⚠ LAST SESSION DID NOT CLOSE CLEANLY — computed, not guessed:"
  printf '%s' "$STALE"
  echo "   Consider /session-close before new work, or confirm this state is intentional."
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
echo "   1. If a missed-close warning appears above, deal with it first. Staleness is computed"
echo "      now, not asked — no warning means the handoff is current"
echo "   2. Invoke /session-workflow         (protocol + toolkit)"
echo "   3. Invoke /superpowers:brainstorming (explore + plan)"
echo "      Use /session-workflow as your operational reference"
echo "═══════════════════════════════════════════════════════════"
