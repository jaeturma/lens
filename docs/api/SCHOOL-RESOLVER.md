# School Resolver API

Defines first-launch School ID validation, immutable school UUID, school
profile, mobile-enabled status, maintenance state, and minimum supported app
version.

## Resolve School

`GET /api/v1/schools/resolve/{publicId}`

Unauthenticated, rate-limited (`school-resolver`: 10 requests/minute per IP).
`publicId` is the guardian-facing "School ID" entered at first launch.

Always returns the school's current profile and mobile status when found —
`mobile_enabled`, `maintenance_mode`, and `minimum_app_version` are reported
as data for the client to act on, not conditions that make the resolver
itself fail. Only a School ID that does not resolve to a configured school
is rejected.

### Success — `200`

```json
{
  "success": true,
  "message": "Request completed.",
  "data": {
    "school_id": "SCH-0001",
    "uuid": "b3f5c2b0-...-...-...-............",
    "name": "Example School",
    "logo_url": null,
    "timezone": "Asia/Manila",
    "mobile_enabled": true,
    "maintenance_mode": false,
    "maintenance_message": null,
    "notifications_enabled": true,
    "minimum_app_version": "0.1.0"
  }
}
```

### Not Found — `404`

Returned when `publicId` does not match a school, or the school has no
`school_settings` record yet (not fully configured). Generic message, no
information leak about which case occurred.

```json
{
  "success": false,
  "message": "School ID not found.",
  "errors": {}
}
```

### Rate Limited — `429`

Standard Laravel throttle response when the per-IP limit is exceeded.

## Client Responsibility

The mobile app is responsible for acting on the returned status fields once
a school resolves: block mobile use when `mobile_enabled` is `false`, show a
maintenance notice using `maintenance_message` when `maintenance_mode` is
`true`, and prompt an upgrade when the installed app version is below
`minimum_app_version`. See `docs/API-STANDARD.md` Maintenance and Version
for how these apply to authenticated endpoints after login.
