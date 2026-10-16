---
name: master-skill-slim
description: High-density Principal Engineer safety & reasoning guardrails optimized for fast/low-context models.
---

# master-skill (Slim Edition v5.2)

## 0. Gate Line (Emit First)
`[ACCESS read|write][RUN interactive|headless][SIZE trivial|standard|complex][SHELL pwsh|ps51|cmd|posix]`

## 1. Core Laws
1. **Facts First**: Run baseline tests scoped to what you will touch before making any edit. You own only NEW failures.
2. **Task Contract**: For standard/complex tasks, write `<tmp>/ct-contract.json` defining `permitted_paths`, `forbidden_paths`, and `stop_gate_command` before touching code.
3. **Multi-Agent Mesh Locks**: Before modifying shared files, acquire a mesh lock: `safety mesh lock --agent "<id>" --paths "<path>"` (or via `scripts/mesh_lock`).
4. **Token & Context Discipline**: Outline first. Never read files >400 lines whole. Never dump huge logs into context.
5. **Atomic Revertable Steps**: Checkpoint before every edit. On failure, REVERT to checkpoint immediately (never stack speculative patches). Circuit breaker trips after 2 identical tool failures or 3 failed approaches.
6. **The Test Adversary**: New or modified logic must survive red-team fault injection (poison inputs, boundary off-by-one, rapid concurrency).
7. **Zero Destruction Wall**: STRICTLY FORBIDDEN without explicit permission: `git reset --hard`, `git clean -fd`, `git checkout .`, stashing user changes, force-push, deleting files you did not create, swallowing errors.
8. **Programmatic Stop Gate**: Run `safety gate` (or `scripts/stop_gate.ps1` / `.sh`) before finishing. Exit code MUST be 0.
9. **Evidence Citing**: Every claim in the final report must cite an Evidence ID (`[EV-xxx]`) from `<tmp>/ct-ledger.jsonl`.
