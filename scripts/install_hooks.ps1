$gitDir = git rev-parse --git-dir 2>$null
if (-not $gitDir) {
    Write-Error "Not inside a git repository."
    exit 1
}
$hookFile = Join-Path $gitDir "hooks\pre-commit"
$hookDir = Split-Path $hookFile
if (-not (Test-Path $hookDir)) { New-Item -ItemType Directory -Path $hookDir -Force | Out-Null }
$hookScript = @'
#!/bin/sh
# master-skill pre-commit quality gate
if command -v powershell >/dev/null 2>&1; then
    powershell -NoProfile -Command "
        $debug = git grep -n 'DEBUG-CT' -- ':!*.md' ':!*.mdc' 2>`$null
        if ($debug) {
            Write-Error 'Commit blocked: Temporary DEBUG-CT instrumentation found:'
            $debug | ForEach-Object { Write-Error $_ }
            exit 1
        }
    "
    exit $?
fi
exit 0
'@
Set-Content -Path $hookFile -Value $hookScript -Encoding ASCII
Write-Output "Git pre-commit hook installed successfully at $hookFile"
