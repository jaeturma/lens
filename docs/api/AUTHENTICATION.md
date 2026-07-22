# Authentication API

Defines school-bound parent login, current guardian, logout, token
validation, and inactive-link behavior.

Web administrator authentication (System/School Administrator) is unchanged:
Fortify-backed session login at `/login`, untouched by this contract.

## Login

`POST /api/v1/auth/login`

Unauthenticated, rate-limited (`mobile-login`: 5 requests/minute per
email+IP, mirroring the web login limiter). Gated by the `school.mobile`
middleware: rejected while the school is in maintenance, mobile access is
disabled, or the app is below the school's minimum version (see below)
before credentials are even checked.

Request:

```json
{
  "school_id": "SCH-0001",
  "email": "guardian@example.com",
  "password": "secret"
}
```

`school_id` must match a configured school's public School ID (the one
resolved via `docs/api/SCHOOL-RESOLVER.md`); this is what makes login
school-bound.

### Success — `200`

```json
{
  "success": true,
  "message": "Login successful.",
  "data": {
    "token": "1|abcdef...",
    "user": {
      "id": 1,
      "name": "Guardian Name",
      "email": "guardian@example.com"
    }
  }
}
```

### Failure

- Unknown/mismatched `school_id`: `422`, standard Error envelope, error key
  `school_id`.
- Wrong email/password: `422`, standard Error envelope, error key `email`
  (does not reveal whether the email exists).
- Valid credentials for a non-guardian account (System/School Administrator):
  `403`, standard Error envelope. Only `guardian`-role accounts may obtain a
  mobile token.
- Valid credentials for a guardian whose `Guardian` profile status is
  `inactive`: `403`, standard Error envelope. A guardian-role account with
  no `Guardian` profile yet is unaffected — a profile is not required to log
  in, only one that explicitly says inactive is rejected (see WP-02-02).
- School in maintenance: `503`, `message` is the school's configured
  maintenance message.
- Mobile access disabled for the school: `503`.
- App below minimum version (see `X-App-Version` below): `426`.
- Rate limit exceeded: `429`.

## Current User

`GET /api/v1/auth/me` — requires a valid Sanctum bearer token
(`Authorization: Bearer {token}`). Returns the authenticated user via the
same shape as `login`'s `user` field. `401` if the token is missing,
invalid, already revoked, or (`guardian.active` middleware, WP-08-03)
belongs to a guardian whose `Guardian` profile has since been deactivated
— a token issued before deactivation stops working on its very next
request rather than remaining valid indefinitely. This is deliberately the
same status code as an expired/revoked token: `SessionController.build()`
on the Flutter side (WP-07-07) already treats any `401` from this endpoint
as "session no longer valid, return to login," and a deactivated guardian
is meant to hit that exact path.

The same `guardian.active` check also gates every `sync` and
`notifications` endpoint below (see `docs/api/SYNC.md`) — a deactivated
guardian's token is rejected there too, not only at `/auth/me`.

## Logout

`POST /api/v1/auth/logout` — requires a valid Sanctum bearer token, but
**not** `guardian.active` — a deactivated guardian can still explicitly
revoke their own token. Revokes the token used to make the request (not
other active tokens/devices).

## App Version Header

Authenticated and gated mobile endpoints read `X-App-Version` (the
installed Flutter app version, e.g. `0.1.0`) when present and compare it
against the school's `minimum_app_version`; below it, the request is
rejected `426` before it reaches the controller. The header is optional —
if absent, the version check is skipped rather than blocking the request
(so this stays opt-in per endpoint/client capability). See
`docs/API-STANDARD.md` Maintenance and Version.

## Not Yet Implemented

"Inactive-link behavior" (a guardian's link to a specific student being
deactivated) depends on WP-02-03 (Student Guardian Relationships).
