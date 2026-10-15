# Mandatory Regression Harness Reference (Bug Fixes)

Protocol for permanently immunizing the codebase against recurring defects by writing automated regression tests.

## 1. The Core Law of Bug Fixing
**A bug fix is not complete without an automated regression test.**
If a bug cannot be reproduced by a test, the fix cannot be proven, and future refactors will inevitably reintroduce the defect.

---

## 2. Regression Test Anatomy

Every regression test must adhere to 4 criteria:
1. **Name Explains Root Cause**:
   - Good: `test_token_refresh_succeeds_when_expiry_within_clock_skew_window`
   - Bad: `test_token_bug` or `test_fix_123`
2. **Minimal Failing Fixture**:
   - Use the isolated input payload identified during Phase 6 Scientific Debugging (Delta Debugging).
   - Zero unnecessary boilerplate; only the properties required to trigger the edge case.
3. **Asserts the Invariant**:
   - Explicitly asserts the business rule that was violated (e.g. `expect(user.balance).toBeGreaterThanOrEqual(0)`).
4. **Permanent Placement**:
   - Place the test inside the project's permanent unit/integration test suite alongside related features—NOT in a temporary scratch script.

---

## 3. The Two-Phase Proof

Before concluding Phase 5 (Verify):
1. **Failure Proof**: Check out the commit *before* the fix (or revert fix temporarily), run the regression test, and confirm it **FAILS** with the exact bug symptom.
2. **Success Proof**: Re-apply the fix, run the regression test, and confirm it **PASSES** cleanly.
3. State in the final report:
   `"Verified with regression test: <test_name> (FAILED on pre-fix code, PASSED on fixed code)."`
