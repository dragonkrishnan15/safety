# Contributing to claude-thinking

Thank you for your interest in contributing to **claude-thinking**! Our mission is to elevate AI coding assistants into disciplined, reliable Principal Engineers across every language, stack, and development tool.

---

## 🛠️ How to Contribute

1. **New Agent / IDE Adapters**:
   - If you use a tool not currently supported (such as Continue.dev, Zed, Aider, etc.), create a new adapter in `adapters/`.
   - Update `AGENT_INSTALL.md`, `install.sh`, and `install.ps1`.
2. **Playbooks & Domain Guides**:
   - Add specialized guides under `references/playbooks.md` or as standalone reference documents.
3. **Bug Reports & Improvements**:
   - Open an issue describing the scenario, prompt, and how the failure mode occurred.

---

## 📐 Development Guidelines

- **Token Discipline**: Keep core rule files dense and high-signal. Avoid verbose boilerplate.
- **Cross-Platform Compatibility**: Always ensure scripts have both PowerShell (`.ps1`) and POSIX (`.sh`) implementations.
- **Zero-Leftover Policy**: Run `scripts/leftover_check.sh` (or `.ps1`) before submitting a pull request to ensure zero temporary tags or trailing whitespace.

---

## 🧪 Submitting a Pull Request

1. Fork the repository and create your branch from `main`:
   ```bash
   git checkout -b feat/my-new-adapter
   ```
2. Commit your changes with clear, descriptive commit messages.
3. Push to your fork and submit a Pull Request to `main`.
