# WP-01-02 — School Profile and Mobile Settings

## Objective

Create the single-school record and mobile-facing settings.

## Affected Layers

- [x] Laravel
- [x] Database
- [x] API
- [ ] Flutter
- [ ] Android
- [ ] RFID Integration

## Scope

Include public School ID, immutable UUID, branding, timezone, mobile-enabled flag, maintenance state, notification flag, and minimum app version.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

WP-01-01.

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

- School ID is unique.
- UUID is immutable.
- Mobile settings are administrable and validated.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes

- Two tables per the existing `docs/DATABASE.md` schema list (`schools`,
  `school_settings`), 1:1 via `school_settings.school_id`:
  - `schools`: `uuid` (unique, auto-generated on create, immutable —
    `App\Models\School` throws `LogicException` if an update attempts to
    change it), `public_id` (unique — the guardian-facing "School ID"),
    `name`, `logo_url` (nullable, minimal branding).
  - `school_settings`: `timezone` (default `Asia/Manila`, validated against
    PHP's timezone list), `mobile_enabled`, `maintenance_mode`,
    `maintenance_message` (required when `maintenance_mode` is true),
    `notifications_enabled`, `minimum_app_version` (semver string, default
    `0.1.0` matching the WP-00-02 mobile version strategy).
  - `App\Models\School`, `App\Models\SchoolSettings` (Eloquent, with
    `#[Fillable]` attributes matching the existing `User` model convention),
    plus factories for testing.
- `App\Http\Requests\SchoolSettingsUpdateRequest` encodes the validation
  rules for "Mobile settings are administrable and validated." No HTTP
  route consumes it yet: an admin mutation endpoint would be unauthenticated
  and unauthorized without Sanctum/policies, which don't exist until
  WP-01-04/WP-01-05. The public School Resolver read endpoint that consumes
  these tables is WP-01-03's scope, not this package's — no API contract
  changed here.
- Tests: `tests/Feature/School/SchoolTest.php` (uuid auto-generation and
  immutability, `public_id`/`uuid`/`school_id` uniqueness, the 1:1
  relationship) and `tests/Feature/School/SchoolSettingsUpdateRequestTest.php`
  (valid data passes; invalid timezone, non-semver version, and
  maintenance-mode-without-message all fail with the expected error keys).
- Verification: `vendor/bin/pint` (auto-fixed an import in the test file),
  `vendor/bin/phpstan analyse` (0 errors after adding generic relation
  return types), full `php artisan test` — 39 passed, 3 pre-existing skips,
  0 failures.
