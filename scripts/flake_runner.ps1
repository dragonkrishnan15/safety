param([string]$Command, [int]$MaxRuns = 20, [int]$TimeoutSec = 60)
$sw = [System.Diagnostics.Stopwatch]::StartNew()
$pass = 0; $fail = 0
for ($i = 1; $i -le $MaxRuns; $i++) {
    if ($sw.Elapsed.TotalSeconds -ge $TimeoutSec) { break }
    Invoke-Expression $Command > $null 2>&1
    if ($LASTEXITCODE -eq 0) { $pass++ } else { $fail++; break }
}
$sw.Stop()
[PSCustomObject]@{
    total_runs = ($pass + $fail)
    passed = $pass
    failed = $fail
    is_clean = ($fail -eq 0)
    elapsed_seconds = [math]::Round($sw.Elapsed.TotalSeconds, 2)
} | ConvertTo-Json -Compress
