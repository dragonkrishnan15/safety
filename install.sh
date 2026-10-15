#!/usr/bin/env bash
# ==============================================================================
# master-skill Universal Installer for macOS / Linux / WSL
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
  TMP_REPO="$(mktemp -d)/master-skill"
  echo "==> Fetching master-skill repository..."
  git clone --depth 1 https://github.com/CodeStrikerMayank/master_skill.git "$TMP_REPO"
  SCRIPT_DIR="$TMP_REPO"
fi

echo "=========================================================="
echo " 🧠 master-skill Universal Installer (v5.1)"
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
    copy_cfg "$SCRIPT_DIR/SKILL.md" "$HOME_DIR/.gemini/config/skills/master-skill/SKILL.md" "Antigravity Global Skill"
    [[ -d "$SCRIPT_DIR/references" ]] && cp -rf "$SCRIPT_DIR/references" "$HOME_DIR/.gemini/config/skills/master-skill/"
    [[ -d "$SCRIPT_DIR/scripts" ]] && cp -rf "$SCRIPT_DIR/scripts" "$HOME_DIR/.gemini/config/skills/master-skill/"
    [[ -d "$SCRIPT_DIR/examples" ]] && cp -rf "$SCRIPT_DIR/examples" "$HOME_DIR/.gemini/config/skills/master-skill/"
    if [[ -d "$HOME_DIR/.gemini/antigravity" ]]; then
      mkdir -p "$HOME_DIR/.gemini/antigravity/skills/master-skill"
      copy_cfg "$SCRIPT_DIR/SKILL.md" "$HOME_DIR/.gemini/antigravity/skills/master-skill/SKILL.md" "Antigravity Fallback Skill"
    fi
    copy_cfg "$SCRIPT_DIR/master-skill.md" "$HOME_DIR/.gemini/config/rules/master-skill.md" "Antigravity Global Rule"
    [[ -f "$HOME_DIR/.gemini/config/rules/claude-thinking.md" ]] && rm -f "$HOME_DIR/.gemini/config/rules/claude-thinking.md"
  fi
  if [[ "$SCOPE" == "project" ]]; then
    copy_cfg "$SCRIPT_DIR/SKILL.md" "$WORK_DIR/.agents/skills/master-skill/SKILL.md" "Antigravity Project Skill"
    [[ -d "$SCRIPT_DIR/references" ]] && cp -rf "$SCRIPT_DIR/references" "$WORK_DIR/.agents/skills/master-skill/"
    [[ -d "$SCRIPT_DIR/scripts" ]] && cp -rf "$SCRIPT_DIR/scripts" "$WORK_DIR/.agents/skills/master-skill/"
    [[ -d "$SCRIPT_DIR/examples" ]] && cp -rf "$SCRIPT_DIR/examples" "$WORK_DIR/.agents/skills/master-skill/"
    copy_cfg "$SCRIPT_DIR/master-skill.md" "$WORK_DIR/.agents/rules/master-skill.md" "Antigravity Project Rule"
  fi
fi

# 2. Anthropic Claude Code
if [[ "$TARGET" =~ ^(auto|all|claude)$ ]]; then
  if [[ "$SCOPE" == "global" ]]; then
    copy_cfg "$SCRIPT_DIR/adapters/CLAUDE.md" "$HOME_DIR/.claude/CLAUDE.md" "Claude Code Global Memory"
    copy_cfg "$SCRIPT_DIR/SKILL.md" "$HOME_DIR/.claude/skills/master-skill/SKILL.md" "Claude Code Global Skill"
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
    copy_cfg "$SCRIPT_DIR/adapters/.cursorrules" "$WORK_DIR/.cursor/rules/master-skill.mdc" "Cursor MDC Rules"
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

  # 8. Git Pre-Commit Quality Gate (if in git repo)
  if [[ -d "$WORK_DIR/.git" && -f "$SCRIPT_DIR/scripts/install_hooks.sh" ]]; then
    bash "$SCRIPT_DIR/scripts/install_hooks.sh" >/dev/null 2>&1 || true
    echo "  [OK] Installed Git Pre-Commit Quality Gate -> .git/hooks/pre-commit"
  fi
fi

echo "=========================================================="
echo " [SUCCESS] master-skill is installed and ready!"
echo "=========================================================="
