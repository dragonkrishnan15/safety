$ErrorActionPreference = 'SilentlyContinue'
$diffNumstat = git diff --numstat 2>$null
$added = 0; $deleted = 0; $fileCount = 0
if ($diffNumstat) {
    foreach ($line in $diffNumstat) {
        $parts = -split $line
        if ($parts.Length -ge 3) {
            $added += [int]$parts[0]
            $deleted += [int]$parts[1]
            $fileCount++
        }
    }
}
$debugMatches = git grep -n "DEBUG-CT" 2>$null
$untracked = (git ls-files --others --exclude-standard 2>$null).Count
[PSCustomObject]@{
    files_changed = $fileCount
    lines_added = $added
    lines_deleted = $deleted
    net_change = ($added - $deleted)
    debug_ct_count = ($debugMatches | Measure-Object).Count
    untracked_files = $untracked
    ratio = if ($deleted -gt 0) { [math]::Round(($added / $deleted), 2) } else { $added }
} | ConvertTo-Json -Compress
