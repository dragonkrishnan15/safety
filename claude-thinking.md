# claude-thinking: always-on global rule (v5.1 Apex Architecture Edition)

For EVERY request to write, modify, refactor, debug, fix, review, optimize, test,
explain, migrate, or deploy code, config, scripts, SQL, or infrastructure (any
language, any stack, any shell), you MUST load and follow the `claude-thinking`
workflow before acting. If the user types `/claude-thinking`, apply it too.

Skill locations:
- `%USERPROFILE%\.gemini\config\skills\claude-thinking\SKILL.md`
- `%USERPROFILE%\.gemini\antigravity\skills\claude-thinking\SKILL.md`
- `.agent\skills\claude-thinking\SKILL.md`

## 0. Gate - emit this line first, then act
`[ACCESS read|write][RUN interactive|headless][SIZE trivial|standard|complex][SHELL pwsh|ps51|cmd|posix]`

- ACCESS=read only if explaining, reviewing, auditing or finding usages AND no file changes, builds, tests, or installs are needed. Anything else is write.
- RUN=headless if running background, unattended, CI, or without user interaction channels. Else interactive.
- SIZE: trivial (local single-line/quick), standard (function/bug/feature), complex (multi-module, public API, migration, concurrency, security, data-loss risk).
- SHELL: pwsh / ps51 / cmd / posix (probe once with `$PSVersionTable` if unknown).

## Core Superpowers Enforced
1. **Pre-Mortem Failure Stress-Test**: Stress-test concurrency, dependency drops, poison payloads, and scale before coding.
2. **Token & Context Discipline**: Treat tokens like money. Never dump files $>400$ lines; outline and slice with ripgrep. Filter logs/tests before reading into context.
3. **Circuit Breakers & Failsafes**: Auto-stop on 2 identical command failures or 3 failed approaches. Zero-destruction wall on destructive git/database commands.
4. **1-Screen Precision Question Schema**: When user input is needed on a one-way door, ask exactly ONE question with context, trade-off matrix, clear **(Recommended)** tag, and a zero-friction default action.
5. **Contract & Documentation Sync**: Automatically sync `.env.example`, API schemas, and docs in the same PR when code changes.
6. **Project Memory**: Consult `.claude-thinking/memory.json` on startup; record 1-sentence lessons upon task completion.
7. **RFC Gate for Complex Tasks**: When `SIZE=complex`, output a 30-second decision card (Mermaid diagram, trade-offs, schema) before coding.
8. **Autonomous Visual Verification & Anti-Slop Gate**: For Web/UI/Frontend tasks, automatically enforce `anti-slop-design` (`[CRAFT]`), establish the 4 Pre-CSS Invariants, run `slop_detector.ps1` (0 high-severity tells), and verify with real browser subagent (0 console errors, no 404s, responsive checks, screenshot in report).
9. **Mandatory Regression Harness**: Bug fixes require an automated regression test that fails before and passes after.
10. **Diff Health & Scorecard**: Pre-commit automated scorecard auditing churn, net lines, blast radius, and 0 `DEBUG-CT` leftovers.

## Hard Rules
- Pre-existing dirty files are **USER-OWNED**; never touch, stage, stash, format, or revert them unasked.
- Checkpoint before every atomic step; on failure, STOP and REVERT to the checkpoint (never stack patches).
- STOP and show a one-screen trade-off matrix for one-way doors. Two-way doors are decided autonomously and logged as assumptions.
- Forbidden without explicit permission: `git reset --hard`, `git clean -fd`, `git checkout .`, stashing user changes, force-push, history rewrite, deleting files you did not create, editing tests just to turn them green.
- Report results first, short: what changed, verified how against baseline, health scorecard, and new project memory recorded.
