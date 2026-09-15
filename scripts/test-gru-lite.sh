#!/bin/bash
# test-gru-lite.sh — behavioural tests for gru-lite's two mechanical parts:
#   1. skills/gru-lite/review-triggers.sh — decides whether Bob reviews a finished task
#   2. hooks/plan-router.sh               — routes a prompt to Gru, gru-lite triage, or nothing
#
# Each case builds a throwaway git repo, so nothing touches a real project.
# Mutation-tested 2026-09-13: each trigger was disabled in turn and its case went red (D-005).
#
# Exit 0 + "N passed, 0 failed", or exit 1.

set -uo pipefail
REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TRIG="${GRU_LITE_TRIGGERS:-$REPO_DIR/skills/gru-lite/review-triggers.sh}"
ROUTER="${GRU_LITE_ROUTER:-$REPO_DIR/hooks/plan-router.sh}"

P=0; F=0
ok() { P=$((P+1)); echo "  PASS  $1"; }
no() { F=$((F+1)); echo "  FAIL  $1 — $2"; }

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
export CLAUDE_CONFIG_DIR="$TMP/config"   # the log goes here, never to the real ~/.claude
mkdir -p "$CLAUDE_CONFIG_DIR"

# new_repo NAME — a repo with one commit on master; prints its path
new_repo() {
  local d="$TMP/$1"
  mkdir -p "$d" && cd "$d" || exit 1
  git init -q -b master . && git config user.email t@t && git config user.name t
  git config core.hooksPath /dev/null          # do not run a machine-wide pre-commit here
  printf 'a\n' > readme.txt && git add -A && git commit -qm init
  echo "$d"
}
lines() { local n=$1 i; for i in $(seq 1 "$n"); do echo "line $i"; done; }
decide() { bash "$TRIG" check --base "$BASE" "$@" 2>&1; }

echo "── review-triggers.sh ──"

d=$(new_repo small); BASE=$(git -C "$d" rev-parse HEAD); cd "$d"
lines 20 > app.py
out=$(decide); echo "$out" | grep -q "^BOB: NO" && ok "small change, no flags -> no Bob" || no "small change" "$out"

d=$(new_repo big_lines); BASE=$(git -C "$d" rev-parse HEAD); cd "$d"
lines 150 > app.py
out=$(decide); echo "$out" | grep -q "^BOB: YES" && echo "$out" | grep -q "size" \
  && ok "150 new lines (untracked) -> Bob, reason: size" || no "big by lines" "$out"

d=$(new_repo big_files); BASE=$(git -C "$d" rev-parse HEAD); cd "$d"
for f in a b c d; do echo x > "$f.py"; done; git add -A && git commit -qm four
out=$(decide); echo "$out" | grep -q "^BOB: YES" && echo "$out" | grep -q "size" \
  && ok "4 files, committed -> Bob, reason: size" || no "big by files" "$out"

d=$(new_repo risky); BASE=$(git -C "$d" rev-parse HEAD); cd "$d"
mkdir -p hooks && echo 'exit 0' > hooks/guard.sh
out=$(decide); echo "$out" | grep -q "^BOB: YES" && echo "$out" | grep -q "risky" \
  && ok "one line in hooks/ -> Bob, reason: risky" || no "risky path" "$out"

d=$(new_repo invariant); cd "$d"
printf 'INV-01: `src/ledger.py` totals must reconcile\n' > INVARIANTS.md && git add -A && git commit -qm inv
BASE=$(git rev-parse HEAD); mkdir -p src && echo 'x = 1' > src/ledger.py
out=$(decide); echo "$out" | grep -q "^BOB: YES" && echo "$out" | grep -q "invariant file" \
  && ok "file named in INVARIANTS.md -> Bob, reason: invariant" || no "invariant file" "$out"

d=$(new_repo custom); cd "$d"
mkdir -p .claude && echo '^client/' > .claude/risky-paths.txt && git add -A && git commit -qm cfg
BASE=$(git rev-parse HEAD); mkdir -p client && echo x > client/page.html
out=$(decide); echo "$out" | grep -q "^BOB: YES" && echo "$out" | grep -q "risky" \
  && ok "project risky-paths.txt honoured -> Bob" || no "custom risky path" "$out"

