# Failsafes & Circuit Breakers Reference

Defensive mechanisms to eliminate infinite tool loops, accidental data destruction, runaway context growth, and secret leaks.

## 1. Loop Detector & Tool Failure Circuit Breaker

### Rule: Max 2 Failures of Identical Command
- If a command or tool call fails twice with the identical exit code or error signature:
  1. **TRIGGER CIRCUIT BREAKER**: Immediately stop re-running the command.
  2. Do not retry with minor cosmetic changes.
  3. Classify: (a) environment defect, (b) missing tool/binary, (c) invalid assumption.
  4. Revert to the last clean checkpoint or switch to an alternate approach.
- **Max 3 Approaches**: If 3 distinct approaches fail across the entire task, halt and escalate to the user with a trade-off matrix. Never burn tokens in speculative loops.

---

## 2. Accidental Data Loss Prevention (Zero-Destruction Wall)

The following commands are **BLOCKED BY HARD FAILSAFE** unless the user provides explicit, typed consent naming the specific action:
- `git reset --hard`
- `git clean -fd`
- `git checkout .` or `git restore .`
- `git push --force` or `--force-with-lease`
- `rm -rf` or `Remove-Item -Recurse -Force` on directories outside `<tmp>`
- `DROP TABLE`, `DROP DATABASE`, `TRUNCATE`, or `DELETE FROM` without a tight WHERE clause
- Modifying, staging, or stashing files marked as `USER-OWNED` at baseline

---

## 3. Secret Redaction Filter

Before any text is written to terminal output, logs, diffs, or `<tmp>/ct-state.json`:
- **Redact Automatically**:
  - API Keys (e.g. `sk-`, `ghp_`, `AKIA`, `AIza`) -> `[REDACTED_API_KEY]`
  - Passwords, Private Keys, JWT Tokens -> `[REDACTED_SECRET]`
  - Reference environment variables only by their key names (e.g. `$env:DATABASE_URL`), never by their evaluated secret values.

---

## 4. Sandbox Isolation & Emergency Recovery

- **Per-Task Temp Isolation**: Scratch scripts, temporary diffs, and intermediate state must live in `<tmp>` outside the project tree.
- **Emergency Recovery**:
  - Every atomic step generates `<tmp>/ct-step-N.patch` or `<tmp>/ct-backup/`.
  - In the event of an abrupt session termination or tool failure, the repository can be restored to exact baseline with a single command:
    `git apply -R <tmp>/ct-step-N.patch` (or copy back from `<tmp>/ct-backup/`).
