# WP-05-04 — Parent Announcement API

## Objective

Expose paginated active announcements to authenticated guardians.

## Affected Layers

- [x] Laravel
- [ ] Database
- [x] API
- [x] Flutter
- [ ] RFID Device Integration

## Scope

Document list and detail contracts and optional read state if included.

## Out of Scope

Unrelated modules and speculative enhancements.

## Dependencies

WP-05-03, WP-02-06.

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

- Only active targeted announcements are returned.
- Pagination works.
- Authorization tests pass.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes for affected code.
- Changed contracts are documented.
- Final implementation report is provided.

## Implementation Notes
