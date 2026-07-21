# WP-01-02 — Authentication Foundation

## Objective

Prepare Laravel authentication for school administrators and parent mobile users.

## Affected Layers

- [x] Laravel
- [x] Database
- [x] API
- [ ] Flutter
- [ ] RFID Device Integration

## Scope

Reuse existing starter-kit authentication, add Sanctum mobile authentication where missing, and document login, current user, and logout.

## Out of Scope

Unrelated modules and speculative enhancements.

## Dependencies

WP-01-01.

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

- Admin web login remains functional.
- Parent API login contract is defined.
- Sanctum token creation and revocation are tested.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes for affected code.
- Changed contracts are documented.
- Final implementation report is provided.

## Implementation Notes
