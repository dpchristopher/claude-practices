# global-rules/ — the always-loaded layer

Two doctrine layers, different reach:

| Layer | Source | Installs to | Loads |
|---|---|---|---|
| **Global** | `global-rules/*.md` | `~/.claude/rules/` | every project, every turn |
| **Project** | `templates/.claude/rules/*.md` | a project's `.claude/rules/` | that project only |

Global rules burn tokens on every turn of every project, so **keep them tiny** and put only
what must fire everywhere. Anything project-shaped belongs in `templates/.claude/rules/`.

Before Wave 7 these two files existed only on the author's machine — untracked, un-backed-up,
and not written by either installer. A reinstall could not restore them.
