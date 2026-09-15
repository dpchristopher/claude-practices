#!/bin/bash
# review-triggers.sh — decides whether a finished gru-lite task gets a bob-verifier review.
#
# Bob on every small task costs a cold-start agent and finds nothing most of the time. Bob on no
# task loses the independent check that makes Gru's output better. So review scales with risk,
# and risk is COMPUTED from the change where it can be, not judged. (D-017.)
#
#   start
#       Records the task's starting commit inside .git (never in the working tree), so `check`
#       needs no shell variable — the Bash tool does not keep variables between calls.
#   check [--base REF] [--done-when-not-command] [--rough-build]
#       Prints "BOB: YES — <reasons>" or "BOB: NO — <what was measured>", and logs one line.
#   outcome found|clean|skipped [note]
#       After Bob runs (or is skipped), logs what happened. This is the calibration data.
#
# Triggers — any one means Bob:
#   size       more than GRU_LITE_MAX_LINES changed lines (default 100) or more than
#              GRU_LITE_MAX_FILES files (default 3). Both numbers are starting GUESSES; the log
#              exists to replace them with evidence.
#   risky      a changed path matches the built-in risky list, or a line of the project's
#              .claude/risky-paths.txt (one extended regex per line; # comments allowed)
#   invariant  a changed path is named in INVARIANTS.md — as a full path, as a backticked file
#              name, or inside a backticked glob or folder (`templates/rules/*`, `src/ledger/`)
#   judgment   --done-when-not-command: success can only be confirmed by judgment
#   rough      --rough-build: an attempt failed, was retried, or the approach changed
#   unknown    the change cannot be measured (not a repo, no valid base, git failed)
#
# The rule that matters most: a failure to MEASURE is "unknown -> review", never "measured zero
# -> no review". bob-verifier found two paths that broke it (an invalid base, and a base lost
# between tool calls) on this script's first review, 2026-09-13.
#
# Files the kit's own hooks generate never count (same list as session-context.sh, D-016).

set -uo pipefail

CONFIG="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
LOG="$CONFIG/gru-lite-log.md"
MAX_LINES="${GRU_LITE_MAX_LINES:-100}"
MAX_FILES="${GRU_LITE_MAX_FILES:-3}"
KIT_ARTIFACTS='^\.claude/(precompact-state\.md|orchestration-log\.txt|monthly-reports/)'
BUILTIN_RISKY='(^|/)(hooks|\.githooks|auth|security|secrets?|credentials?|migrations)/|(^|/)\.env|(^|/)settings(\.local)?\.json$|(^|/)INVARIANTS\.md$|^\.github/workflows/'
G="git -c core.quotePath=false"          # non-ASCII paths come back raw, not "quoted\303\245"

usage() {
  echo "usage: review-triggers.sh start" >&2
  echo "       review-triggers.sh check [--base REF] [--done-when-not-command] [--rough-build]" >&2
  echo "       review-triggers.sh outcome found|clean|skipped [note]" >&2
  exit 2
}

log_line() {
  mkdir -p "$CONFIG" 2>/dev/null
  [ -f "$LOG" ] || printf '# gru-lite review log\n\nOne line per decision, one per outcome. Read at calibration: drop a trigger that never finds anything; add one when a problem slips through.\n\n' > "$LOG"
  printf '%s\n' "$1" >> "$LOG"
}
repo_name() { basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"; }
now() { date '+%Y-%m-%d %H:%M'; }
join() { local IFS=';'; echo "$*"; }

cmd="${1:-}"; shift || true

case "$cmd" in
start)
  git rev-parse --git-dir >/dev/null 2>&1 || { echo "not a git repo — nothing to record; check will say BOB: YES (unknown)"; exit 0; }
  # Before the first commit there is no HEAD: record the empty tree, so everything counts.
  sha=$(git rev-parse -q --verify HEAD 2>/dev/null) || sha=$(git hash-object -t tree /dev/null)
  printf '%s\n' "$sha" > "$(git rev-parse --git-path gru-lite-base)"
  echo "gru-lite base recorded: $(git rev-parse --short "$sha")"
  exit 0
  ;;
