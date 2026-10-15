# Rollback & Atomic Iteration Protocol Reference

Rules for checkpointing atomic edits, handling verification failures cleanly, and preventing patch stacking.

## 1. Checkpointing Before Each Atomic Step

Before making file edits for any step $N$:
1. **Clean Baseline Repo**:
   - Save the exact diff to `<tmp>/ct-step-N.patch`:
     ```powershell
     git diff > "$tmp\ct-step-$stepNumber.patch"
     ```
   - Track any newly created files in `<tmp>/ct-step-N-untracked.txt`.
2. **Dirty Baseline Repo**:
   - For every pre-existing dirty file you are about to touch, copy it to `<tmp>/ct-backup/<stepN>/` before editing.
   - Keep `<tmp>` strictly outside the repository root.

---

## 2. Failure Protocol (When Step Verification Fails)

### Step 1: STOP Immediately
Do NOT attempt to write a quick speculative fix on top of failing code. Never stack patches.

### Step 2: Capture & Classify
Capture the exact error message and test output. Classify into one of 4 categories:
- **(a) Implementation error**: The logic is flawed or incomplete.
- **(b) Test / Environment issue**: Fixture, mock, dependency version, or environment problem.
- **(c) Pre-existing / Flaky failure**: Matches `KNOWN-RED` or `FLAKY` in baseline ledger.
- **(d) Specification misunderstanding**: The requirement was interpreted incorrectly.

### Step 3: Revert to Last Green Checkpoint (For categories a & d)
- Reverse your patch:
  - If using patch file: `git apply -R "$tmp\ct-step-$stepNumber.patch"`
  - Or checkout only the files touched in step $N$ (only if they were clean at baseline):
    `git checkout -- <file1> <file2>`
  - If touching dirty-at-baseline files, restore them from `<tmp>/ct-backup/<stepN>/`.
  - Delete only files created during step $N$.
- **Verify Clean State**: Run `git diff` to confirm the working directory matches the checkpoint.

### Step 4: Write One-Line Lesson
Log the failure reason in `<tmp>/ct-state.json`:
`"Approach A failed because [Root Cause]; reverting to checkpoint."`

### Step 5: Form New Hypothesis & Retry
Design an alternative approach informed by the lesson.

---

## 3. Limits & Escalation Rule
- **Max Reverts Per Step**: At most **2 reverts** of the same step.
- **Max Failed Approaches**: After **3 failed approaches** across the task, STOP immediately. Escalate to the user (or follow the headless PARK rule) with a trade-off matrix.
- **Fix-Forward Exception**: Fixing forward without reverting is allowed **ONLY** for trivial, self-evident one-line slips inside the same step (such as a typo, syntax error, or missing import).
