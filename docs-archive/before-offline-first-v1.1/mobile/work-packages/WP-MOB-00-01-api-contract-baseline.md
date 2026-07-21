# WP-MOB-00-01 — Mobile API Contract Baseline

## Objective

Confirm and document the Laravel API conventions required by the LENS Flutter client.

## Scope

- Confirm `/api/v1` route prefix.
- Confirm Laravel Sanctum token authentication.
- Define login, current-user and logout endpoints.
- Define success, validation and authentication error response shapes.
- Confirm development CORS behavior.
- Add focused Pest tests only where baseline behavior is missing.
- Create or update `docs/mobile/API-CONTRACT.md`.

## Out of Scope

- Flutter screens
- Social login
- Password recovery
- Parent-student account linking
- Push notifications
- Role-specific dashboards

## Acceptance Criteria

- The mobile authentication endpoints and JSON contracts are documented.
- Validation errors use one consistent response shape.
- Unauthorized access returns HTTP 401 without exposing sensitive details.
- Targeted API tests pass.
- No unrelated Laravel modules are changed.
