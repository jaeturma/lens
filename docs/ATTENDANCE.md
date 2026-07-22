# Attendance

## Rules and Schedule (WP-04-01)

`attendance_rules` is a school's singleton configuration (one row per
school, same pattern as `school_settings`), read by later phase-04 work
packages that classify raw RFID scans into attendance events:

- `operating_days` — a JSON array of ISO weekday integers (`1`=Monday
  through `7`=Sunday) the school operates on.
- `arrival_cutoff_time` — the time of day after which an arrival counts as
  late.
- `departure_time` — the school's scheduled dismissal time.
- `absence_cutoff_time` — the time of day after which a student with no
  arrival scan on an operating day is considered absent.
- `duplicate_window_seconds` (default `5`) — how close together two scans
  of the same card must be to be treated as one physical tap read twice,
  rather than two separate events. `App\Actions\Rfid\IngestRfidScan`
  (WP-03-04) reads this value; it previously used a hardcoded `5`, so
  behavior is unchanged until a school's rules are explicitly configured
  with a different value.

`App\Models\AttendanceRule::arrivalCutoffFor(CarbonInterface $date)` /
`departureTimeFor(...)` / `absenceCutoffFor(...)` combine a stored time
with a calendar date **in the school's configured timezone**
(`school.settings.timezone`), returning a real instant — never UTC or
server-local time, per `docs/API-STANDARD.md`'s Time Conventions rule.
`isOperatingDay(CarbonInterface $date)` checks a date's ISO weekday
against `operating_days`.

No admin UI or API exposes these rules for editing yet — no work package
in `docs/EXECUTION-ORDER.md`'s phase 04 is a dedicated settings screen for
them (unlike RFID's WP-03-05). They exist and are usable as ordinary
Eloquent data now; an edit surface is a gap for a future work package to
fill deliberately, not something assumed here.

### Known Limitation: Holidays and One-Off Non-Operating Days

`operating_days` only models a **weekly recurring** pattern (e.g.,
Monday-Friday). It does not support marking a single date as non-operating
when its weekday would otherwise be an operating day — a holiday that
falls on a Tuesday is not automatically excluded in this release. Any
attendance records that would result from treating a holiday as a normal
school day are expected to be corrected manually via WP-04-05 (Attendance
Corrections) once that package exists. A per-date holiday calendar is not
planned for the initial release (see `docs/PROJECT-SCOPE.md`).

## Event Processor (WP-04-02)

`App\Actions\Attendance\ProcessRfidScan` converts a `valid`-classified
`RfidScan` (WP-03-04) into an `attendance_events` row, and rolls it into
that student's `attendance_daily_summaries` row for the day. It runs
automatically via `App\Observers\RfidScanObserver` on every scan
`created` event — no separate trigger or job is needed.

- Only `RfidScanClassification::Valid` scans are processed; duplicate/
  unknown-card/inactive-card scans never produce an event.
- `direction_mode` `entry`/`exit` map deterministically to
  `App\Enums\AttendanceEventType::Arrival`/`Departure`. A `both`-direction
  device's scans are **left unprocessed** (`ProcessRfidScan` returns
  `null`, no event created) — disambiguating them is WP-04-03's job, not
  invented here. `RfidScan::attendanceEvent` (`null` until processed) is
  how processing status is traced.
- `attendance_events.rfid_scan_id` is unique — calling `ProcessRfidScan`
  again on an already-processed scan returns the existing event instead
  of creating a duplicate or re-applying the daily-summary update. This
  is the "reprocessing is safe" guarantee.
- The daily summary's `date` is the event's `occurred_at` (the scan's
  `created_at` — Laravel's receipt time, never the informational
  `device_timestamp`) converted to the **school's configured timezone**,
  not UTC — the same timezone-correctness discipline as WP-04-01's cutoff
  helpers, proven by a test asserting an exact date across a UTC/Asia-
  Manila day boundary. A new arrival event only ever touches
  `arrival_event_id` on that day's summary (and a departure only
  `departure_event_id`) — one type's update never clobbers the other's
  already-recorded event for the same day.
