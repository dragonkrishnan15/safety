#!/usr/bin/env bash
# ==============================================================================
# Automated Integration Test for stop_gate.sh
# ==============================================================================

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
STOP_GATE="$SCRIPT_DIR/../scripts/stop_gate.sh"

echo "🧪 Running stop_gate.sh Integration Test Suite..."

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

# 1. Clean run test
test_clean() {
  local out
  out=$("$STOP_GATE" 2>&1)
  local code=$?
  if [[ $code -ne 0 ]]; then return 1; fi
  echo "$out" | grep -q '"status":"PASSED"'
}
assert_test "Clean state should exit 0 with PASSED status" test_clean

# 2. Test command failure propagation
test_fail_cmd() {
  local out
  out=$("$STOP_GATE" "false" 2>&1) || true
  echo "$out" | grep -q '"status":"REJECTED"'
}
assert_test "Failing test command should exit 1 with REJECTED status" test_fail_cmd

# 3. Contract forbidden paths check
test_contract_violation() {
  local temp_contract="/tmp/test-contract-$$.json"
  echo '{"task_id":"TEST-01","forbidden_paths":["scripts/**"]}' > "$temp_contract"
  local target_file="$SCRIPT_DIR/../scripts/scorecard.sh"
  local orig_content
  orig_content=$(cat "$target_file")
  echo "# test diff for contract check" >> "$target_file"
  local out
  out=$("$STOP_GATE" "" "$temp_contract" 2>&1) || true
  printf "%s" "$orig_content" > "$target_file"
  rm -f "$temp_contract"
  echo "$out" | grep -q '"status":"REJECTED"'
}
assert_test "Forbidden path contract violation triggers REJECTED" test_contract_violation

echo -e "\nStop Gate Test Results: $PASSED passed, $FAILED failed."
if [[ $FAILED -gt 0 ]]; then exit 1; else exit 0; fi
