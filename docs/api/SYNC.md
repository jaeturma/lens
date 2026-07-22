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
user, the guardian's own profile and actively linked children (WP-02-06),
and `next_cursor` — the change-feed position as of the bootstrap call, so
the first incremental sync request does not re-fetch data the bootstrap
already returned.

`guardian` is `null` and `children` is `[]` when the account has no
`Guardian` profile yet (a guardian-role login does not require one — see
WP-02-02/04/05). `children` only ever contains **actively** linked
students, per `Guardian::activeLinks()` (WP-02-03/06) — a revoked link's
student never appears here, even if it appeared in a previous bootstrap.

Each child also carries `today_attendance` (WP-04-06) — that student's
`AttendanceDailySummary` for the **current date in the school's configured
timezone**, or `null` if none exists yet today. This is deliberately a
narrow "current state" snapshot, not a history dump: full attendance
history (including days before today) reaches the client entirely through
incremental sync (below), by walking `/sync/changes` from
`cursor=initial()` if the client wants to backfill it — no separate
paginated history endpoint exists or is needed, since the change feed is
already paginated.

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
    "guardian": {
      "uuid": "...",
      "name": "Maria Dela Cruz",
      "email": "maria@example.com",
      "mobile_number": "09171234567",
      "status": "active",
      "notify_attendance": true,
      "notify_announcements": true
    },
    "children": [
      {
        "uuid": "...",
        "lrn": "123456789012",
        "student_number": "SN-0001",
        "name": "Juan Dela Cruz",
        "sex": "male",
        "grade": "Grade 7",
        "section": "Diamond",
        "school_year": "2026-2027",
        "status": "active",
        "photo_url": null,
        "relationship_type": "mother",
        "is_primary_contact": true,
        "today_attendance": {
          "arrival": "2026-07-22T00:05:00Z",
          "departure": null,
          "is_late": false,
          "is_absent": false
        }
      }
    ],
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

### Guardian-Scoped Authorization (WP-02-06)

`App\Actions\Sync\ScopeChangesToGuardian` filters the page `FetchSyncChanges`
returns before it is serialized:

- `school` entries: visible to every guardian (install-wide, not owned by
  any one guardian).
- `student` entries: visible only if the student is in the guardian's
  **currently active** linked set. Once a link is revoked, that student's
  entries (past and future) stop appearing.
- `guardian` entries: visible only for the guardian's own record.
- `guardian_student_link` entries: visible for links the guardian **owns,
  regardless of current status** — deliberately not filtered by active
  status, because the revoked-link entry is exactly what tells the client
  to remove a student locally.
- `attendance_daily_summary` entries (WP-04-06): visible only if the
  student is in the guardian's **currently active** linked set, same rule
  as `student` — but since the summary's own `resource_id` is the
  summary's row, not the student's, this branch checks the `student_id`
  carried in the entry's `payload` instead of `resource_id`.
- Any other `resource_type` is denied by default. A future work package
  that introduces a new synchronized resource (announcements,
  notifications) must add a branch to this action, or its entries are
  silently invisible to guardians rather than leaked.

This filtering happens **after** pagination, not inside it — `limit`
still bounds how many raw rows `FetchSyncChanges` reads, so a returned
`changes` array can be shorter than `limit` (even empty) while `has_more`
is `true`, if everything in that raw page belonged to other guardians.
`next_cursor` always reflects the true underlying feed position, so
polling again with it converges on the guardian's real backlog — clients
should keep calling with the returned `next_cursor` while `has_more` is
`true`, not assume a full-length `changes` array.

## Synchronized Resources

### `student` (WP-02-01)

`App\Observers\StudentObserver` records a `sync_changes` entry
(`created`/`updated`/`deleted`) on every `App\Models\Student` mutation, with
a full-snapshot `payload` (shown above) rather than a partial diff — the
mobile client can always upsert its local SQLite row wholesale from the
latest entry for a given `resource_id`. Created/edited via the admin web
UI (WP-02-04); exposed to guardians (scoped to active links) via
bootstrap's `children` and incremental sync (WP-02-06).

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
these are not the same column. Created via the admin web UI (WP-02-05).
`status` affects both login (`docs/api/AUTHENTICATION.md`'s rejection for
an inactive profile) and sync (an inactive guardian can still hold a valid
token until it's revoked, but their own `guardian`-type entries are scoped
to their own record either way — inactive status does not currently hide
a guardian's own profile from themselves over sync).

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
always the first and only creation for that pair. Created/revoked via the
admin web UI (WP-02-05); a guardian only ever sees their own links over
sync (see "Guardian-Scoped Authorization" above).

### `attendance_daily_summary` (WP-04-06)

Via `App\Observers\AttendanceDailySummaryObserver` (WP-04-02), which fires
on every `App\Models\AttendanceDailySummary` create/update — including
arrivals/departures (WP-04-02/03), automatic absence marking (WP-04-04),
and administrator corrections (WP-04-05). Payload:

```json
{
  "student_id": 42,
  "date": "2026-07-22",
  "arrival": "2026-07-22T00:05:00Z",
  "departure": null,
  "is_late": false,
  "is_absent": false
}
```

- **Stable ID**: `resource_id` (the summary's own database id) — a summary
  is created once per `(student_id, date)` and only ever *updated*
  thereafter (WP-04-02/03/04/05 all update the existing row rather than
  creating a new one for the same day), so `resource_id` never changes and
  is never reused for a different day. No separate `uuid` column exists or
  is needed for this resource.
- **Corrections** (WP-04-05) record `action` `corrected`, not `updated` —
  `App\Models\AttendanceDailySummary::$wasCorrected` is a transient,
  non-persisted flag `App\Actions\Attendance\CorrectAttendanceDailySummary`
  sets immediately before its `update()` call, and the observer resets it
  right after reading it so it can't leak into a later, unrelated save of
  the same in-memory instance. Every other write path (arrival/departure
  recording, absence marking) leaves it `false`, recording `updated`.
- **Deletion behavior**: never deleted. Nothing in the codebase removes an
  `AttendanceDailySummary` row — corrections update fields in place (see
  WP-04-05), they don't delete and recreate. No `deleted` tombstone action
  will ever be recorded for this resource type.
- **Guardian scoping**: see "Guardian-Scoped Authorization" above —
  scoped by the payload's `student_id`, not `resource_id`.
- **Bootstrap**: each active child's *current* (today, school timezone)
  summary is embedded directly in `children[].today_attendance` (see
  Bootstrap above) — not delivered via a change-feed replay, since a
  guardian's very first bootstrap has no prior cursor position to have
  missed it from.
- **History / pagination**: "if history is separately queried" (the
  original scope language) does not apply — there is no separate
  attendance-history endpoint. A client wanting attendance before today
  gets it by walking `/sync/changes` from `cursor=initial()`, reusing
  `FetchSyncChanges`'s existing cursor/limit pagination rather than adding
  a second, resource-specific pagination mechanism.

## Not Yet Implemented

No synchronized resource exists yet for announcements or notifications
(phase 5-6). Their eventual `resource_type`s must be added to
`App\Actions\Sync\ScopeChangesToGuardian`'s `match` when they land, or
their entries will be silently invisible to guardians (denied by default).
