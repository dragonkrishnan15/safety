# RFC Architecture Gate Reference (SIZE=complex)

Protocol for validating system design, data flow, and trade-offs BEFORE authoring code on non-trivial features.

## 1. When RFC Mode Applies
Mandatory for any task triaged as `SIZE complex`:
- Multi-module or multi-service architecture changes.
- New authentication, payment, or authorization models.
- Database migrations affecting core tables or schema redesigns.
- Public API contract additions or protocol changes.
- Workflows with concurrency, real-time queues, or state synchronization.

---

## 2. The 30-Second Decision Card Structure

Before writing any implementation code, output an **RFC Card** structured as follows:

### 1. Goal & Boundaries
- Core objective in 2 sentences.
- Explicit non-goals (what this change will NOT do).

### 2. Data Flow Architecture (Mermaid Diagram)
Visual representation of component interaction, network hops, and state boundaries.

### 3. Architecture Trade-Off Matrix
| Option | Correctness Risk | Complexity / Effort | Reversibility | Performance Impact | Recommendation |
|---|---|---|---|---|---|
| **Option A (Preferred)** | Low | Medium | High (git revert) | Low latency | **(Recommended)** |
| **Option B (Alternative)** | Medium | High | Low | Extra network hop | Alternative |

### 4. Contract Specification
- **API Endpoint / CLI Command / Function Signature** (inputs, outputs, error states).
- **Database Schema / Migration DDL** (table name, column types, constraints, index strategy).

### 5. Atomic Implementation Plan
Step-by-step atomic steps with explicit checkpoint and rollback strategy.

---

## 3. Interactive vs. Headless Handling

- **Interactive**: Emit the RFC Card and pause for user review. Proceed immediately if the user approves or adjusts direction.
- **Headless**: Proceed with **Option A (Recommended)**, serialize the decision to `<tmp>/ct-state.json`, and park any divergent/breaking aspects.
