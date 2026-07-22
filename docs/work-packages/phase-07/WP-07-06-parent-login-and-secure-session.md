# WP-07-06 — Parent Login and Secure Session

## Objective

Implement school-bound parent login.

## Affected Layers

- [ ] Laravel
- [ ] Database
- [x] API
- [x] Flutter
- [ ] Android
- [ ] RFID Integration

## Scope

Add validation, secure token storage, local guardian persistence, error states, and authenticated routing.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

WP-01-04, WP-07-05.

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

- Valid guardian logs in.
- Invalid or wrong-school account is rejected.
- Token is stored securely.
- Guardian profile is stored locally.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes

New feature `mobile/lib/features/auth/`:

- `data/auth_api.dart` — `POST /auth/login` (WP-01-04). Takes the
  already locally-bound `school_id` (`school_profile.publicId`) rather
  than re-collecting one — there is no School ID field on the login form.
- `application/session_controller.dart` — `AsyncNotifier<bool>` reading
  whether an access token is stored; `markAuthenticated()` flips it
  immediately post-login. Deliberately naive: it does not re-validate an
  existing token against the server, or clear it on logout — both are
  WP-07-07's job (Session Restoration and Logout), which this only lays
  the seam for.
- `application/login_controller.dart` — orchestrates the full flow: call
  `AuthApi.login`, store the token (`TokenStorage`, WP-07-01), then run
  `BootstrapRepository.sync()` (see below) so the guardian's own profile
  is cached before the gate ever shows authenticated content, then marks
  the session authenticated. A failed login (`ApiException`, already
  carrying a safe server message per `docs/api/AUTHENTICATION.md`) returns
  to `LoginIdle` with that message; nothing is stored or marked on failure.
- `presentation/login_page.dart` — email/password form (school already
  resolved, shown as context in the title); client-side validation mirrors
  `docs/api/AUTHENTICATION.md`'s server-side error keys (`email`) without
  duplicating server logic.

**"Guardian profile is stored locally"**: the login response itself
carries no `Guardian` data (only `user.{id,name,email}`, per
`docs/api/AUTHENTICATION.md`) — that comes from the same
`GET /sync/bootstrap` call WP-07-05 already uses for the school profile.
Extended `BootstrapApi`/`BootstrapRepository` (WP-07-05) to also parse and
cache the response's `guardian` field (new `ResolvedGuardian` model,
`school_bootstrap/data/`), renaming `syncSchoolProfile()` to `sync()`
since it now does both. `guardian` is nullable in the response (an
account can be guardian-role without a `Guardian` profile yet, per
WP-02-02/04/05) — when absent, nothing is written to `guardian_profile`,
it is not treated as an error.

**"Authenticated routing"**: `SchoolBindingGate` gained a third layer,
`_AuthenticationGate`, sitting after the binding and school-status checks
(WP-07-03/05): watches `sessionControllerProvider` and shows `LoginPage`
until authenticated, `FoundationPage` after. An unreadable session
(`AsyncError`) fails safe to `LoginPage`, not to assuming a stale session
is still good; the initial loading state gets its own branch so an
already-logged-in guardian never sees a login-screen flash while the
one-time secure-storage read resolves.

**Tests**: `session_controller_test.dart` (reflects token presence;
`markAuthenticated` flips it); `login_controller_test.dart` (success
stores token + caches both profiles + marks the session; failure leaves
`LoginIdle` with the message and touches neither); `login_flow_test.dart`
(login screen shown when unauthenticated; empty-password validation;
full submit → cached guardian → gate swaps to the authenticated screen).
`bootstrap_repository_test.dart` (WP-07-05) extended for the `guardian`
field, present and absent. `school_binding_gate_test.dart` and
`school_id_setup_page_test.dart` (WP-07-03/05) updated to override
`sessionControllerProvider` with a fake — real `SessionController.build()`
hits `flutter_secure_storage`'s platform channel, which has no test-time
mock, so those tests would otherwise hit the new login-screen branch by
accident rather than what they actually test. Added
`FakeAuthenticatedSession`/`FakeUnauthenticatedSession` to the shared test
harness for this.

Verification: `flutter analyze` clean, `dart format` applied, `flutter
test` — 36/36 passing.
