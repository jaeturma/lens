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

## Not Yet Implemented

The scan-ingestion endpoint, its authentication middleware (which will
call `VerifyRfidDeviceCredentials`), request/response shapes, rate
limiting, and idempotency are all WP-03-03/03-04, not yet built.
