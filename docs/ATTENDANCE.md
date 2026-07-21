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

## Not Yet Implemented

Converting a raw scan into an attendance event (WP-04-02), classifying it
as arrival/departure/late (WP-04-03), computing daily absence
(WP-04-04), corrections (WP-04-05), and the guardian-facing sync contract
for attendance (WP-04-06) are all later phase-04 work packages — none of
them exist yet. This document will grow as they land.