d=$(new_repo judged); BASE=$(git -C "$d" rev-parse HEAD); cd "$d"
echo x > app.py
out=$(decide --done-when-not-command); echo "$out" | grep -q "^BOB: YES" && echo "$out" | grep -q "judgment" \
  && ok "done-when not a command -> Bob, reason: judgment" || no "judgment flag" "$out"
out=$(decide --rough-build); echo "$out" | grep -q "^BOB: YES" && echo "$out" | grep -q "rough" \
  && ok "rough build -> Bob, reason: rough" || no "rough flag" "$out"

d=$(new_repo artifacts); BASE=$(git -C "$d" rev-parse HEAD); cd "$d"
mkdir -p .claude && lines 400 > .claude/orchestration-log.txt && lines 400 > .claude/precompact-state.md
out=$(decide); echo "$out" | grep -q "^BOB: NO" && ok "kit artifacts do not count toward size" || no "kit artifacts" "$out"

cd "$TMP" && mkdir -p notrepo && cd notrepo
out=$(bash "$TRIG" check 2>&1); echo "$out" | grep -q "^BOB: YES" && echo "$out" | grep -q "unknown" \
  && ok "not a git repo -> Bob (cannot measure, so review)" || no "not a repo" "$out"

d=$(new_repo logged); BASE=$(git -C "$d" rev-parse HEAD); cd "$d"
echo x > app.py; decide >/dev/null
bash "$TRIG" outcome clean "nothing found" >/dev/null 2>&1
LOG="$CLAUDE_CONFIG_DIR/gru-lite-log.md"
[ -f "$LOG" ] && grep -q "BOB: NO" "$LOG" && grep -q "outcome: clean" "$LOG" \
  && ok "decision and outcome both logged" || no "logging" "$(cat "$LOG" 2>/dev/null)"
bash "$TRIG" outcome maybe >/dev/null 2>&1 && no "outcome validation" "accepted 'maybe'" || ok "outcome rejects unknown values"

# ── Gaps found by bob-verifier, 2026-09-13. Each "measured zero" must become "review", never "no". ──
d=$(new_repo badbase); cd "$d"; mkdir -p hooks && lines 200 > hooks/a.sh && git add -A
out=$(bash "$TRIG" check --base deadbeef 2>&1); echo "$out" | grep -q "^BOB: YES" && echo "$out" | grep -q "is not a commit" \
  && ok "G1 invalid --base -> Bob (unknown), not 'measured zero'" || no "G1 invalid base" "$out"

d=$(new_repo trunkrepo); cd "$d"; git branch -m master trunk; git checkout -qb feat
lines 300 > big.py && git add -A && git commit -qm work
out=$(bash "$TRIG" check 2>&1); echo "$out" | grep -q "^BOB: YES" \
  && ok "G2 no --base, unguessable default branch -> Bob" || no "G2 unguessable base" "$out"

# On a "trunk" repo the base cannot be guessed, so only a recorded base can make this pass.
d=$(new_repo started); cd "$d"; git branch -m master trunk; git checkout -qb feat; bash "$TRIG" start >/dev/null
lines 300 > big.py && git add -A && git commit -qm work
out=$(bash "$TRIG" check 2>&1); echo "$out" | grep -q "^BOB: YES" && echo "$out" | grep -q "size" \
  && ok "G2 'start' records the base so check needs no shell variable" || no "G2 start/check" "$out"
[ -z "$(git status --porcelain)" ] && ok "G2 'start' leaves git status clean" || no "start pollutes status" "$(git status --porcelain)"

d=$(new_repo rename); cd "$d"; mkdir -p scripts && echo 'exit 0' > scripts/g.sh && git add -A && git commit -qm s
BASE=$(git rev-parse HEAD); mkdir -p hooks && git mv scripts/g.sh hooks/g.sh
out=$(decide); echo "$out" | grep -q "^BOB: YES" && echo "$out" | grep -q "risky" \
  && ok "G3 rename into hooks/ -> Bob" || no "G3 rename" "$out"

