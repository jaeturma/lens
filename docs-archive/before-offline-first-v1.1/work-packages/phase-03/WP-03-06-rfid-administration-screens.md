# WP-03-06 — RFID Administration Screens

## Objective

Provide simple school-admin screens for device status, card assignment, and recent scans.

## Affected Layers

- [x] Laravel
- [x] Database
- [ ] API
- [ ] Flutter
- [ ] RFID Device Integration

## Scope

Use the existing Laravel web interface; avoid advanced monitoring dashboards.

## Out of Scope

Unrelated modules and speculative enhancements.

## Dependencies

WP-03-01 through WP-03-05.

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

- Administrators can view devices, cards, and recent scans.
- Inactive and error states are visible.
- Sensitive secrets are not displayed.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes for affected code.
- Changed contracts are documented.
- Final implementation report is provided.

## Implementation Notes
