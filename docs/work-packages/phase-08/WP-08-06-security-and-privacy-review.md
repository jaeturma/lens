# WP-08-06 — Security and Privacy Review

## Objective

Review school binding, authorization, local storage, API exposure, secrets, rate limits, and privacy requirements.

## Affected Layers

- [x] Laravel
- [x] Database
- [x] API
- [x] Flutter
- [x] Android
- [ ] RFID Integration

## Scope

Fix confirmed defects only.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

Phases 1 through 7.

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

- Guardian isolation is proven.
- Device/user auth separation is proven.
- Backup exclusions and local data protection are verified.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes
