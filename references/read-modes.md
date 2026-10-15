# Pure Read-Only Mode Reference (ACCESS=read)

Procedures for code reviews, architectural audits, usage searches, and explanations that involve no file modifications.

## 1. When ACCESS=read Applies
Apply `ACCESS=read` when the task is solely to:
- Explain existing logic, data flow, or system architecture.
- Conduct a code review or security audit without producing patches.
- Find all usages, call sites, or dependencies of a symbol.
- Perform performance or design analysis.

**Hard Rule**: The moment any file edit, build, test execution, dependency install, or code generation is required, immediately emit a mode transition:
`[ACCESS read -> write] Switched to write mode for test verification / file edit.`
And immediately run Phase 0B (Baseline Sanity) before modifying any files.

---

## 2. What Gets Bypassed in Read Mode
To save time and tokens, pure read mode skips:
- Running baseline test suites (no test runner invocation).
- Backing up dirty files to `<tmp>/baseline-dirt.patch`.
- Checkpointing and revert mechanisms.
- Package manager installations or toolchain alterations.

---

## 3. Git Scope Pinning
Even in read mode, pin the exact code revision analyzed:
```powershell
git rev-parse HEAD
git status --porcelain=v1
```
State in the output:
`HEAD=<sha> tree=clean|dirty(<count>) [analyzed committed state | working-tree state]`

---

## 4. Structured Output Format for Read-Only Tasks

Every `ACCESS=read` response must follow this structured schema:

1. **Question / Goal**: Restatement of the inquiry.
2. **Scope**: Commit SHA, branch, and clean/dirty status.
3. **Evidence Ledger**: List of verified facts mapped directly to file and line numbers:
   - `src/router.ts:24-40` - Route definition and middleware pipeline.
   - `src/controllers/auth.ts:112` - Token validation invocation.
4. **Findings**: Clear, synthesized answer addressing the user's question, directly grounded in the evidence above. A claim without an inspected `file:line` citation is not a finding.
5. **Confidence & Unknowns**: Explicitly state any unread modules, generated files, external services, or assumptions made.
