#!/bin/bash
# guard-readonly-bash.sh — PreToolUse(Bash) guard for read-only reviewer agents.
# Blocks obviously state-mutating shell commands. Exit 2 blocks. Read-only inspection passes.
input="$(cat)"
cmd="$(printf '%s' "$input" | grep -oE '"command"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed -E 's/.*"([^"]*)"$/\1/')"
if printf '%s' "$cmd" | grep -qE '(^|[;&| ])(rm|mv|cp|dd|mkfs|chmod|chown|kill|truncate)([ ]|$)|>[^&]|>>|git[[:space:]]+(commit|push|reset|checkout|rm|clean)|npm[[:space:]]+(install|i|publish)|pip[[:space:]]+install'; then
  echo "Blocked: this agent is read-only and may not run state-mutating shell commands ($cmd)." >&2
  exit 2
fi
exit 0
