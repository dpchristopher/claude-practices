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

# --- direction 3: template -> DEPLOYED parity ------------------------------
# The template settings.json is the source of truth for which hooks are meant to
# be wired. This checks the machine's LIVE ~/.claude/settings.json against it.
#
# Why this direction exists: directions 1 and 2 compare files inside this repo to
# each other, so they pass even when the deployed kit wires none of them. That is
# exactly what happened — 8 hooks sat installed-but-unwired while INV-02 reported
# green. A check that cannot observe the deployed state cannot catch deployment
# drift. Skipped (not failed) when no deployed config exists, so CI stays green.
DEPLOYED="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/settings.json"
if [ -f "$DEPLOYED" ]; then
  TPL_HOOKS=$(grep -ohE '[a-zA-Z0-9_-]+\.(sh|ps1|js)' templates/.claude/settings.json 2>/dev/null | sort -u)
  for h in $TPL_HOOKS; do
    [ -f "$HOOKS_DIR/$h" ] || continue   # only kit-owned hooks
    if ! grep -q "$h" "$DEPLOYED"; then
      echo "FAIL: $h is wired in the template but NOT in the deployed config ($DEPLOYED)"
      FAIL=1
    fi
  done
else
  echo "SKIP: no deployed settings.json at $DEPLOYED — deployment parity not checked"
fi

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
