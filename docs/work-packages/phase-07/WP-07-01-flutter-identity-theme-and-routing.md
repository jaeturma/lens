# WP-07-01 — Flutter Identity Theme and Routing

## Objective

Finalize permanent Android identity, theme, startup routes, and navigation shell.

## Affected Layers

- [ ] Laravel
- [ ] Database
- [ ] API
- [x] Flutter
- [x] Android
- [ ] RFID Integration

## Scope

Create routes for school setup, login, home, attendance, announcements, notifications, and profile.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

WP-00-02, existing Flutter foundation.

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

- Permanent application ID is set.
- Startup routing can distinguish unbound, bound-logged-out, and authenticated states.
- Analysis passes.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes
