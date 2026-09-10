#!/bin/bash
# verify-kit.sh — end-to-end check that the DEPLOYED kit matches its doctrine.
#
# Different from verify-hooks.sh (INV-02), which checks template<->deployed parity for hooks
# only. This walks the whole surface: repo state, hook wiring, permissions, global rules,
# per-project stop-verify gates, secrets guards, invariants, and backup.
#
# WHAT IT CANNOT TELL YOU — read this before trusting a green run:
#   * It verifies hooks are WIRED, not that Claude Code FIRES them. Wiring is a line in JSON;
#     firing is only observable from a live session.
#   * It verifies rules are DEPLOYED, not OBEYED. A loaded rule is not a followed rule.
#   * The agent-teams env flag needs a restart to take effect; this sees the setting, not the effect.
# A check that cannot observe its own blind spots is how INV-02 reported green for months
# while 8 hooks fired nowhere. These are stated so this script does not repeat that.
#
# Run: bash scripts/verify-kit.sh
set -uo pipefail
P=0; F=0
ok(){ printf "  \033[32mPASS\033[0m  %s\n" "$1"; P=$((P+1)); }
no(){ printf "  \033[31mFAIL\033[0m  %s — %s\n" "$1" "$2"; F=$((F+1)); }
S=/c/Users/dpchr/.claude/settings.json

echo "── 1. Repo state ──"
cd /c/Dev/claude-practices
# Compare VERSION to the CHANGELOG's newest entry rather than a literal — a hardcoded
# version makes this check fail on every release, which trains you to ignore a red run.
CLV=$(grep -m1 -oE '^## \[[0-9]+\.[0-9]+\.[0-9]+\]' CHANGELOG.md | tr -d '#[] ')
[ "$(cat VERSION)" = "$CLV" ] && ok "VERSION $CLV matches CHANGELOG" || no "VERSION" "VERSION=$(cat VERSION) but CHANGELOG top=$CLV"
[ -z "$(git status --porcelain)" ] && ok "working tree clean" || no "tree" "dirty"
git fetch -q origin 2>/dev/null; [ "$(git rev-parse HEAD)" = "$(git rev-parse origin/master)" ] && ok "master == origin/master" || no "sync" "diverged"

