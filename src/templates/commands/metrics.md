---
description: Report context-window usage, token economy, and forge-methodology adherence for the current session
---

# /project:metrics

Produce a one-screen report on **how this session is performing methodologically**, so the user can correct course early.

## Sections

### 1. Context window
- Estimated current usage (% of model max)
- Largest context-eaters (top 3 file/tool sources by approx token count)
- Recommendation: continue / `/compact` soon / `/clear` and `/freshstart`

### 2. Memory Bank coverage
- Which of the 6 Memory Bank files were read in this session
- Which were modified (and at what timestamps)
- Files older than 14 days flagged as stale

### 3. ADR activity
- New ADRs in this session
- Open architectural questions (search `TASKS.md` and recent edits for `TODO: decide`)

### 4. TDD adherence
- Number of test files added/modified vs. source files added/modified in this session
- Ratio: target ≥ 0.7 for backend; ≥ 0.4 for UI (visual/e2e adjusted)
- Tests that were modified to make them pass — flag as concerning

### 5. Quality Gate readiness (if Full or App tier)
- Last `/project:gate-check` result, if any
- Gates likely to fail given recent changes (heuristic: did we touch UI? data layer? auth?)

### 6. Token economy
- Approximate tokens consumed by tool results (Bash output, file reads)
- Recommendation: which tool patterns to switch to (e.g. Grep instead of full-file Read)

## Output format

A single markdown block with one section per topic, each ≤5 lines. End with a single one-line **Action**: the next concrete thing the user should do.

## Notes

- Tokens are estimated, not measured (Claude Code does not expose exact counts to slash commands). Use ratio of file sizes + tool result lengths as proxy.
- This command is read-only; it never edits Memory Bank or TASKS.md. To act on findings, use the recommended next command.
