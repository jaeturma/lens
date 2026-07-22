# Notifications API

Defines notification inbox, unread count, read state, device token registration, and push delivery logging.

## Device Token Registration (WP-06-04)

`POST /api/v1/notifications/device-tokens` and
`DELETE /api/v1/notifications/device-tokens` — the first real
mobile-facing endpoints in this document. Guardian-authenticated
(`auth:sanctum`), gated by `school.mobile` (maintenance mode,
mobile-disabled, minimum app version — same as login/bootstrap) and the
`device-tokens` rate limiter (30/minute per user). Full contract —
request bodies, register/refresh/duplicate-claiming semantics, and why
logout doesn't auto-revoke — documented in `docs/NOTIFICATIONS.md`'s
"Mobile Device Token Registration" section.

```json
// POST .../device-tokens
{ "token": "<firebase-registration-token>", "previous_token": null }

// DELETE .../device-tokens
{ "token": "<firebase-registration-token>" }
```

Both return the standard `{ "success": true, "message": "...", "data": [] }`
envelope — no response body data beyond the confirmation message.

## Mark Notification Read (WP-07-12)

`PATCH /api/v1/notifications/{uuid}/read` — marks one guardian's own
notification as read. Same middleware stack as device token registration
(`auth:sanctum`, `school.mobile`, `device-tokens` rate limiter — reused
rather than adding a new limiter for a single low-volume action).

- `{uuid}` is the notification's `uuid` column, constrained to a UUID
  shape in the route (`[0-9a-fA-F-]{36}`).
- Looked up scoped to the authenticated guardian
  (`where('guardian_id', $user->guardian->id)`); a notification belonging
  to another guardian, or an unknown UUID, both return a generic `404`
  (no ownership leakage).
- A non-guardian account (no `guardian` relation) gets `403`.
- Idempotent: if `read_at` is already set, the record is left untouched
  (no-op) rather than re-writing it, so repeat calls (e.g. a retried
  offline mutation) don't generate redundant `sync_changes` rows.
- No request body; no response data beyond the standard success envelope.

```json
// PATCH .../notifications/{uuid}/read
// (no body)

// 200
{ "success": true, "message": "Notification marked as read.", "data": [] }
```

Setting `read_at` flows through the existing
`App\Observers\GuardianNotificationObserver`, which records a generic
`updated` `sync_changes` entry for any field change on
`GuardianNotification`. No new sync action/enum value or client-side sync
logic was needed — the change reaches other devices via the same
incremental `GET /api/v1/sync/changes` feed already used for everything
else, scoped by the `guardian_notification` branch in
`App\Actions\Sync\ScopeChangesToGuardian`.

## Status

- WP-06-01 built the notification model
  (`App\Models\GuardianNotification`, table `guardian_notifications` —
  deliberately not `notifications`, see `docs/NOTIFICATIONS.md` for why).
- WP-06-02/06-03 create notifications for attendance events and
  published announcements, respectively — no HTTP surface of their own.
- WP-06-04 added device token registration (above).
- `App\Actions\Sync\ScopeChangesToGuardian` now has a `guardian_notification`
  branch, so a guardian's own notifications sync down via
  `GET /api/v1/sync/changes` like every other resource.
- WP-07-12 (above) adds the read-state endpoint. Inbox listing and
  unread-count are derived client-side from the synced rows — there is no
  separate "list notifications" or "unread count" endpoint by design (the
  same local-first pattern as attendance/announcements).
