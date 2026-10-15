# Scientific Debugging Protocol Reference

Protocol for diagnosing bugs, silent failures, regressions, and state-dependent defects.

## 1. Bug Classification
Classify the problem before touching any production code:
- **Deterministic Crash**: Throws an exception or panic on specific input.
- **Silent Wrong Output**: Completes with exit code 0 but returns incorrect data.
- **Data-Dependent**: Triggered only by specific edge cases or input encodings.
- **State-Dependent**: Fails only when preceded by specific historical actions or state machine transitions.
- **Concurrency / Race**: Non-deterministic failure under parallel execution.
- **Performance / Resource Leak**: Degrades over time or consumes excessive CPU/memory.

## 2. Capture the Evidence
- Exact error message, stack trace, and exit code.
- Inputs, parameters, environment flags, and seeds that reproduced the failure.
- Exact runtime version and dependencies.

## 3. Minimal Reproduction Script (Mandatory)
Write a standalone reproduction script or a failing unit test:
- Apply **Delta Debugging**: Repeatedly cut the failing input, configuration, or steps in half. Keep only what is required to reproduce the error.
- Remove external network, database, or heavy framework dependencies using fakes or in-memory stubs.
- Ensure the reproduction runs in seconds.

## 4. Make It Deterministic
- Fix pseudo-random seeds (`random.seed(42)`).
- Freeze clocks/time using test clock mocks.
- Run single-threaded to isolate race conditions from algorithmic bugs.
- If non-determinism persists, the concurrency/race window IS the primary clue.

## 5. Bisection Techniques
- **Git Bisect**: Use the minimal reproduction script as the automated oracle:
  `git bisect start; git bisect bad; git bisect good <commit>; git bisect run <repro-command>`
- **Midpoint Invariant Assertion**: In multi-stage processing, assert state invariants at the midpoint. Determine which half violates the contract first.

## 6. Hypothesis Ledger & Invariant Logging
Maintain an explicit ledger in `<tmp>/ct-state.json`:
- **Hypothesis**: "Function F calculates negative balance when currency is JPY due to missing zero-decimal rule."
- **Prediction**: "If currency is EUR, error will not reproduce; if JPY, balance is multiplied by 100."
- **Experiment**: Run repro with JPY vs EUR.
- **Result**: Confirmed.
- Temporary logging: Tag all debugging prints or assertions with `DEBUG-CT`.

## 7. Proving the Root Cause
- Write a regression test that FAILS before the fix and PASSES after the fix.
- Remove all `DEBUG-CT` temporary code before running the final verification.
- In the final report, state the root cause clearly:
  `"Root Cause: Function F failed because [X]; under condition [Y], [Z] occurred."`
