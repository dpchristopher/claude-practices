#!/bin/bash
# log-instructions-loaded.sh — InstructionsLoaded: append which context files loaded.
# Never blocks (always exit 0). Diagnostic only — catches a silently-unloaded rule file.
#
# FIXED 2026-09-09: fired correctly for months and logged only "(none captured)".
# It grepped for a "path" field. Claude Code's hooks documentation describes the
# InstructionsLoaded event and its matcher values (session_start, nested_traversal,
# path_glob_match, include, compact) but does NOT document a field naming the loaded
# files. Rather than guess a second field name and re-ship the same silent failure,
# this tries the plausible candidates and, when none match, records the payload's own
# top-level keys. The log then tells you the real shape on its next run.
input="$(cat)"

# Any *.md path anywhere in the payload, whatever key it sits under.
paths="$(printf '%s' "$input" \
  | grep -oE '"[^"]*\.(md|MD)"' | tr -d '"' | sort -u | tr '\n' ',' | sed 's/,$//')"

# Named candidates, in case the payload carries them without a .md suffix.
if [ -z "$paths" ]; then
  for key in path paths file files instructions loaded source sources; do
    v="$(printf '%s' "$input" | grep -oE "\"$key\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" \
         | sed -E 's/.*"([^"]*)"$/\1/' | tr '\n' ',' | sed 's/,$//')"
    [ -n "$v" ] && { paths="$v"; break; }
  done
fi

reason="$(printf '%s' "$input" | grep -oE '"(reason|matcher|load_reason)"[[:space:]]*:[[:space:]]*"[^"]*"' \
  | head -1 | sed -E 's/.*"([^"]*)"$/\1/')"

if [ -z "$paths" ]; then
  keys="$(printf '%s' "$input" | grep -oE '"[a-z_]+"[[:space:]]*:' | tr -d '":' | sort -u | tr '\n' ',' | sed 's/,$//')"
  paths="UNPARSED(keys=${keys:-none})"
fi

mkdir -p .claude 2>/dev/null
printf '%s  loaded=%s reason=%s\n' \
  "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$paths" "${reason:-?}" \
  >> .claude/orchestration-log.txt 2>/dev/null
exit 0
