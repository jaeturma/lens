# Notifications

## Data Model (WP-06-01)

`guardian_notifications` (`App\Models\GuardianNotification`) is the
authoritative, in-app record of a notification — independent of whether a
push signal for it was ever delivered (per this package's own Objective:
"store authoritative in-app notifications independently of push
delivery"). Fields: `uuid` (stable sync ID, same immutable-once-set
pattern as every other synced resource), `guardian_id` (FK to `guardians`,
`cascadeOnDelete` — every notification has exactly one recipient),
`type` (`App\Enums\NotificationType`), `title`, `body`, `payload`
(nullable JSON, resource-specific context — e.g. which
`AttendanceDailySummary`/`Announcement` this is about), `read_at`
(nullable timestamp — read state), `delivery_status`
(`App\Enums\NotificationDeliveryStatus`: `Pending`, `Sent`, `Failed` —
defaults to `Pending` on creation).

### Table Naming: Not `notifications`

`App\Models\User` already uses Laravel's `Notifiable` trait (present from
the starter kit, not currently used to send anything). That trait
defaults to a table literally named `notifications` for its own
database-channel notifications. Naming this table `guardian_notifications`
instead avoids a silent schema collision if that trait's database channel
is ever used later for something unrelated (e.g. a framework-level
admin-facing notice) — two completely different concepts would otherwise
fight over one table name.

### Type Vocabulary

`NotificationType` is defined with the full set two *later* work packages
need, not just what this one creates (this package creates none — see
below): `Arrival`, `Departure`, `Late`, `Absence`, `Correction` (all
WP-06-02, attendance) and `AnnouncementPublished` (WP-06-03). Same
"define the field now, a later package populates it" precedent WP-04-01
set for `AttendanceRule`.

This package (WP-06-01) itself creates no notifications — it builds the
model and sync-feed participation only.
`Guardian.notify_attendance`/`notify_announcements` (WP-02-02, already
existing boolean preferences) are exactly what WP-06-02/06-03 read before
creating one.

### Sync Feed

`App\Observers\GuardianNotificationObserver` (`#[ObservedBy]`, morph map
alias `guardian_notification`) fires on every create/update — including a
future read-state toggle or delivery-status change, both just recorded as
the generic `Updated` action; nothing in this package's own scope calls
for a more specific tombstone-style action the way withdrawing an
announcement does. **No guardian can see any of this yet** —
`App\Actions\Sync\ScopeChangesToGuardian` has no `guardian_notification`
branch, so every entry is currently denied by default (unknown resource
type) — same deferred-visibility gap every other resource in this app
went through before its own dedicated sync-contract package landed
(WP-04-02→WP-04-06, WP-05-01→WP-05-04). That wiring is WP-06-06's job
("Notification Sync and Delivery Logging").

## Attendance Notification Rules (WP-06-02)

`App\Actions\Notifications\NotifyGuardiansOfAttendanceEvent` creates one
`GuardianNotification` per currently active, `notify_attendance`-enabled
guardian of a summary's student, for five of the six `NotificationType`
cases (`Arrival`, `Late`, `Departure`, `Absence`, `Correction` —
`AnnouncementPublished` is rejected, that's WP-06-03's own action).
Nothing calls this action directly from `ProcessRfidScan`/
`MarkDailyAbsences`/`CorrectAttendanceDailySummary` — it's triggered
entirely from `App\Observers\AttendanceDailySummaryObserver`, which
already has full visibility into exactly what changed on every
create/update (via `wasChanged()`/`getOriginal()`, the same mechanism
already used to distinguish `SyncChangeAction::Corrected` from
`Updated`):

- **Arrival vs. Late**: decided by the linked `AttendanceEvent.is_late`
  (WP-04-03), only when `arrival_event_id` transitions from `null` to
  set — the "first entry of the day" rule (WP-04-03) already guarantees
  this only happens once per day, so a repeat entry-device tap never
  re-notifies.
- **Departure**: fires every time `departure_event_id` changes to a new
  value, including repeatedly on the same day — a student who leaves and
  returns produces a new, real departure notification each time (not
  treated as a "duplicate"; each represents a genuinely new tap).
