param(
    [string]$Category = "learned_quirks",
    [string]$Entry = ""
)
if (-not $Entry) { exit 0 }
$memDir = ".claude-thinking"
$memFile = Join-Path $memDir "memory.json"
if (-not (Test-Path $memDir)) { New-Item -ItemType Directory -Path $memDir -Force | Out-Null }
$data = if (Test-Path $memFile) { Get-Content $memFile -Raw | ConvertFrom-Json } else {
    [PSCustomObject]@{
        updated_at = ""
        architectural_decisions = @()
        learned_quirks = @()
        tooling_preferences = @{}
        historical_known_red = @()
    }
}
$data.updated_at = (Get-Date -Format "o")
if ($data.$Category -is [System.Collections.IEnumerable] -and $data.$Category -isnot [string]) {
    $list = [System.Collections.ArrayList]@($data.$Category)
    if (-not $list.Contains($Entry)) { $list.Add($Entry) | Out-Null }
    $data.$Category = $list
}
$data | ConvertTo-Json -Depth 5 | Set-Content -Path $memFile -Encoding UTF8
Write-Output "Memory recorded to $memFile"
