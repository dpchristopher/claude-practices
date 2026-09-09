#!/bin/bash
# verify-sources.sh — INV-04
#
# The machine-checkable form of the kit's sourcing discipline: a platform limit
# number quoted in shipped doctrine must carry a SOURCES.md pointer.
#
# What counts as a "limit claim": a number immediately adjacent to a limit word
# (concurrent / total / agents / levels / deep / daily / children). This is
# deliberately narrow. Prose numbers ("the eight rules of a loop", "3 phases")
# must NOT trip it, or the check becomes noise and gets disabled — which is the
# real failure mode for a lint like this.
#
# What counts as "cited": the file contains a SOURCES.md pointer somewhere. This
# is file-level, not line-level, on purpose: section-level matching in bash is
# brittle, and a file-level pointer is enough to answer "where did this come from".
#
# Exit 0 + "CITATIONS OK", or exit 1 listing each uncited number.

set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

FAIL=0

TARGETS=$(ls templates/.claude/rules/*.md \
             templates/.claude/agents/*.md \
             global-rules/*.md 2>/dev/null)

if [ -z "$TARGETS" ]; then
  echo "FAIL: no doctrine files found to check"
  exit 1
fi

# A number adjacent to a limit word, in either order:
#   "20 concurrent" / "3 levels deep" / "up to 5 levels" / "16 concurrent agents"
#   "capped at 3-4 children" / "1,000 total"
PATTERN='([0-9][0-9,]*(-[0-9]+)?[[:space:]]+(concurrent|total|agents|levels|deep|daily|children))|((concurrent|nesting depth|depth|cap(ped)? at)[[:space:]]+[0-9][0-9,]*)'

for f in $TARGETS; do
  hits=$(grep -nEi "$PATTERN" "$f" 2>/dev/null | grep -v "SOURCES.md")
  [ -z "$hits" ] && continue

  if ! grep -q "SOURCES\.md" "$f"; then
    echo "FAIL: $f quotes a limit number with no SOURCES.md pointer:"
    echo "$hits" | sed 's/^/    /'
    FAIL=1
  fi
done

if [ "$FAIL" -eq 0 ]; then
  echo "CITATIONS OK"
  exit 0
fi
exit 1
