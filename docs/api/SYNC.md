# Synchronization API

Defines bootstrap, incremental cursor, change types, pagination, tombstones, corrections, and cursor commit behavior.

## Change Feed Foundation (WP-01-07)

The `sync_changes` table is the server-side append-only change feed later
work packages record to and WP-01-08's bootstrap/incremental endpoints read
from. No HTTP endpoint exists yet — see "Not Yet Implemented" below.

### Change Entry

Each row: `resource_type`/`resource_id` (the changed resource), `action`
(one of `created`, `updated`, `deleted`, `revoked`, `expired`, `corrected`),
`payload` (JSON, resource-specific; secret-shaped keys are redacted before
storage), `created_at`. Entries are immutable — there is no `updated_at`.

### Tombstones

A change entry with `action` `deleted`, `revoked`, or `expired` is itself
the tombstone: the row is not deleted when the underlying resource is
removed, since `sync_changes` holds no foreign key to it.

### Cursor

`App\Support\Sync\SyncCursor` wraps the monotonic `sync_changes.id`
sequence as an opaque, base64-encoded string per `docs/OFFLINE-SYNC.md`
("Laravel returns an opaque cursor or monotonic change sequence" — clients
must not decode or interpret it). A cursor of `initial()` (encodes sequence
`0`) starts from the beginning. Malformed cursor strings are rejected.

### Pagination

`App\Actions\Sync\FetchSyncChanges` returns changes after a cursor, capped
to a limit (clamped between 1 and 200 per call), plus the next cursor and
whether more remain (`has_more`). When there are no new changes, the
response is an empty page and the cursor is returned unchanged — the client
does not advance past data it has not actually received.

## Not Yet Implemented

The HTTP bootstrap and incremental sync endpoints, the guardian-scoped
authorization that limits a sync response to a guardian's own linked
students/school data, and the request/response JSON shapes are all deferred
to WP-01-08 (Bootstrap and Incremental Sync APIs), which has not run yet.
