# WP-08-03 — Deletion Revocation and Correction Tests

## Objective

Validate deleted announcements, revoked guardian links, deactivated accounts, corrected attendance, and invalidated notifications.

## Affected Layers

- [x] Laravel
- [x] Database
- [x] API
- [x] Flutter
- [ ] Android
- [ ] RFID Integration

## Scope

Verify each server change reaches SQLite correctly.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

WP-07-08.

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

- Every change type is reflected locally.
- Revoked data is no longer accessible.
- Corrections preserve raw RFID data.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes
