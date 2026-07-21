# WP-06-02 — Attendance Notification Rules

## Objective

Create guardian notifications for arrival, departure, late, and absence.

## Affected Layers

- [x] Laravel
- [x] Database
- [x] API
- [ ] Flutter
- [ ] RFID Device Integration

## Scope

Respect active student-guardian links and guardian notification preferences.

## Out of Scope

Unrelated modules and speculative enhancements.

## Dependencies

Phase 4, WP-06-01.

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

- Correct guardians receive notifications.
- Duplicate attendance events do not duplicate notifications.
- Tests cover all initial types.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes for affected code.
- Changed contracts are documented.
- Final implementation report is provided.

## Implementation Notes
