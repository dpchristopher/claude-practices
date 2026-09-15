#!/bin/bash
# plan-router.sh — UserPromptSubmit: route a request to the right amount of planning.
#   planning intent -> Gru (gru-planner)
#   build intent    -> a one-line triage: trivial / gru-lite / Gru
# Planning wins when both match, so a prompt never gets two instructions.
#
# Build triage added 2026-09-13 (D-017). Output quality without Gru was noticeably lower, and Gru is
# too expensive for small and medium tasks. A skill that has to be remembered does not get used —
# feynman-explainer ran 0 times in 39 sessions — so the triage fires from here instead.
#
# Must never block a prompt: every path exits 0 and nothing is written to stderr.
input="$(cat)"
prompt="$(printf '%s' "$input" | tr '[:upper:]' '[:lower:]')"

# The prompt text only, so a word in cwd or transcript_path can't match. Escaped quotes become
# plain ones first, or '\"hi\", then' would end the field early; escaped newlines become spaces,
# or a verb opening a new line ("...weird.\nfix the parser") has no word boundary.
# An escaped backslash goes first, or a prompt ending in "\\" loses its closing quote (bob-verifier).
text="$(printf '%s' "$prompt" | sed -E 's/\\\\/\//g; s/\\"/'"'"'/g; s/\\n/ /g; s/^.*"prompt"[[:space:]]*:[[:space:]]*"//; s/"[[:space:]]*(,.*)?\}?[[:space:]]*$//')"

# Harness events (task notifications, system reminders, slash-command wrappers) arrive through this
# hook too. They are not requests. Observed live 2026-09-13: a background-task notification fired
# the build triage.
if printf '%s' "$text" | grep -qE '^[[:space:]]*<(system-reminder|task-notification|command-|local-command|bash-)'; then
  exit 0
fi

if printf '%s' "$text" | grep -qE "(draft|write|create|make) (an? |the )?plan|let'?s plan|plan (this|the|it) out|plan the |implementation plan|let'?s (build|design) "; then
  echo "PLANNING INTENT DETECTED — before drafting, delegate to Gru (gru-planner). Gru reads the project (CLAUDE.md, HANDOFF, META_ARCHITECTURE, INVARIANTS, rules, agents), runs an applicability pass over the whole kit, drafts a plan with everything explicit, self-audits against .claude/rules/planning.md, and hands it to Bob for an independent check. See .claude/rules/planning.md."
  exit 0
fi

BUILD_MSG="BUILD INTENT — if this asks for a change, triage in one line before starting: trivial (one obvious edit) -> just do it; small/medium -> follow /gru-lite; large, multi-subsystem, or an unexamined problem -> gru-planner. If it doesn't ask for a change, ignore this."
VERBS='build|implement|add|create|fix|refactor|rewrite|wire|migrate|set up|make'
IDIOMS='s/make (sure|progress|sense|certain)//g'

# Leading filler ("ok so why...", "yeah do...") is skipped before looking at how the message opens.
lead="$(printf '%s' "$text" | sed -E 's/^[[:space:]]*((ok|okay|so|well|and|but|also|then|hmm|yeah|yes|alright|right)[,.!]?[[:space:]]+)*//')"

# 1. Opens with a build verb -> a request, whatever follows ("fix tier one, then we can talk
#    about tier two"). Checked before the filters below for exactly that reason.
#    Idioms that only look like a verb ("make sure...") are removed first, here and in step 4.
if printf '%s' "$lead" | sed -E "$IDIOMS" | grep -qE "^(please |go ahead and |can you |could you )?($VERBS|delete|remove)\b"; then
  echo "$BUILD_MSG"; exit 0
fi

# 2. Questions and explanations stay silent: "how do I add a hook" is not a request to build one.
#    "do" only as a question ("do we...") — not an imperative ("do it", "do whatever you need").
if printf '%s' "$lead" | grep -qE '^(what|why|how|when|where|which|who|does|do (you|we|i|they)|did|is|are|was|should|would|could|explain|describe|tell me|show me|summari[sz]e|can (claude|it|i|this|that|they))\b'; then
  exit 0
fi

# 3. Discussion stays silent. Measured 2026-09-13 on 300 real prompts: the first version fired on
#    12% and about half were not build requests ("make sure...", "how do we build it", "lets chat").
if printf '%s' "$text" | grep -qE "let'?s (talk|chat|discuss|think)|talk (through|about)|brainstorm|look into|thoughts on|what do you think|do we (build|need|want)|should we|idea i had"; then
  exit 0
fi

# 4. A build verb anywhere, ignoring idioms that only look like one.
if printf '%s' "$text" | sed -E "$IDIOMS" | grep -qE "\b($VERBS)\b"; then
  echo "$BUILD_MSG"
fi
exit 0
