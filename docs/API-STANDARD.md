# API Standard

## Prefix

`/api/v1`

## Required Context

Mobile requests after school resolution carry the immutable school UUID through the documented request body, route, header, or authenticated context.

## Success

```json
{
  "success": true,
  "message": "Request completed.",
  "data": {}
}
```

## Error

```json
{
  "success": false,
  "message": "Validation failed.",
  "errors": {}
}
```

## Synchronization Response

```json
{
  "success": true,
  "data": {
    "next_cursor": "opaque-value",
    "has_more": false,
    "changes": []
  }
}
```

## Pagination

Non-sync list endpoints use Laravel's standard paginator shape inside `data`:

```json
{
  "success": true,
  "data": [],
  "meta": {
    "current_page": 1,
    "per_page": 20,
    "total": 0
  }
}
```

Sync endpoints use the cursor-based Synchronization Response above instead;
they are never page-numbered.

## Time Conventions

- Laravel stores and returns timestamps in UTC, ISO 8601 (e.g.
  `2026-07-21T02:15:00Z`).
- Each school profile carries an IANA timezone, `Asia/Manila` by default (see
  `docs/api/SCHOOL-RESOLVER.md`). Flutter renders wall-clock times in the
  school's timezone, not device-local time.
- Attendance-day boundaries (arrival, late, absence cutoffs) are computed in
  the school's configured timezone, never in UTC or raw device time.
- An RFID device timestamp is accepted as an informational field on the raw
  scan record only. Laravel's own receipt time is authoritative for
  processing; client-only timestamps are never trusted for ordering (see
  `docs/OFFLINE-SYNC.md` Cursor Rules).

## Maintenance and Version

- A school in maintenance mode returns `503` with the standard Error
  envelope; `message` describes the maintenance state.
- A mobile app below the school's minimum supported version returns `426`
  (Upgrade Required) with the standard Error envelope.
- The mobile app reports its installed version via the `X-App-Version`
  header on gated endpoints (see `docs/api/AUTHENTICATION.md`). The header
  is optional per endpoint; when absent, the version check is skipped
  rather than blocking the request.

## Reference Implementation

`GET /api/v1/health` is the reference implementation of this standard:
versioned routing, the Success envelope, and an `App\Http\Resources\V1`
Resource wrapped by `App\Http\Responses\ApiResponse`. New endpoints follow
the same pattern. It requires no authentication and returns:

```json
{
  "success": true,
  "message": "Request completed.",
  "data": {
    "status": "ok",
    "app": "LENS",
    "version": "v1"
  }
}
```

## Rules

- correct HTTP status codes;
- Laravel API Resources;
- consistent pagination;
- dedicated RFID device authentication;
- school-bound guardian authentication;
- device and guardian credentials are separate types and are never
  interchangeable;
- minimum supported app version and maintenance responses;
- no production stack traces;
- changed contracts must update `docs/api/`.
