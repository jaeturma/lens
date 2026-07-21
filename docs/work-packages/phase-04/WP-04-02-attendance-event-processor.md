# WP-04-02 — Attendance Event Processor

## Objective

Build the transaction-safe, idempotent pipeline that turns a
`valid`-classified `RfidScan` (WP-03-04) into an `AttendanceEvent` and
rolls it into that student's `AttendanceDailySummary` for the day —
processing infrastructure, not the classification rules. This package
only handles the two direction modes with an unambiguous mapping
(`entry`→arrival, `exit`→departure, one event per scan, most-recent-wins
on the summary); WP-04-03 owns "first entry of the day," `both`-direction
disambiguation, and late detection — none of that is invented here.

## Affected Layers

- [x] Laravel
- [x] Database
- [x] API
- [ ] Flutter
- [ ] Android
- [ ] RFID Integration

## Scope

- `attendance_events` table/model: `rfid_scan_id` (FK, **unique** — one
  event per scan, both the "events reference raw scans" mechanism and the
  idempotency key for "reprocessing is safe"), `student_id`,
  `rfid_device_id`, `event_type` (`App\Enums\AttendanceEventType`:
  Arrival/Departure only — no `Late` case; lateness is a modifier WP-04-03
  adds, not a third event category), `occurred_at` (the scan's `created_at`
  — Laravel's authoritative receipt time, never the informational
  `device_timestamp`, per `docs/API-STANDARD.md`). Append-only
  (`created_at` only), same pattern as `rfid_scans`/`audit_logs`.
- `attendance_daily_summaries` table/model: `student_id`, `date` (the
  event's `occurred_at` converted to the **school's configured timezone**
  calendar date, via WP-04-01 — not the UTC date), nullable
  `arrival_event_id`/`departure_event_id` (FK to `attendance_events`),
  unique `(student_id, date)`. Mutable (normal `timestamps()`) — unlike
  events, a summary is a rollup that gets updated through the day.
- `App\Actions\Attendance\ProcessRfidScan`: skips anything not
  `RfidScanClassification::Valid`; skips (returns `null`, no event) a
  scan from a `both`-direction device — WP-04-03's job; otherwise creates
  the `AttendanceEvent` and upserts the day's summary in one
  `DB::transaction()`. If an event already exists for the scan (checked
  first), returns it unchanged instead of creating a duplicate — this is
  what makes calling this action twice on the same scan safe.
- `App\Observers\RfidScanObserver` (`#[ObservedBy]` on `RfidScan`,
  alongside the model's existing lack of sync-feed participation, which
  is unrelated and unchanged): calls `ProcessRfidScan` on every scan
  `created` event, so processing happens automatically as scans arrive —
  `RfidScan::attendanceEvent()` (`HasOne`, new) is what makes "processing
  status traceable": `null` means not yet processed (or not applicable,
  e.g. a `both`-direction scan), present means it was.
- `AttendanceDailySummary` gets `#[ObservedBy]` sync-feed participation
  now (`RecordSyncChange`, registered in the `Relation::morphMap()`),
  matching the precedent `Student`/`Guardian`/`GuardianStudentLink` set in
  WP-02-01/02/03 — the data-model package adds sync participation eagerly;
  the guardian-scoped **authorization** for it
  (`App\Actions\Sync\ScopeChangesToGuardian`) is explicitly WP-04-06's job,
  not added here (an `attendance_daily_summary` entry is invisible to
  every guardian until WP-04-06 adds that branch — the documented
  default-deny behavior, not an oversight). `AttendanceEvent` itself is
  **not** synced — a daily summary already carries what a mobile client
  needs; syncing every raw arrival/departure event too would be redundant.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

WP-03-04, WP-04-01.

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

- `rfid_scan.attendanceEvent` shows whether/how a scan was processed.
- Every `AttendanceEvent` has a valid `rfid_scan_id`; no two events
  reference the same scan.
- Calling `ProcessRfidScan` twice on the same scan does not create a
  second event or double-apply the daily summary update.
- A daily summary's `date` is correct in the school's timezone, not UTC.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes

