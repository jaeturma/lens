# WP-03-03 — RFID Scan Ingestion API

## Objective

Expose the first endpoint a physical device calls: `POST
/api/v1/rfid/scans`, authenticated via WP-03-01's device credentials
(HTTP Basic Auth, not Sanctum — a device presents a fixed `device_code` +
secret on every request, it never "logs in"). This package only accepts
and stores the raw scan; it does not look the `uid` up against
`rfid_cards`, detect duplicates, or interpret direction/attendance — that
cross-referencing is WP-03-04 (idempotency/invalid-card handling) and
WP-04 (attendance), reading the same `rfid_scans` rows.

## Affected Layers

- [x] Laravel
- [x] Database
- [x] API
- [ ] Flutter
- [ ] Android
- [x] RFID Integration

## Scope

- `rfid_scans` table/model: `rfid_device_id` (FK, from the authenticated
  device — never a request field), `uid`, `device_timestamp`,
  `request_id` (the device's own local sequence/idempotency identifier —
  stored now, only *used* for dedup in WP-03-04; no unique constraint
  added here, that's WP-03-04's design space). Append-only, same pattern
  as `audit_logs`/`sync_changes` (`created_at` only, no `updated_at`) — a
  raw scan is never edited after ingestion.
- `App\Http\Middleware\AuthenticateRfidDevice`: parses HTTP Basic Auth
  (`$request->getUser()`/`getPassword()`), calls WP-03-01's
  `VerifyRfidDeviceCredentials`, attaches the resolved device to the
  request on success or returns `401`. New `rfid.device` middleware
  alias.
- Deliberately **not** reusing `school.mobile` (`EnsureSchoolMobileAccessIsAvailable`):
  that middleware conflates maintenance mode with the mobile *app's*
  `mobile_enabled`/minimum-version gates, neither of which make sense for
  hardware — disabling the parent app temporarily should not also stop
  attendance scanning. The RFID endpoint is gated by device credentials
  and rate limiting only.
- New `rfid-scan` named rate limiter, keyed by the authenticated device
  (falls back to IP only if somehow unauthenticated, which the middleware
  ordering prevents from reaching the controller anyway).
- `App\Http\Controllers\Api\V1\Rfid\IngestRfidScanController` +
  `StoreRfidScanRequest` (`uid`, `device_timestamp`, `request_id` — all
  required; no `device` field, since that comes from authentication, not
  the body). Concise response: just the new scan's `id`.
- No audit logging and no `Relation::morphMap()` entry for `rfid_scans` —
  a routine scan is high-frequency telemetry, not a discrete
  administrative action; logging every tap to `audit_logs` would make
  that table useless for its actual purpose. No sync-feed participation
  either, same reasoning as `RfidDevice`/`RfidCard`.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

WP-03-01, WP-03-02.

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

- A well-formed request from a valid, active device is stored and
  returns its `id`.
- Missing/wrong Basic Auth credentials, unknown `device_code`, or a
  revoked device all return `401` without storing anything.
- Malformed payloads (missing `uid`/`device_timestamp`/`request_id`)
  return `422` without storing anything.
- The endpoint is rate-limited per device.
- Tests pass.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes

- `rfid_scans` migration (`2026_07_22_130000_create_rfid_scans_table.php`):
  `rfid_device_id` (FK, `restrictOnDelete` — raw scans must survive even
  if a device row were ever removed, though in practice devices are only
  revoked, never deleted), `uid` (indexed, for WP-03-04's future
  card cross-referencing), `device_timestamp`, `request_id` (plain string,
  no index/uniqueness — WP-03-04 owns that design decision, not this WP),
  `created_at` only (`useCurrent()`, indexed) — append-only, same as
  `audit_logs`/`sync_changes`, enforced on the model via `const UPDATED_AT
  = null`.
- `App\Http\Middleware\AuthenticateRfidDevice`: reads HTTP Basic Auth via
  Symfony's `$request->getUser()`/`getPassword()` (no manual header
  parsing needed), delegates to WP-03-01's `VerifyRfidDeviceCredentials`,
  and stores the resolved device on `$request->attributes` (`'rfidDevice'`)
  for the controller and the rate limiter to read. Registered as the
  `rfid.device` alias in `bootstrap/app.php`.
- New `rfid-scan` rate limiter (120/min, keyed by device ID) in
  `AppServiceProvider` — broadened that method's docblock from "mobile API
  endpoints" to "mobile and device API endpoints" since it's no longer
  guardian-only.
- `IngestRfidScanController` + `StoreRfidScanRequest`: no `device` field
  in the request body (comes from the authenticated device); response is
  just `{id}`. Confirmed the request pipeline order needed here —
  middleware (including `rfid.device`) always runs before a `FormRequest`'s
  own validation, which only happens when Laravel resolves the controller
  method's parameters — so `$request->attributes->get('rfidDevice')` is
  guaranteed set by the time `StoreRfidScanRequest::rules()` or the
  controller body runs.
- Deliberately did not reuse `school.mobile` middleware and did not add
  audit logging or a `sync_changes`/`Relation::morphMap()` entry for
  `rfid_scans` — reasoning captured in Scope above and in
  `docs/api/RFID.md`, so a future reader doesn't mistake either omission
  for something forgotten.
- Tests: `tests/Feature/Api/V1/Rfid/ScanIngestionTest.php` — valid device
  succeeds and stores the row; no credentials, wrong secret, unknown
  `device_code`, and a revoked device all `401` with nothing stored;
  malformed payload `422` with nothing stored; 120 requests succeed then
  the 121st `429`s — 7 tests.
- `docs/api/RFID.md` documents the endpoint's auth, request/response
  shapes, and failure modes, and narrows "Not Yet Implemented" to what's
  actually still missing (WP-03-04's idempotency/card cross-referencing,
  WP-04's attendance interpretation, WP-03-05's admin UI).
- Verification: `vendor/bin/pint` (clean), `vendor/bin/phpstan analyse app`
  (0 errors), full `php artisan test` — 178 passed, 3 pre-existing skips, 0
  failures.