outcome)
  result="${1:-}"; note="${2:-}"
  case "$result" in found|clean|skipped) ;; *) usage ;; esac
  log_line "| $(now) | $(repo_name) | outcome: $result | ${note//|//} |"
  # The outcome ends the task, so its recorded base ends too. Otherwise a later task that skips
  # `start` is silently measured from this one's base — weeks of merged work (/code-review).
  git rev-parse --git-dir >/dev/null 2>&1 && rm -f "$(git rev-parse --git-path gru-lite-base)"
  echo "logged: outcome $result"
  exit 0
  ;;
check) ;;
*) usage ;;
esac

BASE=""; BASE_GIVEN=0; JUDGED=0; ROUGH=0
while [ $# -gt 0 ]; do
  case "$1" in
    --base) [ $# -ge 2 ] || { echo "--base needs a value" >&2; usage; }
            BASE="$2"; BASE_GIVEN=1; shift 2 ;;
    --done-when-not-command) JUDGED=1; shift ;;
    --rough-build) ROUGH=1; shift ;;
    *) echo "unknown option: $1" >&2; usage ;;
  esac
done

REASONS=()
[ "$JUDGED" -eq 1 ] && REASONS+=("judgment (done-when is not a runnable check)")
[ "$ROUGH" -eq 1 ] && REASONS+=("rough (the build needed a retry or a change of approach)")

unknown() {   # unknown REASON — cannot measure, so review
  REASONS+=("unknown ($1)")
  echo "BOB: YES — $(join "${REASONS[@]}")"
  log_line "| $(now) | $(repo_name) | ? lines | ? files | $(join "${REASONS[@]}") | BOB: YES |"
  exit 0
}

git rev-parse --git-dir >/dev/null 2>&1 || unknown "not a git repo — cannot measure the change"
cd "$(git rev-parse --show-toplevel)" || unknown "cannot enter the repo root"

# Base, in order: --base; the commit recorded by `start`; the merge-base with a known default
# branch. An explicit base that does not resolve is NOT silently replaced by a guess.
if [ "$BASE_GIVEN" -eq 1 ] && [ -z "$BASE" ]; then BASE_GIVEN=0; fi     # --base "" = not given
if [ "$BASE_GIVEN" -eq 0 ]; then
  rec="$(git rev-parse --git-path gru-lite-base)"
  [ -f "$rec" ] && BASE=$(tr -d '[:space:]' < "$rec")
fi
if [ -z "$BASE" ]; then
  # A merge-base equal to HEAD means we ARE on that branch, and committed work would be invisible
  # (bob-verifier, second pass: 300 lines committed on master measured as 0). Skip it.
  default=$(git symbolic-ref -q --short refs/remotes/origin/HEAD 2>/dev/null)
  head=$(git rev-parse -q --verify HEAD 2>/dev/null)
  for ref in $default origin/main origin/master main master; do
    if git rev-parse --verify -q "$ref^{commit}" >/dev/null; then
      mb=$(git merge-base HEAD "$ref" 2>/dev/null) || continue
      [ "$mb" != "$head" ] && { BASE=$mb; break; }
    fi
  done
  [ -z "$BASE" ] && unknown "no base: run 'review-triggers.sh start' at the beginning of the task, or pass --base"
fi
git rev-parse --verify -q "$BASE^{commit}" >/dev/null || git rev-parse --verify -q "$BASE^{tree}" >/dev/null \
  || unknown "base '$BASE' is not a commit in this repo"

# Changed paths and line counts: base -> working tree (committed + uncommitted), plus untracked.
# --no-renames: a move is a delete plus an add, so BOTH paths are checked against the risk lists.
NUMSTAT=$($G diff --numstat --no-renames "$BASE" 2>/dev/null) || unknown "git diff against $BASE failed"
N_LINES=0
CHANGED=""
while IFS=$'\t' read -r add del path; do
  [ -z "${path:-}" ] && continue
  printf '%s' "$path" | grep -qE "$KIT_ARTIFACTS" && continue
  [ "$add" = "-" ] && add=0; [ "$del" = "-" ] && del=0     # binary: count the file, not lines
  N_LINES=$(( N_LINES + add + del ))
  CHANGED="${CHANGED}${path}"$'\n'
