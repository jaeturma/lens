# WP-07-11 — Offline Announcements

## Objective

Build announcement list and detail from SQLite.

## Affected Layers

- [ ] Laravel
- [ ] Database
- [ ] API
- [x] Flutter
- [ ] Android
- [ ] RFID Integration

## Scope

Hide or remove expired and withdrawn announcements based on synchronized state.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

WP-05-04, WP-07-08.

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

- Active targeted announcements display.
- Expiration and withdrawal synchronize.
- Offline data is readable.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes

**Bootstrap extended** (`resolved_announcement.dart`, `bootstrap_api.dart`,
`bootstrap_repository.dart`): parses bootstrap's top-level `announcements`
array — deliberately deferred by WP-07-05/06/09 to this package — and
upserts each into the local `announcements` table, the same "bootstrap is
the only place data predating its own `next_cursor` ever enters local
storage" reasoning already established for the guardian's linked children
(WP-07-09). Same known limitation, too: an announcement withdrawn/expired
entirely while this guardian was signed out (not via this app's own
logout) can persist locally until an eventual sync entry tombstones it —
this method only adds/updates what the response currently contains.

**"Hide or remove expired and withdrawn announcements based on
synchronized state"** needed no new logic — `SyncChangeApplier` (WP-07-08)
already deletes the local row outright on `revoked`/`expired`, so the
local `announcements` table's own invariant already *is* "currently
published only." `announcementsProvider` reads it as-is, with no
client-side status re-check — documented in code so a future reader
doesn't assume a missing filter is an oversight.

New feature `mobile/lib/features/announcements/`, plus two new routes
(`/announcements`, `/announcements/:announcementUuid`) and an AppBar
entry point on the home screen:

- `AnnouncementsPage` — a reactive list (`AnnouncementsDao.watchAll()`,
  now ordered newest-published-first), the shared `SyncStatusBanner` for
  "offline data is readable" context, and loading/empty/error states.
- `AnnouncementDetailPage` — reached by `uuid`; if the row is deleted out
  from under it (a revoke/expiry landing while the screen is open), it
  switches to a "no longer available" state rather than an error, since
  that's the tombstone working as intended, not a failure.
- Extracted the shared date formatter (month name/day/year) out of
  `features/attendance/presentation/attendance_text.dart` into
  `core/date_format.dart` now that a second feature needs it —
  `formatAttendanceDate` kept as a thin wrapper so attendance's own
  tests/call sites didn't need touching.

Tests: `bootstrap_repository_test.dart` extended (an announcement from
bootstrap is cached; a repeated sync updates it in place, not a
duplicate); `announcements_page_test.dart` (empty state; list + tap
navigates to detail, via a small purpose-built `GoRouter` rather than the
full app shell); `announcement_detail_page_test.dart` (shows title/body;
not-yet-cached and after-tombstone both show the same "no longer
available" state); `app_router_test.dart` (WP-07-04) updated for the two
new routes; a new `home_page_test.dart` case for the AppBar entry point.

Verification: `flutter analyze` clean, `dart format` applied, `flutter
test` — 94/94 passing.
