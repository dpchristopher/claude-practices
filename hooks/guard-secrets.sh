#!/bin/bash
# guard-secrets.sh — PreToolUse(Write|Edit): block secret-file writes AND secrets pasted into any file.
# Layer 1: path/filename patterns (secret-named files). Layer 2: content scan of the payload for
# high-confidence credential formats. Exit 2 blocks the tool call. Carve-out: .example/.template/.sample.
input="$(cat)"
path="$(printf '%s' "$input" | grep -oE '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed -E 's/.*"([^"]*)"$/\1/')"

# Carve-out: allow safe scaffolding templates (no real secrets in these)
if printf '%s' "$path" | grep -qiE '\.(example|template|sample)$'; then exit 0; fi

# Layer 1 — secret-named files (path/filename based)
if printf '%s' "$path" | grep -qiE '(^|/)\.env($|\.)|\.key$|\.pem$|/secrets/|(^|/)credentials(\.|$)'; then
  echo "Blocked: refusing to write to a secrets file ($path). Edit it manually if truly intended." >&2
  exit 2
fi

# Layer 2 — content scan: high-confidence credential formats anywhere in the write payload.
# Scans the raw stdin (covers Write 'content' and Edit 'new_string' without depending on exact field names).
if printf '%s' "$input" | grep -qE \
  -e 'AKIA[0-9A-Z]{16}' \
  -e 'ASIA[0-9A-Z]{16}' \
  -e 'sk-ant-[A-Za-z0-9_-]{20,}' \
  -e '\bsk-[A-Za-z0-9]{20,}\b' \
  -e 'gh[pousr]_[A-Za-z0-9]{20,}' \
  -e 'xox[baprs]-[A-Za-z0-9-]{10,}' \
  -e '-----BEGIN [A-Z ]*PRIVATE KEY-----' \
  -e 'AIza[0-9A-Za-z_-]{35}'; then
  echo "Blocked: this write appears to contain a hardcoded credential (API key / token / private key)." >&2
  echo "Move the secret to an environment variable or a gitignored .env, and reference it by name instead." >&2
  exit 2
fi
exit 0
