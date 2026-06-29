# install.ps1 — register claude-practices skills + SessionStart hook into ~/.claude
# Idempotent: safe to run repeatedly. Run from the repo root.
$ErrorActionPreference = "Stop"
$RepoDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Dest = Join-Path $env:USERPROFILE ".claude"

Write-Host "Installing claude-practices from: $RepoDir"
Write-Host "Into: $Dest"

# 1. Skills
$skillsDest = Join-Path $Dest "skills"
New-Item -ItemType Directory -Force $skillsDest | Out-Null
foreach ($dir in Get-ChildItem -Directory (Join-Path $RepoDir "skills")) {
    $target = Join-Path $skillsDest $dir.Name
    New-Item -ItemType Directory -Force $target | Out-Null
    Copy-Item -Recurse -Force (Join-Path $dir.FullName "*") $target
    Write-Host "  skill: $($dir.Name)"
}

# 2. Hook
$hooksDest = Join-Path $Dest "hooks"
New-Item -ItemType Directory -Force $hooksDest | Out-Null
Copy-Item -Force (Join-Path $RepoDir "hooks/session-context.sh") (Join-Path $hooksDest "session-context.sh")
Write-Host "  hook: session-context.sh"
Copy-Item -Force (Join-Path $RepoDir "hooks/session-context.ps1") (Join-Path $hooksDest "session-context.ps1")
Write-Host "  hook: session-context.ps1"

Write-Host 'Done. Add the SessionStart hook to your project .claude/settings.json:'
Write-Host '  { "hooks": { "SessionStart": [{ "type": "command", "command": "bash ~/.claude/hooks/session-context.sh" }] } }'
