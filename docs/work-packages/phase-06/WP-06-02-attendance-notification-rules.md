# WP-06-02 — Attendance Notification Rules

## Objective

Create guardian notifications for arrival, departure, late, absence, and corrections where appropriate.

## Affected Layers

- [x] Laravel
- [x] Database
- [x] API
- [ ] Flutter
- [ ] Android
- [ ] RFID Integration

## Scope

Respect active links and notification preferences and prevent duplicates.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

Phase 4, WP-06-01.

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

- Correct guardians receive one notification.
- Duplicate events do not duplicate notifications.
- Tests cover each type.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes

- New `App\Actions\Notifications\NotifyGuardiansOfAttendanceEvent`:
  resolves currently-active, `notify_attendance`-enabled guardians of a
  summary's student and creates one `GuardianNotification` per guardian,
  with type-specific title/body content. Rejects `NotificationType::AnnouncementPublished`
  (validated *before* resolving guardians, so it fails the same way
  regardless of whether any guardian happens to qualify — a real bug
  caught by a test that had no guardian in its fixture, which made the
  original guardians-first ordering skip the validation entirely).
- All triggering logic lives in `App\Observers\AttendanceDailySummaryObserver`,
  not in `ProcessRfidScan`/`MarkDailyAbsences`/`CorrectAttendanceDailySummary`
  themselves — the observer already has full visibility into what
  changed via `wasChanged()`/`getOriginal()` (the exact mechanism already
  used for the `Corrected`-vs-`Updated` sync-action distinction), so
  reusing it avoided adding a constructor dependency to three actions
  with many existing `new ProcessRfidScan`-style test call sites. Added
  handling for both `created()` (a brand-new summary that already carries
  a winning arrival/departure/absence, e.g. a student's first-ever
  summary row) and `updated()` (the ongoing case), with a correction
  short-circuiting arrival/departure/absence classification entirely.
- **Real bug found and fixed during implementation**: a no-op correction
  test (re-applying the same `is_absent` value) initially failed because
  the test fixture created the summary *directly* with
  `is_absent: true` via the factory — which itself fires `created()` and
  sends an Absence notification before the "no-op correction" under test
  even runs, since a factory-created already-absent row is
  indistinguishable from a real `MarkDailyAbsences` result. Fixed by
  having the test perform a real first correction (asserting 1
  notification), then repeating it and asserting the count doesn't grow
  to 2 — not a production bug, but a reminder that this model's
  `created()` hook is not inert for test fixtures either.
- Tests: `NotifyGuardiansOfAttendanceEventTest.php` (5 — recipient
  filtering by active-link/notify_attendance, empty-guardian no-op,
  payload shape, distinct title per type, `AnnouncementPublished`
  rejection) and `Notifications/AttendanceNotificationRulesTest.php` (9,
  end-to-end through the real `ProcessRfidScan`/`MarkDailyAbsences`/
  `CorrectAttendanceDailySummary` flows — arrival, repeat-tap
  no-duplicate, multi-tap departure re-notifies, late classification,
  opted-out guardian, revoked link, absence sweep re-run no-duplicate,
  correction classification, no-op correction no-duplicate) — 14 new
  tests. Full existing attendance test surface (50 tests across phase 4)
  re-run with no regressions from the observer changes.
- Verification: `vendor/bin/pint --dirty` (clean), `vendor/bin/phpstan
  analyse app` (0 errors), full `php artisan test` — 330 passed, 3
  pre-existing skips, 0 failures.
