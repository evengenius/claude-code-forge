# Quality Gate: Privacy & Data Protection

Applies to every release that processes user data.
Mandatory for any feature that introduces collection of new fields or new third-party recipients.

## Data inventory

1. [ ] **What's collected** is documented in `docs/PRIVACY.md` (categories, purpose, retention, lawful basis if EU)
2. [ ] **What's stored locally** vs. **what's sent to server** is explicit
3. [ ] **Third-party recipients** (analytics, error tracking, sync) listed with linked DPAs

## User rights (GDPR-aligned, applied universally)

4. [ ] **Export**: user can download their data in a machine-readable format (JSON/CSV)
5. [ ] **Delete**: user can delete their account; cascades to all stored data including backups within retention window
6. [ ] **Portability**: export format usable by competitors (no proprietary lock-in for raw data)
7. [ ] **Rectification**: user can correct any field they themselves provided

## Storage hygiene

8. [ ] **Local DB encrypted at rest** (SQLCipher / Tauri stronghold / iOS keychain)
9. [ ] **Secrets in keychain**, not in localStorage / AsyncStorage / files
10. [ ] **PII not in logs** — redaction policy enforced at log layer
11. [ ] **Backups encrypted**; key rotation documented
12. [ ] **Retention policy** — data older than X is purged; X is documented per category

## Consent

13. [ ] **No tracking before consent** (analytics, crash reporting if it includes IP/UA, marketing)
14. [ ] **Consent is granular** (functional vs. analytics vs. marketing distinguishable)
15. [ ] **Consent revocation works** — clearly accessible and immediate

## Cross-border

16. [ ] **Data residency** documented (where DBs and backups physically live)
17. [ ] **Third-country transfers** have legal basis (SCCs, adequacy)

## App-store compliance

18. [ ] **Apple privacy nutrition labels** filled accurately
19. [ ] **Google Play data safety form** filled accurately
20. [ ] **Permission rationale strings** in `Info.plist` / `AndroidManifest` honest and specific

## Breach response

21. [ ] **Incident playbook** exists and identifies notification timeline (≤72h for EU users)
22. [ ] **Audit log** retained for security-relevant events (login, perm change, export, delete)
