# WP-07-09 — Offline Home and Linked Children

## Objective

Build the parent home and linked children from SQLite only.

## Affected Layers

- [ ] Laravel
- [ ] Database
- [ ] API
- [x] Flutter
- [ ] Android
- [ ] RFID Integration

## Scope

Show cached child status, last sync, stale/offline indicator, and empty/error states.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

WP-02-06, WP-07-08.

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

- Screens render without live API.
- Multiple children work.
- Offline cached data remains available.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes

**Schema correction to WP-07-08** (done first, since nothing here could
work without it): `GuardianStudentLinks` was keyed by the link's own
`uuid` with a required numeric `studentServerId`. Bootstrap's `children[]`
— which this package establishes as the *only* place a guardian's linked
children ever enter local storage for the first time (the incremental
sync engine only walks forward from bootstrap's own `next_cursor`, so it
can never backfill a child who already existed before this login) —
supplies neither: only the student's own `uuid` and the relationship
fields flattened onto it. Re-keyed the table by `studentUuid` (see
`tables.dart`, and the corresponding note added to
`WP-07-08-incremental-sync-engine.md`); `SyncChangeApplier` updated to
resolve `studentUuid` from a `guardian_student_link` payload's numeric
`student_id` on the create/update path too, the same way it already did
for revoke.

**Bootstrap extended** (`school_bootstrap/data/resolved_child.dart`,
`bootstrap_api.dart`, `bootstrap_repository.dart`): parses `children[]`
into `ResolvedChild` (+ nested `ResolvedTodayAttendance`) and writes each
into `students` + `guardian_student_links`, plus `attendance_records` when
`today_attendance` is present. `notifications_enabled` has no equivalent
field in `LinkedStudentResource` — defaulted `true`, the same
"bootstrap gives an incomplete snapshot, a sync entry backfills the rest"
pattern already used for `Students.serverId`. **Known limitation, not
solved here**: this method only adds/updates children present in the
response; it does not reconcile a child no longer present (e.g. a link
revoked while this guardian was signed out without using this app's own
logout, which already clears everything — WP-07-07). Documented in code
rather than silently left as a surprise.

**Timezone handling**: bootstrap's `today_attendance` carries no `date`
field — the server computes "today" in the school's configured IANA
timezone, and the client has to independently agree on the same date to
key the local row correctly (so a later `attendance_daily_summary` sync
entry for the same day updates it rather than creating a duplicate).
Added the `timezone` package (decided with the user rather than guessing
— device-local-date approximation or a hardcoded Philippines offset were
the alternatives, both correct today but silently wrong for a future
differently-timezoned deployment or a midnight-boundary edge case) and
`core/school_timezone.dart`'s `todayIn(ianaTimezone)`, falling back to the
device's own local date if the timezone string isn't recognized.

**`HomePage`** (`features/home/`) replaces the WP-07-01/05 placeholder
foundation page as the authenticated screen — `lib/features/foundation/`
deleted entirely:

- `LinkedChildrenDao` (new, spanning `Students`+`GuardianStudentLinks`+
  `AttendanceRecords` — no single table/DAO represents "a guardian's
  linked child" on its own) joins actively-linked students with today's
  attendance, reactively.
- `SyncStatusBanner` — "last sync" and a "stale/offline indicator": this
  app has no live connectivity check, so staleness is inferred purely
  from how long ago `sync_state.last_synced_at` was, using the same
  15-minute cadence the Laravel side's own periodic sweeps already use
  (`routes/console.php`), not a new invented threshold.
  `SyncStateDao` gained a `watch()` stream for this (was read-only-once
  before).
- `LinkedChildCard` — "cached child status": name, grade/section, and a
  plain-language status line derived from `todayAttendance`
  (absent/not-yet-arrived/arrived\[+late\]/arrived-and-departed), entirely
  from the joined row, never a live lookup.
- Empty state ("No linked children yet.") and error state (reusing
  `AppErrorView`) for the linked-children stream; "screens render without
  live API" holds because every value on this screen — school branding,
  sync status, and the children list — already came from `AppDatabase`
  before `HomePage` ever mounts.
- Startup sync and pull-to-refresh (WP-07-08) moved here from the deleted
  foundation page, along with the logout action (WP-07-07) and
  maintenance banner (WP-07-05).

**Test-suite side effect**: every existing test asserting `find.text('Foundation Ready')`
as its proxy for "the authenticated screen is showing" was updated to
`find.text('No linked children yet.')` — the equivalent proxy now that a
real (if still children-less, in those tests) home screen exists.

Tests: `linked_children_dao_test.dart` (only active links returned;
today's attendance joined in, a different date's is not; multiple
children ordered by name); `sync_status_banner_test.dart` (never
synced/recent/stale banner variants); `home_page_test.dart` (empty state;
multiple children each rendering their own independent status);
`bootstrap_repository_test.dart` extended (a linked child is cached as a
student + active link + today's attendance; a child with no
`today_attendance` yet writes no attendance row); `sync_change_applier_test.dart`
updated for the `studentUuid`-keyed link schema, including a new
"skipped when the student isn't known locally yet" case matching the one
`attendance_daily_summary` already had.

Verification: `flutter analyze` clean, `dart format` applied, `flutter
test` — 74/74 passing.
