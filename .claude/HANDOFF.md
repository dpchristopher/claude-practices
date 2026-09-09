# HANDOFF — 2026-08-22 (XPS migration: CLOSED)

## State
Migration from Surface complete and verified. Real work lives under C:\Dev (7 repos);
Desktop holds shortcuts only. Kit: 92 skills / 33 agents / 20 hooks (guard-fanout wired)
/ 2 rules (Wave-7) / plugins: superpowers deduped, legalzoom off. claude.ai plugin packs
pruned to Data only. Both .env files populated from the Surface sweep (no key rotation —
Daniel's decision). gitleaks fail-closed hook at C:\Setup\git-hooks on all 7 repos.
Chat transcripts restored + path-rewritten to C:\Dev (cosmetic: app history list still
doesn't surface them; Daniel accepts — progress lives in repo docs, verified 900/900).

## Leftovers (Daniel, optional)
- OneDrive backup toggle (Settings > Sync and backup > Manage backup > off x3)
- Taskbar pins; VS Code GitHub/Claude sign-ins on first launch
- "retire the ghosts": OneDrive\Desktop\Civ_Project + \claude-practices (empty shells,
  locked until app restart) -> C:\Setup\retired-desktop-empty-folders
- ~Aug 26: /fewer-permission-prompts (memory set)
- Windows connector "not compatible" in desktop app: unneeded; diagnose only if wanted

## Recommended next (from 2026-08-22 advice)
1. nbstripout in Rattlers repo  2. Deploy Econ dash (Streamlit Cloud) + Wealth Dash (Vercel)
3. Supabase MCP for Rattlers  4. Create econ-data-pipeline skill
