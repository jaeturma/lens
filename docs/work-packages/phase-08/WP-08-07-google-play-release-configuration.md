# WP-08-07 — Google Play Release Configuration

## Objective

Prepare application ID, signing, AAB, versions, icons, screenshots, privacy policy references, and Data Safety inputs.

## Affected Layers

- [ ] Laravel
- [ ] Database
- [ ] API
- [x] Flutter
- [x] Android
- [ ] RFID Integration

## Scope

Document release and environment commands without committing secrets.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

WP-08-01, WP-08-06.

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

- Release AAB builds.
- Versioning is correct.
- Privacy and account/data deletion requirements are documented.
- Store listing checklist exists.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes
