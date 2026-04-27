---
paths:
  - "apps/web/**"
  - "apps/desktop/**"
  - "apps/mobile/**"
  - "packages/ui/**"
  - "**/*.svelte"
  - "**/*.tsx"
  - "**/components/**"
---
# Testing Rules — UI

For Svelte / React / React Native components and screens.

## Strategy

- **TDD adapted, not strict.** Component tests are written alongside or after a UI sketch — RED→GREEN→REFACTOR is too rigid for visual work. Focus instead on **behavioral** tests: "clicking X produces Y", "screen reader hears Z".
- **Default test type** for a component: **component-level integration** (Playwright Component Testing or @testing-library/svelte) — render real component, query by accessible role, interact via real events.
- **Visual regression** via Playwright screenshots for design-system primitives only (Button, Input, Card). Don't snapshot screens — they change too often.
- **Pure logic in components** (formatters, derived state) extracted and unit-tested separately.

## What to assert

- Accessible queries first: `getByRole`, `getByLabelText`, `getByText`. If you reach for `getByTestId`, ask why.
- Interactions through real events: `userEvent.click`, not `fireEvent` for simulated DOM.
- Async UI: `await screen.findBy*` over arbitrary `waitForTimeout`.
- Focus management asserted explicitly when dynamic.
- Empty / loading / error / success states each have a test.

## E2E layer

- One Playwright e2e per critical user flow (signup, primary action, recovery flow).
- Run e2e against a **real** dev server with a seeded DB, not mocks. Mocks belong in component tests.

## Visual / a11y enforcement

- `@axe-core/playwright` runs on every changed route — zero violations.
- Visual regression tolerance: ≤ 0.1% pixel diff; flag everything else.

## Anti-patterns

- Snapshot of `innerHTML` or computed style.
- Mocking `react-dom` / `svelte` internals.
- Testing 3rd-party library internals (don't test that `<DatePicker>` works — trust it, test your wiring).
- Tests that depend on CSS class names.
