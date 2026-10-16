#!/usr/bin/env bash
# ==============================================================================
# Multi-Agent Mesh Locking Protocol for master-skill / safety
# ==============================================================================

set -uo pipefail

ACTION="${1:-status}"
AGENT_ID="${2:-}"
PATHS_ARG="${3:-}"
TASK="${4:-}"
TTL_SECONDS="${5:-1800}"
LOCK_FILE="${6:-.master-skill/mesh-locks.json}"

mkdir -p "$(dirname "$LOCK_FILE")"

now_epoch=$(date +%s)
now_iso=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date +"%Y-%m-%dT%H:%M:%SZ")

if [[ ! -f "$LOCK_FILE" ]]; then
  echo '{"version":"1.0","locks":[]}' > "$LOCK_FILE"
fi

# Python / Node fallback for json manipulation or simple bash fallback
run_python_or_node() {
  if command -v node >/dev/null 2>&1; then
    node -e "$1"
  elif command -v python3 >/dev/null 2>&1; then
    python3 -c "$2"
  else
    echo "ERROR: node or python3 required for mesh_lock.sh" >&2
    exit 1
  fi
}

case "$ACTION" in
  status)
    run_python_or_node \
      "const fs=require('fs');const db=JSON.parse(fs.readFileSync('$LOCK_FILE','utf8')||'{}');const now=Date.now();const active=(db.locks||[]).filter(l=>new Date(l.acquired_at).getTime()+(l.ttl_seconds||1800)*1000>now);console.log(JSON.stringify({status:'OK',active_locks_count:active.length,locks:active},null,2));" \
      "import json,time,datetime;db=json.load(open('$LOCK_FILE'));now=time.time();active=[l for l in db.get('locks',[]) if datetime.datetime.fromisoformat(l['acquired_at'].replace('Z','+00:00')).timestamp()+(l.get('ttl_seconds',1800))>now];print(json.dumps({'status':'OK','active_locks_count':len(active),'locks':active},indent=2))"
    ;;

  acquire)
    if [[ -z "$AGENT_ID" || -z "$PATHS_ARG" ]]; then
      echo '{"status":"ERROR","message":"AgentId and Paths are required for acquire"}'
      exit 1
    fi

    NODE_SCRIPT="
    const fs = require('fs');
    const file = '$LOCK_FILE';
    const db = JSON.parse(fs.readFileSync(file, 'utf8') || '{\"version\":\"1.0\",\"locks\":[]}');
    const now = Date.now();
    const reqAgent = '$AGENT_ID';
    const reqPaths = '$PATHS_ARG'.split(',').map(p => p.trim());
    const reqTask = '$TASK';
    const ttl = parseInt('$TTL_SECONDS', 10) || 1800;

    const active = (db.locks || []).filter(l => new Date(l.acquired_at).getTime() + (l.ttl_seconds || 1800) * 1000 > now);

    function collision(a, b) {
      const na = a.replace(/\\\\/g, '/').replace(/^\.\//, '');
      const nb = b.replace(/\\\\/g, '/').replace(/^\.\//, '');
      if (na === nb) return true;
      if (na.endsWith('/*') || na.endsWith('/**')) {
        const pfx = na.replace(/\/\*+$/, '');
        if (nb.startsWith(pfx)) return true;
      }
      if (nb.endsWith('/*') || nb.endsWith('/**')) {
        const pfx = nb.replace(/\/\*+$/, '');
        if (na.startsWith(pfx)) return true;
      }
      return false;
    }

    for (const p of reqPaths) {
      for (const l of active) {
        if (l.agent_id !== reqAgent) {
          for (const ep of (l.paths || [])) {
            if (collision(p, ep)) {
              console.log(JSON.stringify({
                status: 'CONFLICT',
                agent_id: reqAgent,
                conflicting_agent: l.agent_id,
                conflicting_path: p,
                held_path: ep,
                acquired_at: l.acquired_at,
                task: l.task
              }));
              process.exit(1);
            }
          }
        }
      }
    }

    const filtered = active.filter(l => l.agent_id !== reqAgent);
    const newLock = {
      agent_id: reqAgent,
      paths: reqPaths,
      acquired_at: new Date(now).toISOString(),
      ttl_seconds: ttl,
      task: reqTask
    };
    filtered.push(newLock);
    db.locks = filtered;
    fs.writeFileSync(file, JSON.stringify(db, null, 2));
    console.log(JSON.stringify({
      status: 'ACQUIRED',
      agent_id: reqAgent,
      paths: reqPaths,
      expires_at: new Date(now + ttl * 1000).toISOString()
    }));
    process.exit(0);
    "

    run_python_or_node "$NODE_SCRIPT" ""
    ;;

  release)
    if [[ -z "$AGENT_ID" ]]; then
      echo '{"status":"ERROR","message":"AgentId is required for release"}'
      exit 1
    fi

    NODE_SCRIPT="
    const fs = require('fs');
    const file = '$LOCK_FILE';
    const db = JSON.parse(fs.readFileSync(file, 'utf8') || '{\"version\":\"1.0\",\"locks\":[]}');
    const reqAgent = '$AGENT_ID';
    const reqPaths = '$PATHS_ARG' ? '$PATHS_ARG'.split(',').map(p => p.trim()) : [];

    let released = 0;
    const remaining = [];
    for (const l of (db.locks || [])) {
      if (l.agent_id === reqAgent) {
        if (reqPaths.length > 0) {
          const np = l.paths.filter(p => !reqPaths.includes(p));
          if (np.length > 0) {
            l.paths = np;
            remaining.push(l);
          } else {
            released++;
          }
        } else {
          released++;
        }
      } else {
        remaining.push(l);
      }
    }
    db.locks = remaining;
    fs.writeFileSync(file, JSON.stringify(db, null, 2));
    console.log(JSON.stringify({ status: 'RELEASED', agent_id: reqAgent, released }));
    "

    run_python_or_node "$NODE_SCRIPT" ""
    ;;

  clean)
    NODE_SCRIPT="
    const fs = require('fs');
    const file = '$LOCK_FILE';
    const db = JSON.parse(fs.readFileSync(file, 'utf8') || '{\"version\":\"1.0\",\"locks\":[]}');
    const now = Date.now();
    const before = (db.locks || []).length;
    const active = (db.locks || []).filter(l => new Date(l.acquired_at).getTime() + (l.ttl_seconds || 1800) * 1000 > now);
    db.locks = active;
    fs.writeFileSync(file, JSON.stringify(db, null, 2));
    console.log(JSON.stringify({ status: 'CLEANED', purged: before - active.length, remaining: active.length }));
    "
    run_python_or_node "$NODE_SCRIPT" ""
    ;;

  *)
    echo "Unknown action: $ACTION. Valid actions: status, acquire, release, clean"
    exit 1
    ;;
esac
