<div align="center">

<!-- Animated Hero Header -->
<img src="assets/animated_hero_header.svg" alt="SAFETY Animated Hero Header" width="100%" />

<br/><br/>

<!-- Modern Shields Badges -->
[![CI Validation](https://github.com/dragonkrishnan15/safety/actions/workflows/ci.yml/badge.svg)](https://github.com/dragonkrishnan15/safety/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-Welcome-brightgreen.svg)](CONTRIBUTING.md)
[![Zero Vendor Lock-in](https://img.shields.io/badge/Vendor%20Lock--in-Zero-blueviolet.svg)](#-universal-compatibility)
[![Secret Scanning](https://img.shields.io/badge/Secret%20Scanner-Active-success.svg)](#-live-animated-terminal-simulation)
[![Release: v5.2 Apex Mesh](https://img.shields.io/badge/Release-v5.2%20Apex%20Mesh-cyan.svg)](CHANGELOG.md)

<p align="center">
  <b>Converts AI coding assistants from unconstrained token generators into disciplined, sandboxed Principal Engineers.</b><br/>
  Enforces immutable task contracts, red-team chaos testing, multi-agent mesh locks, active MCP interception, and zero-leak stop gates.
</p>

[**🚀 Quickstart**](#-instant-installation) • [**🛠️ CLI & MCP**](#-the-safety-cli--mcp-server) • [**⚡ Animated Flow**](#-interactive-animated-pipeline) • [**🛡️ Feature Cards**](#-core-capabilities--runtime-guards) • [**🤖 Supported Agents**](#-supported-ai-agents) • [**📐 Architecture**](ARCHITECTURE.md)

</div>

---

## 🖥️ Live Animated Terminal Simulation

<div align="center">
  <img src="assets/terminal_simulation.svg" alt="Animated Stop Gate Terminal" width="100%" style="border-radius: 12px; box-shadow: 0 10px 30px rgba(0, 242, 254, 0.15);" />
</div>

---

## ⚡ Interactive Animated Pipeline

Data packets travel through 6 deterministic governance gates before any code reaches production:

<div align="center">
  <img src="assets/animated_pipeline_flow.svg" alt="Animated 6-Stage Pipeline Flow" width="100%" style="border-radius: 12px; margin: 12px 0;" />
</div>

---

## 🛡️ Core Capabilities & Runtime Guards

<div align="center">
  <img src="assets/animated_feature_cards.svg" alt="Animated Feature Cards" width="100%" style="border-radius: 12px; margin: 12px 0;" />
</div>

---

## 🤖 Supported AI Agents

Active real-time zero-trust interception across all major coding environments:

<div align="center">
  <img src="assets/animated_agent_matrix.svg" alt="Supported AI Agents Matrix" width="100%" style="border-radius: 12px; margin: 12px 0;" />
</div>

---

## ⚡ The Core Problem vs. The SAFETY Solution

<table>
<tr>
<th width="50%" align="center">❌ Unchecked "Vibe Coding" AI Agents</th>
<th width="50%" align="center">✅ Sandboxed Principal AI with SAFETY</th>
</tr>
<tr>
<td>

- **Hallucinated Passes**: Claims "Fixed and verified!" without ever executing tests.
- **Speculative Patch Stacking**: When tests fail, stacks random edits until code breaks completely.
- **Data Leaks & Secrets**: Commits API keys, local credentials, and internal tokens to GitHub.
- **Scope Creep & Churn**: Refactors untouched files, deletes unrelated tests, and reformats entire directories.
- **Fragile Happy-Path Tests**: Writes trivial mocks that pass locally but implode under real production load.

</td>
<td>

- **Proof-Backed Evidence**: Every assertion must cite a verifiable Evidence ID (`[EV-xxx]`) in `ct-ledger.jsonl`.
- **Atomic Failsafe Rollbacks**: On failure, instantly reverts to clean checkpoint instead of stacking blind edits.
- **Zero-Leak Secret Scanner**: Automatically intercepts API keys (`ghp_`, `sk-`, `AIza`, `AKIA`) before git commits.
- **Strict Contract Boundaries**: Hard blocks unauthorized file writes outside configured `permitted_paths`.
- **The Test Adversary**: Stress-tests code with 30-50 concurrent async workers, poison inputs, and network latency.

</td>
</tr>
</table>

---

## 📐 Deep-Dive System Architecture

<div align="center">
  <img src="assets/architecture_infographic.jpg" alt="Zero-Trust Architecture Infographic" width="100%" style="border-radius: 12px; margin: 16px 0; box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5);" />
</div>

For full technical specifications and state transition diagrams, view [**`ARCHITECTURE.md`**](ARCHITECTURE.md).

---

## 🚀 Instant Installation

### 🤖 Method 1: The "1-Prompt" AI Magic Installer (Zero Terminal, 100% Autonomous)

> **For Users**: Simply copy and paste the block below into **Cursor Composer / Chat**, **Claude Code**, **Windsurf Cascade**, **Google Antigravity**, **Cline / Roo Code**, or **GitHub Copilot**. Your AI assistant will detect your editor, install the correct rules, configure git pre-commit quality gates, and verify the installation autonomously:

```markdown
Please install and activate the @dragonkrishnan15/safety governance framework (master-skill v5.2) in this workspace. Follow these steps autonomously without asking me for intermediate confirmation:

1. READ THE MANIFEST: Fetch and read the installation instructions from:
   https://raw.githubusercontent.com/dragonkrishnan15/safety/main/AGENT_INSTALL.md

2. INSTALLATION PATH:
   - If you have terminal/shell execution tools: Run `npx @dragonkrishnan15/safety init` (or on Windows: `powershell -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/dragonkrishnan15/safety/main/install.ps1 | iex"`; on Linux/macOS: `curl -fsSL https://raw.githubusercontent.com/dragonkrishnan15/safety/main/install.sh | bash`).
   - If you only have file-write/edit tools: Determine which IDE environment I am running (Cursor, Claude, Windsurf, Antigravity, Cline, or Copilot), download the corresponding adapter from https://raw.githubusercontent.com/dragonkrishnan15/safety/main/adapters/ (e.g. .cursorrules, CLAUDE.md, .windsurfrules, or AGENTS.md), and write it to the repository root.

3. ACTIVATE SAFETY GATES:
   - Ensure `ct-contract.json` is created at the repository root defining permitted paths.
   - Run the stop gate verification (`node bin/safety.js gate` or `./scripts/stop_gate.ps1` / `./scripts/stop_gate.sh`) to confirm 0 debug tags, 0 secret leaks, and clean invariants.

4. CONFIRMATION:
   Once completed, reply confirming which IDE adapter was installed, and emit your first principal-engineer gate line:
   `[ACCESS read][RUN interactive][SIZE standard][SHELL ...]`
```

---

### ⚡ Method 2: 1-Command Instant Setup (Zero-Config NPX)
Run this in any local project terminal to auto-detect your editor, drop required adapters, register git pre-commit quality gates, and initialize your task contract in 3 seconds:

```bash
npx @dragonkrishnan15/safety init
```

---

### 💻 Method 3: One-Line Terminal Command (Automated)

#### 🪟 Windows (PowerShell):
```powershell
irm https://raw.githubusercontent.com/dragonkrishnan15/safety/main/install.ps1 | iex
```
*Or install globally across all user projects:*
```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/dragonkrishnan15/safety/main/install.ps1))) -Scope global
```

#### 🍎 macOS / Linux / WSL (Bash):
```bash
curl -fsSL https://raw.githubusercontent.com/dragonkrishnan15/safety/main/install.sh | bash
```
*Or install globally across all user projects:*
```bash
curl -fsSL https://raw.githubusercontent.com/dragonkrishnan15/safety/main/install.sh | bash -s -- --global
```

---

### 🏃 Method 4: Instant Quickstart Runner
Run the interactive onboarder directly in your local clone:
```powershell
# Windows
.\quickstart.ps1

# macOS / Linux / WSL
bash ./quickstart.sh
```

---

## 🛠️ The Safety CLI & MCP Server

SAFETY ships with a zero-dependency CLI (`bin/safety.js`) and a native **Model Context Protocol (MCP)** server (`bin/safety-mcp.js`).

### CLI Commands:
```bash
# 1. Execute the full pre-commit stop gate audit
safety gate --test "npm test"

# 2. Pre-execution zero-destruction wall (blocks dangerous / secret commands)
safety intercept "git reset --hard HEAD"   # -> BLOCKED (Destructive reset forbidden)
safety intercept "npm run test"            # -> ALLOWED

# 3. Decentralized multi-agent mesh locking
safety mesh lock --agent "cursor" --paths "src/api/**" --task "Auth overhaul"
safety mesh status
safety mesh unlock --agent "cursor"

# 4. View diff health & verification scorecard
safety report
```

### Model Context Protocol (MCP) Integration:
Configure the MCP server to give your AI assistants real-time, deterministic tool interception:

```json
{
  "mcpServers": {
    "safety": {
      "command": "node",
      "args": ["<path-to-safety>/bin/safety-mcp.js"]
    }
  }
}
```

---

## ⚡ Interactive Chat Slash Commands

When working in interactive chat environments (Cursor, Claude Code, Antigravity, Windsurf), you can use these shortcuts:

| Command | Action Performed |
|:---|:---|
| **`/master-skill`** (or **`/ms`**) | Forces full zero-trust triage and cognitive reasoning on the active task |
| **`/ms-contract`** | Generates or validates `ct-contract.json` bounds for the current task |
| **`/ms-mesh`** | Acquires, checks, or releases Multi-Agent Mesh Locks (`.master-skill/mesh-locks.json`) |
| **`/ms-adversary`** | Injects red-team fault simulations (concurrency, poison inputs, latency drops) |
| **`/ms-stop`** | Executes `safety gate` pre-commit audit and renders diff health scorecard |
| **`/ms-report`** | Formats verified report citing Evidence IDs (`[EV-xxx]`) from the ledger |

---

## ⚡ High-Density Slim Profile (`profiles/SKILL.slim.md`)

For fast, cost-effective models (Claude 3.5 Haiku, Gemini Flash, GPT-4o-mini), load our compact 1-page profile:
- Located at [`profiles/SKILL.slim.md`](profiles/SKILL.slim.md) (~120 lines / ~2K tokens).
- Retains 100% of the Zero-Destruction Wall, Task Contracts, and Stop Gates with 80% fewer tokens.

---

## 📋 Production-Ready Boilerplate Templates

The repository includes ready-to-use production templates in [`templates/`](templates/):

- [`contract.template.json`](templates/contract.template.json): Task contract schema specifying permitted paths, forbidden paths, and invariants.
- [`ledger.template.jsonl`](templates/ledger.template.jsonl): Append-only cryptographic evidence ledger.
- [`adversary_test.py`](templates/adversary_test.py): Python red-team suite injecting 30 concurrent workers and poison inputs.
- [`adversary_test.ts`](templates/adversary_test.ts): TypeScript/JavaScript suite testing 50 concurrent async promises under latency.

---

<div align="center">

### 🌟 Star this repository on GitHub!
If you believe AI coding agents should be reliable, sandboxed, and disciplined, give this repo a star!

[**GitHub: dragonkrishnan15/safety**](https://github.com/dragonkrishnan15/safety) • [**Issues**](https://github.com/dragonkrishnan15/safety/issues) • [**Contributing Guide**](CONTRIBUTING.md)

Distributed under the [MIT License](LICENSE).

</div>
