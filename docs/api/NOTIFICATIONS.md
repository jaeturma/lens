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

## Status

- WP-06-01 built the notification model only
  (`App\Models\GuardianNotification`, table `guardian_notifications` —
  deliberately not `notifications`, see `docs/NOTIFICATIONS.md` for why).
- WP-06-02/06-03 create notifications for attendance events and
  published announcements, respectively — no HTTP surface of their own.
- WP-06-04 (above) is the only real endpoint so far.
- No guardian can see a `guardian_notification` entry over sync yet
  (`App\Actions\Sync\ScopeChangesToGuardian` has no branch for it) — that
  and inbox/unread-count/read-state and push delivery itself are
  WP-06-05/06-06's job.
