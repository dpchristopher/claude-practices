# Backup — What Git Covers and What It Doesn't

"It's in git" only backs up **committed, pushed** files. Two kinds of kit state are NOT in git
and live only on this machine:

1. **Agent memory** — `~/.claude/agent-memory/<agent>/` and per-project `.claude/agent-memory/`.
   Bob/Kevin/Gru write their own notes here across sessions. Losing it loses institutional memory.
2. **Local runtime state** — `~/.claude/settings.json` edits, `.claude/orchestration-log.txt`,
   and the install manifest.
3. **The global `~/.claude/CLAUDE.md`** — `templates/global-CLAUDE.md` is a generic scaffold with
   placeholders, not this machine's real file, and the template itself says not to commit the real
   one. So the hard rules and toolkit routing table that fire every turn exist in exactly one place.

**Where to put the archive:** not `~/claude-backups`. That is the same disk you are protecting
against. Pass a path that syncs or lives elsewhere — e.g. `./backup-state.sh ~/OneDrive/claude-backups`.
A backup on the failing drive is not a backup.

Committed-and-pushed files (templates, rules, agents, hooks, docs) ARE backed up by the GitHub
remote — that remote *is* your offsite backup. Push after every wave.

## Backing up the un-tracked state
Run `backup-state.sh` (on demand — there's no scheduler) to snapshot the un-tracked precious
paths into a timestamped archive under a directory you choose:
```
./backup-state.sh ~/claude-backups
```
This is a manual discipline, not automation. Run it before anything risky (a big refactor, an
OS reinstall, clearing `~/.claude`).

## Do NOT back up secrets
Never snapshot `.env`, `*.key`, or anything under `secrets/` into a backup archive. The backup
script deliberately skips those patterns.
