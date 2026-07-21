# WP-08-01 — Fresh Install and Binding Tests

## Objective

Validate first install, School ID resolution, lock, restart, logout, app-data clear, uninstall, and reinstall behavior.

## Affected Layers

- [ ] Laravel
- [ ] Database
- [x] API
- [x] Flutter
- [x] Android
- [ ] RFID Integration

## Scope

Include manual device checks where automation is impractical.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

Phase 7.

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

- All binding scenarios are documented and pass.
- Android backup does not restore binding after reinstall.
- No reset option is exposed.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes
