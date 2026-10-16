# Roadmap: master-skill / safety

This roadmap outlines the planned capabilities, security enhancements, and framework integrations for **master-skill / safety**.

---

## 🎯 Completed Milestone: v5.2 (Apex Mesh & Active Governance)

- [x] **Multi-Agent Consensus & Mesh Locking Protocol**:
  - Decentralized invariant locking via `.master-skill/mesh-locks.json` across concurrent agents (Cursor, Claude Code, Antigravity, Cline).
  - Native scripts `scripts/mesh_lock.ps1` and `scripts/mesh_lock.sh` with TTL auto-expiration and collision detection.
- [x] **Active Enforcement Engine (Zero-Dependency CLI & MCP Server)**:
  - Universal executable `bin/safety.js` (`safety gate`, `safety intercept`, `safety contract init`, `safety mesh`, `safety report`).
  - Native stdio JSON-RPC Model Context Protocol server `bin/safety-mcp.js`.
- [x] **Automated Diff Budget & Enhanced Secret Scanner**:
  - Enforce diff line budgets (`max_diff_lines`) and anti-pattern detection (swallowed catch blocks) in `stop_gate.ps1 / .sh`.
  - Expanded secret regex patterns covering OpenAI, Anthropic, Google, AWS, GitHub PATs, Hugging Face, Slack webhooks, and database URIs.
- [x] **Comprehensive Cross-Platform Test Suite & CI Matrix**:
  - Integration test suites in `tests/` for CLI, Stop Gate, and Mesh Locks across Windows (PowerShell) and Ubuntu (POSIX Bash).
- [x] **Dynamic Token-Efficient Slim Profile**:
  - `dist/SKILL.slim.md` for fast, lightweight frontier models (Flash, Haiku, GPT-4o-mini).

---

## 🔮 Active Milestone: v5.3 (Cryptographic Proof of Verification & SDKs)

- [ ] **Native TypeScript & Python SDKs**:
  - Lightweight programmatic wrappers (`npm install @safety/core`, `pip install safety-agent-guard`).
  - Native runtime hooks for LangChain, LlamaIndex, AutoGen, and CrewAI.

---

## 🔮 Future Milestone: v5.3 (Cryptographic Proof of Verification)

- [ ] **Hardware-Backed / GPG Evidence Signing**:
  - Digitally sign `ct-ledger.jsonl` entries with GPG / SSH keys to guarantee tamper-proof audit trails.
- [ ] **Semantic Contract Linter**:
  - AST-level validation ensuring that modified code adheres to explicit contracts (e.g. verifying that Knex/Prisma mutations are enclosed in transaction scopes).
- [ ] **Visual Terminal Dashboard**:
  - Real-time curses/TUI progress monitor rendering active gate metrics during automated agent runs.

---

## 🤝 Community Feedback & Feature Requests

Have a feature idea or want to see support for a new AI coding harness?
Open an issue using our [Feature Request Template](.github/ISSUE_TEMPLATE/adapter_request.md).
