#!/bin/bash
# verify-hooks.sh — INV-02
#
# Two directions of parity:
#   1. Every hook referenced by settings.json or agent frontmatter EXISTS in hooks/.
#      (A dangling reference means a hook silently never fires.)
#   2. Every .sh hook has a .ps1 sibling where one is expected.
#      (Bash/PowerShell drift is a recurring hazard — session-context.sh gained a
#      feature in Wave 7 that .ps1 had to gain too.)
#
# Exit 0 + "HOOK PARITY OK", or exit 1 listing each mismatch.

set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

FAIL=0
HOOKS_DIR="hooks"

if [ ! -d "$HOOKS_DIR" ]; then
  echo "FAIL: no hooks/ directory"
  exit 1
fi

# --- direction 1: referenced -> exists -------------------------------------
# Collect every hook filename mentioned in settings.json or agent frontmatter.
REFS=$(grep -rhoE '[a-zA-Z0-9_-]+\.(sh|ps1)' \
         templates/.claude/settings.json \
         templates/.claude/agents/*.md 2>/dev/null | sort -u)

for ref in $REFS; do
  if [ ! -f "$HOOKS_DIR/$ref" ]; then
    echo "FAIL: referenced but missing from hooks/: $ref"
    FAIL=1
  fi
done

# --- direction 2: .sh/.ps1 parity ------------------------------------------
# Only enforced for hooks that already have a .ps1 sibling — we are not demanding
# every bash hook be ported, only that existing pairs do not drift apart.
for ps1 in "$HOOKS_DIR"/*.ps1; do
  [ -e "$ps1" ] || continue
  base=$(basename "$ps1" .ps1)
  if [ ! -f "$HOOKS_DIR/$base.sh" ]; then
    echo "FAIL: $base.ps1 has no .sh sibling"
    FAIL=1
  fi
done

if [ "$FAIL" -eq 0 ]; then
  echo "HOOK PARITY OK"
  exit 0
fi
exit 1
