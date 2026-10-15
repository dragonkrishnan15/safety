# Token Management & Context Efficiency Reference

Context is finite and expensive. Treat token consumption with principal-engineer discipline: minimize footprint, maximize signal, and prevent context compaction.

## 1. Token Budget Tiers by Task Size

| Task Size | Context Target | Max File Lines Read at Once | Tool Output Strategy |
|---|---|---|---|
| **TRIVIAL** | $\le 4,000$ tokens | $\le 50$ lines | Single targeted symbol view or direct diff |
| **STANDARD** | $\le 20,000$ tokens | $\le 100$ lines with margin | Boundary slicing + ripgrep filters |
| **COMPLEX** | Disciplined Paging | Never whole files ($>400$ lines) | Delegate discovery to subagents; retain only conclusions |

---

## 2. Hard Token Conservation Rules

1. **Never Dump Entire Files**:
   - If a file exceeds 400 lines, **never view the whole file**.
   - Outline first: `rg -n "^(class|def|function|export|type)\b" <file>`.
   - Slice only the target symbol with $\approx 30$ lines of context using `StartLine` and `EndLine`.
2. **Never Dump Unfiltered Logs or Test Suites**:
   - Never print 1,000-line test outputs or web server logs into context.
   - Use shell filtering (`Select-String`, `grep`, `tail -n 30`) to extract only the failure stack trace and summary.
3. **Context Ledger Compression**:
   - As you explore, maintain facts in the compact ledger: `file:line - fact` (e.g. `src/auth.ts:42 - Expiry in seconds`).
   - Do not re-read files across turns to remember facts; query the ledger.
   - Drop intermediate dead-ends from memory.
4. **Subagent Offloading for High-Volume Discovery**:
   - For broad codebase searches across dozens of files ("Where are all SQL queries executed?"), delegate to a subagent or ripgrep summary and retain only the final synthesized findings.
