#!/bin/bash
# post-edit-format.sh — PostToolUse(Write|Edit): auto-format the edited file if a formatter
# is installed. No-op-safe: does nothing (exit 0) when no formatter is available.
# Customize the case arms for your stack.
input="$(cat)"
file="$(printf '%s' "$input" | grep -oE '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed -E 's/.*"([^"]*)"$/\1/')"
[ -z "$file" ] && exit 0
[ -f "$file" ] || exit 0
case "$file" in
  *.py)                  command -v black    >/dev/null 2>&1 && black -q "$file"            >/dev/null 2>&1 ;;
  *.js|*.ts|*.tsx|*.jsx) command -v prettier >/dev/null 2>&1 && prettier --write "$file"    >/dev/null 2>&1 ;;
  *.go)                  command -v gofmt    >/dev/null 2>&1 && gofmt -w "$file"            >/dev/null 2>&1 ;;
esac
exit 0
