# WP-06-02 — Attendance Notification Rules

## Objective

Create guardian notifications for arrival, departure, late, absence, and corrections where appropriate.

## Affected Layers

- [x] Laravel
- [x] Database
- [x] API
- [ ] Flutter
- [ ] Android
- [ ] RFID Integration

## Scope

Respect active links and notification preferences and prevent duplicates.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

Phase 4, WP-06-01.

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

- Correct guardians receive one notification.
- Duplicate events do not duplicate notifications.
- Tests cover each type.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes
