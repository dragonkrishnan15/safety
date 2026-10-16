$ErrorActionPreference = 'SilentlyContinue'

# 1. Check for newly introduced DEBUG-CT in active code diff (excluding docs & tool scripts)
$diffLines = git diff -U0 -- ':!*.md' ':!*.mdc' ':!scripts/*' ':!adapters/*' ':!templates/*' ':!examples/*' ':!assets/*' ':!bin/*' ':!docs/*' 2>$null | Where-Object { $_ -match '^\+[^+].*DEBUG-CT' }
$diffDebugCount = ($diffLines | Measure-Object).Count

# 2. Check for committed DEBUG-CT in code (excluding docs & tool scripts)
$repoMatches = git grep -n "DEBUG-CT" -- ':!*.md' ':!*.mdc' ':!scripts/*' ':!adapters/*' ':!templates/*' ':!examples/*' ':!assets/*' ':!bin/*' ':!docs/*' 2>$null
$repoDebugCount = ($repoMatches | Measure-Object).Count

$totalDebug = $diffDebugCount + $repoDebugCount
$diffStat = git diff --stat 2>$null
$untracked = git ls-files --others --exclude-standard 2>$null
$crlfCheck = git diff --check 2>$null

[PSCustomObject]@{
    debug_ct_count = $totalDebug
    debug_ct_lines = @($diffLines) + @($repoMatches)
    untracked_count = ($untracked | Measure-Object).Count
    has_diff = [bool]($diffStat)
    has_whitespace_or_crlf_errors = [bool]($crlfCheck)
} | ConvertTo-Json -Compress