echo "── 1b. No rule duplicated between global and template ──"
# A rule in BOTH global-rules/ and templates/.claude/rules/ means a scaffolded project loads
# it twice - once from ~/.claude/rules/ globally, once project-local - and the two copies
# drift. Found 2026-09-09: kit-maintenance.md and loop-cost-discipline.md had diverged by 21
# and 17 lines respectively, partly because a fix the night before was applied to only one.
dupe=0
for f in global-rules/*.md; do
  n=$(basename "$f"); [ "$n" = "README.md" ] && continue
  if [ -f "templates/.claude/rules/$n" ]; then
    no "duplicate rule: $n" "exists in BOTH global-rules/ and templates/.claude/rules/"
    dupe=1
  fi
done
[ "$dupe" -eq 0 ] && ok "no rule duplicated between global-rules/ and templates/"

echo "── 2. Hooks actually wired (not just installed) ──"
for h in guard-secrets post-edit-format plan-router subagent-audit guard-verdict log-instructions-loaded session-metrics-stub guard-agent-ownership guard-fanout session-context; do
  grep -q "$h" "$S" && ok "wired: $h" || no "wired: $h" "absent from settings.json"
done
for h in guard-readonly-bash stop-verify; do
  grep -q "\"bash ~/.claude/hooks/$h.sh\"" "$S" && no "NOT-global: $h" "wired globally (should not be)" || ok "correctly not global: $h"
done

echo "── 3. Hook files exist on disk ──"
for h in guard-secrets guard-verdict guard-agent-ownership session-metrics-stub stop-verify; do
  [ -f "/c/Users/dpchr/.claude/hooks/$h.sh" ] && ok "file: $h.sh" || no "file: $h.sh" "missing"
done

echo "── 4. Permissions ──"
python - "$S" <<'PY'
import json,io,sys
s=json.load(io.open(sys.argv[1],encoding='utf-8'))
d=s.get('permissions',{}).get('deny',[])
print(("  \033[32mPASS\033[0m  %d deny rules" % len(d)) if len(d)>=7 else ("  \033[31mFAIL\033[0m  deny rules: %d"%len(d)))
ad=s.get('permissions',{}).get('additionalDirectories',[])
import os
dead=[x for x in ad if not os.path.exists(x)]
print("  \033[32mPASS\033[0m  no dead additionalDirectories" if not dead else "  \033[31mFAIL\033[0m  dead dirs: %s"%dead)
env=s.get('env',{})
print("  \033[32mPASS\033[0m  agent-teams flag set" if env.get('CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS')=='1' else "  \033[31mFAIL\033[0m  agent-teams flag missing")
PY

echo "── 5. Global rules load every turn ──"
for r in kit-maintenance loop-cost-discipline output-accuracy; do
  [ -f "/c/Users/dpchr/.claude/rules/$r.md" ] && ok "rule: $r" || no "rule: $r" "not deployed"
done
grep -q "Agent ownership" /c/Users/dpchr/.claude/CLAUDE.md && ok "CLAUDE.md has ownership rule" || no "CLAUDE.md" "ownership rule missing"
! grep -rq "hooks are enforced" /c/Users/dpchr/.claude/rules/ /c/Users/dpchr/.claude/skills/ 2>/dev/null && ok "no stale 'hooks are enforced' claim" || no "stale claim" "still present"

echo "── 6. stop-verify gates ──"
for d in "/c/Dev/claude-practices" "/c/Dev/Civ_Project" "/c/Dev/Econ Project" "/c/Dev/Wealth Management Dash" "/c/Dev/STL_Project"; do
  n=$(basename "$d")
  c=$(python -c "
import json,io,sys
try: print(json.load(io.open(sys.argv[1],encoding='utf-8')).get('env',{}).get('PROJECT_CHECK_CMD',''))
except Exception: print('')" "$(cygpath -w "$d/.claude/settings.json" 2>/dev/null)" 2>/dev/null)
  if [ -z "$c" ]; then no "gate: $n" "no PROJECT_CHECK_CMD"; continue; fi
  ( cd "$d" && PROJECT_CHECK_CMD="$c" timeout 240 bash /c/Users/dpchr/.claude/hooks/stop-verify.sh >/dev/null 2>&1 ) \
    && ok "gate passes: $n" || no "gate: $n" "check FAILS -> would block every turn"
done

echo "── 7. Secrets guards ──"
for d in /c/Clients/Betsey_Brown_Travel /c/Clients/The_Caregiver_Club /c/Clients /c/Dev/claude-practices /c/Dev/Civ_Project; do
  [ -d "$d/.git" ] || continue
  hp=$(cd "$d" && git config --get core.hooksPath 2>/dev/null)
  [ -n "$hp" ] || [ -f "$d/.git/hooks/pre-commit" ] && ok "gitleaks: $(basename $d)" || no "gitleaks: $(basename $d)" "no hook"
done

echo "── 8. Clients doctrine ──"
[ -f /c/Clients/CLAUDE.md ] && ok "C:\Clients\CLAUDE.md exists" || no "Clients CLAUDE.md" "missing"
( cd /c/Clients && [ -z "$(git status --porcelain)" ] ) && ok "Clients repo clean" || no "Clients repo" "dirty"

echo "── 9. Invariants ──"
cd /c/Dev/claude-practices
bash scripts/verify-hooks.sh >/dev/null 2>&1 && ok "INV-02 hook parity" || no "INV-02" "fails"
bash scripts/verify-sources.sh >/dev/null 2>&1 && ok "INV-04 citations" || no "INV-04" "fails"

echo "── 10. Backup ──"
ls /c/Users/dpchr/OneDrive/claude-backups/*.tar.gz >/dev/null 2>&1 && ok "off-disk backup exists" || no "backup" "none found"

echo "── 11. Key rotation removed from handoff ──"
! grep -qiE "rotate.*(FRED|EIA|BEA)" .claude/HANDOFF.md && ok "no key-rotation nag in handoff" || no "handoff" "still mentions key rotation"

echo
echo "════ $P passed, $F failed ════"
