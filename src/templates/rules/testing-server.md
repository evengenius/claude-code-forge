---
paths:
  - "**/server/**"
  - "**/api/**"
  - "**/services/**"
  - "**/domain/**"
  - "packages/core/**"
  - "packages/db/**"
---
# Testing Rules — Server / Domain

For backend services, domain logic, API handlers, and pure business code.

## Strategy

- **TDD strict**: RED → GREEN → REFACTOR. New behavior is added test-first.
- **No mocks for internal modules.** If you feel the urge, the seam is wrong — refactor.
- **In-memory DB for unit-ish tests** (pglite for Postgres, sqlite `:memory:` for SQLite).
- **Transactional rollback per test** for integration tests against real DB.

## What to assert

- Happy path: input → expected output / state change
- Boundary conditions: empty, single, max, off-by-one
- Error contract: invalid input returns typed error, not throws
- Idempotency: applying the same operation twice has the same effect (where applicable)
- Authorization: protected operations reject unauthorized actor at every entry

## Performance

- Unit + integration suite ≤ 30s for the whole package
- Slow tests (> 200ms) live in `*.slow.test.ts` and run only in CI

## Anti-patterns

- Snapshot tests for serialized DB rows (brittle, no semantic value)
- Asserting against private fields / internal implementation
- "Coverage" tests that exercise lines without behavioral assertion
