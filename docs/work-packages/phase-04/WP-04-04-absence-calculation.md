# WP-04-04 — Absence Calculation

## Objective

Calculate absence after the configured cutoff through the scheduler.

## Affected Layers

- [x] Laravel
- [x] Database
- [x] API
- [ ] Flutter
- [ ] Android
- [ ] RFID Integration

## Scope

Never mark absence before cutoff and ensure present learners are excluded.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

WP-04-01 through WP-04-03.

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

- Scheduled job works.
- Present learners remain present.
- Boundary tests pass.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes

- `attendance_daily_summaries` gained an `is_absent` boolean column
  (migration
  `2026_07_22_180000_add_is_absent_to_attendance_daily_summaries_table.php`,
  default `false`) rather than a third `AttendanceEventType` — there's no
  `RfidScan` behind an absence for `attendance_events.rfid_scan_id` to
  reference.
- `App\Actions\Attendance\MarkDailyAbsences` (new): computes "today" in the
  school's configured timezone, bails out (returns `0`, no writes) unless
  there's a configured `School`/`SchoolSettings`/`AttendanceRule`, today is
  an operating day, and `now()` is past `AttendanceRule::absenceCutoffFor()`
  — satisfies "never mark absence before cutoff." Active students
  (`StudentStatus::Active`) without an `arrival_event_id` on today's
  summary are marked absent; a student with an arrival is never queried
  for marking at all, satisfying "present learners remain present." Row
  lookups use `whereDate('date', $date)` rather than an array-matched
  `updateOrCreate()`, the same trap WP-04-02 flagged against a `date`-cast
  column.
- `App\Console\Commands\MarkDailyAttendanceAbsences`
  (`attendance:mark-absences`) is thin plumbing over the action, scheduled
  in `routes/console.php` via `Schedule::command(...)->everyFifteenMinutes()`
  — the absence cutoff is a per-school configurable time, not a fixed
  clock time, so the command runs frequently and the action itself decides
  whether today's cutoff has passed, making repeated runs safe.
- `App\Actions\Attendance\ProcessRfidScan` (WP-04-02/03) updated: recording
  an arrival now also clears `is_absent` back to `false` on the day's
  summary. Without this, a student who taps in late — after this WP's job
  already ran for the day — would be left showing as both absent and
  arrived, which would silently violate "present learners remain present"
  for the one case that matters most (a late-but-real arrival).
- `docs/ATTENDANCE.md` gained an "Absence Calculation" section; `docs/api/
  ATTENDANCE.md` was left as-is, matching the precedent WP-04-02/03 already
  set of not touching that stub for backend-only changes with no new HTTP
  contract.
- Tests: `tests/Feature/Actions/Attendance/MarkDailyAbsencesTest.php` (8
  tests — marks after cutoff, boundary test just before cutoff, non-operating
  day, present-student exclusion, inactive-student exclusion, idempotent
  re-run, unconfigured rule, unconfigured school), one new case in
  `ProcessRfidScanTest.php` (late arrival clears a prior absence mark), and
  `tests/Feature/Console/MarkDailyAttendanceAbsencesCommandTest.php` (command
  wiring) — 10 new tests total. Time-dependent tests use `$this->travelTo()`
  rather than passing explicit dates, since `MarkDailyAbsences` reads
  `now()` internally.
- Verification: `vendor/bin/pint --dirty` (clean), `vendor/bin/phpstan
  analyse app` (0 errors), full `php artisan test` — 234 passed, 3
  pre-existing skips, 0 failures. Manually verified
  `php artisan schedule:list` shows `attendance:mark-absences` registered
  at `*/15 * * * *`.
