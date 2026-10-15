$ErrorActionPreference = 'SilentlyContinue'
$debugMatches = git grep -n "DEBUG-CT" 2>$null
$diffStat = git diff --stat 2>$null
$untracked = git ls-files --others --exclude-standard 2>$null
$crlfCheck = git diff --check 2>$null
[PSCustomObject]@{
    debug_ct_count = ($debugMatches | Measure-Object).Count
    debug_ct_lines = @($debugMatches)
    untracked_count = ($untracked | Measure-Object).Count
    has_diff = [bool]($diffStat)
    has_whitespace_or_crlf_errors = [bool]($crlfCheck)
} | ConvertTo-Json -Compress
