# Example Workflows

Dynamic Workflows are JavaScript orchestration scripts (`.claude/workflows/*.js`) that spawn
many subagents via `agent()` / `pipeline()`, keeping intermediate results out of the main
context. They are **opt-in** — trigger with "use a workflow to ..." or the `ultracode` keyword.
Requires Claude Code v2.1.154+ on a paid plan.

These are **examples to adapt**, not always-on automation. Edit the agent prompts and the
check command for your repo.

- **`fan-out-audit.js`** — reviews every changed file in parallel, then merges findings into one
  ranked report. Good for a pre-PR sweep. Pairs with the Bob/Kevin review discipline.
- **`fix-until-green.js`** — the runnable form of the loop rule: run the project check, fix
  failures, repeat until it passes or two rounds make no progress (stuck-loop detection). Pass
  `{check:"pytest -q"}` to override the check command.

## Budget / safety (from the workflow docs)
- Hard caps: 16 concurrent / 1000 total agents per run.
- A "Large workflow" warning fires past 25 agents or ~1.5M projected tokens.
- Set a default ceiling with the Dynamic workflow size guideline in `/config` (`small`/`medium`/`large`).
- File-mutating workflows run in `acceptEdits`; scope them to a worktree or narrow tool allowlist.
