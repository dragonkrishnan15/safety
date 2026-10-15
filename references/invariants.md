# Architectural Invariant Gate Reference

Run this checklist at **Plan time** and again on the **Final Diff**. Answer each applicable item `YES` / `NO` / `N/A`.
A `NO` is a defect to fix before completing the step, or an escalation if a breaking change is unavoidable.

---

## 1. Dependency & Layering
- **One-way Dependency Flow**: Dependencies point inward: Presentation -> Application -> Domain -> Infrastructure. The domain layer imports zero UI, framework, ORM, or HTTP code.
- **No Import Cycles**: No cycles between packages/modules. Use `madge --circular`, `cargo tree`, `pydeps`, `go list`, or manual edge tracing.
- **No Cross-Boundary Encapsulation Leaks**: Modules communicate via exported public interfaces or ports; do not reach into internal or private implementation files.
- **No Global Mutable State**: No newly introduced mutable singletons or shared module-level state.

## 2. Data Boundaries & Security
- **Domain Entity Isolation**: Database/ORM models do not leak directly into API responses or UI layers. Map to DTOs/ViewModels at the boundary.
- **Validation at Every Trust Boundary**: Validate and sanitize all external inputs (HTTP payloads, CLI parameters, message queues, environment variables, file inputs).
- **Zero Secrets**: Secrets, access tokens, and private keys never appear in code, diffs, log statements, error messages, or test fixtures.

## 3. API & Contract Compatibility
- **Additive Changes Only**: Public APIs, schema definitions, CLI arguments, database columns, and message payloads change additively. Do not remove fields, rename properties, narrow allowed types, or reorder positional arguments.
- **Deprecate Before Delete**: Mark obsolete endpoints or fields as deprecated and maintain backward compatibility until all consumers have migrated.
- **Contract Schema Validation**: Diff schemas (OpenAPI, GraphQL, Protobuf, JSON Schema) to guarantee backward compatibility.

## 4. Persistence & Transactions
- **Explicit Transaction Boundaries**: Exactly one unit of work per use case. Keep transaction boundaries as short as correctness permits.
- **No Remote I/O Inside Transactions**: Network calls, HTTP requests, third-party APIs, and slow computations are forbidden inside open database transactions.
- **Multi-Step Write Consistency**: Coordinate multi-system writes using two-phase commits, outbox patterns, or sagas; prevent partial commits.
- **Safe Migrations**: Database migrations follow expand -> migrate -> contract patterns, support online rollout, and avoid long-held table locks.

## 5. Reliability & Error Handling
- **Idempotent Retryable Writes**: Any write triggered by message queues, webhooks, or retryable HTTP calls must be idempotent (using idempotency keys or unique constraints).
- **Timeouts & Bounded Retries**: Every outgoing external call must have an explicit timeout and bounded retry count with exponential backoff and jitter. No unbounded loops or queues.
- **No Swallowed Exceptions**: Errors are handled explicitly with context; never use empty catch blocks or discard error values.

## 6. Operability
- **Observability**: New behavior includes structured logs and relevant metrics with clear correlation IDs, without logging PII.
- **Feature Flags**: Significant behavioral changes should be placed behind config toggles or feature flags where established by project convention.
