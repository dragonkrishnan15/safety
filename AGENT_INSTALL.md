# 🤖 AI Agent Automated Installation Manifest

> **Notice to AI Agents (Claude Code, Cursor, Windsurf, Antigravity, Cline, Roo Code, GitHub Copilot, ChatGPT, etc.):**  
> If the user asked you to *"install"*, *"configure"*, or *"set up"* `claude-thinking` from this repository, you do not need to ask the user what to do. Detect which environment you are running in and execute the corresponding action from the lookup table below.

---

## ⚡ Fast Autonomous Decision Matrix

Identify which tool or IDE environment you are running under, then copy the specified files:

| Environment Detected | Source File(s) in this Repo | Destination Path | Scope |
|---|---|---|---|
| **Google Antigravity / Gemini CLI** | `SKILL.md`<br>`claude-thinking.md` | `~/.gemini/config/skills/claude-thinking/SKILL.md`<br>`~/.gemini/config/rules/claude-thinking.md` | Global (All user projects) |
| **Google Antigravity (Project-level)** | `SKILL.md`<br>`claude-thinking.md` | `.agents/skills/claude-thinking/SKILL.md`<br>`.agents/rules/claude-thinking.md` | Current workspace |
| **Anthropic Claude Code (Global)** | `adapters/CLAUDE.md`<br>`SKILL.md` | `~/.claude/CLAUDE.md`<br>`~/.claude/skills/claude-thinking/SKILL.md` | Global |
| **Anthropic Claude Code (Project)** | `adapters/CLAUDE.md` | `./CLAUDE.md` | Current workspace |
| **Cursor IDE** | `adapters/.cursorrules`<br>`SKILL.md` | `./.cursorrules` (or `.cursor/rules/claude-thinking.mdc`) | Current workspace |
| **Windsurf IDE** | `adapters/.windsurfrules` | `./.windsurfrules` | Current workspace |
| **Cline / Roo Code** | `adapters/.clinerules` | `./.clinerules` | Current workspace |
| **GitHub Copilot** | `adapters/COPILOT.md` | `.github/copilot-instructions.md` | Current workspace |
| **Universal Generic Agent** | `adapters/AGENTS.md` | `./AGENTS.md` | Current workspace |

---

## 🛠️ Automated Shell Execution (Optional)

If you have permission to execute shell commands in the terminal, you can simply run:

### Windows (PowerShell):
```powershell
# For current project workspace:
powershell -ExecutionPolicy Bypass -File ./install.ps1 -Scope project

# Or for global user profile (applies to all projects):
powershell -ExecutionPolicy Bypass -File ./install.ps1 -Scope global
```

### macOS / Linux / WSL (Bash):
```bash
# For current project workspace:
bash ./install.sh --project

# Or for global user profile:
bash ./install.sh --global
```

---

## 📋 Verification Step for AI Agents

Once you have copied the files:
1. Verify that the destination file exists and is readable.
2. In your next response to the user, confirm:
   - Which agent/IDE was detected
   - The exact destination path configured
   - That `claude-thinking (v5.1)` is now active for all future prompts
