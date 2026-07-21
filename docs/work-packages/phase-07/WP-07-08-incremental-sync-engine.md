# WP-07-08 — Incremental Sync Engine

## Objective

Implement cursor-based sync into one SQLite transaction.

## Affected Layers

- [ ] Laravel
- [ ] Database
- [x] API
- [x] Flutter
- [ ] Android
- [ ] RFID Integration

## Scope

Support startup, resume, pull-to-refresh, push signal, pagination, retries, tombstones, corrections, and cursor commit safety.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

WP-01-08, WP-07-02, WP-07-07.

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

- Cursor advances only after commit.
- Failed sync keeps previous cursor.
- All change types apply locally.
- Tests cover interruption and retry.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes
