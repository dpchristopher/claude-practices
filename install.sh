#!/bin/bash
# install.sh — register claude-practices skills + SessionStart hook into ~/.claude
# Idempotent: safe to run repeatedly. Run from the repo root.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
DEST="$HOME/.claude"

echo "Installing claude-practices from: $REPO_DIR"
echo "Into: $DEST"

# 1. Skills — copy every skills/<name>/SKILL.md (+ supporting files) into ~/.claude/skills/<name>/
mkdir -p "$DEST/skills"
for dir in "$REPO_DIR"/skills/*/; do
  name="$(basename "$dir")"
  mkdir -p "$DEST/skills/$name"
  cp -R "$dir". "$DEST/skills/$name/"
  echo "  skill: $name"
done

# 2. Hooks — copy every hook script
mkdir -p "$DEST/hooks"
for h in "$REPO_DIR"/hooks/*; do
  cp "$h" "$DEST/hooks/$(basename "$h")"
  echo "  hook: $(basename "$h")"
done
chmod +x "$DEST"/hooks/*.sh 2>/dev/null || true

echo "Done. Add the SessionStart hook to your project's .claude/settings.json:"
echo '  { "hooks": { "SessionStart": [{ "type": "command", "command": "bash ~/.claude/hooks/session-context.sh" }] } }'
