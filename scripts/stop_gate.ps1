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

# 3. Contract Path Boundary & Diff Budget Check
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
        if ($contract.permitted_paths -and $changedFiles) {
            foreach ($file in $changedFiles) {
                $isPermitted = $false
                foreach ($permitted in $contract.permitted_paths) {
                    if ($file -like $permitted) {
                        $isPermitted = $true
                        break
                    }
                }
                if (-not $isPermitted) {
                    $Violations.Add("Violation of Task Contract: Path '$file' not in permitted_paths.")
                }
            }
        }
        if ($contract.max_diff_lines -and $ScorecardData -and $ScorecardData.lines_added) {
            if ($ScorecardData.lines_added -gt [int]$contract.max_diff_lines) {
                $Violations.Add("Violation of Diff Budget: Added $($ScorecardData.lines_added) lines, exceeding limit of $($contract.max_diff_lines).")
            }
        }
    } catch {
        $Violations.Add("Failed to parse Task Contract at ${ContractPath}: $_")
    }
}

# 4. Sensitive Secret & Token Scanner
$SecretPatterns = @(
    'ghp_[A-Za-z0-9]{36}',
    'github_pat_[A-Za-z0-9_]{82}',
    'sk-[A-Za-z0-9]{20,}',
    'sk-proj-[A-Za-z0-9\-_]{20,}',
    'sk-ant-[A-Za-z0-9\-_]{20,}',
    'AIza[0-9A-Za-z-_]{35}',
    'AKIA[0-9A-Z]{16}',
    'aws_secret_access_key\s*=\s*[A-Za-z0-9/+=]{40}',
    'hf_[A-Za-z0-9]{34}',
    'https://hooks\.slack\.com/services/T[A-Za-z0-9]+/B[A-Za-z0-9]+/[A-Za-z0-9]+',
    '(postgres|mysql|mongodb(\+srv)?):\/\/[^\s:]+:[^\s@]+@',
    '-----BEGIN [A-Z ]*PRIVATE KEY-----'
)
$diffContent = git diff -U0 HEAD -- ':!tests/fixtures/*' ':!tests/mocks/*' 2>$null
if ($diffContent) {
    foreach ($pattern in $SecretPatterns) {
        $matches = [regex]::Matches($diffContent, "^\+.*($pattern)", [System.Text.RegularExpressions.RegexOptions]::Multiline)
        if ($matches.Count -gt 0) {
            $Violations.Add("SECURITY ALERT: Detected potential sensitive secret/token matching pattern '$pattern' in git diff.")
        }
    }
}

# 5. Anti-Pattern & Code Invariant Checks (Swallowed Errors)
if ($diffContent) {
    $swallowedMatches = [regex]::Matches($diffContent, '^\+\s*(catch\s*\([^\)]*\)\s*\{\s*\}|except(\s+\w+)?:\s*(pass|\.\.\.))', [System.Text.RegularExpressions.RegexOptions]::Multiline)
    if ($swallowedMatches.Count -gt 0) {
        $Violations.Add("CODE INVARIANT VIOLATION: Detected swallowed exception/catch block without handling in diff additions.")
    }
}

# 6. Deterministic Test Suite Execution
$TestExitCode = 0
if ($TestCommand) {
    $null = & cmd.exe /c $TestCommand 2>&1
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
