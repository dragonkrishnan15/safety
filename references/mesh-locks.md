# Multi-Agent Mesh Locking & Consensus Protocol (`mesh-locks.json`)

> **Core Philosophy (Apex Mesh Governance):**  
> In modern software development, multiple autonomous AI agents (Cursor, Claude Code, Antigravity, Cline, Windsurf) frequently operate concurrently within the same repository. Without decentralized arbitration, agents overwrite each other's edits, cause merge conflicts, and invalidate active test baselines.

---

## 1. The Mesh Lock Architecture

Lock metadata is persisted in `.master-skill/mesh-locks.json` (or `<workspace>/.agents/mesh-locks.json`).
Every agent entering a `SIZE=standard` or `SIZE=complex` task that touches shared files MUST acquire a lock before modifying disk state.

### File Schema (`.master-skill/mesh-locks.json`):
```json
{
  "version": "1.0",
  "locks": [
    {
      "agent_id": "cursor-agent-auth",
      "paths": [
        "src/api/auth/**",
        "tests/unit/auth.test.ts"
      ],
      "acquired_at": "2026-10-16T10:00:00.000Z",
      "ttl_seconds": 1800,
      "task": "Migrate session tokens to JWT"
    }
  ]
}
```

---

## 2. Command-Line Arbitration

Mesh locks can be acquired and released using native scripts or the `safety` CLI:

### PowerShell:
```powershell
# Acquire lock
powershell -ExecutionPolicy Bypass -File ./scripts/mesh_lock.ps1 -Action acquire -AgentId "antigravity-worker-1" -Paths "src/services/billing.ts" -Task "Fix invoice recalculation bug"

# Release lock
powershell -ExecutionPolicy Bypass -File ./scripts/mesh_lock.ps1 -Action release -AgentId "antigravity-worker-1"

# Check active mesh locks
powershell -ExecutionPolicy Bypass -File ./scripts/mesh_lock.ps1 -Action status
```

### POSIX Bash:
```bash
# Acquire lock
./scripts/mesh_lock.sh acquire "claude-code" "src/services/billing.ts" "Fix invoice recalculation bug" 1800

# Release lock
./scripts/mesh_lock.sh release "claude-code"

# Check status
./scripts/mesh_lock.sh status
```

### Safety CLI:
```bash
safety mesh lock --agent "cursor" --paths "src/services/**" --task "Refactor DB queries"
safety mesh unlock --agent "cursor"
safety mesh status
```

---

## 3. Conflict Resolution Rules

1. **Exact & Glob Collisions**:
   If Agent B requests path `src/api/auth/login.ts` and Agent A currently holds `src/api/auth/**`, the acquire operation immediately exits with `code 1 (CONFLICT)` and details the conflicting agent.
2. **Auto-Expiration (TTL)**:
   Locks default to a 30-minute (`1800s`) TTL. If an agent crashes or abandons a task, expired locks are automatically pruned by subsequent operations to prevent deadlocks.
3. **Graceful Degrade**:
   If an agent encounters a lock conflict, it MUST either:
   - PARK the conflicting component and work on independent unblocked modules, OR
   - Wait for the locking agent to finish, OR
   - Escalate to the human operator if the lock was held past its task window.
