#!/bin/bash
# backup-state.sh — snapshot un-git-tracked Claude state (agent memory, logs, local settings).
# Usage: ./backup-state.sh <backup-dir>   (defaults to ~/claude-backups)
set -euo pipefail
BACKUP_DIR="${1:-$HOME/claude-backups}"
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT="$BACKUP_DIR/claude-state-$STAMP.tar.gz"
mkdir -p "$BACKUP_DIR"

CLAUDE="$HOME/.claude"
# Collect precious, un-tracked paths that exist. Skip secret patterns deliberately.
INCLUDE=()
[ -d "$CLAUDE/agent-memory" ] && INCLUDE+=("$CLAUDE/agent-memory")
[ -f "$CLAUDE/settings.json" ] && INCLUDE+=("$CLAUDE/settings.json")
[ -f "$CLAUDE/.claude-practices-install-manifest.txt" ] && INCLUDE+=("$CLAUDE/.claude-practices-install-manifest.txt")
# Per-project orchestration logs under the current dir
[ -f ".claude/orchestration-log.txt" ] && INCLUDE+=(".claude/orchestration-log.txt")

if [ "${#INCLUDE[@]}" -eq 0 ]; then
  echo "Nothing to back up (no agent memory / settings / logs found yet)."
  exit 0
fi

# Exclude secret patterns as a safety net.
tar --exclude='*.env' --exclude='*.key' --exclude='*.pem' --exclude='*secrets*' \
    -czf "$OUT" "${INCLUDE[@]}" 2>/dev/null
echo "Backed up ${#INCLUDE[@]} path(s) to: $OUT"
