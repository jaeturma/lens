# WP-03-01 — RFID Device Registry

## Objective

Create the `rfid_devices` model and its dedicated credential mechanism —
registration (one-time secret exposure) and verification — that WP-03-03's
scan-ingestion endpoint will authenticate against. Per `docs/SECURITY.md`,
device credentials are a genuinely separate mechanism from guardian
Sanctum tokens (a device does not "log in"; it is provisioned once with a
fixed secret), so this is new infrastructure, not a reuse of WP-01-04's
Sanctum setup. No HTTP endpoint or admin UI exists yet (WP-03-03,
WP-03-05) — this package is the model and credential mechanism only.

## Affected Layers

- [x] Laravel
- [x] Database
- [x] API
- [ ] Flutter
- [ ] Android
- [x] RFID Integration

## Scope

- `rfid_devices` table/model: `device_code` (unique), `location`,
  `direction_mode` (`App\Enums\RfidDeviceDirectionMode`: Entry/Exit/Both),
  `secret` (hashed, same `'hashed'` cast pattern as `User.password`;
  never serialized — `#[Hidden(['secret'])]`), `status`
  (`App\Enums\RfidDeviceStatus`: Active/Revoked — "revoked," not
  "active/inactive," matching the literal acceptance criterion and the
  security-sensitive-termination precedent `GuardianStudentLinkStatus`
  already set), `last_activity_at` (nullable). No `school_id` — single-
  install, same reasoning as every other model this session. No `uuid` —
  unlike `Student`/`Guardian`, a device is never synced to a mobile
  client; `device_code` is already its natural stable identifier.
- `App\Actions\RfidDevices\RegisterRfidDevice`: generates a random plain
  secret, stores only the hash, and returns both the model and the plain
  secret in a small DTO — the one and only place the plain value is ever
  available, satisfying "secrets are protected" / "never displayed after
  creation."
- `App\Actions\RfidDevices\VerifyRfidDeviceCredentials`: looks up by
  `device_code`, rejects unless `status` is Active, verifies the secret
  via `Hash::check()`, and touches `last_activity_at` on success — the
  single choke-point WP-03-03's future authentication middleware calls,
  and also where "last activity" naturally gets recorded (a device's last
  activity *is* its last successful authenticated request).
- Register `rfid_device` in the `Relation::morphMap()` (WP-02-01) now,
  even though no `RecordAuditLog`/`RecordSyncChange` call site exists
  yet — WP-03-05's admin UI will need it, same as `student`/`guardian`
  were registered in their own data-model packages before WP-02-04/05
  used them. No sync-feed participation (no `#[ObservedBy]`) — devices
  are backend/admin-only, never part of a guardian's mobile data per
  `docs/OFFLINE-SYNC.md`'s Local Resources list.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

Phase 1.

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

- `device_code` is unique; creating a duplicate fails.
- The plain secret is returned exactly once, at registration; it is never
  present in the model's serialized form or retrievable afterward.
- A revoked device fails verification even with the correct secret.
- Successful verification updates `last_activity_at`.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes

- `rfid_devices` migration (`2026_07_21_110000_create_rfid_devices_table.php`):
  `device_code` (unique), `location`, `direction_mode`, `secret`, `status`
  (default `active`, indexed), `last_activity_at` (nullable),
  `timestamps()`. No `uuid` (not a synced resource, see Scope) and no
  `school_id` (single-install, established pattern).
- `App\Models\RfidDevice`: `#[Hidden(['secret'])]` plus the `'hashed'`
  cast on `secret` — same double-layered protection `User.password` gets
  (hashed at rest, never serialized even if a future endpoint accidentally
  returned the model directly).
- `App\Actions\RfidDevices\RegisterRfidDevice`/`VerifyRfidDeviceCredentials`:
  the two halves of the credential mechanism, both built now with no
  consumer yet (mirrors WP-01-07 building the sync feed before WP-01-08
  exposed it). `App\Support\RfidDevices\RfidDeviceRegistration` is a
  small readonly DTO (device + plain secret) rather than returning a
  bare array — the plain secret only ever exists in this one return
  value, never persisted or logged.
- Registered `'rfid_device' => RfidDevice::class` in the
  `Relation::morphMap()`, ahead of any actual `RecordAuditLog` call site
  (WP-03-05) — same ahead-of-time registration `student`/`guardian` got in
  their own data-model packages.
- No `#[ObservedBy]`/sync-feed participation, unlike `Student`/`Guardian`/
  `GuardianStudentLink` — deliberate, not an oversight: RFID devices are
  never part of a guardian's mobile data per `docs/OFFLINE-SYNC.md`'s
  Local Resources list, so there's nothing to sync.
- Tests: `tests/Feature/Models/RfidDeviceTest.php` (`device_code`
  uniqueness, secret absent from serialization, enum casts),
  `tests/Feature/Actions/RfidDevices/RegisterRfidDeviceTest.php` (creates
  Active device, returned plain secret verifies against the stored hash,
  distinct secrets per registration), `VerifyRfidDeviceCredentialsTest.php`
  (correct credentials succeed and touch `last_activity_at`; wrong secret,
  unknown `device_code`, and a revoked device all fail) — 9 new tests.
- `docs/api/RFID.md` documents the registration/verification contract and
  explicitly defers the actual HTTP endpoint/middleware/rate limiting to
  WP-03-03/03-04.
- Verification: `vendor/bin/pint` (clean), `vendor/bin/phpstan analyse app`
  (0 errors), full `php artisan test` — 160 passed, 3 pre-existing skips, 0
  failures.
