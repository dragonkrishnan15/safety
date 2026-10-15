# Bounded Flake Verification Reference

Protocol for isolating, measuring, and verifying non-deterministic tests and concurrency bugs without hitting tool timeouts.

## 1. Why Fixed 100 Runs Fails
Requiring 100 sequential runs for a 10-second test suite takes over 16 minutes, causing timeouts and context exhaustion. Bounded flake verification uses **statistical confidence intervals** and a **strict time budget**.

## 2. Statistical Sample Sizing

Let $p$ be the baseline failure rate measured during reproduction:
$p = \frac{\text{Failures}}{\text{Reproduction Iterations}}$

To achieve 99% confidence ($1 - (1-p)^K \ge 0.99$) that a fix eliminated the flake:
$K \approx \left\lceil \frac{\ln(0.01)}{\ln(1 - p)} \right\rceil$

- If $p = 0.50$ (50% fail rate): $K = 7$ clean runs.
- If $p = 0.20$ (20% fail rate): $K = 21$ clean runs.
- If $p = 0.10$ (10% fail rate): $K = 44$ clean runs.
- If $p = 0.02$ (2% fail rate): $K = 228$ clean runs (requires concurrency or time-capping).

## 3. Time Budget & Capping Rule

- **Interactive Budget**: Maximum 60 seconds total execution time for flake verification.
- **Headless Budget**: Maximum 180 seconds total execution time.
- If single-run duration is $T$ seconds:
  $\text{Max Runs} = \min\left(K, \left\lfloor \frac{\text{TimeBudget}}{T} \right\rfloor, 100\right)$
- If the time budget allows fewer runs than $K$, report the achieved confidence level:
  $\text{Confidence} = 1 - (1-p)^{N_{\text{executed}}}$

## 4. Concurrency & Acceleration
Where the test does not depend on shared ports or single-instance databases:
- **Go**: `go test -race -count=50 -parallel=8 ./pkg/...`
- **Pytest**: `pytest -n auto --count=30 test_flaky.py`
- **Node**: Run test runner with parallel workers or batch with `scripts/flake_runner.ps1`.

## 5. Concurrency Race Tools & Window Widening
- **Widen the Race Window**: Inject purposeful short yields or sleeps (`time.sleep(0.001)`, `Thread.yield()`) at hypothesized contention points. If the failure rate increases, you have located the race window.
- **Sanitizers**:
  - Go: `-race`
  - C/C++: `-fsanitize=thread`
  - Node: `--detectOpenHandles`
  - Python: `PYTHONDEVMODE=1`
