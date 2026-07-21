# WP-00-06 — API and Time Conventions

## Objective

Finalize response, pagination, school context, timezone, device time, sync, maintenance, and version conventions.

## Affected Layers

- [x] Laravel
- [ ] Database
- [x] API
- [x] Flutter
- [ ] Android
- [x] RFID Integration

## Scope

Align all consumers around one documented contract.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

WP-00-03 through WP-00-05.

## Laravel Requirements

Implement only the server-side work directly required by this package.

## API Contract

Document every new or changed mobile/device contract.

## Flutter and SQLite Requirements

When affected, screens must read SQLite and repositories must synchronize server changes into SQLite.

## Permissions and Security

Apply least privilege, validation, authorization, rate limiting, and secure secret handling.

## Tests

Run targeted Pest, Flutter, SQLite migration, or integration tests appropriate to the changed layer.

## Documentation Updates

Update the relevant core or API document.

## Acceptance Criteria

- API conventions are implementable.
- Asia/Manila handling is documented.
- Device and guardian authentication are separated.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes

- Documentation-only work package: no `routes/api.php`, controllers, or
  Resources exist yet (Phase 01), so there is no code, migration, or test to
  add here.
- `docs/API-STANDARD.md` already carried the prefix, required school context,
  success/error envelopes, and synchronization response shape
  (pre-existing, uncommitted at the start of this task). Added three new
  sections to close the remaining gaps against this package's scope and
  acceptance criteria: Pagination (concrete non-sync list shape vs. the
  existing cursor-based sync shape), Time Conventions (UTC storage,
  `Asia/Manila` default school timezone, device-time handling for RFID
  scans), and Maintenance and Version (concrete `503`/`426` response
  shapes).
- Strengthened the existing device-vs-guardian-authentication Rules bullets
  with one explicit line: the two credential types are never interchangeable.
- Cross-referenced `docs/OFFLINE-SYNC.md` (client timestamps never trusted
  for ordering) and `docs/api/SCHOOL-RESOLVER.md` (school-level timezone
  field) rather than duplicating their content.
