# WP-05-03 — Announcement Audiences

## Objective

Target all guardians, grade, section, or selected student guardians.

## Affected Layers

- [x] Laravel
- [x] Database
- [x] API
- [ ] Flutter
- [ ] Android
- [ ] RFID Integration

## Scope

Resolve audiences without campaign-level complexity.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

WP-05-01, Phase 2.

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

- Each audience type is tested.
- Guardians see only matching announcements.
- Revoked links stop future access.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes
