# Synchronization API

Defines bootstrap, incremental cursor, change types, pagination, tombstones, corrections, and cursor commit behavior.

## Change Feed Foundation (WP-01-07)

The `sync_changes` table is the server-side append-only change feed later
work packages record to and the endpoints below read from.

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

## Bootstrap (WP-01-08)

`GET /api/v1/sync/bootstrap` — requires a valid Sanctum bearer token for a
guardian account (`403` for any other role). Gated by the `school.mobile`
middleware (maintenance/mobile-disabled/version, same as login — see
`docs/api/AUTHENTICATION.md`) and the `sync` rate limiter (30
requests/minute per user). Returns the school profile, the authenticated
user, and `next_cursor` — the change-feed position as of the bootstrap
call, so the first incremental sync request does not re-fetch data the
bootstrap already returned.

```json
{
  "success": true,
  "message": "Request completed.",
  "data": {
    "school": {
      "school_id": "SCH-0001",
      "uuid": "...",
      "name": "Example School",
      "logo_url": null,
      "timezone": "Asia/Manila",
      "mobile_enabled": true,
      "maintenance_mode": false,
      "maintenance_message": null,
      "notifications_enabled": true,
      "minimum_app_version": "0.1.0"
    },
    "user": {
      "id": 1,
      "name": "Guardian Name",
      "email": "guardian@example.com"
    },
    "next_cursor": "MA=="
  }
}
```

## Incremental Sync (WP-01-08)

`GET /api/v1/sync/changes` — same authentication, gating, and rate limit as
bootstrap.

Query parameters:

- `cursor` (required) — an opaque cursor string, from `bootstrap`'s
  `next_cursor` or a previous call's `next_cursor`. Missing or malformed:
  `422`. There is no timestamp-based fallback (see `docs/OFFLINE-SYNC.md`
  Cursor Rules).
- `limit` (optional) — results per call, `1`-`200`, default `100`.

```json
{
  "success": true,
  "message": "Request completed.",
  "data": {
    "next_cursor": "Mg==",
    "has_more": false,
    "changes": [
      {
        "resource_type": "announcement",
        "resource_id": 42,
        "action": "created",
        "payload": {},
        "created_at": "2026-07-21T02:15:00Z"
      }
    ]
  }
}
```

When there are no new changes, `changes` is empty and `next_cursor` is
unchanged from the request's `cursor` (see "Pagination" above).

## Not Yet Implemented

Guardian-scoped resource authorization — limiting `changes` to a specific
guardian's own linked students/school data — is deferred to the phase 2+
work packages that add those resource types and call `RecordSyncChange`;
there is nothing to scope yet. Today the only authorization is "the
authenticated account holds the guardian role," which is already the case
for every account able to obtain a mobile token (see
`docs/api/AUTHENTICATION.md`).
