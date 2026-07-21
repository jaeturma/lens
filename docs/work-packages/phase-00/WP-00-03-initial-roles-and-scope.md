# WP-00-03 — Initial Roles and Scope

## Objective

Define System Administrator, School Administrator, Parent/Guardian, and RFID Device boundaries.

## Affected Layers

- [x] Laravel
- [x] Database
- [x] API
- [ ] Flutter
- [ ] Android
- [ ] RFID Integration

## Scope

Create a simple permission matrix and explicitly exclude future roles.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

WP-00-01.

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

- Initial roles are clear.
- Parent access is limited to linked children.
- RFID devices are not user accounts.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes

- Documentation-only work package: no roles/permissions infrastructure exists
  yet (Phase 01 — no `routes/api.php`, no Sanctum installed, no `roles` table
  per the WP-00-01 baseline), so there is no code, migration, or test to add
  here. This package defines the conceptual boundary ahead of WP-01-05
  (Roles Permissions and Policies), which implements the actual
  policies/gates/migrations.
- Added a "Roles and Permission Matrix" section to `docs/SECURITY.md`
  covering System Administrator, School Administrator, Parent/Guardian, and
  RFID Device, consistent with the one-installation-one-school constraint in
  `docs/ARCHITECTURE.md` and the RFID-device-credential rule already stated
  in `docs/SECURITY.md`.
- Excluded/future roles (Teacher, Student login) are called out explicitly,
  cross-referencing the existing `docs/PROJECT-SCOPE.md` Excluded list rather
  than duplicating it.
