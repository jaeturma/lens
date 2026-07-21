# WP-00-04 — School Binding Architecture

## Objective

Define the one-time School ID setup and immutable installation binding.

## Affected Layers

- [x] Laravel
- [ ] Database
- [x] API
- [x] Flutter
- [x] Android
- [ ] RFID Integration

## Scope

Define School ID resolution, immutable school UUID, local persistence, logout behavior, uninstall reset, and no in-app reset.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

WP-00-01, WP-00-02.

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

- First launch requires School ID.
- Successful binding is never requested again.
- Logout preserves binding.
- Uninstall/reinstall resets binding.
- Multi-school switching is excluded.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes

- Documentation-only work package: no School Resolver API or Flutter binding
  code exists yet (those are WP-01-03 and WP-07-03/WP-07-04 respectively), so
  there is no code, migration, or test to add here.
- `docs/ARCHITECTURE.md` already carried a "First Launch" flow and "Binding
  Rules" section (pre-existing, uncommitted at the start of this task)
  covering most of this package's acceptance criteria. Added two explicit
  bullets to close the remaining gaps: binding is never re-requested after a
  successful first launch, and multi-school switching is explicitly called
  out as unsupported (cross-referencing `docs/PROJECT-SCOPE.md` Excluded
  rather than duplicating it).
- Note: `docs/ARCHITECTURE.md` also contains "Runtime Data Flow", "RFID
  Flow", and "Push Flow" sections that belong to WP-00-05 (Offline First and
  Sync Architecture) and later RFID/notification phases, not this package.
  They were already present in the working tree before this task and were
  left untouched. Since they live in the same file as the binding content,
  committing this file now will include that not-yet-actioned material —
  flagged here rather than split, since splitting one architecture doc
  across per-WP commits isn't practical.
