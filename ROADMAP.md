# Roadmap: master-skill / safety

This roadmap outlines the planned capabilities, security enhancements, and framework integrations for **master-skill / safety**.

---

## 🎯 Active Milestone: v5.2 (Zero-Trust Observability & Mesh Governance)

- [ ] **Multi-Agent Consensus Protocol**:
  - Enable peer-review verification when multiple AI agents (e.g. Cursor + Claude Code + Antigravity) work concurrently in the same repository.
  - Decentralized invariant locking via `.master-skill/mesh-locks.json`.
- [ ] **Automated Performance Budget Checks**:
  - Enforce bundle-size and memory consumption budgets in `stop_gate.ps1 / .sh`.
  - Alert when additions exceed pre-configured kilobyte limits.
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
