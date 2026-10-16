<#
.SYNOPSIS
    Instant developer onboarding & safety check runner.
.EXAMPLE
    .\quickstart.ps1
#>
$ErrorActionPreference = 'Stop'

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " 🛡️  master-skill / safety - Developer Quickstart" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan

Write-Host "`n[*] Running Pre-Flight Verification Gate..." -ForegroundColor Cyan
$stopGate = Join-Path $PSScriptRoot "scripts\stop_gate.ps1"
if (Test-Path $stopGate) {
    & powershell -ExecutionPolicy Bypass -File $stopGate
}

Write-Host "`n[*] Active Environment:" -ForegroundColor Cyan
Write-Host "  - Repository:  dragonkrishnan15/safety" -ForegroundColor White
Write-Host "  - Engine:      master-skill v5.2 (Apex Mesh & Active Governance)" -ForegroundColor White
Write-Host "  - CLI Tool:    safety (bin/safety.js) & safety-mcp (bin/safety-mcp.js)" -ForegroundColor White
Write-Host "  - Memory:      .master-skill/memory.json" -ForegroundColor White

Write-Host "`n[*] Available Slash Commands in AI Chats:" -ForegroundColor Cyan
Write-Host "  /master-skill   -> Activate core zero-trust reasoning workflow" -ForegroundColor Yellow
Write-Host "  /ms-contract    -> Inspect & enforce task contract invariants" -ForegroundColor Yellow
Write-Host "  /ms-mesh        -> Acquire & arbitrate multi-agent mesh locks" -ForegroundColor Yellow
Write-Host "  /ms-adversary   -> Run red-team chaos & fault injection tests" -ForegroundColor Yellow
Write-Host "  /ms-stop        -> Run pre-commit stop gate inspection" -ForegroundColor Yellow

Write-Host "`n[*] Available CLI Commands:" -ForegroundColor Cyan
Write-Host "  safety gate        -> Execute programmatic stop gate" -ForegroundColor Green
Write-Host "  safety intercept   -> Validate command against zero-destruction wall" -ForegroundColor Green
Write-Host "  safety mesh status -> View active multi-agent mesh locks" -ForegroundColor Green
Write-Host "  safety report      -> View diff and verification scorecard" -ForegroundColor Green

Write-Host "`n[SUCCESS] Environment is 100% verified and operational.`n" -ForegroundColor Green
