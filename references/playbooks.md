# Task Playbooks Reference

Checklists and workflows tailored for common engineering domains.

## 1. New Feature
1. Define interface contracts first (inputs, outputs, exceptions/errors, types).
2. Reuse existing internal utilities; do not reinvent pagination, validation, or HTTP clients.
3. Implement in atomic steps with checkpoints.
4. Add unit and integration tests covering standard path and boundary conditions.
5. Provide concise usage documentation or docstring examples.

## 2. Bug Fix
1. Execute baseline sanity and capture repo state.
2. Formulate minimal reproduction script (Phase 6 Scientific Debugging).
3. Identify deterministic root cause.
4. Implement minimal fix matching surrounding style.
5. Prove fix with regression test that fails before and passes after.
6. Verify no regressions across the wider test suite.

## 3. Refactoring
1. Lock current behavior with tests before making any edits.
2. Change structure without changing external behavior.
3. Keep diffs readable; avoid combining renaming with logic changes.
4. Run tests after every single atomic rename or extraction.

## 4. Code Review (Read-Only)
1. Verify against correctness, edge cases, security vulnerabilities, error handling, performance bottlenecks, and test coverage.
2. Provide exact `file:line` citations for all feedback.
3. Categorize findings into `MUST-FIX` (blocking) and `SUGGESTION` (optional polish).

## 5. Performance Optimization
1. Establish a measurable baseline benchmark before changing code.
2. Optimize one factor at a time (e.g. algorithmic complexity, indexing, I/O batching).
3. Re-run benchmark under identical conditions.
4. Report before vs. after metrics (latency, throughput, memory allocation).

## 6. Frontend & UI
1. Respect framework architectural patterns (React, Vue, Angular, Svelte).
2. Ensure accessibility (a11y): ARIA labels, keyboard focus management, semantic HTML.
3. Verify responsive layout across viewport widths.
4. Implement explicit states for loading, empty, error, and success.

## 7. Backend & API
1. Enforce strict input validation at controllers/endpoints.
2. Standardize error responses (status codes, structured error payloads).
3. Ensure authorization checks on every endpoint.
4. Make retryable mutations idempotent.

## 8. Database & Migrations
1. Implement non-locking additive migrations (add column nullable/with default).
2. Migrate data in batches if operating on large tables.
3. Verify backward compatibility with the current running version of the application.
4. Ensure a working down-migration is provided.

## 9. Data Science & Machine Learning
1. Fix pseudo-random seeds across numpy, torch, tensorflow, etc.
2. Prevent data leakage (fit scalers and encoders only on training splits).
3. Validate tensor/DataFrame shapes and dtypes at transformation boundaries.
4. Compare model evaluation metrics against a naive baseline.

## 10. DevOps, Scripts & Infrastructure as Code (IaC)
1. Provide `--dry-run` or plan validation before applying changes.
2. Ensure script idempotency (can be safely executed multiple times).
3. Quote all shell variables; set error handling flags (`set -euo pipefail` / `$ErrorActionPreference = 'Stop'`).
4. Never hard-code credentials or environment-specific IP addresses.

## 11. Systems & Embedded
1. Audit memory lifetimes, ownership semantics, and buffer boundaries.
2. Check integer bounds and prevent overflow or undefined behavior.
3. Run with compiler warnings enabled (`-Wall -Wextra -Werror`) and sanitizers (ASan, TSan).

## 12. Code Explanation
1. State the component's overarching purpose in one sentence.
2. Detail how data flows from input to output.
3. Highlight subtle edge cases, gotchas, or concurrency constraints based on code evidence.
