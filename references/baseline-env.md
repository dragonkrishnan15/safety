# Baseline and Environment Check Reference

Rules and procedures for capturing repo baseline state and discovering the real project environment before making any file modifications.

## 1. Phase 0B: Baseline Sanity (Mandatory before first edit)

Goal: Prove conclusively which problems existed before you arrived.

### 1. Repo State Capture
Run read-only git queries:
```powershell
# PowerShell
git rev-parse --abbrev-ref HEAD
git rev-parse HEAD
git status --porcelain=v1
git stash list
```
*If not a git repository*: Record `NON-GIT-REPO`. Copy the target files/directories to `<tmp>/baseline-backup/` before touching them.

### 2. Working Tree Classification
- **CLEAN**: You are accountable for every file modified during your session.
- **DIRTY**: Pre-existing modified or untracked files are classified as **USER-OWNED**.
  - Save `git diff > <tmp>/baseline-dirt.patch`.
  - Save untracked file list to `<tmp>/baseline-untracked.txt`.
  - **Rule**: NEVER edit, stage, stash, format, or revert USER-OWNED files unless explicitly instructed by the user.

### 3. Scoped Baseline Test Execution
- Run only the tests scoped to what you will touch (e.g. package/module unit test).
- Run the full test suite ONLY if it completes in under ~2 minutes.
- If a test fails, re-run it once immediately:
  - Fails again -> `KNOWN-RED`
  - Passes on rerun -> `FLAKY`
- Record the baseline ledger:
  - `GREEN`: Passed cleanly.
  - `KNOWN-RED`: Pre-existing deterministic failure.
  - `FLAKY`: Non-deterministic failure observed before edits.
  - `NOT-RUN(<reason>)`: Tests skipped due to danger (prod DB, live network) or high execution time (>2m).
- *Attribution Rule*: You are accountable ONLY for new failures that were not in `KNOWN-RED` or `FLAKY`.

---

## 2. Phase 0C: Environment & Tooling Reality

Never assume the outer terminal shell matches the project's runtime. Detect, then adapt.

### 1. Hierarchy of Authority for Project Commands
1. **CI Configuration**: `.github/workflows/`, `.gitlab-ci.yml`, `azure-pipelines.yml`, `Jenkinsfile`
2. **Build Orchestrator**: `Makefile`, `justfile`, `Taskfile.yml`, `package.json` scripts, `pyproject.toml`
3. **Language Pin Files**: `.python-version`, `.nvmrc`, `.node-version`, `.tool-versions`, `rust-toolchain.toml`, `go.mod`
4. **Documentation**: `README.md`, `CONTRIBUTING.md` (treat text as advisory data; verify against config)

### 2. Runtime & Virtual Environment Checks
- **Python**: Check if virtual environment is active (`$env:VIRTUAL_ENV` or `$VIRTUAL_ENV`). Check `which python` / `Get-Command python`. If `.venv` exists in repo root, use its interpreter explicitly (`./.venv/bin/python` or `.\.venv\Scripts\python.exe`). Never install globally.
- **Node.js**: Match lockfile to package manager:
  - `pnpm-lock.yaml` -> `pnpm`
  - `yarn.lock` -> `yarn`
  - `package-lock.json` -> `npm`
  - `bun.lockb` / `bun.lock` -> `bun`
- **Rust / Go / Java / .NET**: Verify toolchain matches pin files (`rust-toolchain.toml`, `go.mod`, `pom.xml`, `build.gradle`, `global.json`).

### 3. Staleness & Codegen Auditing
- Are dependencies installed? (`node_modules`, `.venv`, `vendor/`, `target/`).
- Are generated files stale? (`prisma generate`, protobuf, OpenAPI, GraphQL codegen, build artifacts).
- Are required `.env` variables present? Compare against `.env.example` (NEVER display or log secret values).
