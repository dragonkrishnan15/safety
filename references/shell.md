# Shell Reference: Cross-Platform Adaptation (Windows & POSIX)

Guidelines for detecting, adapting to, and executing commands safely across PowerShell (Core `pwsh` / Desktop `ps51`), Windows `cmd`, and POSIX shells (`bash`, `zsh`, WSL).

## 1. Shell Detection & State

### Shell Probe (run once if SHELL not provided by harness)
- In PowerShell: `$PSVersionTable.PSVersion` returns version (Major >= 6 is `pwsh`, Major == 5 is `ps51`).
- In POSIX: `echo $SHELL` or `uname -s`.

### Temporary Directory `<tmp>`
Always locate `<tmp>` outside the target repository to avoid polluting the workspace or git status:
- **Windows (PowerShell)**: `$env:TEMP\master-skill\<taskId>` or `$env:USERPROFILE\.master-skill\<taskId>`
- **POSIX**: `/tmp/master-skill/<taskId>` or `~/.master-skill/<taskId>`
- Ensure directory exists:
  - PowerShell: `if (-not (Test-Path $tmp)) { New-Item -ItemType Directory -Path $tmp -Force | Out-Null }`
  - POSIX: `mkdir -p "$tmp"`

### State Persistence (`<tmp>/ct-state.json`)
Mirror the gate line, ledgers, assumptions, and loaded reference digests to `<tmp>/ct-state.json` so work survives context resets and allows clean headless resume.

## 2. Command Equivalents Table

| Operation | POSIX (`bash`/`zsh`) | Windows PowerShell (`pwsh`/`ps51`) |
|---|---|---|
| Locate binary | `which <bin>` or `command -v <bin>` | `Get-Command <bin> -ErrorAction SilentlyContinue` |
| Text search | `grep -rn "pattern" <path>` or `rg "pattern"` | `Select-String -Path <path> -Pattern "pattern"` or `rg "pattern"` |
| Line count | `wc -l <file>` | `(Get-Content <file> \| Measure-Object -Line).Lines` |
| File listing (rec) | `find . -name "*.ext" -not -path "*/.*"` | `Get-ChildItem -Recurse -Filter "*.ext" -Exclude ".*"` |
| Diff comparison | `diff -u fileA fileB` | `Compare-Object (Get-Content fileA) (Get-Content fileB)` or `git diff --no-index` |
| Exit code check | `echo $?` (0 = success) | Native exe: `$LASTEXITCODE` (0 = success); Cmdlet: `$?` ($True = success) |
| Environment var | `export VAR="val"` / `echo $VAR` | `$env:VAR = "val"` / `$env:VAR` |
| File size check | `stat -c %s <file>` or `wc -c <file>` | `(Get-Item <file>).Length` |
| Make directory | `mkdir -p <dir>` | `New-Item -ItemType Directory -Path <dir> -Force` |
| Remove temp file | `rm -f <file>` | `Remove-Item -Path <file> -Force -ErrorAction SilentlyContinue` |

## 3. PowerShell Gotchas & Hard Rules

1. **Avoid Cmdlet Alias Ambiguity**:
   - In Windows PowerShell 5.1, `curl` and `wget` are aliases for `Invoke-WebRequest`, NOT the real CLI tools. Use `curl.exe` explicitly if calling curl.
   - `sc` is an alias for `Set-Content`, not `sc.exe` (Service Control).
2. **Quoting and Escaping**:
   - In PowerShell double quotes (`"..."`), variables like `$foo` expand. Escape literal dollar signs with backticks: `` `$foo ``.
   - For string literals with special characters or regex patterns, prefer single quotes (`'...'`).
3. **Exit Codes**:
   - External processes set `$LASTEXITCODE`. PowerShell cmdlets set `$?` (boolean `$true`/`$false`). Always check `$LASTEXITCODE` immediately after running native CLI tools (git, node, python, cargo, pytest).
4. **Encoding & BOM**:
   - Windows PowerShell 5.1 `Out-File` and `>` default to UTF-16 LE.
   - When writing UTF-8 files in PowerShell 5.1, use `[System.IO.File]::WriteAllText($path, $text, [System.Text.UTF8Encoding]::new($false))` to avoid unwanted UTF-16 or UTF-8 BOM.
   - In PowerShell Core (`pwsh` 7+), UTF-8 without BOM is default.
