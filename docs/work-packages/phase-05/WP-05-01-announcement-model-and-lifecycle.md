# WP-05-01 — Announcement Model and Lifecycle

## Objective

Create draft, published, expired, and withdrawn announcements.

## Affected Layers

- [x] Laravel
- [x] Database
- [x] API
- [ ] Flutter
- [ ] Android
- [ ] RFID Integration

## Scope

Include title, body, author, publish time, expiration, and stable sync ID.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

Phase 1.

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

- Drafts are not parent-visible.
- Lifecycle validation works.
- Changes synchronize.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes

- `announcements` migration: `uuid` (unique, stable sync ID), `title`,
  `body` (text), `author_id` (nullable FK to `users`, `nullOnDelete`),
  `status` (string, default `draft`, indexed), `published_at`/
  `expires_at` (nullable timestamps), normal mutable `timestamps()`.
- `App\Models\Announcement`: `uuid` generated + made immutable on the same
  `creating`/`updating` hooks as `Student`/`Guardian`/`GuardianStudentLink`;
  `status` defaults to `Draft` in the `creating` hook if not given
  explicitly.
- Only two admin-triggered lifecycle actions (`PublishAnnouncement`,
  `WithdrawAnnouncement`) plus one automatic one
  (`ExpireDueAnnouncements`, via new `announcements:expire` console
  command scheduled every 15 minutes) — no controllers/routes/Policy,
  deliberately: WP-05-02 (Administration) owns the admin surface calling
  into these, same "usable via code now, edit surface is a future
  package's job" precedent WP-04-01 set for `AttendanceRule`.
  `App\Exceptions\Announcements\InvalidAnnouncementTransitionException`
  guards every transition against an invalid starting state — this is
  "Lifecycle validation works."
- **"Drafts are not parent-visible" enforced at the sync-feed layer, now**,
  not deferred to WP-05-04: `App\Observers\AnnouncementObserver` records
  no `sync_changes` row at all while `status` is `Draft` (creation or
  edit). The first real entry, recorded the moment an announcement leaves
  `Draft`, is `SyncChangeAction::Created` — via `getOriginal('status')`,
  which returns the **cast enum**, not the raw string, in this Laravel
  version (`Concerns\HasAttributes::getOriginal()` calls
  `transformModelValue()`) — comparing it against
  `AnnouncementStatus::Draft` (the enum case) rather than `->value`
  (a string) was the fix once a test caught the mismatch.
  `SyncChangeAction::Corrected`/`Expired` both already existed in the enum
  (pre-provisioned, unused until now and WP-04-06) — `Withdrawn` maps to
  `Revoked` (mirroring `guardian_student_link`'s revoke-as-tombstone),
  `Expired` maps to `Expired`.
- `App\Actions\Sync\ScopeChangesToGuardian` was **not** touched — every
  `announcement` sync entry is currently denied by default (unrecognized
  resource type), exactly the deferred-visibility gap WP-04-02 left for
  attendance until WP-04-06. That's WP-05-03/05-04's job.
- `Relation::morphMap()` gained `'announcement' => Announcement::class`
  (`App\Providers\AppServiceProvider`).
- `docs/ANNOUNCEMENTS.md` (new core doc, added to `docs/README.md`'s
  reading order after `ATTENDANCE.md`) and `docs/api/ANNOUNCEMENTS.md`
  (expanded from its stub) document the lifecycle, the deferred sync
  scoping, and what's not built yet.
- Tests: `AnnouncementTest.php` (uuid generation/immutability, default
  Draft status), `PublishAnnouncementTest.php`/`WithdrawAnnouncementTest.php`
  (valid transition + one rejection test per invalid starting state — 8),
  `ExpireDueAnnouncementsTest.php` (due/not-due/no-expiration/draft/
  already-withdrawn — 5), `AnnouncementObserverTest.php` (draft
  create/edit produce no sync entry, publish/edit-after-publish/withdraw/
  auto-expire produce the right action, a directly-created Published row
  still syncs — 7), `ExpireAnnouncementsCommandTest.php` (command wiring)
  — 23 new tests.
- Verification: `vendor/bin/pint --dirty` (clean), `vendor/bin/phpstan
  analyse app` (0 errors), full `php artisan test` — 275 passed, 3
  pre-existing skips, 0 failures. Manually verified `php artisan
  schedule:list` shows both `attendance:mark-absences` and
  `announcements:expire` registered.
