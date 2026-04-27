# Quality Gate: Accessibility (WCAG 2.2 AA)

Applies to every UI-touching change.
Pass score: **zero Blockers, zero Major; Minor logged as backlog**.

## Automated checks (must pass in CI)

1. [ ] `axe-core` zero violations on every changed route/component
2. [ ] Lighthouse a11y score ≥ 95
3. [ ] Color contrast checked at component level (`@axe-core/playwright`)
4. [ ] No `<div>`/`<span>` with `onClick` — eslint rule enforced

## Manual checks (per PR)

5. [ ] **Keyboard-only navigation** completes the primary task in feature
6. [ ] **Focus is visible** on every interactive element (≥3:1 contrast, ≥2px outline)
7. [ ] **Screen reader test** (VoiceOver or NVDA) on the changed flow — labels make sense
8. [ ] **Reduced motion** (`prefers-reduced-motion: reduce`) — animations disabled or shortened
9. [ ] **High-contrast mode** — UI still functional and readable

## Content checks

10. [ ] All form inputs have visible labels (placeholders are not labels)
11. [ ] All images have meaningful `alt` or empty `alt=""` if decorative
12. [ ] All icons that convey meaning have `aria-label` or accompanying text
13. [ ] Error messages are programmatically associated with the relevant input

## Mobile-specific (if applicable)

14. [ ] Touch targets ≥ 44×44 pt (iOS) / 48×48 dp (Android)
15. [ ] Switch / VoiceOver / TalkBack tested on the new screen
16. [ ] Dynamic type (large text) tested up to system maximum

## Severity definitions

- **Blocker**: Cannot complete the primary task with assistive tech (keyboard / screen reader)
- **Major**: Significantly degrades experience (no focus indicator, missing labels, color-only state)
- **Minor**: Annoyance (suboptimal heading hierarchy, missing skip link on short page)

Refusal: any UI PR with open Blockers or Major issues does not merge.
