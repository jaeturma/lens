# WP-06-04 — Mobile Device Token Registration

## Objective

Register, refresh, revoke, and deactivate Firebase tokens.

## Affected Layers

- [x] Laravel
- [x] Database
- [x] API
- [x] Flutter
- [ ] Android
- [ ] RFID Integration

## Scope

Support multiple devices per guardian.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

WP-01-04, WP-06-01.

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

- Tokens are guardian-bound and school-bound.
- Duplicate tokens are handled.
- Logout token behavior is documented.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes

- Laravel/API layer only, per explicit scoping for this session — the
  Flutter side (Firebase SDK integration, calling these endpoints on
  token refresh and at logout) is separate follow-up work, not included
  here.
- `device_tokens` migration: `guardian_id` (FK, `cascadeOnDelete`),
  `token` (unique), `status` (default `active`), `revoked_at` (nullable).
  **No `school_id` column** — this installation is bound to exactly one
  school already; `school.mobile` middleware on the routes is what
  enforces the "school-bound" acceptance criterion, not a redundant
  column every other guardian-owned table also lacks.
  `App\Enums\DeviceTokenStatus` defines the full vocabulary
  (`Active`/`Revoked`/`Deactivated`) even though this package only ever
  sets the first two — `Deactivated` is WP-06-06's, for invalid-token
  detection during push delivery, same "define the field now, a later
  package populates it" precedent as `NotificationType` (WP-06-01).
  `App\Models\DeviceToken` hides `token` from serialization
  (`#[Hidden]`), matching `RfidDevice.secret`'s caution even though a
  push token isn't a login credential.
- `App\Actions\Notifications\RegisterDeviceToken` handles register,
  refresh, and duplicate-claiming as one action (see
  `docs/NOTIFICATIONS.md` for the full reasoning): a second registration
  of an already-known token — under the same guardian or a different one
  — reactivates and reassigns the existing row rather than attempting a
  second `INSERT` against the unique `token` column.
  `App\Actions\Notifications\RevokeDeviceToken` is unconditional and
  idempotent, matching `RfidDevice` activate/revoke's simplicity rather
  than announcements/attendance corrections' guarded-transition style —
  revoking a token twice isn't an error condition here.
- Two endpoints (`POST`/`DELETE /api/v1/notifications/device-tokens`),
  guardian-self-service (no Policy — a guardian only ever acts on tokens
  scoped to themselves; `RevokeDeviceTokenController` explicitly scopes
  its lookup by `guardian_id` and returns `404` rather than `403` for a
  token it doesn't own, to avoid confirming whether that token exists at
  all). New `device-tokens` rate limiter (30/minute per user, same shape
  as `sync`'s).
- **"Logout token behavior," this package's own scope item — decided as:
  not linked.** Logout (`LogoutController`, WP-01-04) does not
  automatically revoke any device token, and this package didn't change
  it to. A guardian can be logged in on **multiple devices**
  simultaneously (the package's own "support multiple devices per
  guardian" requirement), so the server has no reliable way to know
  which device token corresponds to the session being logged out;
  revoking is left to the client, which knows its own token, as part of
  its own logout flow.
- `Guardian::deviceTokens(): HasMany` added alongside the existing
  `links()`/`activeLinks()`/`notifications()` relations.
- Tests: `DeviceTokenTest.php` (3 — uniqueness, token hidden from
  serialization, default `Active` status), `RegisterDeviceTokenTest.php`
  (6 — new registration, same-guardian idempotency, cross-guardian
  reassignment, reactivating a revoked token, refresh
  revokes-old-activates-new, a `previous_token` owned by a different
  guardian is left untouched), `RevokeDeviceTokenTest.php` (2 — revoke,
  idempotent double-revoke), `Api/V1/Notifications/DeviceTokensTest.php`
  (10 — register success/validation/unauthenticated/non-guardian/
  no-profile-yet/maintenance-mode, revoke own/cross-guardian-denied/
  unknown-404, rate limit) — 21 new tests.
- Verification: `vendor/bin/pint --dirty` (clean), `vendor/bin/phpstan
  analyse app` (0 errors), full `php artisan test` — 361 passed, 3
  pre-existing skips, 0 failures.
