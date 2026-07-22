# WP-07-07 — Session Restoration and Logout

## Objective

Restore valid sessions and clear only parent-specific data on logout.

## Affected Layers

- [ ] Laravel
- [ ] Database
- [x] API
- [x] Flutter
- [ ] Android
- [ ] RFID Integration

## Scope

Logout must preserve school binding and school profile while clearing token and guardian-owned synchronized data as defined.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

WP-07-06.

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

- Session restores when valid.
- Expired token returns to login.
- Logout preserves School ID.
- Local data clearing behavior is tested.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes

Replaces WP-07-06's placeholder session check (`SessionController.build()`
only asked "does a token exist locally") with the real thing:

- **"Session restores when valid"**: `build()` now confirms a stored token
  against `GET /auth/me` (new `AuthApi.currentUser()`) before trusting it.
- **"Expired token returns to login"**: only a `401` — the server
  explicitly rejecting the token — clears it (`TokenStorage.clearAccessToken()`)
  and reports no session. Any other failure (unreachable server, `5xx`)
  fails open and keeps the guardian signed in instead: offline-first
  (`docs/OFFLINE-SYNC.md` Offline Behavior) means a dropped connection
  must not look like a logout. This distinction is exactly why
  `ApiException.statusCode` matters here, not just its message.
- **Logout** (`SessionController.logout()`, new `AuthApi.logout()` calling
  `POST /auth/logout`): revokes the token server-side best-effort (local
  logout proceeds even if that call fails — a guardian tapping "log out"
  expects their own device to forget them regardless of connectivity),
  then clears the stored token and calls the new
  `AppDatabase.clearGuardianOwnedData()`.
- **"Logout preserves School ID"**: `clearGuardianOwnedData()` deletes
  `guardian_profile`, `students`, `attendance_records`, `announcements`,
  `notifications`, and `sync_state` in one transaction — deliberately
  *not* `school_profile` or `app_settings`. Everything cleared is
  guardian-scoped data that would otherwise leak into whichever guardian
  logs in next on the same device (a stale sync cursor is included for
  the same reason: reusing it would make a new guardian's first sync skip
  data it never actually received).
- Added a logout action (`FoundationPage`'s AppBar) as the only reachable
  way to trigger it — there was previously no UI path to logout at all.

**Tests**: `session_controller_test.dart` rewritten — token absent (no
server check made); token present + `/me` succeeds; `401` clears the
token; non-`401` failure fails open; `markAuthenticated`; logout's full
effect (token cleared, guardian tables emptied, `school_profile`
untouched, session flips false); logout still completing locally when the
server-side revoke throws. New `logout_flow_test.dart`: end-to-end through
`LensApp` — tap the logout action, guardian profile is gone, school
binding remains, the gate reactively swaps back to `LoginPage`.

**"Local data clearing behavior is tested"** is covered by the
`clearGuardianOwnedData` assertions above (both the unit-level
`SessionController` test and the full widget-level flow), not a
separate migration/schema test — nothing about the schema itself changed.

Verification: `flutter analyze` clean, `dart format` applied, `flutter
test` — 41/41 passing.
