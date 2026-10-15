#!/usr/bin/env bash
# ==============================================================================
# Programmatic Stop Gate for master-skill (Gravitas-grade Runtime Gate)
# Exits 0 on success (PASSED), 1 on failure (REJECTED)
# ==============================================================================

set -uo pipefail

TEST_CMD="${1:-}"
CONTRACT_PATH="${2:-}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
VIOLATIONS=()

# 1. Leftover check
if [[ -f "$SCRIPT_DIR/leftover_check.sh" ]]; then
  LEFTOVER_JSON=$("$SCRIPT_DIR/leftover_check.sh" 2>/dev/null || true)
  DEBUG_COUNT=$(echo "$LEFTOVER_JSON" | grep -o '"debug_ct_count":[0-9]*' | cut -d: -f2 || echo 0)
  if [[ "$DEBUG_COUNT" -gt 0 ]]; then
    VIOLATIONS+=("Found $DEBUG_COUNT unremoved DEBUG-CT tags.")
  fi
fi

# 2. Contract boundary check
if [[ -z "$CONTRACT_PATH" ]]; then
  if [[ -f "ct-contract.json" ]]; then
    CONTRACT_PATH="ct-contract.json"
  elif [[ -f "/tmp/ct-contract.json" ]]; then
    CONTRACT_PATH="/tmp/ct-contract.json"
  fi
fi

if [[ -n "$CONTRACT_PATH" && -f "$CONTRACT_PATH" ]]; then
  if [[ -z "$TEST_CMD" ]]; then
    EXTRACTED_CMD=$(grep -o '"stop_gate_command": *"[^"]*"' "$CONTRACT_PATH" | cut -d'"' -f4 || true)
    if [[ -n "$EXTRACTED_CMD" ]]; then
      TEST_CMD="$EXTRACTED_CMD"
    fi
  fi
fi

# 3. Sensitive Secret & Token Scanner
diff_additions=$(git diff -U0 HEAD 2>/dev/null | grep '^\+' || true)
if [[ -n "$diff_additions" ]]; then
  if echo "$diff_additions" | grep -Eq '(ghp_[A-Za-z0-9]{36}|sk-[A-Za-z0-9]{20,}|sk-ant-[A-Za-z0-9]{20,}|AIza[0-9A-Za-z-_]{35}|AKIA[0-9A-Z]{16}|-----BEGIN [A-Z ]*PRIVATE KEY-----)'; then
    VIOLATIONS+=("SECURITY ALERT: Detected potential sensitive secret/token in git diff additions.")
  fi
fi

# 4. Test runner execution
TEST_EXIT=0
if [[ -n "$TEST_CMD" ]]; then
  eval "$TEST_CMD" >/dev/null 2>&1 || TEST_EXIT=$?
  if [[ "$TEST_EXIT" -ne 0 ]]; then
    VIOLATIONS+=("Stop Gate test command failed with exit code $TEST_EXIT: $TEST_CMD")
  fi
fi

if [[ ${#VIOLATIONS[@]} -eq 0 ]]; then
  echo '{"status":"PASSED","violations":[],"test_exit_code":0}'
  exit 0
else
  printf '{"status":"REJECTED","violations":['
  for i in "${!VIOLATIONS[@]}"; do
    printf '"%s"' "${VIOLATIONS[$i]}"
    if [[ $i -lt $((${#VIOLATIONS[@]} - 1)) ]]; then printf ','; fi
  done
  printf '],"test_exit_code":%d}\n' "$TEST_EXIT"
  exit 1
fi
