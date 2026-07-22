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

## Not Yet Implemented

Device token registration (WP-06-04), push delivery (WP-06-05), and
notification sync/delivery logging (WP-06-06) are the remaining phase-06
work packages — none exist yet. This document will grow as they land.
