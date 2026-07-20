#!/bin/bash
# install.sh — register claude-practices skills, hooks, and agents into ~/.claude
# Idempotent: safe to run repeatedly. Run from the repo root.
#   --dry-run / -n : print what WOULD be copied, write nothing.
set -euo pipefail

DRY_RUN=0
case "${1:-}" in
  --dry-run|-n) DRY_RUN=1 ;;
esac

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
DEST="$HOME/.claude"
MANIFEST="$DEST/.claude-practices-install-manifest.txt"

if [ "$DRY_RUN" -eq 1 ]; then
  echo "DRY RUN — no files will be written."
fi
echo "Installing claude-practices from: $REPO_DIR"
echo "Into: $DEST"

# do_cp SRC DEST_PATH LABEL — copy (or preview) and record to the manifest
do_cp() {
  local src="$1" dst="$2" label="$3"
  if [ "$DRY_RUN" -eq 1 ]; then
    echo "  [dry-run] would install $label -> $dst"
  else
    cp -R "$src" "$dst"
    echo "  $label"
    echo "$dst" >> "$MANIFEST"
  fi
}

if [ "$DRY_RUN" -eq 0 ]; then
  mkdir -p "$DEST"
  : > "$MANIFEST"   # fresh manifest each run
  echo "# claude-practices install manifest — files this installer wrote. Generated $(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$MANIFEST"
fi

# 1. Skills
[ "$DRY_RUN" -eq 0 ] && mkdir -p "$DEST/skills"
for dir in "$REPO_DIR"/skills/*/; do
  name="$(basename "$dir")"
  [ "$DRY_RUN" -eq 0 ] && mkdir -p "$DEST/skills/$name"
  do_cp "$dir." "$DEST/skills/$name/" "skill: $name"
done

# 2. Hooks
[ "$DRY_RUN" -eq 0 ] && mkdir -p "$DEST/hooks"
for h in "$REPO_DIR"/hooks/*; do
  do_cp "$h" "$DEST/hooks/$(basename "$h")" "hook: $(basename "$h")"
done
[ "$DRY_RUN" -eq 0 ] && { chmod +x "$DEST"/hooks/*.sh 2>/dev/null || true; }

# 3. Agents
[ "$DRY_RUN" -eq 0 ] && mkdir -p "$DEST/agents"
for a in "$REPO_DIR"/templates/.claude/agents/*.md; do
  do_cp "$a" "$DEST/agents/$(basename "$a")" "agent: $(basename "$a")"
done

if [ "$DRY_RUN" -eq 1 ]; then
  echo "Dry run complete. Re-run without --dry-run to install."
else
  echo "Done. Manifest written to $MANIFEST"
  echo "Add the SessionStart hook to your project's .claude/settings.json:"
  echo '  { "hooks": { "SessionStart": [{ "type": "command", "command": "bash ~/.claude/hooks/session-context.sh" }] } }'
fi
