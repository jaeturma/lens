# WP-03-01 — RFID Device Registry

## Objective

Register and manage network RFID readers.

## Affected Layers

- [x] Laravel
- [x] Database
- [x] API
- [ ] Flutter
- [x] RFID Device Integration

## Scope

Store device code, name, school, location, direction mode, secret, last activity, and active status.

## Out of Scope

Unrelated modules and speculative enhancements.

## Dependencies

Phase 1.

## Database Changes

Document and implement only database changes directly required by this work package.

## Laravel Requirements

Implement only the Laravel work explicitly required by the objective and scope.

## API Contract

Document any mobile or device-facing contract added or changed.

## Flutter Requirements

Implement only when Flutter is marked as an affected layer.

## Permissions and Security

Apply least privilege, validation, authorization, and appropriate rate limits.

## Audit Events

Record sensitive administrative or correction actions when applicable.

## Tests

Add targeted Pest or Flutter tests for changed behavior. Run only relevant tests during implementation.

## Documentation Updates

Update the appropriate core or API document when a contract or convention changes.

## Acceptance Criteria

- Devices can be registered and deactivated.
- Device codes are unique.
- Secrets are not exposed after creation.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes for affected code.
- Changed contracts are documented.
- Final implementation report is provided.

## Implementation Notes
