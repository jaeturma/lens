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
- School in maintenance: `503`, `message` is the school's configured
  maintenance message.
- Mobile access disabled for the school: `503`.
- App below minimum version (see `X-App-Version` below): `426`.
- Rate limit exceeded: `429`.

## Current User

`GET /api/v1/auth/me` — requires a valid Sanctum bearer token
(`Authorization: Bearer {token}`). Returns the authenticated user via the
same shape as `login`'s `user` field. `401` if the token is missing,
invalid, or already revoked.

## Logout

`POST /api/v1/auth/logout` — requires a valid Sanctum bearer token. Revokes
the token used to make the request (not other active tokens/devices).

## App Version Header

Authenticated and gated mobile endpoints read `X-App-Version` (the
installed Flutter app version, e.g. `0.1.0`) when present and compare it
against the school's `minimum_app_version`; below it, the request is
rejected `426` before it reaches the controller. The header is optional —
if absent, the version check is skipped rather than blocking the request
(so this stays opt-in per endpoint/client capability). See
`docs/API-STANDARD.md` Maintenance and Version.

## Not Yet Implemented

Guardian-specific restrictions (only guardian-role accounts may obtain a
mobile token, not any `users` row) are deferred to WP-01-05 (Roles
Permissions and Policies) and WP-02-02 (Guardian Data Model), which have not
run yet. Currently any valid `users` credential can authenticate via this
endpoint once role/policy infrastructure exists, this will be restricted.
"Inactive-link behavior" (a guardian's link to a specific student being
deactivated) depends on WP-02-03 (Student Guardian Relationships).
