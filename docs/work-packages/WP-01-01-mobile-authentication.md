# WP-01-01 — Mobile Authentication Baseline

## Status

Blocked by WP-00-02

## Objective

Allow an authorized LENS user to sign in to the Flutter Android application through the Laravel 13 API and securely restore or end the session.

## Scope

- Laravel login, authenticated-user, and logout endpoints
- Request validation and rate limiting
- Sanctum token issuance and revocation
- Flutter login screen
- Secure token storage
- Authenticated session restoration
- Logout

## Out of Scope

- Social login
- Biometric login
- Password recovery
- Multi-factor authentication
- Role-specific dashboards

## Database Changes

Use existing users and Sanctum tables. Add a migration only if the baseline review proves one is required.

## Backend Requirements

- `POST /api/v1/auth/login`
- `GET /api/v1/me`
- `POST /api/v1/auth/logout`
- Safe invalid-credential response
- Protected endpoints require valid authentication

## Flutter Requirements

- Login form with validation
- Loading and error states
- Secure token persistence
- Restore a valid session when the app starts
- Clear local token after logout or confirmed unauthorized response

## Permissions

Only active, authorized accounts may authenticate.

## Tests

- Successful login
- Invalid credentials
- Missing fields
- Inactive or unauthorized account when applicable
- Authenticated profile request
- Logout revokes current token

## Acceptance Criteria

- [ ] A valid user can sign in
- [ ] Invalid credentials return a safe error
- [ ] Protected profile data requires authentication
- [ ] The app restores a valid session
- [ ] Logout clears local and server-side session credentials
- [ ] Relevant backend tests and Flutter analysis pass

## Definition of Done

- [ ] Scope is implemented without unrelated modules
- [ ] API contract is documented
- [ ] Focused tests pass
- [ ] Required setup commands are documented

## Implementation Notes

Pending.

## Verification Notes

Pending.