- `attendance_events` migration: `rfid_scan_id` (FK, **unique**,
  `cascadeOnDelete`), `student_id` (`cascadeOnDelete`, matching
  `RfidCard`/`GuardianStudentLink`'s existing choice for student FKs),
  `rfid_device_id` (`restrictOnDelete`, matching `RfidScan`'s own choice),
  `event_type`, `occurred_at`, `created_at` only (append-only, same
  pattern as `rfid_scans`/`audit_logs`/`sync_changes`).
  `attendance_daily_summaries` migration: `student_id`, `date`, nullable
  `arrival_event_id`/`departure_event_id` (`nullOnDelete`), unique
  `(student_id, date)`, normal mutable `timestamps()`.
- **Real bug found and fixed during implementation**: the daily-summary
  upsert originally used `AttendanceDailySummary::updateOrCreate(['student_id'
  => ..., 'date' => $date], [...])`. A plain array-based `where()` match
  against a `date`-cast column is not reliable — the second call (for a
  same-day departure after an arrival) failed a `UNIQUE constraint failed`
  insert instead of finding the existing row, because the raw date string
  didn't match however the cast column serializes for comparison. Fixed
  by looking the row up explicitly with `whereDate('date', $date)`
  (SQL-level `DATE()` comparison, robust regardless of stored format)
  before deciding to update or create. Caught by the "does not clobber"
  test, not by inspection — worth flagging since `updateOrCreate` against
  a cast column is an easy trap to fall into again elsewhere.
- `App\Actions\Attendance\ProcessRfidScan`: checks for an existing event
  by `rfid_scan_id` first (idempotency), classifies by direction mode
  (`both` → `null`/skip), looks up the active card for the scan's `uid`,
  then creates the event and updates the summary in one
  `DB::transaction()`. `updateDailySummary()`'s school/timezone lookup
  uses an explicit `$school && $school->settings` check rather than
  chained `?->` — a PHPStan finding: Larastan infers a `HasOne` relation
  accessor as non-nullable from its declared return type, so `?->settings
  ?->timezone` gets flagged as an unnecessary nullsafe even though
  `settings` can genuinely be `null` at runtime if a `School` row exists
  without one (the same gap `EnsureSchoolMobileAccessIsAvailable`
  middleware already guards against explicitly, for the same reason).
- `App\Observers\RfidScanObserver` (`#[ObservedBy]` on `RfidScan`, added
  alongside its model, unrelated to and not replacing its deliberate lack
  of sync-feed participation) calls `ProcessRfidScan` on `created`.
  `App\Observers\AttendanceDailySummaryObserver` calls `RecordSyncChange`
  on `created`/`updated`, same shape as `StudentObserver`/`GuardianObserver`.
- Registered `'attendance_daily_summary' => AttendanceDailySummary::class`
  in the `Relation::morphMap()`. Deliberately did **not** touch
  `ScopeChangesToGuardian` (WP-02-06) — that's WP-04-06's job; these
  entries are invisible to every guardian for now (documented default-deny
  behavior).
- Tests: `tests/Feature/Actions/Attendance/ProcessRfidScanTest.php`
  (entry→arrival, exit→departure, both-direction left unprocessed,
  non-valid classification skipped, reprocessing the same scan is a
  no-op, an arrival doesn't clobber a same-day departure and vice versa,
  timezone-correct summary date across a UTC/Asia-Manila day boundary,
  and that creating a scan through the normal factory path
  auto-triggers processing via the observer), plus
  `tests/Feature/Observers/AttendanceDailySummaryObserverTest.php`
  (created/updated sync entries) — 10 new tests. The timezone test
  needed `RfidScan::withoutEvents()` around the scan's creation to
  backdate `created_at` before the observer's automatic first processing
  could run with the wrong timestamp — otherwise the auto-triggered
  processing would beat the test's own backdating.
- `docs/ATTENDANCE.md` gained an "Event Processor" section documenting
  the pipeline, the idempotency guarantee, and the deferred sync-scoping
  gap.
- Verification: `vendor/bin/pint` (clean), `vendor/bin/phpstan analyse app`
  (0 errors), full `php artisan test` — 217 passed, 3 pre-existing skips, 0
  failures.
