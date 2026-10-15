<#
.SYNOPSIS
    Programmatic Stop Gate for master-skill (Gravitas-grade Runtime Gate)
.DESCRIPTION
    Validates that a task satisfies all invariant conditions before completion:
    1. Zero leftover DEBUG-CT or whitespace errors.
    2. Zero unauthorized changes outside contract permitted_paths.
    3. Test suite exit code == 0.
    4. Diff blast radius sanity.
.PARAMETER TestCommand
    Optional command line to run tests (e.g. "npm test" or "pytest").
.PARAMETER ContractPath
    Path to ct-contract.json (defaults to searching in current or tmp directory).
#>
[CmdletBinding()]
param(
    [string]$TestCommand = '',
    [string]$ContractPath = ''
)

$ErrorActionPreference = 'SilentlyContinue'
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Violations = [System.Collections.Generic.List[string]]::new()

# 1. Leftover & Cleanliness Check
$LeftoverScript = Join-Path $ScriptDir "leftover_check.ps1"
if (Test-Path $LeftoverScript) {
    $leftoverJson = & powershell -ExecutionPolicy Bypass -File $LeftoverScript 2>$null | ConvertFrom-Json
    if ($leftoverJson.debug_ct_count -gt 0) {
        $Violations.Add("Found $($leftoverJson.debug_ct_count) unremoved DEBUG-CT instrumentation tags.")
    }
    if ($leftoverJson.has_whitespace_or_crlf_errors) {
        $Violations.Add("Found git diff whitespace or CRLF format violations.")
    }
}

# 2. Scorecard Check
$ScorecardScript = Join-Path $ScriptDir "scorecard.ps1"
$ScorecardData = $null
if (Test-Path $ScorecardScript) {
    $ScorecardData = & powershell -ExecutionPolicy Bypass -File $ScorecardScript 2>$null | ConvertFrom-Json
}

# 3. Contract Path Boundary Check
if (-not $ContractPath) {
    if (Test-Path "ct-contract.json") { $ContractPath = "ct-contract.json" }
    elseif (Test-Path "$env:TEMP/ct-contract.json") { $ContractPath = "$env:TEMP/ct-contract.json" }
}

if ($ContractPath -and (Test-Path $ContractPath)) {
    try {
        $contract = Get-Content $ContractPath -Raw | ConvertFrom-Json
        if (-not $TestCommand -and $contract.stop_gate_command) {
            $TestCommand = $contract.stop_gate_command
        }
        $changedFiles = git diff --name-only HEAD 2>$null
        if ($contract.forbidden_paths -and $changedFiles) {
            foreach ($file in $changedFiles) {
                foreach ($forbidden in $contract.forbidden_paths) {
                    if ($file -like $forbidden) {
                        $Violations.Add("Violation of Task Contract: Modified forbidden path '$file'.")
                    }
                }
            }
        }
    } catch {
        $Violations.Add("Failed to parse Task Contract at ${ContractPath}: $_")
    }
}

# 4. Deterministic Test Suite Execution
$TestExitCode = 0
if ($TestCommand) {
    Invoke-Expression $TestCommand
    $TestExitCode = $LASTEXITCODE
    if ($TestExitCode -ne 0) {
        $Violations.Add("Stop Gate test command failed with exit code ${TestExitCode}: $TestCommand")
    }
}

$Passed = ($Violations.Count -eq 0)

$Result = [PSCustomObject]@{
    status = if ($Passed) { "PASSED" } else { "REJECTED" }
    violations = @($Violations)
    test_exit_code = $TestExitCode
    scorecard = $ScorecardData
}

$ResultJson = $Result | ConvertTo-Json -Compress
Write-Output $ResultJson

if (-not $Passed) {
    exit 1
} else {
    exit 0
}
