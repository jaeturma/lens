# WP-02-03 — Student Guardian Relationships

## Objective

Support multiple guardians per student and multiple students per guardian.

## Affected Layers

- [x] Laravel
- [x] Database
- [x] API
- [ ] Flutter
- [ ] RFID Device Integration

## Scope

Create relationship storage with relationship type, primary contact flag, access status, and notification status.

## Out of Scope

Unrelated modules and speculative enhancements.

## Dependencies

WP-02-01, WP-02-02.

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

- Many-to-many links work.
- Duplicate active links are prevented.
- Guardian access is limited to linked students.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes for affected code.
- Changed contracts are documented.
- Final implementation report is provided.

## Implementation Notes
