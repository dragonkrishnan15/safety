# Task Contract Engine (`ct-contract.json`)

> **Core Philosophy (Gravitas Runtime Pattern):**  
> Never allow an AI agent to execute file modifications or terminal commands from a raw prompt. Before writing any code, the agent must instantiate a formal **Task Contract** that defines its boundaries, invariants, and allowed blast radius.

---

## 1. When is a Contract Required?
- **Mandatory**: Any task where `SIZE=standard` or `SIZE=complex`.
- **Optional / Inline**: `SIZE=trivial` (can be stated as a 2-line contract in the initial response).

---

## 2. The Contract File (`<tmp>/ct-contract.json`)

On startup of a `standard` or `complex` task, write the following JSON schema to `<tmp>/ct-contract.json`:

```json
{
  "task_id": "CT-20261016-01",
  "objective": "Clear, measurable description of what success looks like",
  "invariants": [
    "No breaking changes to existing public APIs",
    "All pre-existing green tests remain green",
    "Zero database schema mutations without explicit migration scripts",
    "Zero new external dependencies added without permission"
  ],
  "permitted_paths": [
    "src/modules/auth/**",
    "tests/modules/auth/**"
  ],
  "forbidden_paths": [
    ".env*",
    "config/secrets/**",
    "src/modules/billing/**",
    "package-lock.json"
  ],
  "stop_gate_command": "npm test -- tests/modules/auth"
}
```

---

## 3. The 4 Invariant Rules

1. **Permitted Paths Lockdown**:  
   The agent is strictly forbidden from editing, creating, or deleting files outside `permitted_paths`. If a fix requires touching another module, the contract must be explicitly amended with logged justification.

2. **Forbidden Paths Barrier**:  
   Any attempt to read or modify files matching `forbidden_paths` triggers an immediate policy exception.

3. **Invariants Checklist**:  
   Before the task can pass the Stop Gate, every item in `invariants` must be audited with concrete evidence.

4. **Stop Gate Binding**:  
   The `stop_gate_command` defines the deterministic verification command that must return exit code `0` for the task to be marked complete.
