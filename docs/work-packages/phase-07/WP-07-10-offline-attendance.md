# WP-07-10 — Offline Attendance

## Objective

Build child attendance status and history from SQLite.

## Affected Layers

- [ ] Laravel
- [ ] Database
- [ ] API
- [x] Flutter
- [ ] Android
- [ ] RFID Integration

## Scope

Use reactive local queries and display corrections and sync freshness.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

WP-04-06, WP-07-09.

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

- Attendance works offline after sync.
- Corrected records update locally.
- Loading, empty, stale, and error states exist.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes

**Scope boundary**: `docs/api/SYNC.md` notes a client *can* backfill full
attendance history by walking `/sync/changes` from `cursor=initial()` —
explicitly described as something to do "if the client wants to," not a
requirement. This package builds the screen against whatever has already
accumulated locally through the normal incremental sync path (today's
snapshot from bootstrap, WP-07-09, plus every ongoing change/correction
from then on, WP-07-08) — it does not add a separate "walk from the
beginning" backfill operation, which would be a materially different
feature (a second sync mode) beyond "reactive local queries."

New feature `mobile/lib/features/attendance/`, reached by tapping a child
on the home screen (new navigation in this app — `go_router` previously
had exactly one route):

- `AppRoutes.attendanceHistory` (`/attendance/:studentUuid`) added to
  `app_router.dart`; `LinkedChildCard` (WP-07-09) gained an `onTap`
  wrapping it in an `InkWell`.
- `AttendanceHistoryPage` — student name as the title (reactive via new
  `StudentsDao.watchByUuid`), a day-by-day list (`AttendanceRecordsDao.watchForStudent`,
  now ordered newest-first), the same `SyncStatusBanner` the home screen
  uses for "sync freshness," and loading/empty/error states.
- **"Corrected records update locally"**: needs no special handling
  beyond what already exists — `SyncChangeApplier` (WP-07-08) upserts a
  `corrected` action into the same `(studentUuid, date)` row `updated`
  would, so this screen's reactive stream reflects it the moment it
  lands, with no distinct code path. Tested by upserting the same row
  twice in `attendance_history_page_test.dart` and confirming the
  displayed row changes in place.
- Formatting (`attendance_text.dart`) extracted out of `LinkedChildCard`
  so both it and the new history tiles share one phrasing rather than
  duplicating it — `noRecordText` is parameterized since "no attendance
  recorded" reads better as "...yet today" on the home screen than as a
  blanket message against an arbitrary historical date.
- `SyncStatusBanner` and `syncStateProvider` — both introduced by
  WP-07-09 under `features/home/` — relocated to `features/sync/` now
  that a second, unrelated feature needs them too, rather than having
  `attendance` reach laterally into `home`.

**A real bug caught by the "corrected records update in place" test,
not by inspection**: `AttendanceDayTile` originally colored an absent
day via `ListTile.subtitleTextStyle: isAbsent ? TextStyle(color: ...) :
null`. `ListTile` drives that through its own `AnimatedDefaultTextStyle`;
toggling it between an explicit `TextStyle(color: ...)` (`inherit: true`)
and `null` (falls back to a theme-merged style, `inherit: false`) makes
Flutter try to interpolate between mismatched `inherit` values the moment
a correction flips `isAbsent` and the tile rebuilds — and
`TextStyle.lerp` throws rather than silently doing the wrong thing.
Fixed by coloring the subtitle `Text`'s own `style` instead, leaving
`ListTile`'s animated style untouched and constant across rebuilds.

Tests: `attendance_text_test.dart` (every `attendanceStatusText`/
`formatTimeOfDay`/`formatAttendanceDate` branch); `attendance_history_page_test.dart`
(title; empty state; multiple days newest-first; a correction updating
a row in place without re-fetching); `sync_status_banner_test.dart`
moved under `features/sync/` with its relocated widget;
`app_router_test.dart` (WP-07-04) updated for the second route now
present; a new `home_page_test.dart` case confirming a tap actually
navigates to the right student's history.

Verification: `flutter analyze` clean, `dart format` applied, `flutter
test` — 86/86 passing.
