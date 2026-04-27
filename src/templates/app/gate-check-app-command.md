---
description: Run all Quality Gates (architecture + app-tier) and report per-gate score
---

# /project:gate-check (App tier)

Run a comprehensive readiness check before merging or releasing.

## Steps

1. **Determine applicable gates** for the change at hand:
   - `architecture-gate.md` — always
   - `offline-first-gate.md` — if change touches data layer or sync
   - `cross-platform-gate.md` — if change is in shared UI or platform-targeted code
   - `a11y-gate.md` — if change touches UI
   - `performance-gate.md` — if change is on a hot path or in a release branch
   - `privacy-gate.md` — if change introduces data collection / storage / sharing

2. **For each applicable gate**:
   - Read the gate checklist from `.claude/quality-gates/{gate}.md`
   - Walk every item against the actual change
   - Score: count passed items / total items × 10
   - For each failed/skipped item: list a one-line reason

3. **Report**:
   ```
   Gate                       Score     Status
   ───────────────────────────────────────────
   architecture               9/10      PASS
   offline-first              7/10      FAIL (items 4, 6, 9)
   cross-platform             N/A       (frontend-only change)
   a11y                       10/10     PASS
   performance                N/A       (no hot-path change)
   privacy                    9/10      PASS
   ───────────────────────────────────────────
   Overall: 1 gate FAILED — see details below.
   ```

4. **If any gate fails**, propose concrete remediation per failed item (file + change), and propose a TASK-### entry in TASKS.md if the fix is non-trivial.

5. **Never auto-fix without confirmation** for items requiring user judgment (e.g. retention policy, consent UX). Flag them and stop.

## Notes

- A "FAIL" is not a merge blocker on its own — engineering judgment can override with a linked ADR or PR comment justifying the exception. The gate is a forcing function, not a tribunal.
- Architectural exceptions go in `adr/`; one-time exceptions go in PR description.
