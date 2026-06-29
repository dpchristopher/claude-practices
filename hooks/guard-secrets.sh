#!/bin/bash
# guard-secrets.sh — PreToolUse(Write|Edit): block writes to secret files.
# Defense-in-depth alongside the Read(.env) deny rules. Exit 2 blocks the tool call.
input="$(cat)"
path="$(printf '%s' "$input" | grep -oE '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed -E 's/.*"([^"]*)"$/\1/')"
# Carve-out: allow safe scaffolding templates (no real secrets in these)
if printf '%s' "$path" | grep -qiE '\.(example|template|sample)$'; then exit 0; fi
if printf '%s' "$path" | grep -qiE '(^|/)\.env($|\.)|\.key$|\.pem$|/secrets/|credentials'; then
  echo "Blocked: refusing to write to a secrets file ($path). Edit it manually if truly intended." >&2
  exit 2
fi
exit 0
