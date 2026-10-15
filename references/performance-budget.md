# Performance & Resource Budget Reference

Protocols for ensuring changes do not introduce performance regressions, bundle bloat, or memory leaks.

## 1. Web & Frontend Performance Budgets
- **Tree-Shaking & Barrel Imports**:
  - Forbid whole-library imports where modular imports are supported:
    - Bad: `import _ from 'lodash';` or `import * as Icons from 'lucide-react';`
    - Good: `import debounce from 'lodash/debounce';` or `import { User, Settings } from 'lucide-react';`
- **Render Performance**:
  - Avoid unnecessary re-renders in components: memoize expensive callbacks (`useCallback`, `useMemo`) or compute outside render loops.
  - Defer offscreen media: use `loading="lazy"` on images and dynamic `import()` for heavy modals or complex chart components.

---

## 2. Backend & Data Processing Budgets
- **N+1 Database Query Prevention**:
  - Forbid running queries inside loops:
    - Bad: Loop over 100 users, execute `SELECT * FROM orders WHERE user_id = ?` for each.
    - Good: Batch fetch with `WHERE user_id IN (...)` or use ORM eager loading (`include`/`prefetch_related`).
- **Index Verification**:
  - Any column added to a `WHERE`, `JOIN`, or `ORDER BY` clause on tables with $>10,000$ rows must have a supporting index.
- **Memory Retention & Leaks**:
  - Clear event listeners, intervals, and timeouts when objects/components are destroyed.
  - Stream large files or database query results rather than buffering entire payloads in memory (`fs.createReadStream`, cursor iteration).
