# Changelog

All notable changes to the **master-skill / safety** project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [5.2.0] - 2026-10-16

### Added
- **Active Enforcement Engine (CLI & Model Context Protocol Server)**:
  - `bin/safety.js`: Universal zero-dependency Node CLI (`safety gate`, `safety intercept`, `safety contract init`, `safety mesh`, `safety report`).
  - `bin/safety-mcp.js`: Standalone stdio JSON-RPC MCP server exposing deterministically enforced safety guardrails to any MCP-compliant agent.
  - Interceptor: Zero-Destruction Wall hard-blocking `git reset --hard`, `git clean -fd`, force-pushes, and root deletions before execution.
- **Multi-Agent Consensus & Mesh Locking Protocol**:
  - `scripts/mesh_lock.ps1` and `scripts/mesh_lock.sh`: Decentralized lock arbitration via `.master-skill/mesh-locks.json` with TTL auto-expiration and path collision detection.
  - Slash command `/ms-mesh` and reference guide `references/mesh-locks.md`.
- **Strengthened Stop Gate & Secret Scanner**:
  - Expanded regex pattern detection across OpenAI, Anthropic, Google, AWS, GitHub fine-grained PATs, Hugging Face, Slack webhooks, and database URIs.
  - AST-style anti-pattern checks catching swallowed exceptions and empty `catch` blocks in diffs.
  - Diff line count budgeting (`max_diff_lines`).
  - Isolated test command execution in `stop_gate.ps1` to prevent premature script exits.
- **Automated Cross-Platform Test Suite & CI Matrix**:
  - `tests/test_safety_cli.js`: End-to-end unit tests for CLI commands and interception policies.
  - `tests/test_stop_gate.ps1` & `.sh`: Integration tests for clean execution, test command failure propagation, and contract violations.
  - `tests/test_mesh_lock.ps1` & `.sh`: Concurrency conflict and lock acquisition tests.
  - Multi-platform GitHub Actions CI matrix across Ubuntu and Windows runners.
- **Dynamic Token-Efficient Slim Profile**:
  - `dist/SKILL.slim.md`: Condensed single-page profile (~120 lines / ~2K tokens) for fast/low-context models.

### Fixed
- Fixed documentation false positives in `scorecard.ps1` and `scorecard.sh` where markdown occurrences of `DEBUG-CT` were counted as unremoved code tags.

---

## [5.1.0] - 2026-10-16

### Added
- **Gravitas Zero-Trust Runtime Engine**:
  - `task-contract.json`: Structured boundaries defining `permitted_paths`, `forbidden_paths`, and `invariants`.
  - `ct-ledger.jsonl`: Immutable append-only verification trail linking evidence IDs (`[EV-xxx]`) to test outputs.
  - `Test Adversary`: Red-team fault injection suites for concurrency races, network chaos, and poison inputs.
  - `stop_gate.ps1` & `stop_gate.sh`: Automated pre-commit quality gate verifying zero debug tags, contract bounds, and diff efficiency.
- **Universal Multi-Agent Installation Matrix**:
  - AI Agent 1-Prompt auto-installation via `AGENT_INSTALL.md`.
  - 1-line curl/irm terminal installers for Windows (`install.ps1`) and macOS/Linux (`install.sh`).
  - Pre-commit git hook auto-installation blocking accidental commits of temporary debug tags.
- **Cross-Session Memory Subsystem**:
  - `.master-skill/memory.json`: High-density recall of architectural decisions and repo quirks across restarts.
  - Synchronized CLI helper scripts (`memory_sync.ps1`, `memory_sync.sh`).
- **Modern Governance Documentation**:
  - `ARCHITECTURE.md`: Complete sequence diagrams and 6-stage verification pipeline specification.
  - Interactive slash command shortcuts (`/master-skill`, `/ms-contract`, `/ms-adversary`, `/ms-stop`).

### Changed
- Rebranded framework to **master-skill / safety** with zero vendor lock-in.
- Hardened privacy: complete scrubbing of local usernames, hardcoded machine paths, and private emails across git commit history.
- Upgraded diff efficiency algorithm with automated churn ratio scorecards.

---

## [5.0.0] - 2026-09-15

### Added
- Multi-IDE adapter support for Cursor IDE, Windsurf, Claude Code, Antigravity IDE, and GitHub Copilot.
- Anti-Slop Design & Interface Engineering integration.
- Pre-mortem failure analysis protocol prior to file modifications.
- Failsafe atomic checkpoint and rollback engine.

---

## [4.0.0] - 2026-06-20

### Added
- Standard and Complex task branching workflows.
- Baseline test ledger tracking `KNOWN-RED`, `FLAKY`, and `GREEN` tests.
- Cross-platform shell adaptation guidelines (`shell.md`).

---

## [1.0.0] - 2026-01-10

### Added
- Initial release of structured AI cognitive engineering protocols.
