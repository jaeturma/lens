# WP-01-08 — Bootstrap and Incremental Sync APIs

## Objective

Expose WP-01-07's change feed over the mobile API: an authenticated
bootstrap endpoint and an authenticated incremental sync endpoint, matching
`docs/API-STANDARD.md`'s Synchronization Response shape. No guardian-owned
domain resource (students, announcements, attendance) exists yet — this
package wires the transport only; the `changes` array is empty until phase
2+ work packages start calling `RecordSyncChange`.

## Affected Layers

- [x] Laravel
- [ ] Database
- [x] API
- [x] Flutter
- [ ] Android
- [ ] RFID Integration

## Scope

- `GET /api/v1/sync/bootstrap` (`auth:sanctum`, `school.mobile`,
  `throttle:sync`): returns the school profile (reusing
  `SchoolResolverResource`), the authenticated user
  (`UserResource`), and `next_cursor` — the change-feed position as of now,
  so the client's first incremental sync call starts after the bootstrap
  snapshot instead of re-downloading it.
- `GET /api/v1/sync/changes` (same middleware): requires a `cursor` query
  parameter (obtained from bootstrap or a previous call — no timestamp
  fallback, per `docs/OFFLINE-SYNC.md` Cursor Rules), optional `limit`
  (1-200, default 100). Returns `next_cursor`, `has_more`, and `changes`
  (each entry: `resource_type`, `resource_id`, `action`, `payload`,
  `created_at`) via WP-01-07's `FetchSyncChanges`.
- Both endpoints reject non-guardian accounts with `403`, mirroring
  `LoginController` (defense in depth: today only guardian accounts can
  obtain a Sanctum token at all, but this does not rely on that staying
  true).
- New `sync` named rate limiter (`RateLimiter::for`), applied like
  `mobile-login`/`school-resolver`, per `docs/SECURITY.md` "Rate limits on
  login, resolver, sync, and device scan endpoints."

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

WP-01-04, WP-01-07.

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

- Bootstrap returns the school profile, the authenticated guardian, and a
  usable next cursor.
- Incremental sync rejects a missing/malformed cursor, chunks results, and
  reports `has_more` correctly.
- Only guardian accounts may call either endpoint; both are gated by
  `school.mobile` (maintenance/disabled/version) and rate limited.
- Contracts are documented in `docs/api/SYNC.md`.
- Tests pass.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes

- `GET /api/v1/sync/bootstrap` (`App\Http\Controllers\Api\V1\Sync\BootstrapController`)
  and `GET /api/v1/sync/changes` (`...\ChangesController`), both under
  `Route::prefix('sync')->middleware(['auth:sanctum', 'school.mobile',
  'throttle:sync'])` in `routes/api.php` — nested as a sibling of the
  existing `auth` group rather than inside it, since sync is not an auth
  concern.
- `App\Actions\Sync\CurrentSyncCursor`: `SyncCursor::fromSequence((int)
  (SyncChange::max('id') ?? 0))` — new, small addition needed so bootstrap
  can hand back a cursor positioned at "now" (WP-01-07 only had
  cursor-relative fetching, not "what is the current tip").
- Both controllers reject non-guardian accounts with `403`
  (`This account is not enabled for mobile synchronization.`), mirroring
  `LoginController`. This is deliberate defense in depth: today only
  guardian accounts can ever hold a Sanctum token (WP-01-05's login gate),
  so this check cannot currently be hit via the real login flow, but the
  endpoint does not rely on that staying true.
- `App\Http\Requests\Sync\SyncChangesRequest`: `cursor` is `required` (no
  timestamp fallback, per `docs/OFFLINE-SYNC.md`), validated via a closure
  rule that calls `SyncCursor::fromString()` and fails with a normal
  validation error (`422`) rather than leaking the `InvalidArgumentException`
  message. `limit` is `nullable|integer|min:1|max:200`; the controller
  applies the `100` default (the same clamp also lives in
  `FetchSyncChanges` as a second line of defense).
- New `sync` named rate limiter in `AppServiceProvider`
  (`Limit::perMinute(30)->by($request->user()?->id ?: $request->ip())`) —
  keyed by user, not IP, since these are authenticated endpoints; `auth:sanctum`
  runs before `throttle:sync` in the route middleware so `$request->user()`
  is resolved when the limiter closure executes.
- `App\Http\Resources\V1\BootstrapResource`, `SyncChangesResource`, and
  `SyncChangeResource` added, reusing the existing `SchoolResolverResource`
  and `UserResource` rather than duplicating those fields. `created_at` is
  formatted `Y-m-d\TH:i:s\Z` to match `docs/API-STANDARD.md`'s literal
  example (no microseconds) — the first resource in the app to serialize a
  raw timestamp, so this sets the convention for later resources.
- Extracted the `bindSchool()` test helper (previously local to
  `MobileLoginTest.php`) into `tests/Pest.php`'s shared Functions section,
  since the new sync tests need the same school-binding setup and
  duplicating the function name in two loaded test files would fatal-error
  on redeclaration. No behavior change — confirmed by `MobileLoginTest`
  still passing unmodified.
- `docs/api/SYNC.md` documents both endpoints with full request/response
  examples and narrows the "Not Yet Implemented" note to guardian-scoped
  *resource* authorization (deferred to phase 2+, since no guardian-owned
  resource type exists yet) rather than the endpoints themselves.
  `docs/API-STANDARD.md`'s Synchronization Response example changed
  `"changes": {}` to `"changes": []` to match the real (array) shape.
- Tests: `tests/Feature/Api/V1/Sync/BootstrapTest.php` (school/user/cursor
  shape, `401`/`403`/`503`/`429`), `ChangesTest.php` (returns changes after
  cursor, deterministic no-change response, missing/malformed cursor `422`,
  limit `>200` rejected, chunking + `has_more`, non-guardian `403`),
  `tests/Feature/Actions/Sync/CurrentSyncCursorTest.php` — 17 new tests.
- Verification: `vendor/bin/pint` (clean), `vendor/bin/phpstan analyse app`
  (0 errors), full `php artisan test` — 89 passed, 3 pre-existing skips, 0
  failures (no regression).
