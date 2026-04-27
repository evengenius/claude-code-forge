---
paths:
  - "**/integration/**"
  - "**/*.integration.test.*"
  - "**/src-tauri/**"
  - "**/migrations/**"
  - "packages/sync/**"
---
# Testing Rules — Integration & Native

For tests that exercise real subsystems together: DB + ORM, Tauri commands + native APIs, sync layer + multiple devices.

## DB integration

- Use a **production-shaped fixture** (real schema, indexes, sample data), not empty DB.
- Each test wraps in transaction → rollback. No shared mutable state.
- Test migration **forwards** on a snapshot of production data; flag anything > 1s lock or full table scan.

## Tauri commands

- Unit-test command logic with `tauri::test::mock_app()` for fast feedback.
- Integration-test through `tauri-driver` for flows that depend on real OS APIs (filesystem, notifications, permissions).
- Cross-platform: at minimum the smoke suite runs on macOS, Windows, Linux in CI.

## Sync (PowerSync / ElectricSQL / Convex / custom CRDT)

- **Two-device test** is the minimum unit: device A and device B both online, both make a change, both observe convergence.
- **Offline-then-online** test: device goes offline, makes mutations, comes back, verifies all flushed.
- **Conflict test per entity**: each synced entity has at least one test exercising the documented conflict resolution.
- **Tombstone test**: delete on A, sync, B observes deletion; B comes online late, still sees deletion.
- **Schema-drift test**: client at version N + server at version N+1 — both work for at least one release window.

## Network / external API

- Use a **fake at the boundary** (MSW for HTTP, fake-aws-sdk for AWS). Never let real external traffic into the test suite.
- Contract tests against the real API run nightly, not per-PR (slow, flaky, third-party).

## Performance budget per integration suite

- Per-package: ≤ 60s for the integration suite
- Sync suite: ≤ 2 min (allowed to be slower due to multi-device setup)
- Native UI smoke: ≤ 5 min per platform
