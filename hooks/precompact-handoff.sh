#!/bin/bash
# precompact-handoff.sh — PreCompact: snapshot session state to disk before compaction.
#
# WHY THIS EXISTS
# `session-workflow.md` requires writing `.claude/HANDOFF.md` at session end. That is a manual
# discipline, and the 2026-09-09 usage report measured how well manual session discipline
# actually holds: the kit's "every session, no exceptions" start protocol fired in 9 of 39
# sessions. A rule that depends on remembering is a rule that fires sometimes.
#
# Compaction is the moment state is most likely to be lost and least likely to be noticed —
# it happens mid-work, without being asked for. This writes a breadcrumb first.
#
# It deliberately does NOT try to write HANDOFF.md. A hook cannot summarise a session; only
# Claude can. What it can do is preserve the mechanical facts that are expensive to re-derive
# after context is gone: branch, HEAD, dirty files, recent commits, and the prior handoff.
# Claude reads this back via SessionStart (session-context.sh) or on request.
#
# Never blocks: always exit 0. Diagnostic/recovery only.
set -uo pipefail

OUT=".claude/precompact-state.md"
mkdir -p .claude 2>/dev/null || exit 0

# Only meaningful inside a git repo; elsewhere record what little there is and leave.
if ! git rev-parse --git-dir >/dev/null 2>&1; then
  printf '# Pre-compaction snapshot — %s\n\nNot a git repository. cwd: `%s`\n' \
    "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$PWD" > "$OUT" 2>/dev/null
  exit 0
fi

{
  printf '# Pre-compaction snapshot — %s\n\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  printf '> Written automatically by `precompact-handoff.sh` when context was about to be\n'
  printf '> compacted. These are the mechanical facts that are expensive to re-derive once\n'
  printf '> the conversation is gone. It is NOT a handoff — a hook cannot summarise intent.\n\n'

  printf '## Git\n\n'
  printf -- '- branch: `%s`\n' "$(git branch --show-current 2>/dev/null || echo '(detached)')"
  printf -- '- HEAD: `%s`\n' "$(git log --oneline -1 2>/dev/null)"
  printf -- '- upstream: `%s`\n' "$(git status -sb 2>/dev/null | head -1)"

  dirty=$(git status --porcelain 2>/dev/null)
  if [ -n "$dirty" ]; then
    printf -- '- **uncommitted changes (%s files):**\n\n' "$(printf '%s\n' "$dirty" | wc -l | tr -d ' ')"
    printf '%s\n' "$dirty" | head -25 | sed 's/^/      /'
  else
    printf -- '- working tree clean\n'
  fi

  printf '\n## Commits this session (last 10)\n\n'
  git log --oneline -10 2>/dev/null | sed 's/^/- /'

  if [ -f .claude/HANDOFF.md ]; then
    printf '\n## Prior HANDOFF.md — first 25 lines\n\n'
    head -25 .claude/HANDOFF.md | sed 's/^/> /'
  fi
} > "$OUT" 2>/dev/null

exit 0
