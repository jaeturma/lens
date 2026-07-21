# WP-04-03 — Arrival Departure and Late Detection

## Objective

Apply deterministic entry, exit, bidirectional, and late rules.

## Affected Layers

- [x] Laravel
- [x] Database
- [ ] API
- [ ] Flutter
- [ ] Android
- [ ] RFID Integration

## Scope

Avoid guess-heavy behavior and document edge cases.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

WP-04-02.

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

- First valid entry creates arrival.
- Valid exit creates departure.
- Late follows configured cutoff.
- Duplicate scans are not misclassified.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes
