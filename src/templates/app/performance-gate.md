# Quality Gate: Performance

Applies to release builds; track per-feature on PRs that touch hot paths.

## Web budgets

1. [ ] **First Contentful Paint** ≤ 1.5s on Slow 4G (Lighthouse mobile preset)
2. [ ] **Largest Contentful Paint** ≤ 2.5s
3. [ ] **Time to Interactive** ≤ 3.5s
4. [ ] **Cumulative Layout Shift** ≤ 0.1
5. [ ] **JS bundle** (initial) ≤ 200 KB gzipped
6. [ ] **CSS** (initial) ≤ 50 KB gzipped
7. [ ] No render-blocking 3rd-party scripts in critical path

## Native budgets (Tauri / Expo)

8. [ ] **Cold start** ≤ 2s on baseline device (M1 Mac / Pixel 6 / iPhone 12)
9. [ ] **Bundle size** — Tauri ≤ 15 MB; Expo ≤ 30 MB (per ABI)
10. [ ] **Memory at idle** ≤ 200 MB
11. [ ] **CPU at idle** ≤ 1% (no busy loops)

## Timer / sync specifics

12. [ ] **Timer drift** ≤ 1s/hour when app is foreground
13. [ ] **Background sync** completes ≤ 5s for typical delta (≤100 records)

## Database / API

14. [ ] **p95 query** ≤ 100ms on production-shaped fixture
15. [ ] **N+1 queries** detected by integration test budget (max 3 queries per request unless documented)
16. [ ] **Indexes verified** for every WHERE / ORDER BY clause hitting > 1000 rows

## How to enforce

- CI: Lighthouse-CI on PRs against web app; assert budgets fail the build.
- Native: nightly build job emits bundle-size and cold-start metrics; alert on regression.
- DB: pgbadger / pg_stat_statements review weekly during development.
