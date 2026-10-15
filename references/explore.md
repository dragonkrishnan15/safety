# Context-Efficient Hierarchical Exploration Reference

Spend context like money. Narrow first, widen only when concrete evidence requires it. Never read a large file blindly.

## The Exploration Ladder

Stop at the lowest rung that answers the question:

### 1. Map (Depth 2 Directory Tree)
- Inspect high-level layout, entry points, configuration, and manifests.
- Ignore noise: `node_modules`, `.git`, `dist`, `build`, `target`, `__pycache__`, `.venv`, `.idea`.
- Tools: `list_dir` or fast shell command.

### 2. Locate by Symbol
- Search definition first: `rg -n "def <name>|class <name>|function <name>|interface <name>"`
- Search references second: `rg -n "\b<name>\b"`
- For errors/logs: search exact error string or log message.
- Prefer symbol/definition tools when supported in the environment.

### 3. Outline Before Reading
- Never read a file over ~400 lines in full.
- Outline first by viewing line count and top-level definitions:
  - PowerShell: `(Get-Content <file> | Measure-Object -Line).Lines`
  - Ripgrep symbol outline: `rg -n "^(\s*)(def|class|fn|func|function|export|pub|public|type)\b" <file>`

### 4. Boundary Slice
- Read target symbol with a bounded margin (~30 lines before and after).
- Use `view_file` with precise `StartLine` and `EndLine`.
- Expand upward only if the symbol relies on class-level or module-level state defined elsewhere.

### 5. Call Graph Trace (Depth-Limited)
- **Upward (Callers)**: Trace 1 level up. Only trace 2 levels up for shared utilities or public interfaces.
- **Downward (Callees)**: Follow downward until hitting a framework boundary, database/IO boundary, or unaffected subsystem.
- **Test Cross-Check**: Read the unit test exercising the symbol; tests serve as executable behavior contracts.

### 6. Git History & Blame (When Intent is Unclear)
- `git log -n 5 --oneline -- <file>`
- `git blame -L <start>,<end> <file>` to discover commit messages and rationale behind subtle edge-case handling.

### 7. Fact Ledger (`file:line - fact`)
- Maintain a running context ledger in memory / `<tmp>/ct-state.json`:
  ```
  src/auth/token.ts:45 - Token expiration checked in UTC seconds
  src/auth/token.ts:88 - Refresh token rotation triggers event 'auth:rotated'
  ```
- Consult the ledger rather than repeatedly re-reading files across turns.

### 8. Exit Criteria
You are ready to plan/implement when you can state in **3 sentences**:
1. How the existing code works today.
2. The exact location where the modification belongs.
3. Why this location is safe and sufficient.
If you cannot state these 3 sentences, explore further down the ladder. If you can, stop exploring immediately.
