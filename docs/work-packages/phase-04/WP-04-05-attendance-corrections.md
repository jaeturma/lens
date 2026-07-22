# WP-04-05 — Attendance Corrections

## Objective

Allow authorized daily summary corrections with required reason.

## Affected Layers

- [x] Laravel
- [x] Database
- [x] API
- [ ] Flutter
- [ ] Android
- [ ] RFID Integration

## Scope

Corrections create sync changes and audit logs without changing raw scans.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

WP-04-04, WP-01-06, WP-01-07.

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

- Raw scans remain immutable.
- Correction reason is required.
- Mobile receives corrected state incrementally.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes

- `App\Actions\Attendance\CorrectAttendanceDailySummary` (new): the only
  correctable field is `is_absent`. Correcting to `true` also nulls
  `arrival_event_id`/`departure_event_id` (a summary can't be both absent
  and have a recorded arrival); correcting to `false` just flips the flag,
  since there's no real scan to attach. Raw `rfid_scans`/`attendance_events`
  rows are never modified — only proven with a dedicated test.
- `App\Http\Controllers\Attendance\CorrectAttendanceDailySummaryController`
  (`PATCH attendance/daily-summaries/{summary}/correct`, new
  `routes/attendance.php`, required in `web.php` after `rfid.php`) +
  `App\Http\Requests\Attendance\CorrectAttendanceDailySummaryRequest`
  (`is_absent` required boolean, `reason` required string `min:5`) +
  `App\Policies\AttendanceDailySummaryPolicy::update` (administrators
  only) — mirrors `ReplaceRfidCardController`/`ReplaceRfidCardRequest`'s
  shape exactly.
- No new migration: `attendance_daily_summaries.is_absent` (WP-04-04)
  already exists, and `AttendanceDailySummary`'s `#[ObservedBy]` →
  `RecordSyncChange` (WP-04-02) already fires on `update()` — a correction
  reaches the sync feed with zero new wiring, satisfying "mobile receives
  corrected state incrementally" for free.
- No admin UI/page was built, only the backend endpoint — deliberate,
  matching WP-04-01's precedent for `AttendanceRule` (usable now via the
  endpoint, an edit surface is a gap for a future work package). Flag for
  you: if a correction screen is actually wanted now, that's follow-up
  work this package didn't include, since no phase-04 work package names
  "attendance screens" the way RFID's WP-03-05 does.
- `docs/ATTENDANCE.md` gained an "Attendance Corrections" section.
  `docs/SECURITY.md` already named WP-04-05 as a future
  `RecordAuditLog` call site (written during WP-01-06), so it needed no
  further update.
- Tests: `tests/Feature/Actions/Attendance/CorrectAttendanceDailySummaryTest.php`
  (5 — clears events on absent, flips flag on present without fabricating
  an arrival, audit log has reason + before/after, sync change recorded,
  raw scan/event rows untouched) and
  `tests/Feature/Attendance/AttendanceCorrectionAdministrationTest.php` (4
  — guardian forbidden, administrator succeeds and clears events, reason
  required, `is_absent` required) — 9 new tests.
- Verification: `vendor/bin/pint --dirty` (clean), `vendor/bin/phpstan
  analyse app` (0 errors), full `php artisan test` — 243 passed, 3
  pre-existing skips, 0 failures.
