# Rollback — Undoing a Bad Update

Three layers of undo, smallest to largest.

## 1. Within a session — `/rewind`
Claude Code checkpoints before each change. `/rewind` restores code, conversation, or both to
an earlier point. First reach for this when a change in the current session went wrong.

## 2. Source code — git
Every wave is committed and tagged (`v1.2.0`, `v1.3.0`, …). To go back to a prior version of
the KIT itself:
```
git checkout v1.2.0        # inspect / build from an earlier version
git revert <sha>           # undo a specific committed change, keeping history
```

## 3. The global install — the install manifest
`git checkout` changes the repo, but the kit also *copied files into* `~/.claude`. Checking out
an old tag does not remove what a newer `install.sh` already wrote there. To roll the global
install back cleanly:
1. `git checkout v1.2.0` (the version you want).
2. Re-run the installer: `./install.sh` (or `.\install.ps1`). It's idempotent and overwrites the
   global copies with the older version's files. Preview first with `./install.sh --dry-run`.
3. The installer writes `~/.claude/.claude-practices-install-manifest.txt` listing exactly what
   it placed — use it to see (or manually remove) files a newer version added that the older one
   doesn't ship.

## What is preserved across a rollback
Your **agent memory**, `HANDOFF.md`, `INVARIANTS.md`, and project files are NOT touched by the
installer — it only writes skills/hooks/agents into `~/.claude`. A rollback changes the tooling,
not your project state. (Back up memory separately — see `BACKUP.md`.)

## Tagging discipline
Tag each wave at merge so "the previous version" is always an addressable thing:
```
git tag v1.3.0 && git push origin v1.3.0
```