done <<< "$NUMSTAT"

while IFS= read -r path; do
  [ -z "$path" ] && continue
  printf '%s' "$path" | grep -qE "$KIT_ARTIFACTS" && continue
  if [ -f "$path" ] && grep -Iq . "$path" 2>/dev/null; then  # -I: binary files count 0 lines
    n=$(wc -l < "$path" | tr -d ' ')
    N_LINES=$(( N_LINES + ${n:-0} ))
  fi
  CHANGED="${CHANGED}${path}"$'\n'
done < <($G ls-files --others --exclude-standard 2>/dev/null)

N_FILES=$(printf '%s' "$CHANGED" | grep -c .)

if [ "$N_LINES" -gt "$MAX_LINES" ] || [ "$N_FILES" -gt "$MAX_FILES" ]; then
  REASONS+=("size ($N_LINES lines, $N_FILES files; limits $MAX_LINES/$MAX_FILES)")
fi

# Invariant references: backticked tokens that look like a path, file name, glob, or folder.
INV_TOKENS=""
# A leading "./" is dropped; a token of only wildcards ("*") would match every path, so it is skipped.
[ -f INVARIANTS.md ] && INV_TOKENS=$(grep -oE '`[^`[:space:]]+`' INVARIANTS.md | tr -d '`' | sed 's#^\./##' \
  | grep -E '[./*]' | grep -vE '^[*?]+$' | sort -u)

inv_match() {   # inv_match PATH — 0 if INVARIANTS.md names this path
  local p="$1" b tok
  b=$(basename "$p")
  [ -f INVARIANTS.md ] || return 1
  case "$p" in */*) grep -qF "$p" INVARIANTS.md && return 0 ;; esac   # full paths: literal mention
  while IFS= read -r tok; do
    [ -z "$tok" ] && continue
    [ "$p" = "$tok" ] || [ "$b" = "$tok" ] && return 0
    case "$tok" in
      # Globs first: `rules/*.md` also fits the folder-without-slash shape below (/code-review).
      *'*'*|*'?'*) # shellcheck disable=SC2053
             [[ "$p" == $tok ]] && return 0 ;;
      */) [ "${p#"$tok"}" != "$p" ] && return 0 ;;
      */*) [ "${p#"$tok/"}" != "$p" ] && return 0 ;;   # a folder written without its slash
    esac
  done <<< "$INV_TOKENS"
  return 1
}

RISKY_HITS=""; INV_HITS=""
CUSTOM=""
[ -f .claude/risky-paths.txt ] && CUSTOM=$(grep -vE '^[[:space:]]*(#|$)' .claude/risky-paths.txt | paste -sd'|' -)
while IFS= read -r path; do
  [ -z "$path" ] && continue
  if printf '%s' "$path" | grep -qE "$BUILTIN_RISKY" \
     || { [ -n "$CUSTOM" ] && printf '%s' "$path" | grep -qE "$CUSTOM"; }; then
    RISKY_HITS="${RISKY_HITS} ${path}"
  fi
  [ "$path" != "INVARIANTS.md" ] && inv_match "$path" && INV_HITS="${INV_HITS} ${path}"
done <<< "$CHANGED"
[ -n "$RISKY_HITS" ] && REASONS+=("risky path:$(echo $RISKY_HITS | cut -c1-120)")
[ -n "$INV_HITS" ] && REASONS+=("invariant file:$(echo $INV_HITS | cut -c1-120)")

if [ ${#REASONS[@]} -gt 0 ]; then
  VERDICT="BOB: YES — $(join "${REASONS[@]}")"
  TRIG_TEXT=$(join "${REASONS[@]}")
else
  VERDICT="BOB: NO — $N_LINES lines, $N_FILES files, no risky or invariant paths, done-when is a command"
  TRIG_TEXT=none
fi
echo "$VERDICT"
echo "  base: $(git rev-parse --short "$BASE")"
log_line "| $(now) | $(repo_name) | $N_LINES lines | $N_FILES files | $TRIG_TEXT | ${VERDICT%% —*} |"
exit 0
