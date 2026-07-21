# WP-04-01 — Attendance Rules and Schedule

## Objective

Create `attendance_rules` as the school's singleton configuration (same
shape as `SchoolSettings`) that later phase-04 work packages read: WP-04-02
(event processor) and WP-04-03 (arrival/departure/late detection) will
classify raw scans against these cutoffs, and this package also closes a
loop WP-03-04 deliberately left open — the RFID duplicate-scan window was
hardcoded there as "a judgment call worth flagging" pending real
configuration; it now reads from here. This package is the configuration
model and timezone-aware cutoff helpers only, no scan processing.

## Affected Layers

- [x] Laravel
- [x] Database
- [ ] API
- [ ] Flutter
- [ ] Android
- [ ] RFID Integration

## Scope

- `attendance_rules` table/model (`App\Models\AttendanceRule`), one row
  per school (`school_id` unique FK, same singleton pattern as
  `SchoolSettings`): `operating_days` (JSON array of ISO weekday integers,
  1=Monday..7=Sunday), `arrival_cutoff_time`/`departure_time`/
  `absence_cutoff_time` (plain `TIME` columns — no inherent date or
  timezone, deliberately not cast to a bare Carbon instance, since a raw
  time alone can't represent a real instant), `duplicate_window_seconds`
  (default `5`, matching WP-03-04's previous hardcoded value exactly, so
  behavior doesn't change until a school explicitly reconfigures it).
- Timezone-aware helpers (`arrivalCutoffFor(CarbonInterface $date)`,
  `departureTimeFor(...)`, `absenceCutoffFor(...)`, each returning a real
  `CarbonImmutable` instant) and `isOperatingDay(CarbonInterface $date)` —
  combine a stored time with a given calendar date **in the school's
  configured timezone** (`school.settings.timezone`), per
  `docs/API-STANDARD.md`'s Time Conventions rule that attendance-day
  boundaries are never computed in UTC or raw device time. This is the
  "timezone boundaries are tested" acceptance criterion — thoroughly
  tested here since WP-04-02/03 (the actual consumers) don't exist yet.
- `App\Actions\Rfid\IngestRfidScan` (WP-03-04) updated to read
  `duplicate_window_seconds` from the school's `AttendanceRule` instead of
  its own hardcoded constant, falling back to `5` if no row exists yet
  (school not fully configured) — preserves current behavior exactly when
  there's nothing to configure.
- No admin UI or API for editing these rules — nothing in
  `docs/EXECUTION-ORDER.md`'s phase-04 list is a dedicated "attendance
  settings" screen (unlike RFID's WP-03-05); editing capability is a gap
  for a future work package to fill, not silently assumed to be part of
  this one. No seeding either, matching `School`/`SchoolSettings`, which
  also aren't seeded today.
- "Holidays or non-operating days" beyond the weekly `operating_days`
  pattern (e.g., a one-off holiday landing on a normally-operating
  weekday) are **not** modeled in this release — documented as a known
  limitation (see Documentation Updates), not built.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

WP-01-02.

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

- A school's attendance rules can be created/updated as an ordinary
  Eloquent row (one per school).
- Cutoff helpers return the correct UTC instant for a school in a non-UTC
  timezone, proven by tests, not just by inspection.
- `docs/SECURITY.md` or an equivalent doc states plainly that per-date
  holiday exceptions are out of scope for this release.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes

- `attendance_rules` migration (`2026_07_22_150000_create_attendance_rules_table.php`):
  `school_id` (unique FK, `cascadeOnDelete` — same singleton shape as
  `school_settings`), `operating_days` (JSON), three plain `TIME` columns,
  `duplicate_window_seconds` (default `5`). No `uuid` and no sync-feed
  `#[ObservedBy]`/morph-map entry — this is backend configuration, not
  guardian-facing data, same reasoning already applied to `RfidDevice`/
  `RfidCard`/`RfidScan`.
- `App\Models\AttendanceRule`: `operating_days` cast to `array`,
  `arrival_cutoff_time`/`departure_time`/`absence_cutoff_time`
  deliberately **not** cast to a bare Carbon instance — a raw `TIME`
  value has no date or timezone of its own, so casting it directly would
  produce a misleading instant (implicitly today, implicitly UTC/app
  timezone). The three `xFor(CarbonInterface $date)` helper methods and
  `isOperatingDay()` are the only way to get a real, correctly-timezoned
  instant out of a rule, via a private `combine()` that parses
  `date + time` explicitly in `school.settings.timezone` using
  `CarbonImmutable::parse($string, $timezone)`.
- Closed the loop WP-03-04 left open: `IngestRfidScan` now calls
  `AttendanceRule::query()->value('duplicate_window_seconds')` instead of
  its own hardcoded constant, falling back to `5`
  (`DEFAULT_DUPLICATE_WINDOW_SECONDS`) when no rule row exists yet (an
  unconfigured school) — behavior is unchanged for every existing test
  and every school that hasn't explicitly reconfigured this value.
- No admin UI/API for editing rules, and no seeding — confirmed
  `DatabaseSeeder` doesn't seed `School`/`SchoolSettings` either, so
  `AttendanceRule` following the same "exists as a model, not
  auto-created" pattern is consistent, not an oversight.
- New `docs/ATTENDANCE.md` (added to `docs/README.md`'s reading order,
  after `SECURITY.md`) documents the rule fields, the timezone-correctness
  guarantee, and explicitly states the holiday/one-off-non-operating-day
  limitation this WP's acceptance criteria required to be documented
  rather than built.
- Tests: `tests/Feature/Models/AttendanceRuleTest.php` (`isOperatingDay`
  against a weekday set; `arrivalCutoffFor` proven correct for Asia/Manila
  — UTC+8, no DST — by asserting the exact UTC instant, not just "some
  time near 07:30"; `departureTimeFor`/`absenceCutoffFor` proven for
  America/New_York during DST; two different timezones on the same date
  produce different UTC instants, ruling out an implementation that
  silently ignores timezone), plus a new case in
  `tests/Feature/Actions/Rfid/IngestRfidScanTest.php` proving the
  duplicate window now honors a configured value shorter than the old
  hardcoded default — 7 new tests total.
- Verification: `vendor/bin/pint` (clean), `vendor/bin/phpstan analyse app`
  (0 errors), full `php artisan test` — 207 passed, 3 pre-existing skips, 0
  failures (no regression, including WP-03-04's existing scan tests after
  the duplicate-window source change).
