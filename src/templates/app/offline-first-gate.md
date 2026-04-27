# Quality Gate: Offline-first

Applies to any feature where a user can perform the action without an internet connection.
Pass score: **9/10** before merge.

## Checklist

1. [ ] **Local read works offline.** Disable network, restart app, the data is still there.
2. [ ] **Local write works offline.** Create/edit/delete enqueues; UI shows pending state.
3. [ ] **Queued mutations are durable.** Force-quit during pending write; on relaunch, the mutation still flushes.
4. [ ] **Sync resumes automatically** when connection returns; no user action required.
5. [ ] **Conflict resolution is defined and tested.** Two devices edit the same record offline → result is documented and predictable.
6. [ ] **Tombstones replicated correctly.** Delete on device A, sync, deletion appears on device B even if B was offline at delete-time.
7. [ ] **Schema migration is sync-safe.** Old client + new server (and vice versa) for at least one release window.
8. [ ] **UI distinguishes pending/synced/failed.** No silent failures.
9. [ ] **Large payloads handled separately.** Attachments don't block small mutation sync.
10. [ ] **Conflict surfaces to user when manual resolution required;** never silent data loss.

## How to test
- `pnpm test:e2e:offline` — Playwright with `context.setOffline(true)` between actions.
- Two-device manual: phone airplane mode + desktop online, edit same record, restore phone.
- Chaos: random network drop during mutation flush.
