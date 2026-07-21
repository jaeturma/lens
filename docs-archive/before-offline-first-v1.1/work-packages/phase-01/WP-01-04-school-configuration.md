# WP-01-04 — School Configuration

## Objective

Add the single-school profile and basic attendance configuration foundation.

## Affected Layers

- [x] Laravel
- [x] Database
- [ ] API
- [ ] Flutter
- [ ] RFID Device Integration

## Scope

Store school name, code, address, timezone, contact details, active school year, and basic status.

## Out of Scope

Unrelated modules and speculative enhancements.

## Dependencies

WP-01-03.

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

- School settings can be administered.
- Required settings are validated.
- Single-school scope is preserved.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes for affected code.
- Changed contracts are documented.
- Final implementation report is provided.

## Implementation Notes
