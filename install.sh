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

# 2. Hook
mkdir -p "$DEST/hooks"
cp "$REPO_DIR/hooks/session-context.sh" "$DEST/hooks/session-context.sh"
chmod +x "$DEST/hooks/session-context.sh" || true
echo "  hook: session-context.sh"
cp "$REPO_DIR/hooks/session-context.ps1" "$DEST/hooks/session-context.ps1"
echo "  hook: session-context.ps1"

echo "Done. Add the SessionStart hook to your project's .claude/settings.json:"
echo '  { "hooks": { "SessionStart": [{ "type": "command", "command": "bash ~/.claude/hooks/session-context.sh" }] } }'
