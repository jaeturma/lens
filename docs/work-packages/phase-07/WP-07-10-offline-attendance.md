# WP-07-10 — Offline Attendance

## Objective

Build child attendance status and history from SQLite.

## Affected Layers

- [ ] Laravel
- [ ] Database
- [ ] API
- [x] Flutter
- [ ] Android
- [ ] RFID Integration

## Scope

Use reactive local queries and display corrections and sync freshness.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

WP-04-06, WP-07-09.

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

- Attendance works offline after sync.
- Corrected records update locally.
- Loading, empty, stale, and error states exist.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes
