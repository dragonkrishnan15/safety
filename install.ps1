<#
.SYNOPSIS
    master-skill Universal Installer for Windows & PowerShell
.DESCRIPTION
    Installs master-skill rules and skills for Claude Code, Cursor, Windsurf,
    Google Antigravity / Gemini CLI, Cline, Roo Code, and GitHub Copilot.
.PARAMETER Scope
    'project' (current workspace) or 'global' (user profile across all projects). Default: 'project'.
.PARAMETER Target
    'auto' (auto-detect installed agents), 'all', or specific agent name. Default: 'auto'.
.EXAMPLE
    irm https://raw.githubusercontent.com/dragonkrishnan15/safety/main/install.ps1 | iex
#>
[CmdletBinding()]
param(
    [ValidateSet('project', 'global')]
    [string]$Scope = 'project',

    [ValidateSet('auto', 'all', 'cursor', 'windsurf', 'claude', 'gemini', 'cline', 'copilot')]
    [string]$Target = 'auto'
)

$ErrorActionPreference = 'Stop'
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Handle one-liner execution where script is piped (irm | iex)
if (-not $ScriptDir -or -not (Test-Path "$ScriptDir/SKILL.md")) {
    $TempRepo = Join-Path ([System.IO.Path]::GetTempPath()) "master-skill-install"
    Write-Host "[*] Fetching master-skill repository..." -ForegroundColor Cyan
    if (Test-Path $TempRepo) { Remove-Item -Recurse -Force $TempRepo }
    git clone --depth 1 https://github.com/dragonkrishnan15/safety.git $TempRepo
    $ScriptDir = $TempRepo
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " 🧠 master-skill Universal Installer (v5.1)" -ForegroundColor Green
Write-Host " Scope:  $Scope" -ForegroundColor Yellow
Write-Host " Target: $Target" -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan

function Copy-Config {
    param([string]$Src, [string]$Dest, [string]$Label)
    if (Test-Path $Src) {
        $DestDir = Split-Path -Parent $Dest
        if ($DestDir -and -not (Test-Path $DestDir)) {
            New-Item -ItemType Directory -Path $DestDir -Force | Out-Null
        }
        Copy-Item -Path $Src -Destination $Dest -Force
        Write-Host "  [OK] Installed $Label -> $Dest" -ForegroundColor Green
    } else {
        Write-Host "  [WARN] Missing source file $Src" -ForegroundColor DarkYellow
    }
}

$HomeDir = [Environment]::GetFolderPath('UserProfile')
$WorkDir = (Get-Location).Path

# 1. Google Gemini / Antigravity
if ($Target -in @('auto', 'all', 'gemini')) {
    if ($Scope -eq 'global' -or (Test-Path "$HomeDir\.gemini")) {
        $GeminiSkillDir = "$HomeDir\.gemini\config\skills\master-skill"
        if (-not (Test-Path $GeminiSkillDir)) { New-Item -ItemType Directory -Path $GeminiSkillDir -Force | Out-Null }
        Copy-Config "$ScriptDir\SKILL.md" "$GeminiSkillDir\SKILL.md" "Antigravity Global Skill"
        if (Test-Path "$ScriptDir\references") { Copy-Item -Path "$ScriptDir\references" -Destination $GeminiSkillDir -Recurse -Force }
        if (Test-Path "$ScriptDir\scripts") { Copy-Item -Path "$ScriptDir\scripts" -Destination $GeminiSkillDir -Recurse -Force }
        if (Test-Path "$ScriptDir\bin") { Copy-Item -Path "$ScriptDir\bin" -Destination $GeminiSkillDir -Recurse -Force }
        if (Test-Path "$ScriptDir\profiles") { Copy-Item -Path "$ScriptDir\profiles" -Destination $GeminiSkillDir -Recurse -Force }
        if (Test-Path "$ScriptDir\examples") { Copy-Item -Path "$ScriptDir\examples" -Destination $GeminiSkillDir -Recurse -Force }
        $AgyLegacyDir = "$HomeDir\.gemini\antigravity\skills\master-skill"
        if (Test-Path "$HomeDir\.gemini\antigravity") {
            if (-not (Test-Path $AgyLegacyDir)) { New-Item -ItemType Directory -Path $AgyLegacyDir -Force | Out-Null }
            Copy-Config "$ScriptDir\SKILL.md" "$AgyLegacyDir\SKILL.md" "Antigravity Fallback Skill"
        }
        Copy-Config "$ScriptDir\master-skill.md" "$HomeDir\.gemini\config\rules\master-skill.md" "Antigravity Global Rule"
        if (Test-Path "$HomeDir\.gemini\config\rules\claude-thinking.md") { Remove-Item -Force "$HomeDir\.gemini\config\rules\claude-thinking.md" 2>$null }
    }
    if ($Scope -eq 'project') {
        Copy-Config "$ScriptDir\SKILL.md" "$WorkDir\.agents\skills\master-skill\SKILL.md" "Antigravity Project Skill"
        Copy-Config "$ScriptDir\master-skill.md" "$WorkDir\.agents\rules\master-skill.md" "Antigravity Project Rule"
    }
}

# 2. Anthropic Claude Code
if ($Target -in @('auto', 'all', 'claude')) {
    if ($Scope -eq 'global') {
        Copy-Config "$ScriptDir\adapters\CLAUDE.md" "$HomeDir\.claude\CLAUDE.md" "Claude Code Global Memory"
    } else {
        Copy-Config "$ScriptDir\adapters\CLAUDE.md" "$WorkDir\CLAUDE.md" "Claude Code Workspace Memory"
    }
}

# 3. Cursor IDE
if ($Target -in @('auto', 'all', 'cursor')) {
    if ($Scope -eq 'global') {
        Copy-Config "$ScriptDir\adapters\.cursorrules" "$HomeDir\.cursorrules" "Cursor Global Rules"
    } else {
        Copy-Config "$ScriptDir\adapters\.cursorrules" "$WorkDir\.cursorrules" "Cursor Project Rules"
        Copy-Config "$ScriptDir\adapters\.cursorrules" "$WorkDir\.cursor\rules\master-skill.mdc" "Cursor MDC Rules"
    }
}

# 4. Windsurf IDE
if ($Target -in @('auto', 'all', 'windsurf')) {
    if ($Scope -eq 'global') {
        Copy-Config "$ScriptDir\adapters\.windsurfrules" "$HomeDir\.windsurfrules" "Windsurf Global Rules"
    } else {
        Copy-Config "$ScriptDir\adapters\.windsurfrules" "$WorkDir\.windsurfrules" "Windsurf Project Rules"
    }
}

# 5. Cline / Roo Code
if ($Target -in @('auto', 'all', 'cline')) {
    if ($Scope -eq 'global') {
        Copy-Config "$ScriptDir\adapters\.clinerules" "$HomeDir\.clinerules" "Cline Global Rules"
    } else {
        Copy-Config "$ScriptDir\adapters\.clinerules" "$WorkDir\.clinerules" "Cline Project Rules"
    }
}

# 6. GitHub Copilot
if ($Target -in @('auto', 'all', 'copilot')) {
    Copy-Config "$ScriptDir\adapters\COPILOT.md" "$WorkDir\.github\copilot-instructions.md" "GitHub Copilot Instructions"
}

# 7. Universal Agent Fallback
if ($Scope -eq 'project') {
    Copy-Config "$ScriptDir\adapters\AGENTS.md" "$WorkDir\AGENTS.md" "Universal AGENTS.md Workspace Spec"

    # 8. Git Pre-Commit Quality Gate (if in git repo)
    if (Test-Path "$WorkDir\.git") {
        $HookScript = "$ScriptDir\scripts\install_hooks.ps1"
        if (Test-Path $HookScript) {
            & powershell -ExecutionPolicy Bypass -File $HookScript 2>$null
            Write-Host "  [OK] Installed Git Pre-Commit Quality Gate -> .git/hooks/pre-commit" -ForegroundColor Green
        }
    }
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " [SUCCESS] master-skill is installed and ready!" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan
