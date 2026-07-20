# install.ps1 — register claude-practices skills, hooks, and agents into ~/.claude
# Idempotent: safe to re-run. Run from the repo root.
#   -DryRun : print what WOULD be copied, write nothing.
param([switch]$DryRun)
$ErrorActionPreference = "Stop"
$RepoDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Dest = Join-Path $env:USERPROFILE ".claude"
$Manifest = Join-Path $Dest ".claude-practices-install-manifest.txt"

if ($DryRun) { Write-Host "DRY RUN - no files will be written." }
Write-Host "Installing claude-practices from: $RepoDir"
Write-Host "Into: $Dest"

if (-not $DryRun) {
  New-Item -ItemType Directory -Force $Dest | Out-Null
  "# claude-practices install manifest - files this installer wrote. Generated $(Get-Date -Format o)" | Set-Content $Manifest
}

function Install-Item($src, $dst, $label) {
  if ($DryRun) {
    Write-Host "  [dry-run] would install $label -> $dst"
  } else {
    Copy-Item -Recurse -Force $src $dst
    Write-Host "  $label"
    Add-Content $Manifest $dst
  }
}

# 1. Skills
$skillsDest = Join-Path $Dest "skills"
if (-not $DryRun) { New-Item -ItemType Directory -Force $skillsDest | Out-Null }
foreach ($dir in Get-ChildItem -Directory (Join-Path $RepoDir "skills")) {
  $target = Join-Path $skillsDest $dir.Name
  if (-not $DryRun) { New-Item -ItemType Directory -Force $target | Out-Null }
  Install-Item (Join-Path $dir.FullName "*") $target "skill: $($dir.Name)"
}

# 2. Hooks
$hooksDest = Join-Path $Dest "hooks"
if (-not $DryRun) { New-Item -ItemType Directory -Force $hooksDest | Out-Null }
foreach ($h in Get-ChildItem -File (Join-Path $RepoDir "hooks")) {
  Install-Item $h.FullName (Join-Path $hooksDest $h.Name) "hook: $($h.Name)"
}

# 3. Agents
$agentsDest = Join-Path $Dest "agents"
if (-not $DryRun) { New-Item -ItemType Directory -Force $agentsDest | Out-Null }
foreach ($a in Get-ChildItem -File (Join-Path $RepoDir "templates/.claude/agents")) {
  Install-Item $a.FullName (Join-Path $agentsDest $a.Name) "agent: $($a.Name)"
}

if ($DryRun) {
  Write-Host "Dry run complete. Re-run without -DryRun to install."
} else {
  Write-Host "Done. Manifest written to $Manifest"
  Write-Host 'Add the SessionStart hook to your project .claude/settings.json:'
  Write-Host '  { "hooks": { "SessionStart": [{ "type": "command", "command": "bash ~/.claude/hooks/session-context.sh" }] } }'
}
