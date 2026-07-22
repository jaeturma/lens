# WP-04-06 — Parent Attendance Sync Contract

## Objective

Expose current and historical attendance through bootstrap and incremental sync.

## Affected Layers

- [x] Laravel
- [ ] Database
- [x] API
- [x] Flutter
- [ ] Android
- [ ] RFID Integration

## Scope

Define stable IDs, corrections, deletion behavior, and pagination if history is separately queried.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

WP-02-06, WP-04-05.

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

- Guardians receive only linked-child attendance.
- Corrections synchronize.
- Contracts and tests pass.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes

- Laravel/API layer only, per explicit scoping for this session — Flutter
  consumption of this contract is separate follow-up work, not included
  here.
- `App\Actions\Sync\ScopeChangesToGuardian`: added `attendance_daily_summary`,
  scoped by the entry's `payload['student_id']` (the summary's own
  `resource_id` is the summary row, not the student — unlike `student`
  entries, this branch can't compare `resource_id` directly).
- `App\Observers\AttendanceDailySummaryObserver`: `updated()` now records
  `SyncChangeAction::Corrected` instead of `Updated` when the update came
  from `CorrectAttendanceDailySummary` (WP-04-05) — detected via a new
  transient `App\Models\AttendanceDailySummary::$wasCorrected` flag (a
  plain typed public property, not an Eloquent attribute, so it never
  reaches `getDirty()`/the SQL `UPDATE`), set by the action right before
  its `update()` call and reset by the observer immediately after reading
  it. Field-diffing alone can't distinguish a correction from
  `ProcessRfidScan`/`MarkDailyAbsences` writes, which can land on the same
  columns (`is_absent` toggling with no arrival/departure change happens
  in both an admin correction and an automatic absence mark).
- `payload()` gained `is_late` and `is_absent`, and now force-reloads
  `arrivalEvent`/`departureEvent` via `$summary->load(...)` instead of the
  cached property accessor. **Real bug found and fixed during
  implementation**: the cached accessor goes stale when the same in-memory
  `$summary` instance is created then updated again in one request (e.g. a
  correction immediately after creation) — the very first access, even at
  creation when `arrival_event_id` is still null, permanently caches a
  `null` relation on that instance, so a later update's payload would
  silently keep reporting the *original* (missing) arrival. Caught by a
  test that created-then-corrected the same instance, not by inspection —
  the existing `arrival`/`departure` fields were already exposed to this
  same risk before this package, just never triggered by prior callers.
- `App\Models\Student::attendanceSummaries()` (new `HasMany`, generic —
  not date-scoped itself) + `App\Http\Controllers\Api\V1\Sync\BootstrapController`
  eager-loads it constrained to today (`whereDate('date', $today)`, school
  timezone) with `arrivalEvent`/`departureEvent` nested to avoid N+1.
  `App\Http\Resources\V1\LinkedStudentResource` gained `today_attendance`,
  reading the (at most one, due to the constraint) loaded summary.
- Nullsafe-plus-`??` on `arrivalEvent?->is_late` and
  `$school?->settings?->timezone` both hit the same Larastan false-positive
  WP-04-02 already documented (a `BelongsTo`/`HasOne` accessor inferred as
  never-null from its declared return type) — worked around the same way,
  with an explicit truthy check instead of `?->`.
- `docs/api/SYNC.md`: documented `today_attendance` under Bootstrap, added
  the `attendance_daily_summary` branch to Guardian-Scoped Authorization,
  added a full `attendance_daily_summary` entry under Synchronized
  Resources (stable ID, corrections, deletion behavior, and why no
  separate history-pagination endpoint was built — a client backfills
  history by walking `/sync/changes` from `cursor=initial()`, reusing
  existing pagination), and trimmed "Not Yet Implemented" to drop
  attendance. `docs/ATTENDANCE.md` gained a "Parent Attendance Sync
  Contract" section and now marks phase 4 complete.
- Tests: `ScopeChangesToGuardianTest.php` (+2 — active-link visibility
  scoped by payload, revoked-link invisibility), `AttendanceDailySummaryObserverTest.php`
  (+3 — payload carries `is_late`/`is_absent`, a correction records
  `corrected`, a later ordinary update goes back to `updated`),
  `BootstrapTest.php` (+3 — null/populated/not-yesterday `today_attendance`),
  `ChangesTest.php` (+1 — end-to-end own-vs-other-guardian attendance
  scoping), and `CorrectAttendanceDailySummaryTest.php` (WP-04-05, updated
  — its sync-change assertion now expects `corrected` instead of the old
  `updated`, since that behavior is exactly what this package changed) —
  9 new tests, 1 updated.
- Verification: `vendor/bin/pint --dirty` (clean), `vendor/bin/phpstan
  analyse app` (0 errors), full `php artisan test` — 252 passed, 3
  pre-existing skips, 0 failures.
