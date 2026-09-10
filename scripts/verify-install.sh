#!/bin/bash
# verify-install.sh — INV-01
#
# Two claims, both actually tested:
#   1. A dry run writes NOTHING to the install destination.
#   2. The installer is idempotent — installing twice leaves identical state.
#
# WHY THIS SCRIPT EXISTS (2026-09-09)
# INV-01's original check was:
#     ./install.sh --dry-run && git status --porcelain | wc -l   → 0
# Two defects, both found by audit:
#   * install.sh writes to "$HOME/.claude" (install.sh:13, DEST). `git status` runs in the
#     REPO and cannot see that directory at all. A dry run that copied every file into
#     ~/.claude would still have printed 0. The check watched the wrong place entirely.
#   * `| wc -l` swallows the exit code — wc always exits 0 — so a crashed installer passed.
#   * Idempotence, half the invariant, was never tested by anything.
# Same defect class as INV-02's original blindness: a check that cannot observe the thing
# it is about.
#
# Exit 0 + "INSTALL OK", or exit 1 listing each failure.

set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

FAIL=0
DEST="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"

if [ ! -d "$DEST" ]; then
  echo "SKIP: no install destination at $DEST — nothing to verify"
  exit 0
fi

# Fingerprint the destination: path + size + mtime for every file the installer touches.
# Deliberately not a content hash — mtime catches a rewrite even when bytes are identical,
# which is the failure mode a dry run would exhibit.
# Watches the WHOLE destination, not just the directories the installer is known to write.
# An earlier version listed only skills/hooks/agents/rules and was mutation-tested with a
# file written to the destination ROOT, which it could not see. Naming the paths you expect
# to change means you cannot detect a change you did not expect — the same blindness INV-01
# and INV-02 both originally had. Excludes only paths that churn for unrelated reasons.
fingerprint() {
  find "$DEST" -type f \
       -not -path "*/projects/*" \
       -not -path "*/todos/*" \
       -not -path "*/shell-snapshots/*" \
       -not -path "*/statsig/*" \
       -not -path "*/plugins/cache/*" \
       -not -name ".credentials.json" \
       -not -name "*.bak-*" \
       -not -name "history.jsonl" \
       -printf '%p %s %T@\n' 2>/dev/null | sort
}
# --- claim 1: dry run writes nothing to DEST ---------------------------------
BEFORE=$(fingerprint)
REPO_BEFORE=$(git status --porcelain 2>/dev/null)

if ! bash install.sh --dry-run >/tmp/verify-install-dry.log 2>&1; then
  echo "FAIL: install.sh --dry-run exited non-zero"
  sed 's/^/    /' /tmp/verify-install-dry.log | tail -5
  FAIL=1
fi

AFTER=$(fingerprint)

if [ "$BEFORE" != "$AFTER" ]; then
  echo "FAIL: --dry-run modified the install destination ($DEST):"
  diff <(printf '%s\n' "$BEFORE") <(printf '%s\n' "$AFTER") | grep '^[<>]' | head -10 | sed 's/^/    /'
  FAIL=1
fi

# The repo must also be UNCHANGED BY THE DRY RUN. Deliberately a before/after comparison,
# not an absolute cleanliness assertion: asserting "the repo is pristine" would make this
# check impossible to pass during ordinary work, and a check you cannot run is a check that
# never runs. Snapshot is taken above, before install.sh is invoked.
if [ "$REPO_BEFORE" != "$(git status --porcelain 2>/dev/null)" ]; then
  echo "FAIL: --dry-run changed the repo working tree:"
  diff <(echo "$REPO_BEFORE") <(git status --porcelain 2>/dev/null) | grep "^[<>]" | head -5 | sed "s|^|    |"
  FAIL=1
fi

# --- claim 2: idempotence ----------------------------------------------------
# Opt-in: this performs REAL installs. Skipped unless explicitly requested, so the
# check is safe to run casually.
if [ "${VERIFY_INSTALL_IDEMPOTENCE:-0}" = "1" ]; then
  bash install.sh >/dev/null 2>&1 || { echo "FAIL: first real install exited non-zero"; FAIL=1; }
  ONE=$(fingerprint | sed 's/ [0-9.]*$//')     # drop mtime; compare path+size only
  bash install.sh >/dev/null 2>&1 || { echo "FAIL: second real install exited non-zero"; FAIL=1; }
  TWO=$(fingerprint | sed 's/ [0-9.]*$//')
  if [ "$ONE" != "$TWO" ]; then
    echo "FAIL: installer is not idempotent — file set or sizes changed between runs:"
    diff <(printf '%s\n' "$ONE") <(printf '%s\n' "$TWO") | grep '^[<>]' | head -10 | sed 's/^/    /'
    FAIL=1
  fi
else
  echo "note: idempotence check skipped (set VERIFY_INSTALL_IDEMPOTENCE=1 to run real installs)"
fi

if [ "$FAIL" -eq 0 ]; then
  echo "INSTALL OK"
  exit 0
fi
exit 1
