# session-context.ps1 — SessionStart context loader (Windows-native sibling of session-context.sh)
Write-Host "==========================================================="
Write-Host "SESSION CONTEXT"
Write-Host "==========================================================="

function Show-Head($file, $title, $n) {
  if (Test-Path $file) {
    Write-Host ""; Write-Host "## $title"
    Get-Content $file -TotalCount $n
  }
}

Show-Head "CLAUDE.md" "PROJECT RULES (CLAUDE.md - first 80 lines)" 80
Show-Head "META_ARCHITECTURE.md" "ARCHITECTURE SNAPSHOT (META_ARCHITECTURE.md - first 120 lines)" 120

$plan = Get-ChildItem ".claude/plans/*.md" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if ($plan) { Write-Host ""; Write-Host "## ACTIVE PLAN ($($plan.Name))"; Get-Content $plan.FullName -TotalCount 50 }

if (Test-Path "INVARIANTS.md") {
  Write-Host ""; Write-Host "## SYSTEM INVARIANTS (INVARIANTS.md - full; these must NOT break)"
  Get-Content "INVARIANTS.md"
}

if (Test-Path ".claude/HANDOFF.md") {
  Write-Host ""; Write-Host "## LAST SESSION - BLOCKERS & NEXT ACTION (.claude/HANDOFF.md)"
  Get-Content ".claude/HANDOFF.md"
} else {
  Write-Host ""; Write-Host "## HANDOFF"; Write-Host "WARN HANDOFF not found - new project or first session."
}

Write-Host ""
Write-Host "==========================================================="
Write-Host "CONTEXT LOADED. MANDATORY: 1) flag stale context 2) /session-workflow 3) /superpowers:brainstorming"
Write-Host "==========================================================="
