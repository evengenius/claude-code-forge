# App tier (Level 4) — overview

Level 4 extends `Full` with quality gates specific to **end-user applications** that ship across web + native and may operate offline.

## Adds on top of Full

- `.claude/quality-gates/offline-first-gate.md` — local-first correctness
- `.claude/quality-gates/cross-platform-gate.md` — Web + Desktop + Mobile parity
- `.claude/quality-gates/a11y-gate.md` — WCAG 2.2 AA enforcement
- `.claude/quality-gates/performance-gate.md` — perf budgets per platform
- `.claude/quality-gates/privacy-gate.md` — GDPR-aligned data protection

## When to choose Level 4

Choose **App** if your project hits any two of these:
- Targets ≥ 2 platforms (web/desktop/mobile)
- Persists user data locally
- Has authentication
- Is consumer-facing (vs. internal tooling)
- Will be distributed via app stores

## When NOT to choose

- Pure backend service / API → use Full
- CLI tool → use Standard
- Internal admin panel → use Standard or Full

## Workflow change

`/project:gate-check` runs **all** gates (architecture + 5 app-tier gates) and reports a per-gate score.
A merge requires every applicable gate to pass; non-applicable gates can be marked `N/A` with rationale in the PR.
