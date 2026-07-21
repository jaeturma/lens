# WP-01-01 — API Versioning and Error Responses

## Objective

Establish `/api/v1` and consistent JSON responses.

## Affected Layers

- [x] Laravel
- [ ] Database
- [x] API
- [ ] Flutter
- [ ] Android
- [ ] RFID Integration

## Scope

Add versioned route groups, representative resources, validation and exception behavior, and tests.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

Phase 0.

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

- Versioned routes work.
- Validation and authorization errors are consistent.
- Tests pass.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes

- `routes/api.php` created and registered in `bootstrap/app.php`
  (`withRouting(api: ...)`), prefixed `v1` inside the file (final path
  `/api/v1/...`, matching `docs/API-STANDARD.md`).
- Added `App\Http\Responses\ApiResponse` (`success()`/`error()` static
  helpers) implementing the Success/Error envelope from
  `docs/API-STANDARD.md`. Reused by both the reference controller and the
  global exception renderers, so future work packages have one shared
  helper instead of each controller building the envelope by hand.
- `JsonResource::withoutWrapping()` enabled in `AppServiceProvider::boot()`
  so API Resources don't double-wrap under Laravel's default `"data"` key
  on top of our own envelope.
- Representative resource: `App\Http\Resources\V1\HealthResource` +
  `App\Http\Controllers\Api\V1\HealthController` (invokable) at
  `GET /api/v1/health`, documented in `docs/API-STANDARD.md` under
  "Reference Implementation" as the pattern future endpoints follow.
- `bootstrap/app.php` `withExceptions()`: added `render()` closures, scoped
  to `api/*` requests only (web/Inertia error rendering untouched), for
  `ValidationException` (422), `AuthenticationException` (401),
  `AuthorizationException` (403), `ModelNotFoundException` /
  `NotFoundHttpException` (404), and a generic `Throwable` fallback that
  preserves the real HTTP status when the exception carries one and falls
  back to a generic "Server error." message (no leaked exception message or
  trace) for anything else when `app.debug` is off.
- Tests: `tests/Feature/Api/V1/HealthTest.php` (envelope shape) and
  `tests/Feature/Api/V1/ErrorResponseTest.php` (404 on unknown route, plus
  422/401/403/500 exercised via routes registered ad hoc inside the test —
  a standard Laravel technique for testing global exception handling
  without adding permanent throwaway business routes). No Sanctum/auth
  routes are added here; guardian authentication is WP-01-04's scope.
- Verification run: `vendor/bin/pint` (auto-fixed import order/spacing in
  `bootstrap/app.php`), `vendor/bin/phpstan analyse` on all changed files
  (0 errors after adding two missing array value-type annotations), full
  `php artisan test` (29 passed, 3 pre-existing skips, 0 failures),
  `php artisan route:list --path=api` confirms `GET|HEAD api/v1/health`.
