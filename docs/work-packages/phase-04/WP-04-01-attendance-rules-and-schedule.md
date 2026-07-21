# WP-04-01 — Attendance Rules and Schedule

## Objective

Configure operating days, arrival cutoff, departure rules, absence cutoff, and duplicate window.

## Affected Layers

- [x] Laravel
- [x] Database
- [ ] API
- [ ] Flutter
- [ ] Android
- [ ] RFID Integration

## Scope

Keep first release limited to arrival, departure, late, and absence.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

WP-01-02.

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

- Rules are configurable.
- Timezone boundaries are tested.
- Holidays or non-operating days have a documented first-release behavior.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes
