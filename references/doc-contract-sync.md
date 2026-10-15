# Automated Documentation & Contract Synchronization Reference

Code and documentation must never drift apart. When code changes public behavior, its contracts and documentation must be updated in the same commit.

## 1. Synchronization Triggers & Obligations

| If you modify / introduce... | You MUST simultaneously update... |
|---|---|
| **Environment Variable** (`process.env`, `os.environ`) | `.env.example` (add variable name with dummy/commented default; never real secrets) |
| **API Endpoint / Route** (HTTP / GraphQL / gRPC) | OpenAPI / Swagger specification, Postman collection, or typed API schema |
| **CLI Flag / Command Argument** | CLI `--help` output, man page, or `README.md` usage section |
| **Database Schema / Migration** | Database ERD / docs or internal data dictionary |
| **Public Library Function / Class** | JSDoc, docstrings, or typed exported declarations |
| **Architectural Invariant / Convention** | `.master-skill/memory.json` |

---

## 2. Phase 6 (Self-Review) Contract Audit

Before declaring a change verified:
1. Run `git diff --name-only` to review touched files.
2. If configuration files (`config.ts`, `settings.py`, `.env`) were touched, verify `.env.example` has matching entries.
3. If public controllers or handlers were touched, verify documentation reflects the exact request/response shapes.
4. Report contract updates in the final report under **Documentation & Contract Sync**.
