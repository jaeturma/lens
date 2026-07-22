# WP-08-03 — Deletion Revocation and Correction Tests

## Objective

Validate deleted announcements, revoked guardian links, deactivated accounts, corrected attendance, and invalidated notifications.

## Affected Layers

- [x] Laravel
- [x] Database
- [x] API
- [x] Flutter
- [ ] Android
- [ ] RFID Integration

## Scope

Verify each server change reaches SQLite correctly.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

WP-07-08.

## Laravel Requirements

Implement only the server-side work directly required by this package.

## API Contract

Document every new or changed mobile/device contract.

## Flutter and SQLite Requirements

When affected, screens must read SQLite and repositories must synchronize server changes into SQLite.

## Permissions and Security

Apply least privilege, validation, authorization, rate limiting, and secure secret handling.

## Tests

Run targeted Pest, Flutter, SQLite migration, or integration tests appropriate to the changed layer.

## Documentation Updates

Update the relevant core or API document.

## Acceptance Criteria

- Every change type is reflected locally.
- Revoked data is no longer accessible.
- Corrections preserve raw RFID data.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes

This package validates, and where genuinely missing, extends test coverage
of deletion/revocation/correction behavior already built across phases
2-6, synchronized to SQLite by WP-07-08. One real gap was found and fixed
(see below) rather than only tested — Laravel/Database/API are checked as
Affected Layers for this package specifically because closing it required
a small server-side change, not just a new assertion.

### Scenario → Evidence

| Objective scenario | Where it's proven |
| --- | --- |
| Deleted announcements (withdrawn → `revoked`, auto-expired → `expired`) | `tests/Feature/Observers/AnnouncementObserverTest.php`, `tests/Feature/Api/V1/Sync/ChangesTest.php`, `mobile/test/features/sync/sync_change_applier_test.dart` |
| Revoked guardian links (never visible again, but the revocation itself always reaches its own guardian) | `tests/Feature/Observers/GuardianStudentLinkObserverTest.php`, `tests/Feature/Actions/Sync/ScopeChangesToGuardianTest.php`, `tests/Feature/Api/V1/Sync/ChangesTest.php`, `mobile/test/features/sync/sync_change_applier_test.dart` |
| Deactivated accounts blocked from a *future* login | `tests/Feature/Api/V1/Auth/MobileLoginTest.php` |
| Deactivated accounts' *existing* token losing access (new) | `tests/Feature/Api/V1/Auth/GuardianDeactivationAccessTest.php` |
| Deactivated accounts' mobile session ending on next launch | `mobile/test/features/auth/session_controller_test.dart` ("a 401 from GET /auth/me clears the stored token...") — already generic to *any* 401, so the new middleware's 401 is covered for free |
| Corrected attendance (tagged `corrected`, not `updated`) | `tests/Feature/Observers/AttendanceDailySummaryObserverTest.php`, `mobile/test/features/sync/sync_change_applier_test.dart` |
| Corrections preserve raw RFID data | `tests/Feature/Actions/Attendance/CorrectAttendanceDailySummaryTest.php` ("a correction never touches the underlying raw scan or attendance event rows") |
| Invalidated notifications (a correction notifies separately rather than silently overwriting the guardian's prior understanding) | `tests/Feature/Actions/Notifications/NotifyGuardiansOfAttendanceEventTest.php`, `tests/Feature/Notifications/AttendanceNotificationRulesTest.php` |

### The One Real Gap: Deactivation Didn't Actually Revoke Access

Every other scenario above already had full, passing coverage. Deactivated
accounts did not: `docs/api/SYNC.md`'s own `guardian` resource section had
explicitly documented, since WP-02-02, that "an inactive guardian can
still hold a valid token until it's revoked" — i.e. deactivating a
guardian only blocked a *future* login; a token issued beforehand kept
working against `/auth/me`, `/sync/bootstrap`, `/sync/changes`, and the
notification endpoints indefinitely. Confirmed with a throwaway probe
before touching anything: a guardian deactivated mid-session could still
successfully call `GET /sync/changes` and receive their own scoped data.

This directly contradicts this package's own acceptance criterion
("revoked data is no longer accessible") for the one scenario the
Objective names as "deactivated accounts," so it was fixed rather than
merely documented as a risk (user-confirmed direction):

- Added `App\Http\Middleware\EnsureGuardianAccountIsActive`
  (`guardian.active` alias, registered in `bootstrap/app.php`) — rejects
  with `401` when the request's user is a guardian whose `Guardian`
  profile is `Inactive`. A guardian-role account with no profile yet, and
  every non-guardian role, passes through untouched.
- Applied to `auth/me`, the `sync` group, and the `notifications` group in
  `routes/api.php`. Deliberately **not** applied to `auth/logout` — a
  deactivated guardian can still explicitly revoke their own token.
- `401`, not `403`: `docs/api/AUTHENTICATION.md`'s `/auth/me` contract and
  `SessionController.build()` on the Flutter side (WP-07-07) already treat
  any `401` from that endpoint as "session no longer valid, return to
  login" (fails open on anything else, by design — offline-first). Using
  `401` means a deactivated guardian's mobile session ends on its very
  next launch/resume with **zero mobile code changes**, because
  `session_controller_test.dart`'s existing "a 401 from GET /auth/me
  clears the stored token" test is already written generically against
  the status code, not against a specific server-side cause.
- Added `tests/Feature/Api/V1/Auth/GuardianDeactivationAccessTest.php`:
  rejection from `/auth/me`, `/sync/bootstrap`, `/sync/changes`, and
  device-token registration once deactivated; logout still succeeds;
  active guardians, no-profile-yet guardian accounts, and administrators
  are all unaffected (regression coverage for the new middleware itself).
- Updated `docs/api/AUTHENTICATION.md` and `docs/api/SYNC.md` to describe
  the new behavior in place of the old "unresolved" note.

No proactive token deletion on deactivation was added — the middleware's
per-request check is the single enforcement point and is sufficient on
its own; the guardian's very next request (of any kind, from any device)
is rejected, not just their next login.

Verified: `vendor/bin/pint --test` clean, `vendor/bin/phpstan analyse`
clean on changed files, full Pest suite passing (399 tests, 3 pre-existing
skips unrelated to this change).

No migrations. New/changed contract: `GET /api/v1/auth/me`,
`GET /api/v1/sync/bootstrap`, `GET /api/v1/sync/changes`, and the
`notifications` endpoints now respond `401` (previously succeeded) for a
deactivated guardian's still-valid token — documented above.
