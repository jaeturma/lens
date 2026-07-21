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

`resource_type` is a short, stable alias from `Relation::morphMap()`
(`App\Providers\AppServiceProvider`), e.g. `student`, not the PHP class
name — the contract does not change if a model is renamed or moved.

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
        "resource_type": "student",
        "resource_id": 42,
        "action": "created",
        "payload": {
          "uuid": "...",
          "lrn": "123456789012",
          "student_number": "SN-0001",
          "name": "Juan Dela Cruz",
          "sex": "male",
          "grade": "Grade 7",
          "section": "Diamond",
          "school_year": "2026-2027",
          "status": "active",
          "photo_url": null
        },
        "created_at": "2026-07-21T02:15:00Z"
      }
    ]
  }
}
```

When there are no new changes, `changes` is empty and `next_cursor` is
unchanged from the request's `cursor` (see "Pagination" above).

## Synchronized Resources

### `student` (WP-02-01)

`App\Observers\StudentObserver` records a `sync_changes` entry
(`created`/`updated`/`deleted`) on every `App\Models\Student` mutation, with
a full-snapshot `payload` (shown above) rather than a partial diff — the
mobile client can always upsert its local SQLite row wholesale from the
latest entry for a given `resource_id`. No admin UI (WP-02-04) or
guardian-facing endpoint (WP-02-06) exists yet to create students through;
this is the data model and its sync participation only.

### `guardian` (WP-02-02)

Same pattern via `App\Observers\GuardianObserver`. Payload:

```json
{
  "uuid": "...",
  "name": "Maria Dela Cruz",
  "email": "maria@example.com",
  "mobile_number": "09171234567",
  "status": "active",
  "notify_attendance": true,
  "notify_announcements": true
}
```

`email`/`name` here are the guardian's own contact fields on the `guardians`
table, distinct from `User.email` (the login credential returned by
`bootstrap`'s `user` field) — see WP-02-02 Implementation Notes for why
these are not the same column. No admin UI (WP-02-05) creates a `Guardian`
profile yet; today the only place `status` has an effect is
`docs/api/AUTHENTICATION.md`'s login rejection for an inactive profile.

### `guardian_student_link` (WP-02-03)

Via `App\Observers\GuardianStudentLinkObserver`. Payload:

```json
{
  "uuid": "...",
  "student_id": 42,
  "guardian_id": 7,
  "relationship_type": "mother",
  "is_primary_contact": true,
  "status": "active",
  "notifications_enabled": true
}
```

`status` transitioning to `revoked` records a `sync_changes` entry with
`action` `revoked` (not `updated`) — the client can special-case this to
remove local access immediately rather than waiting to notice a field
diff. A `(student_id, guardian_id)` pair has at most one row, ever;
re-linking after a revocation updates that row back to `active` rather than
inserting a new one, so a `created` entry for a given `resource_id` is
always the first and only creation for that pair. No admin UI (WP-02-05)
creates links yet, and no guardian-facing endpoint (WP-02-06) reads them —
`Guardian::activeLinks()`/`Student::activeLinks()` exist for that endpoint
to use.

## Not Yet Implemented

Guardian-scoped resource authorization — limiting `changes` to a specific
guardian's own linked students/school data — is deferred to the phase 2+
work packages that add those resource types and call `RecordSyncChange`;
there is nothing to scope yet. Today the only authorization is "the
authenticated account holds the guardian role," which is already the case
for every account able to obtain a mobile token (see
`docs/api/AUTHENTICATION.md`).
