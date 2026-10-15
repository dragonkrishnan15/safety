# The Evidence Chain & Immutable Ledger

> **Core Philosophy (Gravitas Runtime Pattern):**  
> "Trust, but verify" is dead in AI engineering.  
> **Never trust agent self-reports.** Every claim made in a task report must cite a concrete, immutable **Evidence ID (`[EV-xxx]`)** recorded in the session ledger.

---

## 1. The Session Ledger (`<tmp>/ct-ledger.jsonl`)

The agent records all significant tool executions, test outputs, and browser checks as append-only JSONL events.

### Ledger Event Format:
```json
{"ev_id": "EV-001", "type": "baseline_test", "cmd": "npm test", "exit_code": 0, "summary": "42 passed, 0 failed"}
{"ev_id": "EV-002", "type": "adversary_test", "cmd": "pytest tests/test_concurrency.py", "exit_code": 0, "summary": "50 concurrent requests handled safely"}
{"ev_id": "EV-003", "type": "visual_browser", "url": "http://localhost:3000", "console_errors": 0, "screenshot": "tmp/audit_01.png"}
{"ev_id": "EV-004", "type": "stop_gate", "cmd": "./scripts/stop_gate.ps1", "exit_code": 0, "summary": "Clean diff, invariants satisfied"}
```

---

## 2. The Strict Citation Rule

When writing the final report, **every statement about verification must explicitly cite an Evidence ID**:

### ❌ Rejected (Vague / Unverified Claims):
- *"I tested the code and all tests pass."*
- *"The UI looks great with no issues."*
- *"The bug is resolved."*

### ✅ Accepted (Evidence-Citing Claims):
- *"All unit tests pass without regressions [EV-001: npm test - 42 passed, exit 0]."*
- *"Adversarial concurrency attack was repelled [EV-002: 50 concurrent requests handled without mutex deadlock]."*
- *"Visual browser audit confirmed 0 console errors and responsive layout [EV-003: screenshot saved to tmp/audit_01.png]."*
- *"Programmatic Stop Gate passed with 0 invariant violations [EV-004: exit 0]."*

> **Rule:** Any claim without an Evidence ID is categorized as an **UNVERIFIED ASSUMPTION**.
