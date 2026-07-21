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
