# WP-07-07 — Session Restoration and Logout

## Objective

Restore valid sessions and clear only parent-specific data on logout.

## Affected Layers

- [ ] Laravel
- [ ] Database
- [x] API
- [x] Flutter
- [ ] Android
- [ ] RFID Integration

## Scope

Logout must preserve school binding and school profile while clearing token and guardian-owned synchronized data as defined.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

WP-07-06.

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

- Session restores when valid.
- Expired token returns to login.
- Logout preserves School ID.
- Local data clearing behavior is tested.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes
