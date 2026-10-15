# Autonomous Visual Verification Reference (Web & UI)

Protocol for validating user interfaces through real browser execution, DOM inspection, screenshot capture, and error log audits.

## 1. When Visual Verification Applies
Apply this protocol during Phase 5 (Verify) whenever:
- Modifying or creating HTML, CSS, frontend components (React, Vue, Svelte, Angular, Next.js, Vite).
- Fixing UI bugs (alignment, layout overflow, responsiveness, styling).
- Implementing new pages or visual features.

---

## 2. Pre-Verification: Dev Server Spin-up

1. **Check if Dev Server is Running**:
   - Check if port (e.g. 3000, 5173, 8080) responds.
   - If not running, launch dev server as a daemon task (`IsDaemon=true` via `run_command`).
2. **Verify Port Readiness**: Wait until localhost URL is accessible before launching browser subagent.

---

## 3. Autonomous Browser Inspection Checklist

Dispatch `browser_subagent` to execute the verification task:
```text
Task: Navigate to http://localhost:<port>.
1. Verify the page renders without a blank white screen or 404.
2. Check browser console logs: Ensure 0 unhandled JavaScript exceptions.
3. Test key user interaction: Click primary interactive element (e.g. toggle theme, submit form, open modal).
4. Verify responsiveness: Inspect layout at desktop (1280x800) and mobile (375x667).
5. Capture a screenshot of the final rendered state to the artifacts directory.
```

---

## 4. Visual Verification Standards

A UI task CANNOT be marked as verified unless all of the following pass:
- **No Console Exceptions**: Zero unhandled `TypeError`, `ReferenceError`, or React hydration warnings.
- **No Network 404s**: All bundled scripts, CSS files, web fonts, and images load successfully.
- **No Layout Overflows**: No horizontal scroll on mobile viewport; no overlapping text elements.
- **Theme Consistency**: High contrast, readable typography, and complete color palette integration.
- **Embedded Proof**: Screenshot captured into artifact directory and linked directly in the final report.
