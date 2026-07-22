# WP-04-03 — Arrival Departure and Late Detection

## Objective

Apply deterministic entry, exit, bidirectional, and late rules.

## Affected Layers

- [x] Laravel
- [x] Database
- [ ] API
- [ ] Flutter
- [ ] Android
- [ ] RFID Integration

## Scope

Avoid guess-heavy behavior and document edge cases.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

WP-04-02.

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

- First valid entry creates arrival.
- Valid exit creates departure.
- Late follows configured cutoff.
- Duplicate scans are not misclassified.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes

- `attendance_events` gained an `is_late` boolean column (migration
  `2026_07_22_170000_add_is_late_to_attendance_events_table.php`, default
  `false`) rather than a third `AttendanceEventType` case, matching
  WP-04-02's explicit design note that lateness is a modifier, not a
  category. Set only for arrival-type events.
- `App\Actions\Attendance\ProcessRfidScan` rewritten:
  - The day's `AttendanceDailySummary` is now looked up (with
    `lockForUpdate()`) *before* the event type is decided, inside the same
    `DB::transaction()` as the event creation and summary write — needed
    because `both`-direction resolution and the late/first-arrival logic
    all depend on that state being current and race-free.
  - `both`-direction devices: no arrival yet today → arrival; arrival
    already recorded → departure (every further tap that day, matching
    `exit`-mode's most-recent-wins rule). No third state — a device
    genuinely can't express more than "in" or "out" per tap.
  - Arrival events no longer unconditionally overwrite the summary's
    `arrival_event_id`; a second entry-type or bidirectional-arrival scan
    the same day still creates its own `AttendanceEvent` (traceability
    preserved) but the summary keeps pointing at the first one.
  - `is_late` computed via `AttendanceRule::arrivalCutoffFor()` (WP-04-01)
    against the scan's `occurred_at`; no `AttendanceRule` row → always
    `false`, never guessed.
- `docs/ATTENDANCE.md` gained an "Arrival, Departure, and Late Detection"
  section; the "Not Yet Implemented" list was trimmed to drop the three
  items this package closes.
- Tests (`tests/Feature/Actions/Attendance/ProcessRfidScanTest.php`): the
  pre-existing "bidirectional device is left unprocessed" test was
  replaced (that behavior is exactly what this package changes) with
  first/second/third-tap toggle tests, a first-arrival-not-replaced test,
  late/not-late/unconfigured-rule/departure-never-late tests — 8 new or
  changed tests, 15 total in the file.
- Verification: `vendor/bin/pint --dirty` (clean), `vendor/bin/phpstan
  analyse app` (0 errors), full `php artisan test` — 224 passed, 3
  pre-existing skips, 0 failures.
