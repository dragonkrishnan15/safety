# 🤖 AI Agent Automated Installation Manifest

> **Notice to AI Agents (Claude Code, Cursor, Windsurf, Antigravity, Cline, Roo Code, GitHub Copilot, ChatGPT, etc.):**  
> If the user asked you to *"install"*, *"configure"*, or *"set up"* `master-skill` from this repository, you do not need to ask the user what to do. Detect which environment you are running in and execute the corresponding action from the lookup table below.

---

## ⚡ Fast Autonomous Decision Matrix

Identify which tool or IDE environment you are running under, then copy the specified files:

| Environment Detected | Source File(s) in this Repo | Destination Path | Scope |
|---|---|---|---|
| **Google Antigravity / Gemini CLI** | `SKILL.md`<br>`master-skill.md` | `~/.gemini/config/skills/master-skill/SKILL.md`<br>`~/.gemini/config/rules/master-skill.md` | Global (All user projects) |
| **Google Antigravity (Project-level)** | `SKILL.md`<br>`master-skill.md` | `.agents/skills/master-skill/SKILL.md`<br>`.agents/rules/master-skill.md` | Current workspace |
| **Anthropic Claude Code (Global)** | `adapters/CLAUDE.md`<br>`SKILL.md` | `~/.claude/CLAUDE.md`<br>`~/.claude/skills/master-skill/SKILL.md` | Global |
| **Anthropic Claude Code (Project)** | `adapters/CLAUDE.md` | `./CLAUDE.md` | Current workspace |
| **Cursor IDE** | `adapters/.cursorrules`<br>`SKILL.md` | `./.cursorrules` (or `.cursor/rules/master-skill.mdc`) | Current workspace |
| **Windsurf IDE** | `adapters/.windsurfrules` | `./.windsurfrules` | Current workspace |
| **Cline / Roo Code** | `adapters/.clinerules` | `./.clinerules` | Current workspace |
| **GitHub Copilot** | `adapters/COPILOT.md` | `.github/copilot-instructions.md` | Current workspace |
| **Universal Generic Agent** | `adapters/AGENTS.md` | `./AGENTS.md` | Current workspace |

---

## 🛠️ Automated Shell Execution (Fastest & Recommended)

If you have permission to execute shell commands in the terminal, execute the official setup wizard:

### Cross-Platform (Zero-Dependency NPX):
```bash
npx @dragonkrishnan15/safety init
```

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

Once you have copied the files or run the installer:
1. Verify that the destination file exists and is readable.
2. Run the programmatic stop gate to ensure full compliance:
   - If Node is available: `node bin/safety.js gate`
   - Windows PowerShell: `powershell -ExecutionPolicy Bypass -File ./scripts/stop_gate.ps1`
   - Linux/macOS: `bash ./scripts/stop_gate.sh`
3. In your next response to the user, confirm:
   - Which agent/IDE was detected
   - The exact destination path configured
   - That **`master-skill (v5.2 Apex Mesh Edition)`** is now active for all future prompts
   - Emit your initial gate line: `[ACCESS read][RUN interactive][SIZE standard][SHELL ...]`
