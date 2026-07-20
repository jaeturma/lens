# WP-00-01 — Project Baseline

## Objective

Inspect the existing Laravel and Flutter projects and document the current technical baseline without changing application behavior.

## Affected Layers

- [x] Laravel
- [ ] Database
- [ ] API
- [x] Flutter
- [ ] RFID Device Integration

## Scope

Record versions, installed auth, packages, database state, routes, tests, Flutter foundation, package name, and current risks.

## Out of Scope

Unrelated modules and speculative enhancements.

## Dependencies

None.

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

- A concise baseline document exists.
- No application behavior is changed.
- Gaps that affect later phases are listed.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes for affected code.
- Changed contracts are documented.
- Final implementation report is provided.

## Implementation Notes
