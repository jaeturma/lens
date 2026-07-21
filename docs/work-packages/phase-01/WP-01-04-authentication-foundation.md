# WP-01-04 — Authentication Foundation

## Objective

Prepare school-bound administrator and guardian authentication.

## Affected Layers

- [x] Laravel
- [x] Database
- [x] API
- [ ] Flutter
- [ ] Android
- [ ] RFID Integration

## Scope

Reuse existing web authentication and add Sanctum mobile login, current user, logout, and revocation.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

WP-01-03.

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

- Admin web login remains functional.
- Guardian login requires the resolved school.
- Tokens can be revoked.
- Tests pass.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes

- Architecture decision (confirmed with the user before implementing):
  guardians authenticate as `App\Models\User` rows via Sanctum tokens, not a
  separate Authenticatable model. `HasApiTokens` added to `User` (closing
  the gap the WP-00-01 baseline already flagged). WP-02-02's own wording
  ("guardian records linked to authentication") matches this: it will add a
  `guardians` profile table with a `user_id` FK, not a competing login
  mechanism. Admin web login (Fortify) is completely untouched — verified
  by the full suite still passing, including `tests/Feature/Auth/*`.
- `laravel/sanctum` installed; `config/sanctum.php` and the
  `personal_access_tokens` migration published (not yet run against a real
  dev DB, only dry-run + the in-memory test DB).
- `POST /api/v1/auth/login` (`App\Http\Requests\MobileLoginRequest`,
  `App\Http\Controllers\Api\V1\Auth\LoginController`): school-bound via
  `Rule::exists('schools', 'public_id')` on `school_id` — this is what
  satisfies "guardian login requires the resolved school." Rate limited
  (`mobile-login`, 5/min per email+IP, mirroring Fortify's own `login`
  limiter). Issues a Sanctum token on success.
- `GET /api/v1/auth/me`, `POST /api/v1/auth/logout`
  (`App\Http\Controllers\Api\V1\Auth\{MeController,LogoutController}`):
  standard `auth:sanctum`-protected routes. Logout revokes only the
  current token (`currentAccessToken()->delete()`), satisfying "tokens can
  be revoked" without inventing a "revoke all devices" endpoint that wasn't
  asked for.
- New `App\Http\Middleware\EnsureSchoolMobileAccessIsAvailable` (alias
  `school.mobile`, applied to `login` only — not `me`/`logout`, so an
  already-authenticated guardian can still check identity or log out during
  maintenance): enforces the maintenance/mobile-enabled/minimum-version
  policy that `docs/API-STANDARD.md` (WP-00-06) already documented but
  nothing enforced until now. Introduces the `X-App-Version` request header
  convention (optional; skips the version check when absent), documented in
  both `docs/api/AUTHENTICATION.md` and `docs/API-STANDARD.md`.
- Known, deliberate gap: any valid `users` credential can obtain a mobile
  token right now — there's no role check restricting this to guardians,
  because roles/policies don't exist until WP-01-05, and WP-02-02 hasn't
  created the guardian profile table yet. Documented in
  `docs/api/AUTHENTICATION.md` "Not Yet Implemented" so it isn't mistaken
  for an oversight.
- Tests: `tests/Feature/Api/V1/Auth/MobileLoginTest.php` (issue token,
  school-id mismatch, wrong password, maintenance/disabled/version
  rejections, rate limit) and `MobileSessionTest.php` (current user,
  unauthenticated rejection, logout revokes, revoked token can't
  re-authenticate) — 12 tests total.
- Verification: `vendor/bin/pint` (clean), `vendor/bin/phpstan analyse`
  (0 errors), full `php artisan test` — 55 passed, 3 pre-existing skips,
  0 failures (confirms no regression in existing Fortify web auth tests).
