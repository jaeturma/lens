# WP-01-07 — Synchronization Change Feed

## Objective

Create the server-side incremental sync foundation: a durable, append-only
change feed and the recording/reading primitives WP-01-08's bootstrap and
incremental sync endpoints, and later domain work packages (attendance,
announcements, notifications, guardian links), build on. This package does
not add an HTTP endpoint — that is WP-01-08 — and does not yet have any
domain resource to record changes for (students, announcements, etc. do not
exist until phase 2+); it only builds the reusable mechanism.

## Affected Layers

- [x] Laravel
- [x] Database
- [x] API
- [ ] Flutter
- [ ] Android
- [ ] RFID Integration

## Scope

- `sync_changes` table: polymorphic `resource` (`resource_type`/
  `resource_id`, via `morphs()`), `action` (`created`/`updated`/`deleted`/
  `revoked`/`expired`/`corrected`), nullable `payload` (JSON), `created_at`
  only (append-only, no `updated_at`). The auto-increment `id` is the
  monotonic sequence; a change row with `action = deleted|revoked|expired`
  is itself the tombstone (the row persists even after the underlying
  resource is gone, since there is no foreign key to it).
- `App\Support\Sync\SyncCursor`: opaque cursor wrapping a sequence number
  (base64-encoded string on the wire, per `docs/OFFLINE-SYNC.md` "Laravel
  returns an opaque cursor"), with an `initial()` starting point and a
  `fromString()` parser that rejects malformed input.
- `App\Actions\Sync\RecordSyncChange`: the call site future work packages
  use to append a change entry for a resource mutation.
- `App\Actions\Sync\FetchSyncChanges`: given a cursor and a limit, returns a
  chunked page (capped) of changes after that cursor, the next cursor, and
  whether more remain. An empty result leaves the cursor unchanged
  (deterministic — no drift when nothing changed).

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

WP-01-01, WP-01-02.

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

- Create/update/delete/revoke/expire/correct changes are representable.
- Cursors are opaque, deterministic, and reject malformed input.
- Secret-shaped payload keys are redacted before storage.
- Tests cover pagination (chunking + `has_more`) and no-change responses.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes

- `sync_changes` migration (`2026_07_21_070000_create_sync_changes_table.php`):
  `morphs('resource')` (`resource_type`/`resource_id`, auto-indexed, no FK —
  deliberate, so a tombstone row survives the resource's own deletion),
  `action` (string, cast to `App\Enums\SyncChangeAction`), nullable JSON
  `payload`, `created_at` only (`useCurrent()`, indexed) with
  `const UPDATED_AT = null` on the model — same append-only shape as
  `audit_logs` (WP-01-06).
- `App\Enums\SyncChangeAction`: `Created`/`Updated`/`Deleted`/`Revoked`/
  `Expired`/`Corrected` — the exact six verbs named in this WP's acceptance
  criteria; nothing speculative added.
- `App\Support\Sync\SyncCursor`: immutable value object over the
  `sync_changes.id` monotonic sequence. `encode()`/`fromString()` use plain
  base64 — opaque to the client, not a security boundary (nothing secret is
  encoded, it only stops clients from treating the cursor as a timestamp or
  doing arithmetic on it, per `docs/OFFLINE-SYNC.md`). `fromString()` and
  the constructor reject negative/non-numeric/malformed input via
  `InvalidArgumentException`, for WP-01-08 to translate into a `422` at the
  request boundary.
- `App\Actions\Sync\RecordSyncChange`: `(resource, action, payload)` →
  `SyncChange`. `App\Actions\Sync\FetchSyncChanges`: `(cursor, limit)` →
  `App\Support\Sync\SyncChangePage` (`changes`, `nextCursor`, `hasMore`).
  Limit is clamped to `[1, 200]` (chunking). An empty result leaves
  `nextCursor` equal to the input cursor unchanged, so repeated polling with
  no new data cannot drift the client's position.
- Extracted the secret-redaction logic `RecordAuditLog` (WP-01-06)
  introduced into `App\Support\RedactsSensitiveMetadata`, now used by both
  `RecordAuditLog` and `RecordSyncChange` rather than duplicating it — no
  behavior change to WP-01-06, confirmed by its existing tests still
  passing unmodified.
- No call sites were added — no domain resource (student, announcement,
  attendance event, etc.) exists yet to record changes for. Downstream work
  packages call `RecordSyncChange` at their own mutation points, and
  WP-01-08 calls `FetchSyncChanges` from the incremental sync endpoint.
- `docs/api/SYNC.md` documents the change entry shape, tombstone design,
  cursor opacity, and pagination/chunking behavior, and explicitly defers
  the HTTP endpoints and guardian-scoped authorization to WP-01-08.
- Tests: `tests/Unit/Support/Sync/SyncCursorTest.php` (encode/decode
  round-trip, opacity, malformed/negative rejection — pure value object, no
  DB needed), `tests/Feature/Actions/Sync/RecordSyncChangeTest.php`
  (records resource/action/payload, tombstone survives resource deletion,
  redaction), `tests/Feature/Actions/Sync/FetchSyncChangesTest.php`
  (ordered chunked pagination with `has_more`, deterministic no-change
  response, non-positive limit clamped) — 13 new tests.
- Verification: `vendor/bin/pint` (clean), `vendor/bin/phpstan analyse app`
  (0 errors), full `php artisan test` — 75 passed, 3 pre-existing skips, 0
  failures (no regression, including WP-01-06's audit log tests after the
  redaction-trait extraction).
