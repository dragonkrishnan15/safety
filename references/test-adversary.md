# The Test Adversary (Red-Team Fault Injection Protocol)

> **Core Philosophy (Gravitas Runtime Pattern):**  
> Coding models suffer from severe confirmation bias — they write tests that only verify their own assumptions.  
> The **Test Adversary** persona breaks this cycle by forcing the agent to roleplay as a hostile QA engineer or malicious attacker whose sole goal is to crash the implementation.

---

## 1. When to Activate the Test Adversary

Activate immediately after the implementation step passes its initial happy-path unit test.  
Before calling `scripts/stop_gate`, the agent must submit its code to the **Adversary Gate**.

---

## 2. The 5 Adversary Attack Vectors

The agent must pick at least **2 attack vectors** relevant to the task and author concrete test cases targeting them:

| Attack Vector | What to Inject | Example Test Case |
|---|---|---|
| **Poison Inputs & Type Confusion** | Null bytes, empty strings, extremely large integers ($2^{63}-1$), unicode homoglyphs, malformed JSON. | Pass `""`, `null`, `NaN`, `{"$gt": ""}` to the parser/handler. |
| **Concurrency & Race Conditions** | Parallel requests, duplicate clicks, rapid double-submit, simultaneous read/write. | Fire 50 concurrent async requests to test mutex / transaction boundaries. |
| **Boundary & Off-by-One** | Index 0, Index $N-1$, Index $N$, arrays with 0 elements, arrays with $10^5$ items. | Test slicing, pagination offsets, and loop termination limits. |
| **Partial Failure & Drops** | Socket timeout, simulated network drop, disk full, aborted HTTP connection mid-stream. | Mock an exception in the 3rd step of a multi-step operation to verify rollback. |
| **Idempotency & Replay** | Same API call repeated 3 times with the exact same payload. | Verify duplicate payment/event handling produces 0 duplicate records. |

---

## 3. The Adversary Verification Rule

1. Write the adversarial test.
2. Run it against the current implementation.
3. If the test passes without breaking the code, document the resilience in the report.
4. If the test reveals an unhandled crash or state corruption:
   - Mark as **REPRODUCED ADVERSARIAL DEFECT**.
   - Apply a clean atomic fix.
   - Re-run the test to prove it now passes cleanly.
