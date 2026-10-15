# Precision Question & Recommendation Protocol

Guidelines for soliciting user decisions without wasting time, generating cognitive fatigue, or halting progress unnecessarily.

## 1. The Core Law of Questioning
**Never ask lazy, open-ended questions.**
Bad: *"What would you like me to do next?"* or *"Should we use Redux or Zustand or something else?"*
Good: Present a concrete recommendation, a structured trade-off table, and a safe default that keeps progress moving.

---

## 2. When to Ask vs. When to Decide Autonomously

- **Ask the User ONLY for One-Way Doors**:
  - Irreversible data or schema loss.
  - Breaking changes to public interfaces.
  - New paid cloud services or heavy dependencies.
  - Critical product ambiguity where two valid paths lead to completely different features.
- **Decide Autonomously for Two-Way Doors**:
  - Naming, internal refactoring, helper functions, test cases, code organization.
  - State the choice as an **Assumption** in your report; do NOT block execution to ask.

---

## 3. The 1-Screen Precision Question Schema

When an escalation triggers and user input is mandatory, adhere strictly to this format:

```markdown
### Decision Required: [Clear 1-Line Title]

**Context**: [1-2 sentences explaining why this decision is a one-way door].

| Option | Correctness Risk | Effort | Reversibility | Maintainability | Recommendation |
|---|---|---|---|---|---|
| **Option A: [Name]** | Low | Low (1h) | Instant (git revert) | High (clean) | **(Recommended)** |
| **Option B: [Name]** | Medium | High (4h) | Difficult (migration) | Moderate | Alternative |

- **Recommendation**: Option A because [1 clear rationale].
- **Default Action**: If you reply "yes" or press Enter, I will proceed with **Option A**.
```

### Protocol Rules:
1. **Exactly 1 Question**: Never ask multiple disjointed questions in a single turn.
2. **Always Include a Default**: Give the user a zero-friction path to proceed by hitting Enter.
3. **Continue Unblocked Work**: While waiting for a decision on a blocked component, continue implementing independent, unblocked subtasks.
