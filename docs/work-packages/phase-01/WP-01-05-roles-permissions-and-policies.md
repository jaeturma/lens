# WP-01-05 — Roles Permissions and Policies

## Objective

Implement initial permissions and authorization.

## Affected Layers

- [x] Laravel
- [x] Database
- [x] API
- [ ] Flutter
- [ ] Android
- [ ] RFID Integration

## Scope

Add or align role assignment, middleware, policies, seeders, and tests.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

WP-01-04.

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

- Unauthorized administration is blocked.
- Guardian data isolation is enforced.
- Setup instructions exist.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes

- Added `App\Enums\UserRole` (`system_administrator`, `school_administrator`,
  `guardian`) with `isAdministrator()`.
- Added `role` column to `users` (migration
  `2026_07_21_050830_add_role_to_users_table.php`), default `guardian`, cast
  to `UserRole` on the model. `User::isGuardian()` / `isAdministrator()`
  helpers added.
- `App\Policies\UserPolicy` (auto-discovered): a user may only `view`/
  `update` their own account. `Controller` now uses `AuthorizesRequests`;
  `MeController` calls `$this->authorize('view', $user)`.
- `LoginController` rejects non-guardian accounts with `403` before issuing a
  mobile token (mobile login is guardian-only; System/School Administrator
  accounts keep using the unchanged Fortify web login).
- `UserFactory` gained `systemAdministrator()` / `schoolAdministrator()`
  states; `DatabaseSeeder` now seeds the default test user as a system
  administrator.
- Tests: `tests/Feature/Api/V1/Auth/MobileLoginTest.php` (non-guardian
  rejected), `tests/Feature/Policies/UserPolicyTest.php` (self vs. other
  account access). Full suite: 58 passed, 3 skipped (pre-existing,
  feature-gated). Pint and PHPStan (`app/`) both pass.
- `docs/api/AUTHENTICATION.md` updated: removed the "Not Yet Implemented"
  note for guardian-only login and documented the `403` failure case.
- No admin-facing routes exist yet, so `UserPolicy` is currently only
  exercised by `/api/v1/auth/me`; broader admin authorization arrives with
  the work packages that add those endpoints (e.g. WP-02 administration
  screens).
