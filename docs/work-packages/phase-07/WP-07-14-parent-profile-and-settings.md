# WP-07-14 — Parent Profile and Settings

## Objective

Build local-first profile, notification preference display, last-sync information, and logout.

## Affected Layers

- [ ] Laravel
- [ ] Database
- [x] API
- [x] Flutter
- [ ] Android
- [ ] RFID Integration

## Scope

Do not add school switching or unsupported profile editing.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

WP-07-07 through WP-07-13.

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

- Profile is accurate from SQLite.
- Logout is available.
- School binding cannot be edited.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes

Flutter only — no Laravel/API changes (every value shown already syncs
locally via WP-07-06/07-08/07-13; nothing new is read from or written to
the server).

- New `features/profile/`: `guardianProfileProvider` (reactive off
  `guardian_profile`) plus reuse of the existing `schoolBindingProvider`
  (`school_binding_gate.dart`) and `syncStateProvider` for the school and
  last-sync halves. `ProfilePage` shows guardian name/email/mobile,
  school name/School ID, notification preferences as **disabled**
  `Switch`es (`onChanged: null` — display-only, not editable), the same
  `SyncStatusBanner` used elsewhere, and its own Log Out button.
- `HomePage` gained a Profile app-bar action (`Icons.person_outline`,
  tooltip `Profile`) opening `/profile` (new route in `app_router.dart`).
- Fixed a real navigation bug caught by the widget test, not just a test
  artifact: `ProfilePage` is reached via `context.push` (a sibling route
  on top of `/`, unlike `HomePage`'s own Log Out button which lives *on*
  `/`). Logging out from a pushed screen left it mounted while
  `clearGuardianOwnedData()` deleted its own data out from under it,
  spinning on the loading state forever (`pumpAndSettle` timed out at 10
  minutes). Fixed by calling `context.go(AppRoutes.foundation)` after
  `logout()` completes, unwinding the stack back to `SchoolBindingGate`'s
  already-correct "no session" branch.
- No school-switching or profile-editing control was added anywhere on
  this screen, per this package's own Scope line — verified by a
  dedicated test asserting no "Change School"/"Reset School" text exists.

Verified: `flutter analyze` clean; full mobile suite passing, 116/116
(`flutter test --concurrency=1`), including new
`test/features/profile/` tests (profile content, disabled preference
switches, no school-edit control, and the full logout-from-profile flow)
and the `HomePage`/router test additions for the new action and route.

No migrations, no new API contracts, no unresolved risks.
