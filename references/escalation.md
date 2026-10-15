# Escalation Matrix Reference

Comprehensive guide to handling one-way doors, trade-offs, and decisions across interactive and headless modes.

## 1. One-Way Doors vs. Two-Way Doors

- **One-Way Door**: High cost to reverse, wide blast radius, risk of data loss or contract breaks.
  -> **STOP** and escalate to the user (Interactive) or enforce NEVER/PARK (Headless).
- **Two-Way Door**: Reversible in one command or git revert, local blast radius, follows existing repo conventions, easily testable.
  -> **DECIDE** autonomously and log as an assumption in the final report.

---

## 2. The 12 Escalation Triggers & Behaviors

| # | Trigger | Headless Behavior | Interactive Action |
|---|---|---|---|
| **1** | Destructive, irreversible, touches production | **NEVER** execute | Stop; show one-screen trade-off matrix; wait for user |
| **2** | Irreversible data or schema migration | Author up/down migration in sandbox; **NEVER** apply | Present migration plan and rollback risks |
| **3** | Breaking change to public API / schema / CLI / event | **GO** additive path; **PARK** the breaking change | Offer additive vs breaking trade-off |
| **4** | Security, authn/authz, payment, or PII handling | Sandbox + mark `NEEDS-HUMAN-REVIEW`; **NEVER** touch secrets | Detail security model and impact |
| **5** | Competing architectures with different long-term cost | **GO** most reversible & convention-following; log rejected | Present matrix with architecture pros/cons |
| **6** | Heavy dependency, new tech, license, or financial cost | **PARK**; use zero-dependency path if viable | Compare dependency vs in-house implementation |
| **7** | Ambiguity where a wrong guess is costly | **GO** narrowest valid reading; **PARK** divergent rest | Ask ONE specific question with clear default |
| **8** | Scope growth > ~2x the request or unrequested refactor | **GO** original scope; **PARK** refactors | Clarify scope boundary before proceeding |
| **9** | Environment change (global install, upgrade, services) | **GO** if sandbox/local; **NEVER** global/sudo | Provide exact manual install command |
| **10** | Spec conflict or pre-existing defect blocking task | **GO**: ledger as `KNOWN-RED`; **PARK** blocked step | Explain conflict with reproduction proof |
| **11** | 3 failed approaches or critical path unverifiable | **PARK**; revert to last green; mark `UNVERIFIED` | Summarize failed approaches and lessons |
| **12** | Conflict with USER-OWNED dirty files | **NEVER** edit them; deliver patch against base SHA | Request guidance on how to integrate |

---

## 3. Interactive Trade-off Matrix Template

When escalating interactively, adhere strictly to a **one-screen table** format:

| Option | Correctness Risk | Effort | Reversibility | Blast Radius | Maintainability | Recommendation |
|---|---|---|---|---|---|---|
| **Option A (Additive)** | Low | Low (1h) | Instant (git revert) | Local module | High (clean) | Recommended |
| **Option B (Breaking)** | Medium | Medium (3h) | Difficult (downstream) | Repo-wide | High | Alternative |

**Recommendation**: Option A because it preserves contract compatibility without requiring migration of external consumers.
**Default if you do not reply**: Option A.
*(Note: Never proceed on a default for a one-way door).*
