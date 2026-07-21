# WP-03-05 — RFID Administration Screens

## Objective

Extend the admin web UI (Inertia + React, same stack/conventions as
WP-02-04/05) to RFID devices, card assignment, and a read-only recent-scans
view, closing out Phase 03. Every mutation reuses WP-03-01/02's actions
(`RegisterRfidDevice`, `AssignRfidCard`, `DeactivateRfidCard`,
`ReplaceRfidCard`) rather than writing new business logic — this package
is controllers, requests, policies, and pages around what already exists.

## Affected Layers

- [x] Laravel
- [x] Database
- [ ] API
- [ ] Flutter
- [ ] Android
- [ ] RFID Integration

## Scope

- `App\Policies\RfidDevicePolicy`/`RfidCardPolicy`/`RfidScanPolicy` — same
  `isAdministrator()` shape as `StudentPolicy`/`GuardianPolicy`.
  `RfidScanPolicy` only needs `viewAny` (scans are never created/edited
  through the admin UI — only physical devices via WP-03-03's endpoint).
- **Devices** (`RfidDeviceController`: index/create/store/show/edit/update,
  plus `ActivateRfidDeviceController`/`RevokeRfidDeviceController`):
  clarifies a question WP-03-01 deliberately left open — revocation *is*
  reversible through this UI (an admin can reactivate a mis-revoked
  device), the same Active/Inactive-cycle shape `Student`/`Guardian`
  already have, just spelled `active`/`revoked` because that's the enum
  WP-03-01 chose. `edit`/`update` only ever touch `location`/
  `direction_mode` — never `device_code` (identity) or `secret` (no
  "regenerate" feature; not asked for, and not needed to make revoke/
  reactivate work).
- **One-time secret display**: `store()` calls `RegisterRfidDevice`, then
  `Inertia::flash('rfidDeviceSecret', $plainSecret)` before redirecting to
  the device's `show` page — reuses the existing `Inertia::flash()`
  mechanism already used for toasts (`ProfileController` etc.), not a new
  channel. The plain secret is never stored anywhere and is only present
  in the *one* response immediately after registration; every later visit
  to the same `show` page has no `flash.rfidDeviceSecret` prop at all.
- **Cards** (`RfidCardController`: index/create/store,
  `DeactivateRfidCardController`, `ReplaceRfidCardController`): a single
  global index (search by `uid`/student name, filter by status) rather
  than embedding assignment inside the student's own show page — cards
  are their own administrative surface here (WP-02-04's student pages are
  not touched). Controllers call WP-03-02's actions directly
  (`AssignRfidCard`/`DeactivateRfidCard`/`ReplaceRfidCard`), which already
  call `RecordAuditLog` themselves (built into those actions since
  WP-03-02's own acceptance criteria required it) — the controllers here
  must **not** log again, only pass `$request->user()` through as actor.
  Device actions (`RegisterRfidDevice` and friends) do **not**
  self-audit, so `RfidDeviceController`/`Activate`/`RevokeRfidDeviceController`
  call `RecordAuditLog` themselves, matching WP-02-04/05's pattern.
- **Recent scans** (`RfidScanController@index`, read-only): paginated
  list with `device`/`classification` filters, showing `uid`,
  `device_timestamp`, `created_at`, and a status-like badge per
  classification. No live/auto-refreshing view ("avoid ... live
  telemetry") — a plain page the admin reloads.
- "RFID Devices"/"RFID Cards"/"RFID Scans" added to the sidebar nav.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

WP-03-01 through WP-03-04.

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

- A guardian-role account is rejected (`403`) from every `rfid-*` route;
  an administrator can list/search/filter all three, register/edit/
  activate/revoke devices, and assign/deactivate/replace cards.
- Revoked devices, non-active cards, and non-`valid` scans are visually
  distinguishable (badges), not just present in an undifferentiated list.
- The plain device secret appears exactly once (immediately after
  registration) and is never retrievable afterward, from the UI or the
  database.
- Tests pass.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes

- `App\Policies\RfidDevicePolicy`/`RfidCardPolicy`/`RfidScanPolicy`: same
  `isAdministrator()` shape as `StudentPolicy`/`GuardianPolicy`.
  `RfidScanPolicy` only defines `viewAny` — there is genuinely no other
  ability to gate, since scans are never mutated through this UI.
- **Revocation reconsidered**: WP-03-01 deliberately left open whether
  `revoked` was one-way. This package resolves it: `ActivateRfidDeviceController`
  makes it reversible, the same Active/Inactive-cycle shape `Student`/
  `Guardian` already have. This also sidesteps a real problem a one-way
  revoke would have created — `device_code` has a plain `unique()`
  constraint (unlike `RfidCard`'s generated-column trick), so a
  permanently-revoked device would have permanently blocked its own
  `device_code` from ever being reused.
- **One-time secret display**: `RfidDeviceController::store()` calls
  `Inertia::flash('rfidDeviceSecret', $plainSecret)` before redirecting to
  `show`. Confirmed via
  `TestResponse::assertInertiaFlash()`/`assertInertiaFlashMissing()`
  (macros the `inertiajs/inertia-laravel` package itself provides for
  exactly this — flashed data lives under a single nested session key,
  `inertia.flash_data`, not as a top-level session key, so a plain
  `assertSessionHas('rfidDeviceSecret')` doesn't work; this cost one
  failed test run to discover). `show.tsx` reads
  `usePage().props.flash.rfidDeviceSecret` directly (not the `toast`
  event-listener pattern `useFlashToast` uses — that hook is a global,
  page-agnostic listener; this is page-specific reveal logic, so reading
  the prop directly on mount is the right tool here) and renders it only
  when present — the next visit to the same `show` page has no such prop.
- Card admin controllers (`RfidCardController`,
  `DeactivateRfidCardController`, `ReplaceRfidCardController`) call
  WP-03-02's actions directly and pass `$request->user()` through as
  actor — those actions already call `RecordAuditLog` themselves, so the
  controllers must not (and don't) log again. Device controllers
  (`RfidDeviceController`, `Activate`/`RevokeRfidDeviceController`) do
  call `RecordAuditLog` themselves, since `RegisterRfidDevice` and
  friends (WP-03-01) never self-audit — mirrors the exact split already
  documented in WP-03-05's Scope.
- `RfidCardController::store()` fixed a PHPStan finding during
  implementation: `Student::query()->findOrFail($validated['student_id'])`
  is typed to possibly return a `Collection` (its generic signature
  covers both single- and multi-ID lookups), which doesn't match
  `AssignRfidCard`'s `Student $student` parameter. Switched to
  `->where('id', ...)->firstOrFail()`, which has an unambiguous
  single-`Model` return type.
- Cards get their own global index (search by `uid`/student name, filter
  by status) rather than being embedded in the student's show page,
  unlike WP-02-05's guardian-student links — the WP explicitly frames
  device/card/scan administration as three parallel surfaces, and a card
  is meaningful to look up by UID alone (e.g. "whose card is this")
  without already knowing the student.
- Recent scans (`RfidScanController@index`) is intentionally read-only —
  no create/edit/delete route exists, matching "recent scans are visible"
  without any mutation ability, and no polling/auto-refresh ("avoid ...
  live telemetry").
- "RFID Devices"/"RFID Cards"/"RFID Scans" added to the sidebar nav
  alongside "Students"/"Guardians".
- Tests: `tests/Feature/RfidDevices/RfidDeviceAdministrationTest.php`
  (guardian rejected from all 8 routes, index/search/filter, register +
  one-time secret flash + audit log, validation, edit/update,
  revoke/reactivate with audit logs), `tests/Feature/RfidCards/RfidCardAdministrationTest.php`
  (guardian rejected, index/search/filter, assign + audit log, duplicate-
  UID rejection, deactivate, replace, replace-with-taken-UID rejection),
  `tests/Feature/RfidScans/RfidScanAdministrationTest.php` (guardian
  rejected, index + device/classification filters) — 15 new tests.
- Verification: `vendor/bin/pint` (clean), `vendor/bin/phpstan analyse app`
  (0 errors), full `php artisan test` — 202 passed, 3 pre-existing skips, 0
  failures. Frontend: `tsc --noEmit`, `eslint .`, `prettier --check`
  (clean after `npm run format`), `vite build` — all clean. Same browser-
  verification caveat as WP-02-04/05: the Chrome extension was not
  connected in this environment, so the UI (including the one-time secret
  reveal) was not visually confirmed in an actual browser — verification
  is limited to the full server-side HTTP/Inertia response cycle plus
  static/build checks.
