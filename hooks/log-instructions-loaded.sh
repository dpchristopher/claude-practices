#!/bin/bash
# log-instructions-loaded.sh — InstructionsLoaded: append which context files loaded.
# Never blocks (always exit 0). Diagnostic only — catches a silently-unloaded INVARIANTS.md etc.
input="$(cat)"
paths="$(printf '%s' "$input" | grep -oE '"path"[[:space:]]*:[[:space:]]*"[^"]*"' | sed -E 's/.*"([^"]*)"$/\1/' | tr '\n' ',')"
[ -z "$paths" ] && paths="(none captured)"
mkdir -p .claude 2>/dev/null
printf '%s  loaded=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$paths" >> .claude/orchestration-log.txt 2>/dev/null
exit 0
