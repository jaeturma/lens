# WP-03-05 — Duplicate and Invalid Scan Handling

## Objective

Identify duplicate, unknown-card, inactive-card, and invalid-device events without losing raw data.

## Affected Layers

- [x] Laravel
- [x] Database
- [x] API
- [ ] Flutter
- [ ] RFID Device Integration

## Scope

Add idempotency or duplicate-window logic and consistent processing statuses.

## Out of Scope

Unrelated modules and speculative enhancements.

## Dependencies

WP-03-03, WP-03-04.

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

- Duplicate scans do not create duplicate attendance events.
- Unknown cards remain traceable.
- Raw scans are preserved.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes for affected code.
- Changed contracts are documented.
- Final implementation report is provided.

## Implementation Notes