- `AttendanceDailySummary` gained sync-feed participation
  (`#[ObservedBy]` → `RecordSyncChange`, registered in the
  `Relation::morphMap()` as `attendance_daily_summary`) — but no guardian
  can see these entries yet. `App\Actions\Sync\ScopeChangesToGuardian`
  (WP-02-06) has no branch for this resource type, so it is invisible by
  default until WP-04-06 (Parent Attendance Sync Contract) adds the
  scoping. `AttendanceEvent` itself is not synced — the daily summary
  already carries what a mobile client needs.

## Arrival, Departure, and Late Detection (WP-04-03)

`ProcessRfidScan` (WP-04-02) now fully resolves event type and lateness
instead of leaving `both`-direction scans unprocessed:

- **First arrival of the day wins.** Once a student's daily summary has an
  `arrival_event_id`, further entry-type scans that day still create their
  own `AttendanceEvent` (so every scan stays traceable via
  `RfidScan::attendanceEvent`), they just don't replace the recorded
  arrival. This is the "duplicate scans are not misclassified" guarantee —
  a repeat tap is still correctly typed as an arrival event, it simply
  isn't the one the summary points to.
- **Most recent departure wins**, unchanged from WP-04-02 — a student who
  leaves and returns can still be re-scanned, and the summary always
  reflects the latest exit.
- **`both`-direction devices toggle deterministically** off the student's
  own day so far, not the device's own history: no arrival recorded yet
  today → this tap is the arrival; an arrival already exists → this tap is
  a departure (repeatedly, for every further tap that day — the same
  "most recent wins" rule `exit`-mode devices use). This is decided inside
  the same `DB::transaction()` that reads the day's summary
  (`lockForUpdate()`), so two near-simultaneous taps on the same
  bidirectional device can't both resolve to "arrival."
- **Lateness is a per-event boolean** (`attendance_events.is_late`), not a
  third `AttendanceEventType` case — computed only for arrival-type events,
  by comparing the scan's `occurred_at` against
  `AttendanceRule::arrivalCutoffFor()` (WP-04-01) in the school's
  configured timezone. A departure event's `is_late` is always `false`. If
  no `AttendanceRule` row exists yet (school not configured), nothing is
  ever flagged late — the same "unconfigured means unchanged, not guessed"
  default WP-04-01's duplicate-window fallback established, rather than
  assuming a cutoff time that was never set.

## Absence Calculation (WP-04-04)

`App\Actions\Attendance\MarkDailyAbsences` marks every active student with
no arrival today as absent, once the school's configured
`absence_cutoff_time` has passed. It's driven by the
`attendance:mark-absences` console command, scheduled to run every 15
minutes (`routes/console.php`) — because the cutoff is a configurable
time-of-day, not a fixed schedule slot, the command runs frequently and the
action itself decides whether "now" is past today's cutoff, making it safe
to run repeatedly.

- **Never marks before cutoff.** If `now()` (in the school's timezone) is
  earlier than `AttendanceRule::absenceCutoffFor(today)`, or today isn't an
  operating day, or no `School`/`SchoolSettings`/`AttendanceRule` is
  configured yet, the action does nothing and returns `0`.
- **Present learners are excluded.** A student with an `arrival_event_id`
  on today's `AttendanceDailySummary` is never touched — absence is
  computed purely from "no arrival yet," matching `absence_cutoff_time`'s
  definition in WP-04-01.
- **Marking is on `attendance_daily_summaries.is_absent`** (new boolean
  column), not a third `AttendanceEventType` — there's no `RfidScan` behind
  an absence for `AttendanceEvent.rfid_scan_id` to reference, so it can't
  be an event the way arrival/departure/late are.
- **A later arrival un-marks absence.** If a student taps in after the
  absence job already ran for the day (late but present), `ProcessRfidScan`
  now clears `is_absent` back to `false` whenever it records an arrival —
  otherwise a genuinely present, late-arriving student would be left
  showing as both absent and arrived.
- **Idempotent**, matching every other write path here: re-running the
  action the same day only touches students not already marked, using the
  same `whereDate()`-based lookup (not an array-matched `updateOrCreate()`)
  WP-04-02 established is required against a `date`-cast column.
- Only `StudentStatus::Active` students are considered — inactive
  (transferred-out/withdrawn) students never accumulate absence records.

## Not Yet Implemented

Corrections (WP-04-05) and the guardian-facing sync contract for
attendance (WP-04-06) are the remaining phase-04 work packages — neither
exists yet. This document will grow as they land.
