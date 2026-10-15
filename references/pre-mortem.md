# Pre-Mortem Failure Mode Analysis (Red-Teaming Reference)

Before writing implementation code, simulate how the solution could fail in production. Identify vulnerabilities early rather than debugging post-mortems.

## 1. The 4 Pre-Mortem Stress Tests

Execute this 60-second mental stress test during Phase 3 (Plan):

### Axis 1: Concurrency & Race Windows
- **Scenario**: Two requests, threads, or background jobs hit this logic at the exact same millisecond.
- **Questions**:
  - Is there a check-then-act vulnerability (e.g. `if (exists) update else insert`)?
  - Can shared state or database rows be corrupted by interleaved execution?
  - Does this logic require an idempotency key, row lock (`SELECT FOR UPDATE`), or atomic upsert?

### Axis 2: Network & Dependency Faults
- **Scenario**: A remote microservice, database connection, or third-party API hangs for 10 seconds or drops with a 503 error.
- **Questions**:
  - Is there an explicit timeout set, or will the request worker hang forever?
  - Is there a fallback state (cached data, graceful degradation, user error message)?
  - Are retries bounded with exponential backoff and jitter to prevent thundering herds?

### Axis 3: Poison Payloads & Boundary Edge Cases
- **Scenario**: The incoming payload contains extreme, malformed, or missing data.
- **Questions**:
  - What happens if a field is `null`, `undefined`, empty string `""`, or `[]`?
  - What if text contains 4-byte UTF-8 emojis or 50,000 characters?
  - What if numeric values are `0`, negative, fractional, or exceeding standard integer limits?

### Axis 4: Scale & Memory Bloat
- **Scenario**: The dataset grows from 10 items in local testing to 500,000 items in production.
- **Questions**:
  - Is there an accidental $O(N^2)$ nested loop or in-memory array search?
  - Does this query cause an N+1 database round-trip problem?
  - Are results paginated, or does it attempt to load the entire table into memory?

---

## 2. Pre-Mortem Documentation in Plan
In the Phase 3 Plan, include a 2-line pre-mortem statement:
`"Pre-Mortem Mitigations: Bounded timeout of 3s on external auth call; atomic upsert used to prevent race conditions on concurrent token refresh."`
