# Policy & Tool Interceptor Runtime

> **Core Philosophy (Gravitas Runtime Pattern):**  
> Intercept every tool execution *before* it touches the operating system or filesystem. Block forbidden commands, protect user-owned files, and halt on destructive operations.

---

## 1. Pre-Tool Verification Checks (Mental Hook)

Before emitting ANY tool call (command execution or file edit), the agent MUST verify these 5 safety checks:

```text
[TOOL INTERCEPTOR GATE]
1. Is the command in the Blocked List? (e.g. rm -rf, git reset --hard, git clean, sudo, kill -9) -> REJECT
2. Does the target file match forbidden_paths in ct-contract.json? -> REJECT
3. Is the file marked USER-OWNED (pre-existing dirty file)? -> REJECT
4. Does the command leak or expose environment secrets (.env, keys, tokens)? -> REJECT
5. Does the action modify global system configuration or databases? -> REJECT
```

---

## 2. Blocked Commands Directory

| Pattern | Status | Reason |
|---|---|---|
| `git reset --hard` | ❌ FORBIDDEN | Destroys uncommitted user work. |
| `git clean -fd` | ❌ FORBIDDEN | Deletes untracked user files. |
| `git checkout .` / `git restore .` | ❌ FORBIDDEN | Reverts user changes. |
| `rm -rf /` or recursive deletions | ❌ FORBIDDEN | Data loss risk. |
| `npm install -g` / `pip install` (global) | ❌ FORBIDDEN | Modifies system environment outside project sandbox. |
| Editing `.env` with production keys | ❌ FORBIDDEN | Secret exposure. |

---

## 3. Post-Tool State Drift Audit

Immediately after a tool completes:
1. Check exit code: If non-zero, capture exact stderr.
2. Check for unexpected file creation or git status drift.
3. If 2 consecutive tool calls fail with the identical error, the **Circuit Breaker trips** -> STOP and diagnose.