- **Absence**: fires only when `is_absent` transitions `false` → `true`
  outside a correction — covers both `MarkDailyAbsences` (WP-04-04) and a
  brand-new summary created already absent. Re-running the scheduled
  sweep never re-notifies, since it only ever updates a student not
  already marked absent (WP-04-04's own duplicate-prevention).
- **Correction**: takes over entirely when
  `AttendanceDailySummary::$wasCorrected` (WP-04-06) is set — never also
  classified as Arrival/Departure/Absence, and only fires when
  `is_absent`/`arrival_event_id`/`departure_event_id` actually changed,
  so a no-op correction (the same value re-applied) stays silent —
  "corrections where appropriate." The notification body is deliberately
  generic and does **not** repeat the administrator's audit-log reason
  text (`App\Actions\Audit\RecordAuditLog`'s `metadata.reason`) — that's
  internal context (may reference other students, device faults, etc.),
  not necessarily meant for guardian-facing display.
- **Recipients**: every `Guardian` with a currently **active**
  `GuardianStudentLink` to the student and `notify_attendance = true` —
  a revoked link or an opted-out guardian receives nothing. Each
  qualifying guardian gets their own notification row (a student with two
  guardians produces two rows, one per guardian) — "one notification"
  means "exactly one per qualifying guardian," not one shared row.
- **Duplicate prevention has no logic of its own** in this action — it
  relies entirely on the fact that every one of its three callers (via
  the observer) already only reaches it at a genuine, one-time state
  transition. This is why the trigger point is the daily-summary
  observer, not the raw `AttendanceEvent` creation: a repeat entry-device
  tap creates its own `AttendanceEvent` row for audit purposes (WP-04-03)
  without ever updating the summary, so it never reaches this action at
  all.

## Announcement Notifications (WP-06-03)

`App\Actions\Notifications\NotifyGuardiansOfAnnouncement` creates one
`GuardianNotification` (`NotificationType::AnnouncementPublished`) per
currently active, `notify_announcements`-enabled guardian whose audience
matches (`App\Actions\Announcements\ResolveAnnouncementAudience`,
WP-05-03) — **deduplicated per guardian**, not per matching child: a
guardian with two students who both match still gets exactly one
notification, since the announcement's content doesn't vary by which
child it matched through. Title/body mirror the announcement's own
`title`/`body` directly rather than inventing separate copy. Triggered
from `App\Observers\AnnouncementObserver`, same "the observer already
knows exactly what changed" pattern WP-06-02 used for attendance.

### Publish and Republish Behavior (this package's own scope item)

- **Publish**: notifies exactly once, at the `Draft` → `Published`
  transition (`updated()`'s existing `$leftDraft` check, already computed
  for the `Created` sync action) — or immediately on `created()` for the
  admin-UI-unreachable case of an announcement created directly as
  `Published`. A `Draft` never notifies, whether just created or edited
  while still a draft (WP-05-01's observer already returns early for any
  `Draft`-status create/update).
- **Republish, decided as: not supported.** Editing an already-`Published`
  announcement — title, body, or audience — **never sends additional
  notifications**, in either direction: a widened audience does not
  backfill a notification to newly-matching guardians, and a narrowed one
  does not retract anything already sent. `PublishAnnouncement` itself
  already rejects a second publish attempt on a non-`Draft` announcement
  (`InvalidAnnouncementTransitionException`, WP-05-01), so there is no
  code path that could re-run the notification round even by accident. An
  administrator who wants to reach a different or wider audience
  withdraws and creates a **new** announcement — the same "a withdrawn
  announcement isn't resurrected, a new one is created" precedent
  WP-05-01 already set for the `Withdrawn`/`Expired` terminal states
  themselves, extended here to cover audience changes too.
- Withdrawing and (both scheduled and manual) expiring never notify —
  only the publish transition does.

## Mobile Device Token Registration (WP-06-04)

`device_tokens` (`App\Models\DeviceToken`): `guardian_id` (FK,
`cascadeOnDelete`), `token` (the Firebase registration token itself,
**unique**, hidden from serialization — `#[Hidden(['token'])]`, same
caution `RfidDevice.secret` gets, even though a push token isn't a login
credential), `status` (`App\Enums\DeviceTokenStatus`: `Active`,
`Revoked`, `Deactivated` — only the first two are ever set by this
package; `Deactivated` is WP-06-06's, for invalid-token detection during
push delivery), `revoked_at` (nullable timestamp). No `school_id` column
— see the migration's own note: this installation is bound to exactly
one school already (`docs/SECURITY.md`), so every token registered
through it is implicitly school-bound; the `school.mobile` middleware on
both routes below (same gate login/sync/bootstrap use — maintenance
mode, mobile-disabled, minimum app version) is what actually *enforces*
that binding, not a redundant column.

### Endpoints

Both under `/api/v1/notifications/device-tokens`, guardian-authenticated
(`auth:sanctum` + `school.mobile`), rate-limited (`device-tokens`, 30
requests/minute per user, same shape as `sync`'s limiter):

- `POST` — register or refresh. Body: `token` (required), `previous_token`
  (optional — see Refresh below). Rejects a non-guardian account (`403`)
  or a guardian-role account with no `Guardian` profile yet (`403`, same
  backward-compatible case bootstrap already handles).
- `DELETE` — revoke. Body: `token` (required). Only ever revokes a token
  the **authenticated guardian owns**; a token belonging to a different
  guardian (or that doesn't exist) returns `404` rather than leaking
  whose it is or letting one guardian revoke another's.

### Register, Refresh, and Duplicate Handling

`App\Actions\Notifications\RegisterDeviceToken` handles all three as one
action:

- **Register** (no `previous_token`): if `token` has no existing row,
  creates one, `Active`, owned by the calling guardian.
- **Duplicate tokens are handled by claiming, not erroring.** `token` is
  globally unique, so a raw second `INSERT` for an already-registered
  value would violate the constraint. Instead, if a row for that exact
  `token` already exists — under this guardian (a redundant re-register,
  e.g. an app restart) or under a **different** one (the same physical
  device previously belonged to another guardian's login) — it's
  reactivated (`Active`, `revoked_at` cleared) and reassigned to the
  current guardian, rather than throwing. This also transparently
  reactivates a token that was previously revoked.
- **Refresh** (`previous_token` given): Firebase periodically rotates a
  device's token; the client is expected to tell the server which token
  the new one replaces. The `previous_token` row is revoked (only if it
  belongs to the **same** calling guardian — a `previous_token` claim
  can't be used to revoke a different guardian's token), then the new
  `token` is registered via the same claim-or-create logic above.

### Revoke and Logout — Deliberately Not Linked

`App\Actions\Notifications\RevokeDeviceToken` is unconditional and
idempotent (revoking an already-revoked token is a no-op, not an error —
same simplicity as `RfidDevice`'s activate/revoke, no
`InvalidTransitionException` the way announcements/attendance
corrections have).

**Logout (`App\Http\Controllers\Api\V1\Auth\LogoutController`, WP-01-04)
does not automatically revoke any device token, and this package
deliberately did not change that.** A guardian's Sanctum session and
their device's push token are different things: the same physical device
could have several Sanctum tokens over time (re-logins), and a guardian
could be logged in on **multiple devices** at once (this package's own
"support multiple devices per guardian" scope item) — the server has no
reliable way to know *which* device token corresponds to the session
being logged out. Revoking is the **client's** responsibility: a
well-behaved mobile client calls `DELETE .../device-tokens` with its own
token as part of its own logout flow, before or after discarding its
Sanctum token — that's Flutter-side work, out of scope for this session
(Laravel/API only).

## Firebase Push Signal Delivery (WP-06-05)

`App\Jobs\SendPushSignal` (`ShouldQueue`) sends a push signal to every
**active** device token of a `GuardianNotification`'s guardian, via
[`kreait/laravel-firebase`](https://github.com/kreait/laravel-firebase)
(installed for this package — the standard, actively-maintained way to
call Firebase Cloud Messaging's v1 API from Laravel without hand-rolling
Google's OAuth2 service-account JWT flow). Dispatched from
`App\Observers\GuardianNotificationObserver::created()` — "push delivery
is queued" is satisfied by `ShouldQueue` itself; no bespoke queueing
mechanism was needed.

### The Payload Is Genuinely Empty of Content

This package's own scope item — "do not place authoritative attendance
or announcement bodies solely in the push payload" — is implemented as
strictly as that reading allows: the FCM message carries **no**
`notification` block at all (so no OS-level banner/sound is triggered by
the push itself on any platform) and its `data` payload is limited to
`{"type": "sync_signal", "notification_type": "<NotificationType value>"}`
— never the notification's own `title`/`body`, never attendance or
announcement content. The push is purely a wake-up trigger; the
authoritative content is the `GuardianNotification` row itself, which
the client fetches by syncing after waking up — the same "the push
signal only says 'go sync,' it's never itself the source of truth"
principle the package's Objective states directly. Making that content
actually reachable **over sync** is WP-06-06's job — `GuardianNotification`
still isn't guardian-visible via `ScopeChangesToGuardian` as of this
package either.

### Failure Handling

- **"Failure does not delete notification records"**: nothing in this
  job's failure path ever touches the `GuardianNotification` row beyond
  its own `delivery_status` — a Firebase call that throws (unreachable,
  misconfigured, credentials missing, or a genuine FCM-reported error) is
  caught, logged, and recorded as `NotificationDeliveryStatus::Failed`,
  never re-thrown. A record with no active device token at all is left
  `Pending` (not `Failed` — no delivery attempt was actually made; the
  enum has no third "nothing to do" state, and inventing one wasn't
  needed since the guardian may simply not have registered a device
  yet).
- **Invalid/unknown tokens are not acted on here.** FCM's response can
  identify specific tokens as invalid or unknown
  (`MulticastSendReport::invalidTokens()`/`unknownTokens()`), but
  deactivating a `DeviceToken` in response to that is explicitly
  WP-06-06's own scope item ("invalid-token deactivation"), not this
  one's — this job only decides the notification's own `Sent`/`Failed`
  status (at least one successful send among the targeted tokens = `Sent`).
- No retry logic was added — "retry state" is WP-06-06's own scope item
  too. A failed job is not automatically re-attempted by this package;
  it stays queued-and-attempted-once.

### Secrets Are Not Committed

The Firebase service account JSON is sourced entirely from the
`FIREBASE_CREDENTIALS` (or `GOOGLE_APPLICATION_CREDENTIALS`) environment
variable — `config/firebase.php` (trimmed from the package's published
default to just what Cloud Messaging needs; the Firestore/Realtime
Database/Storage/Auth-tenant sections that ship by default were removed
as unused dead config) never hardcodes a path or embeds a credential.
`.gitignore` gained explicit entries for a conventional
`firebase-credentials.json` filename and `storage/app/firebase-credentials.json`,
on top of the `.env*` patterns already excluded — defense in depth, since
the real secret should never be anywhere in the repository regardless of
which convention an operator picks. No real Firebase project or
credentials exist in this development environment; provisioning them for
each real environment is WP-08-08's ("Laravel Deployment Queue and
Scheduler") documented job, not this package's.

### Testing Without Real Firebase Credentials

`Kreait\Firebase\Contract\Messaging` is Laravel-container-bound as a
singleton that lazily connects to a real Firebase project — resolving it
with no credentials configured throws quickly (a local
`RuntimeException`, not a network hang, confirmed by direct
measurement: ~2 seconds, no outbound call attempted). Even so, letting
every test that creates a `GuardianNotification` trigger a real attempt
would be slow and environment-dependent (dozens of pre-existing WP-06-01/
02/03 tests do exactly that, and `QUEUE_CONNECTION=sync` in `phpunit.xml`
means a dispatched job runs **inline, immediately** — there is no
deferred queue to *not* process in tests). `tests/Pest.php` now calls
`Queue::fake()` in a global `beforeEach` for every Feature test — safe
because `SendPushSignal` is the only queued job in the app, so this has
zero effect on anything else. `tests/Feature/Jobs/SendPushSignalTest.php`
exercises the job's own logic directly (`(new SendPushSignal($notification))->handle($mockedMessaging)`,
via Mockery against the `Messaging` contract) rather than through the
queue, so it needs no real credentials either.

## Not Yet Implemented

Notification sync and delivery logging (WP-06-06) is the remaining
phase-06 work package — it doesn't exist yet. This document will grow as
it lands.
