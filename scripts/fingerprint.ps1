$ErrorActionPreference = 'SilentlyContinue'
$gitBranch = git rev-parse --abbrev-ref HEAD 2>$null
$gitSha = git rev-parse HEAD 2>$null
$gitDirty = (git status --porcelain=v1 2>$null).Count
$nodeV = node -v 2>$null
$pythonV = python --version 2>$null
$pwshV = $PSVersionTable.PSVersion.ToString()
$pkgMgr = if (Test-Path 'pnpm-lock.yaml') { 'pnpm' } elseif (Test-Path 'yarn.lock') { 'yarn' } elseif (Test-Path 'package-lock.json') { 'npm' } elseif (Test-Path 'poetry.lock') { 'poetry' } elseif (Test-Path 'uv.lock') { 'uv' } else { 'none' }
[PSCustomObject]@{
    os = [System.Environment]::OSVersion.Platform.ToString()
    shell = "pwsh-$pwshV"
    git = @{ branch = "$gitBranch"; sha = "$gitSha"; dirty_count = [int]$gitDirty }
    runtimes = @{ node = "$nodeV"; python = "$pythonV" }
    package_manager = $pkgMgr
} | ConvertTo-Json -Compress
