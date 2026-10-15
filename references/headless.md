# Headless / Unattended Execution Reference (RUN=headless)

Procedures for non-interactive environments, background tasks, CI runs, and automated pipelines.

## 1. When RUN=headless Applies
Apply `RUN=headless` when:
- The task prompt contains flags or keywords: `headless`, `unattended`, `background`, `CI`, `no-prompt`, `batch`.
- You are running inside an automated harness where no human reply can be received.
- In interactive runs: if an escalation question was asked and no reply is received while all unblocked work has completed, the task converts to headless rules for the escalated decision.

---

## 2. Headless Escalation Classes

When an item in the Escalation Matrix fires during a headless run:

### Class NEVER: Immediate Hard Stop on That Action
- Never execute destructive actions, table drops, force pushes, production writes, secret access, or live credential handling.
- Write the exact proposed command and reason for deferral to `<tmp>/HANDOFF.md`.
- Mark the action as `BLOCKED-NEEDS-HUMAN-EXECUTION`.

### Class GO: Proceed Autonomously with Safe Default
- Choose the most conservative, reversible, precedent-following path.
- In APIs: Choose the **additive** path (do not break existing contracts).
- In Dependencies: Use zero-dependency implementation if viable.
- Log the decision and rationale into `<tmp>/ct-state.json` under `assumptions`.

### Class PARK: Isolate and Defer
- Skip the divergent or breaking portion of the task.
- Proceed with all independent, unblocked subtasks.
- Record the parked items, unresolved questions, and next steps in `<tmp>/HANDOFF.md`.

---

## 3. Persistent State & Artifacts

### State Serialization (`<tmp>/ct-state.json`)
Store continuous progress outside the repo:
```json
{
  "gate": "[ACCESS write][RUN headless][SIZE standard][SHELL pwsh]",
  "base_sha": "a1b2c3d4",
  "baseline_ledger": {
    "GREEN": ["tests/unit/test_auth.py"],
    "KNOWN-RED": ["tests/integration/test_payment.py"],
    "FLAKY": []
  },
  "assumptions": [
    "Used additive query parameter 'version=2' to prevent breaking API contract."
  ],
  "parked_items": [
    "Row 3 Escalation: Deprecation of legacy /v1 endpoint deferred to human review."
  ]
}
```

### Self-Contained Exit Document (`<tmp>/HANDOFF.md`)
On task completion, ensure `<tmp>/HANDOFF.md` contains:
1. Executive summary of implemented changes.
2. Exact test verification commands executed and baseline comparison.
3. Parked items requiring human input.
4. Exact copy-paste commands for manual execution of any NEVER-class actions.
