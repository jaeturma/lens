# WP-07-04 — Locked School Binding and Backup Rules

## Objective

Lock the school selection and ensure uninstall resets it.

## Affected Layers

- [ ] Laravel
- [ ] Database
- [ ] API
- [x] Flutter
- [x] Android
- [ ] RFID Integration

## Scope

Remove all app reset routes, preserve binding on logout, and exclude binding, secure state, and SQLite from Android backup/restore.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

WP-07-03.

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

- App restart does not ask again.
- Logout preserves school.
- No in-app change/remove option exists.
- Reinstall begins unbound.
- Android backup rules are tested or manually verified.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes
