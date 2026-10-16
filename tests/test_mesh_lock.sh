#!/usr/bin/env bash
# ==============================================================================
# Automated Integration Test for mesh_lock.sh
# ==============================================================================

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
MESH_SCRIPT="$SCRIPT_DIR/../scripts/mesh_lock.sh"
TEMP_LOCK="/tmp/test-mesh-locks-$$.json"

echo "🧪 Running mesh_lock.sh Integration Test Suite..."

PASSED=0
FAILED=0

assert_test() {
  local name="$1"
  shift
  if "$@"; then
    echo "  ✅ [PASS] $name"
    PASSED=$((PASSED + 1))
  else
    echo "  ❌ [FAIL] $name"
    FAILED=$((FAILED + 1))
  fi
}

rm -f "$TEMP_LOCK"

# 1. Initial Status
test_initial_status() {
  local out
  out=$("$MESH_SCRIPT" status "" "" "" "" "$TEMP_LOCK" 2>&1)
  echo "$out" | grep -q '"active_locks_count": 0'
}
assert_test "Initial status returns active_locks_count 0" test_initial_status

# 2. Acquire Lock
test_acquire() {
  local out
  out=$("$MESH_SCRIPT" acquire "agent-1" "src/services/**" "DB upgrade" 1800 "$TEMP_LOCK" 2>&1)
  echo "$out" | grep -q '"status":"ACQUIRED"'
}
assert_test "Agent-1 acquires lock successfully" test_acquire

# 3. Collision Detection
test_collision() {
  local out
  out=$("$MESH_SCRIPT" acquire "agent-2" "src/services/user.ts" "Fix auth" 1800 "$TEMP_LOCK" 2>&1) || true
  echo "$out" | grep -q '"status":"CONFLICT"'
}
assert_test "Agent-2 encounters CONFLICT on overlapping path" test_collision

# 4. Release Lock
test_release() {
  local out
  out=$("$MESH_SCRIPT" release "agent-1" "" "" "" "$TEMP_LOCK" 2>&1)
  echo "$out" | grep -q '"status":"RELEASED"'
}
assert_test "Agent-1 releases lock cleanly" test_release

# 5. Re-acquire after release
test_reacquire() {
  local out
  out=$("$MESH_SCRIPT" acquire "agent-2" "src/services/user.ts" "Fix auth" 1800 "$TEMP_LOCK" 2>&1)
  echo "$out" | grep -q '"status":"ACQUIRED"'
}
assert_test "Agent-2 can acquire path after Agent-1 release" test_reacquire

rm -f "$TEMP_LOCK"

echo -e "\nMesh Lock Test Results: $PASSED passed, $FAILED failed."
if [[ $FAILED -gt 0 ]]; then exit 1; else exit 0; fi
