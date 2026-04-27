# Quality Gate: Cross-platform

Applies to every feature in a project that targets ≥2 of: Web, macOS, Windows, Linux, iOS, Android.
Pass score: **all targets green** before merge to main.

## Checklist

1. [ ] **Builds on every target.** CI matrix runs build for each target; red = blocker.
2. [ ] **Critical flow smoke-tested on every target.** Login → primary action → logout works.
3. [ ] **Platform conventions respected.**
   - macOS: menu bar, ⌘-shortcuts, traffic lights
   - Windows: title bar, Win-key shortcuts, system tray
   - iOS: safe areas, swipe-back, haptics
   - Android: back button, system insets, Material motion
4. [ ] **Filesystem paths abstracted.** No hardcoded `/`, `\`, `~`, `%APPDATA%`. Use `path` lib / Tauri `pathResolver`.
5. [ ] **Native dialogs over web dialogs** when running native (file picker, alerts, share sheet).
6. [ ] **Notifications** use platform mechanism (APNs / FCM / Notification API) — not custom toast for important events.
7. [ ] **Feature detection, not platform sniffing.** `if (canDoX)` over `if (isMac)`.
8. [ ] **DPI / display scaling tested.** Hidpi screens don't render blurry.
9. [ ] **Keyboard shortcuts non-conflicting** with system shortcuts on each platform.
10. [ ] **Tray / dock badge / lock-screen widgets** behave correctly when supported.
11. [ ] **Deep links / URL handlers** registered and tested per platform.
12. [ ] **Build artifacts signed** (notarized on macOS, signed on Windows) for distribution targets.
13. [ ] **Bundle size** within target budget per platform (see performance-gate).

## How to test
- CI: `pnpm test:e2e:web`, `pnpm tauri build` for desktop matrix, `eas build --profile preview` for mobile.
- Manual: each platform once before release; subsequent regressions caught by snapshot/visual tests.
