# WP-01-03 — School Resolver API

## Objective

Implement the first-launch School ID resolver.

## Affected Layers

- [x] Laravel
- [ ] Database
- [x] API
- [x] Flutter
- [ ] Android
- [ ] RFID Integration

## Scope

Create a rate-limited unauthenticated resolver returning safe school profile and mobile status data.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

WP-01-02.

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

- Valid School ID resolves.
- Invalid or disabled school is rejected safely.
- Minimum version and maintenance fields are returned.
- Pest tests pass.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes

- Laravel/API layer only, this session. Flutter is marked as an affected
  layer in this package, but the first-launch School ID screen depends on
  Drift/SQLite (WP-07-02), which is not installed yet per the WP-00-01
  baseline — that consumption is WP-07-03's scope, not this one.
- `GET /api/v1/schools/resolve/{publicId}` (`App\Http\Controllers\Api\V1\ResolveSchoolController`,
  `App\Http\Resources\V1\SchoolResolverResource`): unauthenticated, rate
  limited via a new named limiter (`school-resolver`, 10/min per IP,
  registered in `AppServiceProvider` following the existing Fortify `login`
  limiter pattern). Route parameter constrained to `[A-Za-z0-9\-]{1,64}`
  before it ever reaches a query.
- Design decision: `mobile_enabled` / `maintenance_mode` do not make the
  resolver reject the request — they're returned as status data for the
  client to act on, per the Scope wording ("returning safe school profile
  and mobile status data") and the explicit acceptance criterion that
  minimum version and maintenance fields must be *returned*. Only a School
  ID that doesn't resolve to a school with settings is rejected, with a
  generic "School ID not found." message (no information leak about which
  case occurred) — documented in `docs/api/SCHOOL-RESOLVER.md`.
- Tests: `tests/Feature/Api/V1/SchoolResolverTest.php` — valid resolve,
  unknown School ID, school without settings, disabled/maintenance school
  still resolves with accurate flags, and the per-IP rate limit trips at
  the 11th request within a minute.
- Verification: `vendor/bin/pint` (clean), `vendor/bin/phpstan analyse`
  (0 errors), full `php artisan test` — 44 passed, 3 pre-existing skips,
  0 failures.
