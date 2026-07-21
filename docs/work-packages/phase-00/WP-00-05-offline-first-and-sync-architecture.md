# WP-00-05 — Offline First and Sync Architecture

## Objective

Finalize SQLite-first repositories and incremental synchronization.

## Affected Layers

- [x] Laravel
- [x] Database
- [x] API
- [x] Flutter
- [ ] Android
- [ ] RFID Integration

## Scope

Define bootstrap, cursor sync, tombstones, corrections, local transactions, retry, and offline behavior.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

WP-00-04.

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

- Screens read SQLite.
- Cursor is saved only after local commit.
- Delete/revoke/expire/correct changes are supported.
- Timestamp-only sync is rejected.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes

- Documentation-only work package: no sync API, repositories, or Drift
  SQLite schema exist yet (Drift is not yet installed per the WP-00-01
  baseline; the concrete sync endpoints are WP-01-07/WP-01-08 and the
  Flutter sync engine is WP-07-08), so there is no code, migration, or test
  to add here.
- `docs/OFFLINE-SYNC.md` already carried the bootstrap, cursor rules, change
  types, sync triggers, and offline-behavior sections (pre-existing,
  uncommitted at the start of this task) covering most of this package's
  acceptance criteria. Added one explicit Cursor Rules bullet: a sync
  request with only a client timestamp and no valid cursor is rejected.
- "Screens read SQLite" is already covered by `docs/ARCHITECTURE.md`'s
  Runtime Data Flow section (committed under WP-00-04): reactive SQLite
  query -> Flutter UI, screens do not use network responses as their primary
  view model. Not duplicated here.
- `docs/api/SYNC.md` is a one-line placeholder for the concrete Synchronization
  API contract, owned by WP-01-08 (Bootstrap and Incremental Sync APIs), not
  this architecture-level package — left untouched.
