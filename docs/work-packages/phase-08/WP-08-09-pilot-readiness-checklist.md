# WP-08-09 — Pilot Readiness Checklist

## Objective

Produce final go/no-go checklist for one participating school.

## Affected Layers

- [x] Laravel
- [ ] Database
- [x] API
- [x] Flutter
- [x] Android
- [x] RFID Integration

## Scope

Cover school setup, accounts, cards, devices, attendance rules, sync, privacy, support, backup, and limitations.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

WP-08-01 through WP-08-08.

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

- Checklist is complete.
- Known limitations are explicit.
- Go/no-go criteria are clear.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes
