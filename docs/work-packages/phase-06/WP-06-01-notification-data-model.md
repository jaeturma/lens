# WP-06-01 — Notification Data Model

## Objective

Store authoritative in-app notifications independently of push delivery.

## Affected Layers

- [x] Laravel
- [x] Database
- [x] API
- [ ] Flutter
- [ ] Android
- [ ] RFID Integration

## Scope

Include type, recipient, title, body, payload, read state, sync ID, and delivery state.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

Phase 2.

## Laravel Requirements

Implement only the server-side work directly required by this package.

## API Contract

Document every new or changed mobile/device contract.

## Flutter and SQLite Requirements

When affected, screens must read SQLite and repositories must synchronize server changes into SQLite.

## Permissions and Security

Apply least privilege, validation, authorization, rate limiting, and secure secret handling.

## Tests

Run targeted Pest, Flutter, SQLite migration, or integration tests appropriate to the changed layer.

## Documentation Updates

Update the relevant core or API document.

## Acceptance Criteria

- Notifications remain available after push failure.
- Unread state synchronizes.
- Tests pass.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes

- `guardian_notifications` migration: `uuid` (unique), `guardian_id` (FK,
  `cascadeOnDelete`), `type` (string), `title`, `body` (text), `payload`
  (nullable JSON), `read_at` (nullable timestamp), `delivery_status`
  (string, default `pending`), normal mutable `timestamps()`, indexed on
  `(guardian_id, read_at)` for an eventual "guardian's unread
  notifications" query. **Not** named `notifications` — `App\Models\User`
  already uses Laravel's `Notifiable` trait (unused today), which claims
  that table name by convention for its own database-channel
  notifications; a collision there would be a genuinely hard bug to
  trace later, so it was avoided now while it's free to avoid.
- `App\Enums\NotificationType` (`Arrival`/`Departure`/`Late`/`Absence`/
  `Correction`/`AnnouncementPublished`) and
  `App\Enums\NotificationDeliveryStatus` (`Pending`/`Sent`/`Failed`,
  defaults to `Pending` in the `creating` hook). The type vocabulary
  covers what WP-06-02 (attendance) and WP-06-03 (announcements) will
  need, decided now since "type" is this package's own scope item and the
  vocabulary is already fully specified by those two work packages'
  Objective text.
- `App\Models\GuardianNotification`: `uuid` generated + immutable on the
  same `creating`/`updating` hooks as every other synced resource;
  `Guardian::notifications(): HasMany` added alongside the existing
  `links()`/`activeLinks()` relations.
- `App\Observers\GuardianNotificationObserver`: `created`/`updated` both
  record a sync change (`Created`/`Updated` — no tombstone-style action
  needed, since nothing in this package's scope produces one).
  `Relation::morphMap()` gained `'guardian_notification' =>
  GuardianNotification::class`.
- No rule creates a notification row (WP-06-02/06-03's job — this package
  builds the destination, not any trigger), no guardian-facing visibility
  (`App\Actions\Sync\ScopeChangesToGuardian` untouched — WP-06-06's job),
  and no HTTP endpoint at all. `Guardian.notify_attendance`/
  `notify_announcements` (already existing since WP-02-02) are untouched
  — exactly what the later rule packages will read.
- `docs/NOTIFICATIONS.md` (new core doc, added to `docs/README.md`'s
  reading order after `ANNOUNCEMENTS.md`) and `docs/api/NOTIFICATIONS.md`
  (expanded from its stub) document the model, the table-naming decision,
  and what's deliberately not built yet.
- Tests: `GuardianNotificationTest.php` (3 — uuid generation/immutability,
  default `Pending` delivery status, starts unread),
  `GuardianNotificationObserverTest.php` (3 — creation records `Created`,
  a read-state update records `Updated` with the new `read_at` in the
  payload, the payload carries type/guardian/delivery status) — 6 new
  tests.
- Verification: `vendor/bin/pint --dirty` (clean), `vendor/bin/phpstan
  analyse app` (0 errors), full `php artisan test` — 316 passed, 3
  pre-existing skips, 0 failures.
