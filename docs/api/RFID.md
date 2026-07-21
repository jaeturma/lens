# RFID API

Defines dedicated device authentication, scan ingestion, idempotency, duplicate handling, and concise device responses.

## Device Registry and Credentials (WP-03-01)

No HTTP endpoint exists yet — this documents the `rfid_devices` model and
credential mechanism WP-03-03's scan-ingestion endpoint (and its
authentication middleware) will be built on.

A device does not authenticate the way a guardian does. Guardians get a
Sanctum bearer token after a login request; a device is provisioned once
by an administrator with a fixed `device_code` + secret pair and presents
both on every request thereafter (transport — header vs. Basic Auth — is
decided in WP-03-03, since that's where the actual endpoint exists).

### Registration

`App\Actions\RfidDevices\RegisterRfidDevice(deviceCode, location,
directionMode)` creates the device with a random secret, stores only its
hash (`RfidDevice.secret` has the same `'hashed'` cast as `User.password`,
and is `#[Hidden]` — never present in a serialized model), and returns
the plain secret exactly once, in an `App\Support\RfidDevices\RfidDeviceRegistration`
DTO. There is no way to retrieve it again after this call returns; a
device believed compromised must be revoked and re-registered, not
"looked up."

### Verification

`App\Actions\RfidDevices\VerifyRfidDeviceCredentials(deviceCode, secret)`
returns the `RfidDevice` on success or `null` if the device doesn't exist,
is not `active` (a `revoked` device fails even with the correct secret),
or the secret doesn't match. Successful verification updates
`last_activity_at` — this is the single point where "last activity" is
recorded, so nothing else needs to touch it separately.

### Fields

`device_code` (unique), `location`, `direction_mode`
(`entry`/`exit`/`both` — how the device's raw scans should be interpreted
for attendance direction; the actual interpretation logic is WP-04's
concern), `status` (`active`/`revoked`), `last_activity_at`.

## Card Assignment (WP-03-02)

No HTTP endpoint or admin UI exists yet (WP-03-05) — this documents the
`rfid_cards` model and the three actions that mutate it, since this
package's own acceptance criteria requires their actions to be audited
now, not once a controller exists.

`rfid_cards` is an assignment **history**, not a single mutable row per
student: `uid`, `student_id`, `status` (`active`/`deactivated`/`replaced`).
A student's card history can have many rows; at most one row for a given
`uid` may be `active` at a time, enforced by a database-level unique index
on a stored generated column (`active_uid`, `NULL` unless `status =
'active'`) — this is what `docs/DATABASE.md`'s Rules mean by "unique
indexes protect ... active RFID UID." A plain unique index on `uid` itself
would be wrong: the same physical card's `uid` legitimately appears in
multiple historical (non-active) rows over time.

- `App\Actions\RfidCards\AssignRfidCard(Student, uid, ?actor)` — creates a
  new `active` row. Rejects with `App\Exceptions\RfidCards\RfidUidAlreadyActiveException`
  if the `uid` is already actively assigned to anyone (checked proactively,
  and also caught from the underlying `QueryException` if a race loses to
  the DB constraint). Records `rfid_card.assigned`.
- `App\Actions\RfidCards\DeactivateRfidCard(RfidCard, ?actor)` — marks a
  card `deactivated` (lost/disabled, no replacement issued). Records
  `rfid_card.deactivated`.
- `App\Actions\RfidCards\ReplaceRfidCard(currentCard, newUid, ?actor)` —
  one transaction: marks `currentCard` `replaced` and creates a new
  `active` row with `newUid` for the same student. Always a new row, never
  reactivating the old one — a physical replacement card has its own
  `uid`. Records `rfid_card.replaced` against the new card, with the old
  card's ID/`uid` in the metadata. Same duplicate-`uid` rejection as
  `AssignRfidCard`.

`actor` is an explicit nullable parameter on all three, not read from
`auth()` internally — keeps the actions usable outside an HTTP request
context and testable without faking authentication state. WP-03-05's
future admin controller will pass `$request->user()`.

## Not Yet Implemented

The scan-ingestion endpoint, its authentication middleware (which will
call `VerifyRfidDeviceCredentials`), request/response shapes, rate
limiting, and idempotency are all WP-03-03/03-04, not yet built. No admin
UI creates/deactivates/replaces cards yet (WP-03-05).
