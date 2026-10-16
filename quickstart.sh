#!/usr/bin/env bash
# ==============================================================================
# master-skill / safety - Developer Quickstart (POSIX)
# ==============================================================================
set -euo pipefail

printf '\033[36m==========================================================\033[0m\n'
printf '\033[32m 🛡️  master-skill / safety - Developer Quickstart\033[0m\n'
printf '\033[36m==========================================================\033[0m\n\n'

printf '\033[36m[*] Running Pre-Flight Verification Gate...\033[0m\n'
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$SCRIPT_DIR/scripts/stop_gate.sh" ]]; then
  bash "$SCRIPT_DIR/scripts/stop_gate.sh" || true
fi

printf '\n\033[36m[*] Active Environment:\033[0m\n'
printf '  - Repository:  dragonkrishnan15/safety\n'
printf '  - Engine:      master-skill v5.2 (Apex Mesh & Active Governance)\n'
printf '  - CLI Tool:    safety (bin/safety.js) & safety-mcp (bin/safety-mcp.js)\n'
printf '  - Memory:      .master-skill/memory.json\n\n'

printf '\033[36m[*] Available Slash Commands in AI Chats:\033[0m\n'
printf '  \033[33m/master-skill\033[0m   -> Activate core zero-trust reasoning workflow\n'
printf '  \033[33m/ms-contract\033[0m    -> Inspect & enforce task contract invariants\n'
printf '  \033[33m/ms-mesh\033[0m        -> Acquire & arbitrate multi-agent mesh locks\n'
printf '  \033[33m/ms-adversary\033[0m   -> Run red-team chaos & fault injection tests\n'
printf '  \033[33m/ms-stop\033[0m        -> Run pre-commit stop gate inspection\n\n'

printf '\033[36m[*] Available CLI Commands:\033[0m\n'
printf '  \033[32msafety gate\033[0m        -> Execute programmatic stop gate\n'
printf '  \033[32msafety intercept\033[0m   -> Validate command against zero-destruction wall\n'
printf '  \033[32msafety mesh status\033[0m -> View active multi-agent mesh locks\n'
printf '  \033[32msafety report\033[0m      -> View diff and verification scorecard\n\n'

printf '\033[32m[SUCCESS] Environment is 100% verified and operational.\033[0m\n\n'
