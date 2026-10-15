# Changelog

All notable changes to the **master-skill / safety** project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