d=$(new_repo unicode); BASE=$(git -C "$d" rev-parse HEAD); cd "$d"
mkdir -p hooks && echo x > "hooks/gård.sh" && git add -A
out=$(decide); echo "$out" | grep -q "^BOB: YES" && echo "$out" | grep -q "risky" \
  && ok "G4 non-ASCII path in hooks/ -> Bob" || no "G4 non-ascii" "$out"

d=$(new_repo globinv); cd "$d"
printf 'INV-04: every file in `templates/.claude/rules/*` cites sources\n' > INVARIANTS.md && git add -A && git commit -qm inv
BASE=$(git rev-parse HEAD); mkdir -p templates/.claude/rules && echo x > templates/.claude/rules/planning.md
out=$(decide); echo "$out" | grep -q "^BOB: YES" && echo "$out" | grep -q "invariant file" \
  && ok "G5 folder-scoped invariant (glob) -> Bob" || no "G5 glob invariant" "$out"

d=$(new_repo baseinv); cd "$d"
printf 'INV-02: `ledger.py` must reconcile. Run `make check`.\n' > INVARIANTS.md && git add -A && git commit -qm inv
BASE=$(git rev-parse HEAD); mkdir -p src && echo x > src/ledger.py
out=$(decide); echo "$out" | grep -q "invariant file:.*ledger" && ok "invariant named by file name only -> Bob" || no "basename invariant" "$out"
echo x > make
out=$(decide); echo "$out" | grep -q "invariant file:.*make" && no "G7 substring" "'make' matched '\`make check\`'" || ok "G7 a file named 'make' does not match '\`make check\`'"

d=$(new_repo binary); BASE=$(git -C "$d" rev-parse HEAD); cd "$d"
head -c 200000 /dev/urandom > img.png
out=$(decide); echo "$out" | grep -q "^BOB: NO" && ok "G7 untracked binary counts as a file, not newline-lines" || no "G7 binary" "$out"

out=$(timeout 10 bash "$TRIG" check --base 2>&1); rc=$?
[ "$rc" -ne 124 ] && [ "$rc" -ne 0 ] && echo "$out" | grep -q "needs a value" && ok "G6 --base with no value errors instead of hanging" || no "G6 hang" "rc=$rc"

# ── Second bob-verifier pass. ──
d=$(new_repo onmaster); cd "$d"; mkdir -p hooks && lines 300 > hooks/big.sh && git add -A && git commit -qm work
out=$(bash "$TRIG" check 2>&1); echo "$out" | grep -q "^BOB: YES" \
  && ok "N1 committed on master, no start -> Bob (fallback base would be HEAD itself)" || no "N1 fallback == HEAD" "$out"

d="$TMP/unborn"; mkdir -p "$d" && cd "$d" && git init -q -b master . && git config user.email t@t && git config user.name t && git config core.hooksPath /dev/null
bash "$TRIG" start >/dev/null 2>&1; lines 300 > big.py && git add -A && git commit -qm first
out=$(bash "$TRIG" check 2>&1); echo "$out" | grep -q "^BOB: YES" && echo "$out" | grep -q "size" \
  && ok "N1 'start' before the first commit records the empty tree -> size counted" || no "N1 unborn" "$out"

d=$(new_repo dirtoken); cd "$d"
printf 'INV: `src/ledger` and `./install.sh` and a bare `*` wildcard\n' > INVARIANTS.md && git add -A && git commit -qm inv
BASE=$(git rev-parse HEAD); mkdir -p src/ledger && echo x > src/ledger/a.py
out=$(decide); echo "$out" | grep -q "invariant file:.*src/ledger/a.py" && ok "N3 folder token without trailing slash" || no "N3 folder no slash" "$out"
git add -A && git commit -qm a && BASE=$(git rev-parse HEAD); echo x > install.sh
out=$(decide); echo "$out" | grep -q "invariant file:.*install.sh" && ok "N3 ./install.sh token matches install.sh" || no "N3 ./ prefix" "$out"
git add -A && git commit -qm b && BASE=$(git rev-parse HEAD); echo x > notes.txt
out=$(decide); echo "$out" | grep -q "invariant file" && no "N4 bare *" "matched everything: $out" || ok "N4 a bare \`*\` token does not match every path"

