#!/bin/bash
# file-sweep.sh — one-file-at-a-time review sweep.
#
# Nicholas Carlini's method, as described by Thomas Ptacek (sockpuppet.org): instead of asking
# for a whole-codebase review, loop over files and ask the same narrow question about each one.
# Cross-checked three ways during the 2026-09-08 research sweep.
#
# WHY IT WORKS, and why it is not just "ask Claude to review the repo"
# A whole-repo prompt buries each file in the context of every other file, and the model
# prioritises. One file per call means every file gets the same attention and nothing is
# skipped because something else looked more interesting. It is slower and more thorough, and
# it is exactly the shape the kit already prefers: narrow, verifiable, independently checkable.
#
# This script does NOT call a model. It prints the sweep commands so you can review them,
# pipe them, or run them one at a time. Generating work to approve beats a script that
# silently spends money.
#
# Usage:
#   bash scripts/file-sweep.sh <glob> "<question>"        # print the commands
#   bash scripts/file-sweep.sh <glob> "<question>" --run  # actually run them, serially
#
# Examples:
#   bash scripts/file-sweep.sh 'mod/**/*.lua' 'Does this file call any API that does not exist?'
#   bash scripts/file-sweep.sh 'pages/*.py' 'Is there an unhandled failure path here?'
set -uo pipefail

GLOB="${1:-}"
QUESTION="${2:-}"
RUN="${3:-}"

if [ -z "$GLOB" ] || [ -z "$QUESTION" ]; then
  sed -n '2,25p' "$0" | sed 's/^# \?//'
  exit 1
fi

# shellcheck disable=SC2086
FILES=$(ls $GLOB 2>/dev/null)
[ -z "$FILES" ] && { echo "No files matched: $GLOB"; exit 1; }

N=$(printf '%s\n' "$FILES" | grep -c .)
echo "# $N files matched. Question: $QUESTION" >&2

if [ "$RUN" != "--run" ]; then
  echo "# Printing commands only. Append --run to execute serially." >&2
  echo >&2
fi

i=0
printf '%s\n' "$FILES" | while IFS= read -r f; do
  [ -f "$f" ] || continue
  i=$((i+1))
  cmd="claude -p \"$QUESTION Answer only about this one file. If nothing is wrong, reply exactly NOTHING FOUND.\" < \"$f\""
  if [ "$RUN" = "--run" ]; then
    echo "── [$i/$N] $f" >&2
    out=$(claude -p "$QUESTION Answer only about this one file. If nothing is wrong, reply exactly NOTHING FOUND." < "$f" 2>&1)
    case "$out" in
      *"NOTHING FOUND"*) : ;;                      # silence on clean files is the point
      *) printf '\n=== %s ===\n%s\n' "$f" "$out" ;;
    esac
  else
    echo "$cmd"
  fi
done

exit 0
