# WP-06-04 — Mobile Device Token Registration

## Objective

Register and revoke Firebase device tokens for authenticated guardians.

## Affected Layers

- [x] Laravel
- [x] Database
- [x] API
- [x] Flutter
- [ ] RFID Device Integration

## Scope

Support multiple devices per guardian and token refresh.

## Out of Scope

Unrelated modules and speculative enhancements.

## Dependencies

WP-01-02, WP-06-01.

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

- Tokens are linked to the authenticated guardian.
- Duplicate tokens are handled safely.
- Logout can revoke or deactivate the current token.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes for affected code.
- Changed contracts are documented.
- Final implementation report is provided.

## Implementation Notes
