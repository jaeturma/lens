# WP-07-03 — First Launch School ID Setup

## Objective

Build the School ID screen and resolver integration.

## Affected Layers

- [ ] Laravel
- [ ] Database
- [x] API
- [x] Flutter
- [x] Android
- [ ] RFID Integration

## Scope

Validate the School ID, display the resolved school, require confirmation, and persist the binding locally.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

WP-01-03, WP-07-02.

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

- First launch asks for School ID.
- Invalid ID shows a safe error.
- Valid school is confirmed and stored.
- No login is shown before binding.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes

New feature `mobile/lib/features/school_setup/`:

- `data/school_resolver_api.dart` + `resolved_school.dart` — calls the
  existing `GET /schools/resolve/{publicId}` (WP-01-03), reusing the
  project's existing `dioProvider`/`ApiException` conventions. No Laravel
  changes; that endpoint already existed.
- `application/school_id_setup_controller.dart` (+ `_state.dart`) — a plain
  `Notifier` (no codegen, matching this project's existing Riverpod usage)
  driving `Idle -> Resolving -> Resolved -> Confirming`. `confirm()` upserts
  the resolved school into the `school_profile` Drift table from WP-07-02
  and does not transition to any further local "bound" state itself.
- `presentation/school_id_setup_page.dart` — the form, then a confirmation
  card (name, School ID, a non-blocking maintenance notice if
  `maintenance_mode` is true — informational only, matching the resolver's
  own design of never using these flags to reject a request).
- `presentation/school_binding_gate.dart` — replaces `FoundationPage` as
  the router's actual builder for `/`. Watches `school_profile` reactively
  (`docs/ARCHITECTURE.md` Runtime Data Flow): renders
  `SchoolIdSetupPage` while no row exists, otherwise the (still
  placeholder) foundation page. This is what satisfies "No login is shown
  before binding" — there is no login screen yet (WP-07-06), so the gate is
  what stands in for that check today, and will keep working unchanged once
  WP-07-06/07-07 add a real one behind it.
- **Binding signal**: a row existing in `school_profile` *is* the binding —
  no separate "is bound" flag was added to `app_settings`. Locking the
  binding against re-entry/reset and the Android backup exclusion rules are
  WP-07-04's scope, not this package's; nothing here prevents a future
  screen from writing to `school_profile` again.

Two Drift/flutter_test issues hit during verification, unrelated to this
package's own logic but blocking every widget test that touches the
database:

- A test helper file was initially named `dispose_app_under_test.dart` —
  `flutter test` treats any `*_test.dart` file under `test/` as a test
  file in its own right and failed it for having no `main()`. Renamed to
  `test/support/app_test_harness.dart`.
- `ProviderScope` disposal cancels the school-binding gate's drift stream
  subscription, which drift itself schedules onto a zero-duration `Timer`
  (`StreamQueryStore.markAsClosed`) rather than cancelling synchronously.
  Left to flutter_test's own implicit end-of-test teardown, that timer is
  still pending when the framework's `!timersPending` leak check runs,
  failing every test that reaches the gate. Fixed by having each such test
  explicitly swap in an empty widget and `pumpAndSettle()` before returning
  (`disposeAppUnderTest` in the harness above), forcing disposal — and the
  chance to flush the timer it schedules — while the test still controls
  pumping.

Tests: `school_id_setup_controller_test.dart` (resolve success/failure,
confirm persists, editAgain persists nothing) against fakes overriding
`schoolResolverApiProvider`/`appDatabaseProvider` — no real network or
platform channel involved. `school_id_setup_page_test.dart` (empty-ID
validation error; full resolve → confirm → gate swaps to the bound screen).
`app_smoke_test.dart` updated: an unbound install's actual first screen is
now `SchoolIdSetupPage`, not the old static foundation page — the previous
assertion was superseded by this package's own "First launch asks for
School ID" acceptance criterion.

Verification: `flutter analyze` clean, `dart format` applied, `flutter
test` — 13/13 passing.
