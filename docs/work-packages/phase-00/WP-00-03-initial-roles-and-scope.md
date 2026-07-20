# WP-00-03 — Initial Roles and Scope

## Objective

Define the initial users and permissions without implementing future roles.

## Affected Layers

- [x] Laravel
- [x] Database
- [ ] API
- [ ] Flutter
- [ ] RFID Device Integration

## Scope

Define System Administrator, School Administrator, Parent or Guardian, and RFID Device access boundaries.

## Out of Scope

Unrelated modules and speculative enhancements.

## Dependencies

WP-00-01.

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

- Roles and responsibilities are documented.
- Out-of-scope roles are explicitly excluded.
- Permission matrix is ready for Phase 1.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes for affected code.
- Changed contracts are documented.
- Final implementation report is provided.

## Implementation Notes
