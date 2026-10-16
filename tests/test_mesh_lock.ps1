<#
.SYNOPSIS
    Automated Integration Test for mesh_lock.ps1
#>
$ErrorActionPreference = 'Stop'
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$MeshScript = Join-Path $ScriptDir "..\scripts\mesh_lock.ps1"
$TempLock = Join-Path ([System.IO.Path]::GetTempPath()) "test-mesh-locks.json"

Write-Host "🧪 Running mesh_lock.ps1 Integration Test Suite..." -ForegroundColor Cyan

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

try {
    if (Test-Path $TempLock) { Remove-Item -Force $TempLock }

    # 1. Initial Status
    Assert-Test "Initial status returns active_locks_count 0" {
        $out = & powershell -ExecutionPolicy Bypass -File $MeshScript -Action status -LockFile $TempLock 2>&1
        $json = $out | ConvertFrom-Json
        if ($json.active_locks_count -ne 0) { throw "Expected 0 active locks" }
    }

    # 2. Acquire Lock
    Assert-Test "Agent-1 acquires lock successfully" {
        $out = & powershell -ExecutionPolicy Bypass -File $MeshScript -Action acquire -AgentId "agent-1" -Paths "src/services/**" -Task "DB upgrade" -LockFile $TempLock 2>&1
        $code = $LASTEXITCODE
        if ($code -ne 0) { throw "Expected exit 0, got $code" }
        $json = $out | ConvertFrom-Json
        if ($json.status -ne "ACQUIRED") { throw "Expected ACQUIRED, got $($json.status)" }
    }

    # 3. Collision Detection
    Assert-Test "Agent-2 encounters CONFLICT on overlapping path" {
        $out = & powershell -ExecutionPolicy Bypass -File $MeshScript -Action acquire -AgentId "agent-2" -Paths "src/services/user.ts" -Task "Fix auth" -LockFile $TempLock 2>&1
        $code = $LASTEXITCODE
        if ($code -ne 1) { throw "Expected exit 1 due to lock collision, got $code" }
        $json = $out | ConvertFrom-Json
        if ($json.status -ne "CONFLICT") { throw "Expected CONFLICT, got $($json.status)" }
        if ($json.conflicting_agent -ne "agent-1") { throw "Expected conflicting_agent agent-1" }
    }

    # 4. Release Lock
    Assert-Test "Agent-1 releases lock cleanly" {
        $out = & powershell -ExecutionPolicy Bypass -File $MeshScript -Action release -AgentId "agent-1" -LockFile $TempLock 2>&1
        $code = $LASTEXITCODE
        if ($code -ne 0) { throw "Expected exit 0 on release" }
        $json = $out | ConvertFrom-Json
        if ($json.status -ne "RELEASED") { throw "Expected RELEASED, got $($json.status)" }
    }

    # 5. Re-acquire after release
    Assert-Test "Agent-2 can acquire path after Agent-1 release" {
        $out = & powershell -ExecutionPolicy Bypass -File $MeshScript -Action acquire -AgentId "agent-2" -Paths "src/services/user.ts" -Task "Fix auth" -LockFile $TempLock 2>&1
        $code = $LASTEXITCODE
        if ($code -ne 0) { throw "Expected exit 0 on re-acquire" }
        $json = $out | ConvertFrom-Json
        if ($json.status -ne "ACQUIRED") { throw "Expected ACQUIRED, got $($json.status)" }
    }
} finally {
    if (Test-Path $TempLock) { Remove-Item -Force $TempLock }
}

Write-Host "`nMesh Lock Test Results: $Passed passed, $Failed failed." -ForegroundColor Cyan
if ($Failed -gt 0) { exit 1 } else { exit 0 }
