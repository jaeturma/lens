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

- Baseline documented in `docs/PROJECT-BASELINE.md` (Laravel 13.20.0 / PHP
  8.3.16; Fortify web auth installed, Sanctum not yet installed; no
  `/api/v1` routes yet; only default Laravel migrations present; Flutter
  3.44.6 with Riverpod/GoRouter/Dio/secure-storage foundation already
  scaffolded under `mobile/lib`; Android package name still the placeholder
  `com.example.mobile`).
- No application code, config, dependencies, or database schema were
  changed — read-only inspection only.
- Gaps flagged for later phases: missing Sanctum/API routes/LENS tables
  (expected, tracked by Phases 01-06 and WP-00-02 for package name);
  duplicate/legacy work-package docs found outside the canonical
  `docs/work-packages/phase-XX/` tree (`docs/work-packages/WP-00-01...md`,
  `WP-00-02-architecture-alignment.md`, `WP-01-01-mobile-authentication.md`,
  `docs/mobile/work-packages/WP-MOB-00-01...md`, `WP-MOB-01-01...md`); and
  leftover installer/backup directories at the repo root
  (`lens-flutter-foundation/`, `_foundation_backup_20260719-202508/`). None
  were modified or removed — see `docs/PROJECT-BASELINE.md` for details.
