# WP-02-06 — Parent Mobile Student API

## Objective

Expose the current guardian profile and linked children through the mobile API.

## Affected Layers

- [x] Laravel
- [ ] Database
- [x] API
- [x] Flutter
- [ ] RFID Device Integration

## Scope

Implement `/me` and linked-children contracts. Flutter work in this package is limited to models and repository preparation if requested separately.

## Out of Scope

Unrelated modules and speculative enhancements.

## Dependencies

WP-02-03, WP-01-02.

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

- Guardian receives only linked children.
- Inactive links are excluded.
- API Resource and authorization tests pass.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes for affected code.
- Changed contracts are documented.
- Final implementation report is provided.

## Implementation Notes
