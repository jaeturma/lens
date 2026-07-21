# WP-04-06 — Attendance Reports and Parent API

## Objective

Expose simple attendance history for parents and basic reports for administrators.

## Affected Layers

- [x] Laravel
- [ ] Database
- [x] API
- [x] Flutter
- [ ] RFID Device Integration

## Scope

Implement child attendance status and history endpoints plus simple admin filters or export only if already supported.

## Out of Scope

Unrelated modules and speculative enhancements.

## Dependencies

WP-02-06, WP-04-05.

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

- Guardians access only linked children.
- History is paginated.
- API tests pass.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes for affected code.
- Changed contracts are documented.
- Final implementation report is provided.

## Implementation Notes
