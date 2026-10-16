<#
.SYNOPSIS
    Automated Integration Test for stop_gate.ps1
#>
$ErrorActionPreference = 'Stop'
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$StopGateScript = Join-Path $ScriptDir "..\scripts\stop_gate.ps1"

Write-Host "🧪 Running stop_gate.ps1 Integration Test Suite..." -ForegroundColor Cyan

$Passed = 0
$Failed = 0

function Assert-Test {
    param([string]$Name, [scriptblock]$Block)
    try {
        & $Block
        Write-Host "  ✅ [PASS] $Name" -ForegroundColor Green
        $global:Passed++
    } catch {
        Write-Host "  ❌ [FAIL] $Name : $_" -ForegroundColor Red
        $global:Failed++
    }
}

# 1. Clean run test
Assert-Test "Clean state should exit 0 with PASSED status" {
    $out = & powershell -ExecutionPolicy Bypass -File $StopGateScript 2>&1
    $code = $LASTEXITCODE
    if ($code -ne 0) { throw "Expected exit 0, got $code. Output: $out" }
    $json = $out | ConvertFrom-Json
    if ($json.status -ne "PASSED") { throw "Expected PASSED, got $($json.status)" }
}

# 2. Test command failure propagation
Assert-Test "Failing test command should exit 1 with REJECTED status" {
    $out = & powershell -ExecutionPolicy Bypass -File $StopGateScript -TestCommand "exit 42" 2>&1
    $code = $LASTEXITCODE
    if ($code -ne 1) { throw "Expected exit 1, got $code" }
    $json = $out | ConvertFrom-Json
    if ($json.status -ne "REJECTED") { throw "Expected REJECTED, got $($json.status)" }
    if ($json.test_exit_code -ne 42) { throw "Expected test_exit_code 42, got $($json.test_exit_code)" }
}

# 3. Contract forbidden paths check
Assert-Test "Forbidden path contract violation triggers REJECTED" {
    $tempContract = Join-Path ([System.IO.Path]::GetTempPath()) "test-contract.json"
    $contractData = @{
        task_id = "TEST-01"
        forbidden_paths = @("scripts/**")
    } | ConvertTo-Json
    Set-Content -Path $tempContract -Value $contractData -Encoding UTF8

    $targetFile = Join-Path $ScriptDir "..\scripts\scorecard.ps1"
    $originalContent = [System.IO.File]::ReadAllText($targetFile)

    try {
        [System.IO.File]::AppendAllText($targetFile, "`n# test diff for contract check`n")
        $out = & powershell -ExecutionPolicy Bypass -File $StopGateScript -ContractPath $tempContract 2>&1
        $code = $LASTEXITCODE
        if ($code -ne 1) { throw "Expected exit 1 due to forbidden path modification, got $code. Output: $out" }
        $json = $out | ConvertFrom-Json
        if ($json.status -ne "REJECTED") { throw "Expected REJECTED status, got $($json.status)" }
    } finally {
        [System.IO.File]::WriteAllText($targetFile, $originalContent)
        if (Test-Path $tempContract) { Remove-Item -Force $tempContract }
    }
}

Write-Host "`nStop Gate Test Results: $Passed passed, $Failed failed." -ForegroundColor Cyan
if ($Failed -gt 0) { exit 1 } else { exit 0 }
