#!/usr/bin/env bash
# ==============================================================================
# claude-thinking Universal Installer for macOS / Linux / WSL
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/CodeStrikerMayank/master_skill/main/install.sh | bash
#   or locally:
#   ./install.sh [--global | --project] [--target all|claude|cursor|windsurf|gemini|cline|copilot]
# ==============================================================================

set -euo pipefail

SCOPE="project"
TARGET="auto"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --global|-g)
      SCOPE="global"
      shift
      ;;
    --project|-p)
      SCOPE="project"
      shift
      ;;
    --target|-t)
      TARGET="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"

# If executed via curl | bash, SCRIPT_DIR might not have SKILL.md
if [[ ! -f "$SCRIPT_DIR/SKILL.md" ]]; then
  TMP_REPO="$(mktemp -d)/claude-thinking"
  echo "==> Fetching claude-thinking repository..."
  git clone --depth 1 https://github.com/CodeStrikerMayank/master_skill.git "$TMP_REPO"
  SCRIPT_DIR="$TMP_REPO"
fi

echo "=========================================================="
echo " 🧠 claude-thinking Universal Installer (v5.1)"
echo " Scope:  $SCOPE"
echo " Target: $TARGET"
echo "=========================================================="

copy_cfg() {
  local src="$1"
  local dest="$2"
  local label="$3"

  if [[ -f "$src" ]]; then
    mkdir -p "$(dirname "$dest")"
    cp -f "$src" "$dest"
    echo "  [OK] Installed $label -> $dest"
  else
    echo "  [WARN] Missing source: $src"
  fi
}

HOME_DIR="$HOME"
WORK_DIR="$(pwd)"

# 1. Antigravity / Gemini CLI
if [[ "$TARGET" =~ ^(auto|all|gemini)$ ]]; then
  if [[ "$SCOPE" == "global" || -d "$HOME_DIR/.gemini" ]]; then
    copy_cfg "$SCRIPT_DIR/SKILL.md" "$HOME_DIR/.gemini/config/skills/claude-thinking/SKILL.md" "Antigravity Global Skill"
    copy_cfg "$SCRIPT_DIR/claude-thinking.md" "$HOME_DIR/.gemini/config/rules/claude-thinking.md" "Antigravity Global Rule"
  fi
  if [[ "$SCOPE" == "project" ]]; then
    copy_cfg "$SCRIPT_DIR/SKILL.md" "$WORK_DIR/.agents/skills/claude-thinking/SKILL.md" "Antigravity Project Skill"
    copy_cfg "$SCRIPT_DIR/claude-thinking.md" "$WORK_DIR/.agents/rules/claude-thinking.md" "Antigravity Project Rule"
  fi
fi

# 2. Anthropic Claude Code
if [[ "$TARGET" =~ ^(auto|all|claude)$ ]]; then
  if [[ "$SCOPE" == "global" ]]; then
    copy_cfg "$SCRIPT_DIR/adapters/CLAUDE.md" "$HOME_DIR/.claude/CLAUDE.md" "Claude Code Global Memory"
    copy_cfg "$SCRIPT_DIR/SKILL.md" "$HOME_DIR/.claude/skills/claude-thinking/SKILL.md" "Claude Code Global Skill"
  else
    copy_cfg "$SCRIPT_DIR/adapters/CLAUDE.md" "$WORK_DIR/CLAUDE.md" "Claude Code Workspace Memory"
  fi
fi

# 3. Cursor IDE
if [[ "$TARGET" =~ ^(auto|all|cursor)$ ]]; then
  if [[ "$SCOPE" == "global" ]]; then
    copy_cfg "$SCRIPT_DIR/adapters/.cursorrules" "$HOME_DIR/.cursorrules" "Cursor Global Rules"
  else
    copy_cfg "$SCRIPT_DIR/adapters/.cursorrules" "$WORK_DIR/.cursorrules" "Cursor Project Rules"
    copy_cfg "$SCRIPT_DIR/adapters/.cursorrules" "$WORK_DIR/.cursor/rules/claude-thinking.mdc" "Cursor MDC Rules"
  fi
fi

# 4. Windsurf IDE
if [[ "$TARGET" =~ ^(auto|all|windsurf)$ ]]; then
  if [[ "$SCOPE" == "global" ]]; then
    copy_cfg "$SCRIPT_DIR/adapters/.windsurfrules" "$HOME_DIR/.windsurfrules" "Windsurf Global Rules"
  else
    copy_cfg "$SCRIPT_DIR/adapters/.windsurfrules" "$WORK_DIR/.windsurfrules" "Windsurf Project Rules"
  fi
fi

# 5. Cline / Roo Code
if [[ "$TARGET" =~ ^(auto|all|cline)$ ]]; then
  if [[ "$SCOPE" == "global" ]]; then
    copy_cfg "$SCRIPT_DIR/adapters/.clinerules" "$HOME_DIR/.clinerules" "Cline Global Rules"
  else
    copy_cfg "$SCRIPT_DIR/adapters/.clinerules" "$WORK_DIR/.clinerules" "Cline Project Rules"
  fi
fi

# 6. GitHub Copilot
if [[ "$TARGET" =~ ^(auto|all|copilot)$ ]]; then
  copy_cfg "$SCRIPT_DIR/adapters/COPILOT.md" "$WORK_DIR/.github/copilot-instructions.md" "GitHub Copilot Instructions"
fi

# 7. Universal Agent Fallback
if [[ "$SCOPE" == "project" ]]; then
  copy_cfg "$SCRIPT_DIR/adapters/AGENTS.md" "$WORK_DIR/AGENTS.md" "Universal AGENTS.md Workspace Spec"
fi

echo "=========================================================="
echo " [SUCCESS] claude-thinking is installed and ready!"
echo "=========================================================="