echo "── plan-router.sh ──"
route() { printf '{"prompt":"%s"}' "$1" | bash "$ROUTER"; }

out=$(route "let's draft a plan for the tax engine"); echo "$out" | grep -q "PLANNING INTENT" \
  && ok "planning prompt -> Gru" || no "planning" "$out"
# This prompt matches BOTH patterns ("let's build " and "add"), so precedence is actually tested.
out=$(route "let's build a plan to add auth"); echo "$out" | grep -q "PLANNING INTENT" && ! echo "$out" | grep -q "BUILD INTENT" \
  && ok "prompt matching both -> Gru only" || no "planning precedence" "$out"
for p in "add a retry to the fetch client" "fix the date parsing bug" "yes build it" "can you refactor the loader" "implement csv export" \
         "can we make the bars above the threshold green" "set up the folder and fix that dirty repo" "ok fix all of tier one" \
         "fix all of tier one then we can talk about tier two" "yeah do whatever you need to make the repo clean"; do
  out=$(route "$p"); echo "$out" | grep -q "BUILD INTENT" && ok "build -> triage: $p" || no "build: $p" "silent"
done
# The second row is real false positives from the first version, measured on 300 past prompts.
for p in "what does this function do" "why did the test fail" "how do I add a hook" "should we build this" "explain the fix you made" "thanks" \
         "make sure we addressed everything" "what can I do right now to make progress" "lets talk through how we would build it" \
         "so then why does the tab say create pr" "can claude still work with the screen off" "do we build an agent or an mcp"; do
  out=$(route "$p"); [ -z "$out" ] && ok "silent: $p" || no "should be silent: $p" "$out"
done

# The real hook payload carries other keys; a path containing a build verb must not trigger.
out=$(printf '%s' '{"session_id":"s1","transcript_path":"/x/fix-build/t.jsonl","cwd":"/c/Dev/add-tools","hook_event_name":"UserPromptSubmit","prompt":"why is this slow"}' | bash "$ROUTER")
[ -z "$out" ] && ok "full payload: verbs in cwd/transcript_path ignored" || no "full payload" "$out"
out=$(printf '%s' '{"session_id":"s1","prompt":"fix the login redirect","cwd":"/c/Dev/app"}' | bash "$ROUTER")
echo "$out" | grep -q "BUILD INTENT" && ok "full payload: prompt not last key still routes" || no "prompt not last" "$out"

# Router gaps found by bob-verifier, plus one observed live (a task notification fired the triage).
out=$(printf '%s' '{"prompt":"the logs look weird.\nfix the parser"}' | bash "$ROUTER")
echo "$out" | grep -q "BUILD INTENT" && ok "R1 verb after an escaped newline routes" || no "R1 newline" "silent"
out=$(route "yes do it, add the tests"); echo "$out" | grep -q "BUILD INTENT" && ok "R2 'do it' is an imperative" || no "R2 do it" "silent"
out=$(printf '%s' '{"prompt":"say \"hi\", then fix the bug"}' | bash "$ROUTER")
echo "$out" | grep -q "BUILD INTENT" && ok "R3 escaped quote + comma keeps the whole prompt" || no "R3 escaped quote" "silent"
out=$(printf '%s' '{"cwd":"/c/Dev/draft a plan","prompt":"thanks"}' | bash "$ROUTER")
[ -z "$out" ] && ok "planning check reads the prompt only, not cwd" || no "planning reads cwd" "$out"
out=$(printf '%s' '{"prompt":"<system-reminder>\n<task-notification>agent finished. fix the base check</task-notification>"}' | bash "$ROUTER")
[ -z "$out" ] && ok "harness notifications are not user requests" || no "notification fired" "$out"
out=$(printf '%s' '{"prompt":"the file lives in c:\\dev\\","cwd":"C:\\Dev\\fix-tools"}' | bash "$ROUTER")
[ -z "$out" ] && ok "N2 prompt ending in an escaped backslash does not leak cwd" || no "N2 trailing backslash" "$out"

echo
echo "════ $P passed, $F failed ════"
[ "$F" -eq 0 ]
