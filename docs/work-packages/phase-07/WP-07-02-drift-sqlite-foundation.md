# WP-07-02 — Drift SQLite Foundation

## Objective

Add typed local database, migrations, DAOs, and repository boundaries.

## Affected Layers

- [ ] Laravel
- [ ] Database
- [ ] API
- [x] Flutter
- [x] Android
- [ ] RFID Integration

## Scope

Create local tables for settings, school, guardian, students, attendance, announcements, notifications, and sync state.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

WP-00-05, WP-07-01.

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

- Database opens and migrates.
- Tables have stable server IDs.
- Tests cover creation and migration.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes

Added `drift`/`drift_flutter` (+ `drift_dev`/`build_runner` dev deps) and a
typed `AppDatabase` (`mobile/lib/core/database/`) with all 8 tables this
package's Scope line names — `app_settings`, `school_profile`,
`guardian_profile`, `students`, `attendance_records`, `announcements`,
`notifications`, `sync_state` — matching `docs/DATABASE.md`'s Flutter/SQLite
list except `mobile_device_state`, which is not in this WP's Scope line and
is left for whichever later package owns push-token/device state on the
Flutter side.

- **Stable server IDs**: every synced-resource table (`school_profile`,
  `guardian_profile`, `students`, `announcements`, `notifications`) is keyed
  by `uuid` — the client-facing identifier `docs/api/SYNC.md` establishes
  for every resource, and the only identifier bootstrap ever actually
  exposes (it never sends a numeric database id). `attendance_records` is
  the one exception: bootstrap's embedded `today_attendance` carries no id
  at all, so it's keyed by a local autoincrement id with a
  `(studentUuid, date)` unique index — the always-derivable natural key —
  plus a nullable `serverId` column for the summary's own `resource_id`
  once a change-feed entry supplies it. `students` also carries a nullable
  `serverId`, needed because `attendance_daily_summary` payloads reference
  `student_id` as that same numeric id, not `uuid`.
- **DAOs**: one per table (`daos.dart`), typed reads/writes only — no sync
  or business logic. That's deliberately left to whichever package actually
  writes into these tables (WP-07-08 Incremental Sync Engine, and the
  offline-screen packages WP-07-09 through WP-07-12), so this stays a
  foundation, not a premature repository implementation.
- `AttendanceRecordsDao.upsert` passes an explicit `DoUpdate` conflict
  target (`studentUuid`, `date`); Drift's `insertOnConflictUpdate` shortcut
  only de-duplicates against a table's primary key, which here is the
  unrelated local autoincrement id.
- Added `mobile/build.yaml` enabling `store_date_time_values_as_text` —
  without it, Drift stores `DateTime` columns as unix timestamps that
  round-trip through the device's local timezone on read, silently
  shifting every synced UTC timestamp by the device's UTC offset (caught by
  a failing test during verification).
- `Notifications`' generated data class is renamed via `@DataClassName`
  (`NotificationRow`) — the default (`Notification`) collides with
  Flutter's own `Notification` widget-tree type. The SQL table name itself
  is untouched (`notifications`, matching `docs/DATABASE.md`).
- Tests: `mobile/test/core/database/app_database_test.dart` — the database
  opens and creates all 8 tables; uuid-keyed tables upsert in place rather
  than duplicating; the `(studentUuid, date)` attendance upsert path;
  the sync-state singleton row is overwritten, not appended to.

Not done here (other work packages' scope): repository classes that
actually call the sync API and write through these DAOs (WP-07-08);
consuming these tables from screens (WP-07-09 through WP-07-12); the
concrete `app_settings` keys for school-binding lock state (WP-07-03/04).

Verification: `flutter analyze` clean, `dart format` applied,
`flutter test` — 7/7 passing (1 pre-existing smoke test + 6 new).
