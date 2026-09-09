# Secret Protection — Layered Defense

Secrets leak in three ways. This kit defends each layer; none alone is enough.

## Layer 1 — Reads blocked (settings.json)
`.claude/settings.json` denies `Read(.env)`, `Read(**/*.key)`, `Read(**/*.pem)`,
`Read(**/secrets/**)`, `Read(**/credentials*)`. Claude can't pull a secret file into context.

## Layer 2 — Writes blocked (guard-secrets.sh, PreToolUse hook)
Fires on every Write/Edit. Blocks (a) writes to secret-*named* files, and (b) writes whose
*content* contains a high-confidence credential format (AWS `AKIA…`, `sk-ant-…`, GitHub
`ghp_…`, Slack `xox…`, private-key headers, Google `AIza…`). This is the layer that catches
a key hardcoded into ordinary source. Deterministic — runs as code every time.

## Layer 3 — Commit-time backstop (pre-commit + gitleaks)
`.pre-commit-config.yaml` runs gitleaks on every `git commit`. Set it up once per clone:
`pip install pre-commit && pre-commit install`. Bypass a specific commit with `SKIP=gitleaks git commit`.

## One-time history sweep
Layers 2–3 only guard *new* writes/commits. To catch secrets already sitting in git history:
```
gitleaks git --log-opts="--all" -v
```
Run this once on any repo before you trust it clean. If it finds something, the secret is in
history and must be rotated (deleting the file does not remove it from past commits).

## Golden rule
No real secret ever belongs in a tracked file. Put it in a gitignored `.env`, reference it by
name (`os.getenv("API_KEY")`), and commit only a `.env.example` with blank placeholders.
