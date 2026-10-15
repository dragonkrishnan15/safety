# Diff Health & Blast Radius Scorecard Reference

Pre-commit automated quality gate to ensure changes simplify the codebase, prevent bloat, and maintain structural integrity.

## 1. When Scorecard Runs
Run automatically before generating the Phase 7 Final Report on any `ACCESS=write` task using `scripts/scorecard.ps1` (or `scorecard.sh`).

---

## 2. Key Health Metrics & Thresholds

| Metric | Target / Healthy | Warning / Review Required | Danger / Blocking |
|---|---|---|---|
| **Added vs Deleted Ratio** | $\le 2.0$ (Balanced/Net Deletion) | $> 5.0$ (High Additions) | Excessive boilerplate generation |
| **Files Touched** | Scoped strictly to task ($\le 5$) | 6 – 10 files | $> 10$ files on `SIZE standard` (Scope creep) |
| **Dependency Changes** | 0 new packages | 1 vetted, lightweight package | Heavyweight / duplicate dependency added |
| **`DEBUG-CT` Leftovers** | **0 occurrences** | $> 0$ (Requires cleanup) | Blocks commit/report |
| **Unreferenced Exports** | 0 new dead functions | Unused helper function | Dead code introduced |
| **Formatting Churn** | Only edited lines | Whitespace changes across whole file | Bulk reformatting violation |

---

## 3. Scorecard Report Embedding
Incorporate the JSON output of `scripts/scorecard` into the Phase 7 Report:

```text
### Health Scorecard
- Churn: +45 lines / -18 lines across 2 files (Net +27)
- Blast Radius: Localized to src/auth/jwt.ts
- Dependencies: 0 added, 0 modified
- Leftover Check: Clean (0 DEBUG-CT, 0 trailing whitespace violations)
```
