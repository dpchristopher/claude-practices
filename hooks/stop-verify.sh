#!/bin/bash
# stop-verify.sh — Stop hook TEMPLATE (opt-in). Blocks turn-end until a project check passes.
# Set PROJECT_CHECK_CMD (e.g. "pytest -q && ruff check .") in your environment or edit below,
# then wire into settings.json hooks.Stop. No-op (exit 0) until configured.
CHECK_CMD="${PROJECT_CHECK_CMD:-}"
[ -z "$CHECK_CMD" ] && exit 0
LOG="${TMPDIR:-/tmp}/stop-verify.log"
if ! eval "$CHECK_CMD" >"$LOG" 2>&1; then
  echo "Stop blocked: project check failed — fix before finishing:" >&2
  tail -20 "$LOG" >&2
  exit 2
fi
exit 0
