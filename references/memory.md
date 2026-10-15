# Cross-Session Project Memory Reference

Protocol for persisting and recalling repository-specific knowledge, architectural invariants, framework quirks, and past lessons across separate AI sessions.

## 1. Memory Store Location & Structure

Memory is stored locally in the project repository under:
`.master-skill/memory.json` (or `.ct-memory.json` at root if directory creation is restricted).
*If the repository has a `.gitignore`, ensure `.master-skill/` is tracked or ignored based on team preference (tracked if shared team conventions, ignored if developer-local).*

### Schema:
```json
{
  "project_name": "my-app",
  "updated_at": "2026-10-15T18:40:00Z",
  "architectural_decisions": [
    "State management: Zustand stores in src/stores/; Redux is deprecated.",
    "Database mutations: Always wrapped in explicit Knex transactions."
  ],
  "learned_quirks": [
    "Vite proxy requires changeOrigin: true to prevent 401 on /api routes.",
    "Tailwind v4 requires @import 'tailwindcss' in index.css without postcss.config."
  ],
  "tooling_preferences": {
    "package_manager": "pnpm",
    "test_command": "pnpm test:unit",
    "lint_command": "pnpm lint"
  },
  "historical_known_red": [
    "tests/e2e/flaky-payment.spec.ts fails on Windows CI due to timeout"
  ]
}
```

---

## 2. Phase 0C: Memory Recall Protocol

When entering Phase 0C (Environment & Tooling Reality):
1. **Probe for Memory File**: Check if `.master-skill/memory.json` exists.
2. **If Found**: Read `architectural_decisions`, `learned_quirks`, and `tooling_preferences`.
3. **Log Recall**: In the Phase 0 Gate output, log:
   `[MEMORY] Recalled 2 architectural decisions and 1 known quirk from .master-skill/memory.json`
4. **Constraint Enforcement**: Automatically apply recalled decisions to Phase 1 (Understand) and Phase 3 (Plan). Never violate a documented architectural decision without explicit user authorization.

---

## 3. Phase 7: Memory Recording Protocol

During Phase 7 (Self-Review & Report), evaluate if new persistent knowledge was uncovered:

### Triggers to Record Knowledge:
- A non-obvious framework bug, library quirk, or environment fix was discovered.
- An explicit architectural preference was chosen or confirmed by the user.
- A pre-existing flaky test was identified.

### Recording Action:
Run `scripts/memory_sync.ps1` (or update `.master-skill/memory.json`):
- Append new items to the appropriate list.
- Keep entries strictly **1 sentence each** (high signal, zero fluff).
- Avoid recording temporary task state or trivial variable names.
