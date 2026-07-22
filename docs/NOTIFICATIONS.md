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

### No Notifications Are Created Yet

This package builds the model, its sync-feed participation, and nothing
else — no rule creates a `GuardianNotification` row for any real event.
`Guardian.notify_attendance`/`notify_announcements` (WP-02-02, already
existing boolean preferences) are exactly what WP-06-02/06-03 will read
before creating one; this package doesn't touch them.

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

## Not Yet Implemented

Attendance notification rules (WP-06-02), announcement notifications
(WP-06-03), device token registration (WP-06-04), push delivery
(WP-06-05), and notification sync/delivery logging (WP-06-06) are the
remaining phase-06 work packages — none exist yet. This document will
grow as they land.
