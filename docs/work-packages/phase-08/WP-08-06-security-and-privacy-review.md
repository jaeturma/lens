# WP-08-06 — Security and Privacy Review

## Objective

Review school binding, authorization, local storage, API exposure, secrets, rate limits, and privacy requirements.

## Affected Layers

- [x] Laravel
- [x] Database
- [x] API
- [x] Flutter
- [x] Android
- [ ] RFID Integration

## Scope

Fix confirmed defects only.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

Phases 1 through 7.

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

- Guardian isolation is proven.
- Device/user auth separation is proven.
- Backup exclusions and local data protection are verified.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes

A systematic pass over each named review area (school binding,
authorization, local storage, API exposure, secrets, rate limits,
privacy) against `docs/SECURITY.md`'s own baseline. Per this package's
Scope line ("fix confirmed defects only"), only concretely-demonstrated
gaps were changed — no speculative hardening.

### Review Findings

| Area | Finding | Action |
| --- | --- | --- |
| Rate limits | `auth/me` and `auth/logout` were the only two authenticated mobile endpoints with no throttle at all — every other one (`sync`, `device-tokens`, `rfid-scan`) already had one | **Fixed** — new `account` limiter (60/min per user), applied to both |
| Device/user auth separation | Structurally already disjoint (Basic Auth against `rfid_devices` vs. Sanctum bearer against `personal_access_tokens`), but never directly asserted, and the acceptance criterion specifically asks for it to be *proven* | **Tested** (no code change) — `tests/Feature/Api/V1/Auth/DeviceUserAuthSeparationTest.php` |
| Roles and Permission Matrix vs. implementation | `docs/SECURITY.md` documented RFID device registry as System-Administrator-exclusive; every `App\Policies\*` check in the codebase (not just `RfidDevicePolicy`) uses a single `isAdministrator()` with no tier distinction, and `RfidDeviceAdministrationTest.php` already deliberately tests this with a plain School Administrator — confirmed as intended, tested behavior, not an oversight (user-confirmed direction) | **Doc fixed**, no code change |
| Guardian isolation | Already extensively proven — `ScopeChangesToGuardianTest.php`, `ChangesTest.php`, `GuardianDeactivationAccessTest.php` (WP-08-03) | No gap found |
| Local storage | Auth token: `flutter_secure_storage` only (`mobile/lib/core/storage/token_storage.dart`), never SQLite/`SharedPreferences`. SQLite tables (`mobile/lib/core/database/tables.dart`) carry no password/token/secret fields — spot-checked against every sync payload shape in `docs/api/SYNC.md` | No gap found |
| Android backup exclusion | Already re-verified in WP-08-01 (`docs/work-packages/phase-08/WP-08-01-...md`'s own notes); confirmed via `git log` that neither `tables.dart` nor the backup/data-extraction rules XML has changed since | No gap found, not re-verified from scratch |
| API exposure | Spot-checked `UserResource` (no password/role leak), `MarkNotificationReadController`/`RevokeDeviceTokenController` (properly scoped by `guardian_id`, no IDOR) | No gap found |
| Secrets | `RfidDevice.secret` hashed + `#[Hidden]` (pre-existing). `.env*`, `firebase-credentials.json` gitignored; nothing secret-shaped committed (`git ls-files` checked) | No gap found |
| Privacy (policy, account/data deletion) | Explicitly owned by WP-08-07 (`docs/work-packages/phase-08/WP-08-07-...md`'s own acceptance criteria) | Out of scope here, not duplicated |

### Rate Limiting Fix

Added `RateLimiter::for('account', ...)` in `App\Providers\AppServiceProvider`
(60 requests/minute per authenticated user, matching the shape of the
existing `sync`/`device-tokens` limiters) and applied `throttle:account`
to the `auth/me` + `auth/logout` route group in `routes/api.php`. A valid
Sanctum token is already required either way, so this closes a
resource-exhaustion gap (a compromised or misbehaving client hammering
these two endpoints), not an authentication bypass. Documented in
`docs/api/AUTHENTICATION.md`.

### Device/User Auth Separation Tests (New)

`tests/Feature/Api/V1/Auth/DeviceUserAuthSeparationTest.php`: a
guardian's Sanctum token rejected when presented as RFID Basic Auth
credentials (and nothing stored); an RFID device's secret, and separately
its `device_code`, both rejected when presented as a Sanctum bearer
token. All three fail closed (`401`), confirming the two credential
spaces cannot be crossed in either direction.

### Roles and Permission Matrix Correction

`docs/SECURITY.md`'s matrix previously implied a real System
Administrator vs. School Administrator permission split (device registry,
administrator accounts, system-level settings reserved to System
Administrator). Confirmed this was never actually implemented anywhere —
every policy in the app uses one `isAdministrator()` check, and existing
tests already deliberately exercise device-registry management with a
plain School Administrator. Corrected the matrix to describe current,
tested behavior (both roles share full operational access this release;
the two `UserRole` cases are reserved for a future split, not yet gated
anywhere since administrator-account management/system-level settings
screens don't exist yet).

Verified: `vendor/bin/pint --test` clean, `vendor/bin/phpstan analyse`
clean on changed files (2 pre-existing, unrelated errors in
`config/sanctum.php`/`UserFactory.php`), full Pest suite passing
(403/406, 3 pre-existing skips unrelated to this change).

No migrations. Changed/new contract detail (not a new endpoint):
`GET /api/v1/auth/me` and `POST /api/v1/auth/logout` now respond `429`
after 60 requests/minute per user — documented in
`docs/api/AUTHENTICATION.md`.
