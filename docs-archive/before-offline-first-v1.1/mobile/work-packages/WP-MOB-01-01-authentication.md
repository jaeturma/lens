# WP-MOB-01-01 — Flutter Authentication

## Objective

Implement a bounded mobile authentication flow using the approved Laravel API contract.

## Dependencies

- WP-MOB-00-01 completed
- `docs/mobile/API-CONTRACT.md` available

## Scope

- Login page
- Login request and response model
- Authentication API service
- Authentication repository
- Riverpod authentication controller
- Secure access-token storage
- Session restoration
- Logout
- Router redirect for authenticated and unauthenticated states
- Loading, validation and error states
- Focused tests

## Out of Scope

- Registration
- Password reset
- Biometrics
- Multiple profiles
- Parent-student linking
- Push notifications

## Acceptance Criteria

- A valid account can log in through the Laravel API.
- Invalid credentials show a safe user-facing error.
- The access token is stored only in secure storage.
- A valid session is restored when the app restarts.
- Logout clears local authentication state and calls the server endpoint.
- `dart format`, `flutter analyze` and focused tests pass.
- Laravel files are not modified unless the work package explicitly documents a contract defect.
