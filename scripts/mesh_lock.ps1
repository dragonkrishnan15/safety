<#
.SYNOPSIS
    Multi-Agent Mesh Locking Protocol for master-skill / safety
.DESCRIPTION
    Provides decentralized, atomic lock arbitration across concurrent AI agents
    (Cursor, Claude Code, Antigravity, Cline) to prevent conflicting edits.
.PARAMETER Action
    acquire, release, status, or clean. Default: status.
.PARAMETER AgentId
    Unique identifier of the AI agent (e.g. "cursor-agent-1", "claude-code").
.PARAMETER Paths
    One or more relative file/directory paths to lock.
.PARAMETER Task
    Brief summary of the operation being performed.
.PARAMETER TtlSeconds
    Lock time-to-live in seconds before auto-expiration (default: 1800 / 30m).
.PARAMETER LockFile
    Optional custom path to the mesh-locks.json file.
#>
[CmdletBinding()]
param(
    [ValidateSet('acquire', 'release', 'status', 'clean')]
    [string]$Action = 'status',

    [string]$AgentId = '',
    [string[]]$Paths = @(),
    [string]$Task = '',
    [int]$TtlSeconds = 1800,
    [string]$LockFile = ''
)

$ErrorActionPreference = 'Stop'

# Determine Lock File Location
if (-not $LockFile) {
    $Dir = ".master-skill"
    if (-not (Test-Path $Dir)) {
        New-Item -ItemType Directory -Path $Dir -Force | Out-Null
    }
    $LockFile = Join-Path $Dir "mesh-locks.json"
}

# Load or Initialize Lock Database
$now = [DateTime]::UtcNow
$lockDb = @{ version = "1.0"; locks = @() }

if (Test-Path $LockFile) {
    try {
        $content = Get-Content $LockFile -Raw
        if ($content -and $content.Trim()) {
            $parsed = $content | ConvertFrom-Json
            if ($parsed.locks) {
                $lockDb.locks = @($parsed.locks)
            }
        }
    } catch {
        # Corrupt file; start fresh
        $lockDb.locks = @()
    }
}

# Helper to filter active locks
function Get-ActiveLocks {
    param([array]$Locks, [DateTime]$CurrentTime)
    $active = [System.Collections.Generic.List[object]]::new()
    foreach ($l in $Locks) {
        $acquired = [DateTime]::Parse($l.acquired_at)
        $ttl = if ($l.ttl_seconds) { [int]$l.ttl_seconds } else { 1800 }
        $expires = $acquired.AddSeconds($ttl)
        if ($expires -gt $CurrentTime) {
            $active.Add($l)
        }
    }
    return $active
}

# Helper to check path collision
function Test-PathCollision {
    param([string]$PathA, [string]$PathB)
    $normA = $PathA.Replace('\', '/').TrimStart('./')
    $normB = $PathB.Replace('\', '/').TrimStart('./')
    if ($normA -eq $normB) { return $true }
    if ($normA.EndsWith('/*') -or $normA.EndsWith('/**')) {
        $prefix = $normA.TrimEnd('*').TrimEnd('/')
        if ($normB.StartsWith($prefix)) { return $true }
    }
    if ($normB.EndsWith('/*') -or $normB.EndsWith('/**')) {
        $prefix = $normB.TrimEnd('*').TrimEnd('/')
        if ($normA.StartsWith($prefix)) { return $true }
    }
    return $false
}

switch ($Action) {
    'acquire' {
        if (-not $AgentId) { throw "AgentId is required for acquire." }
        if (-not $Paths -or $Paths.Count -eq 0) { throw "At least one path is required for acquire." }

        $activeLocks = Get-ActiveLocks -Locks $lockDb.locks -CurrentTime $now

        # Check for conflicts
        foreach ($p in $Paths) {
            foreach ($lock in $activeLocks) {
                if ($lock.agent_id -ne $AgentId) {
                    foreach ($existingPath in $lock.paths) {
                        if (Test-PathCollision -PathA $p -PathB $existingPath) {
                            $res = [PSCustomObject]@{
                                status = "CONFLICT"
                                agent_id = $AgentId
                                conflicting_agent = $lock.agent_id
                                conflicting_path = $p
                                held_path = $existingPath
                                acquired_at = $lock.acquired_at
                                task = $lock.task
                            }
                            Write-Output ($res | ConvertTo-Json -Compress)
                            exit 1
                        }
                    }
                }
            }
        }

        # Remove previous locks by same agent on these paths, then append
        $updatedLocks = [System.Collections.Generic.List[object]]::new()
        foreach ($l in $activeLocks) {
            if ($l.agent_id -ne $AgentId) {
                $updatedLocks.Add($l)
            }
        }

        $newLock = [PSCustomObject]@{
            agent_id = $AgentId
            paths = @($Paths)
            acquired_at = $now.ToString("o")
            ttl_seconds = $TtlSeconds
            task = $Task
        }
        $updatedLocks.Add($newLock)

        $lockDb.locks = @($updatedLocks)
        $lockDb | ConvertTo-Json -Depth 5 | Set-Content -Path $LockFile -Encoding UTF8

        $res = [PSCustomObject]@{
            status = "ACQUIRED"
            agent_id = $AgentId
            paths = @($Paths)
            expires_at = $now.AddSeconds($TtlSeconds).ToString("o")
        }
        Write-Output ($res | ConvertTo-Json -Compress)
        exit 0
    }

    'release' {
        if (-not $AgentId) { throw "AgentId is required for release." }
        $activeLocks = Get-ActiveLocks -Locks $lockDb.locks -CurrentTime $now
        $remaining = [System.Collections.Generic.List[object]]::new()
        $releasedCount = 0

        foreach ($l in $activeLocks) {
            if ($l.agent_id -eq $AgentId) {
                if ($Paths.Count -gt 0) {
                    $newPaths = @($l.paths | Where-Object { $Paths -notcontains $_ })
                    if ($newPaths.Count -gt 0) {
                        $l.paths = $newPaths
                        $remaining.Add($l)
                    } else {
                        $releasedCount++
                    }
                } else {
                    $releasedCount++
                }
            } else {
                $remaining.Add($l)
            }
        }

        $lockDb.locks = @($remaining)
        $lockDb | ConvertTo-Json -Depth 5 | Set-Content -Path $LockFile -Encoding UTF8

        $res = [PSCustomObject]@{
            status = "RELEASED"
            agent_id = $AgentId
            released = $releasedCount
        }
        Write-Output ($res | ConvertTo-Json -Compress)
        exit 0
    }

    'status' {
        $activeLocks = Get-ActiveLocks -Locks $lockDb.locks -CurrentTime $now
        $res = [PSCustomObject]@{
            status = "OK"
            active_locks_count = $activeLocks.Count
            locks = @($activeLocks)
        }
        Write-Output ($res | ConvertTo-Json -Depth 5)
        exit 0
    }

    'clean' {
        $activeLocks = Get-ActiveLocks -Locks $lockDb.locks -CurrentTime $now
        $purgedCount = $lockDb.locks.Count - $activeLocks.Count
        $lockDb.locks = @($activeLocks)
        $lockDb | ConvertTo-Json -Depth 5 | Set-Content -Path $LockFile -Encoding UTF8

        $res = [PSCustomObject]@{
            status = "CLEANED"
            purged_expired_locks = $purgedCount
            remaining_active_locks = $activeLocks.Count
        }
        Write-Output ($res | ConvertTo-Json -Compress)
        exit 0
    }
}
