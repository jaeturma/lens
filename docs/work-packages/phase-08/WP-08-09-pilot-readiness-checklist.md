# WP-08-09 — Pilot Readiness Checklist

## Objective

Produce final go/no-go checklist for one participating school.

## Affected Layers

- [x] Laravel
- [ ] Database
- [x] API
- [x] Flutter
- [x] Android
- [x] RFID Integration

## Scope

Cover school setup, accounts, cards, devices, attendance rules, sync, privacy, support, backup, and limitations.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

WP-08-01 through WP-08-08.

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

- Checklist is complete.
- Known limitations are explicit.
- Go/no-go criteria are clear.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes

Pure documentation — no application code changes. Synthesizes WP-08-01
through WP-08-08 (this session's own work, not re-derived from
scratch) plus one new finding surfaced while writing it. Deliverable:
`docs/PILOT-READINESS.md`.

### The One New Finding: No Admin UI for School/AttendanceRule Setup

Checking how a real pilot school's `School`/`SchoolSettings`/`AttendanceRule`
rows would actually get created surfaced that **no admin UI or artisan
command exists for either** — `database/seeders/DatabaseSeeder.php`
seeds only a fixed dummy System Administrator, nothing else. Every other
operational area (students, guardians, RFID devices/cards, attendance
corrections, announcements) already has a full admin UI; only these two
one-time-per-school setup steps don't. Documented as a checklist item
with the exact `tinker` commands needed (Sections 1–2 of
`docs/PILOT-READINESS.md`) rather than built now — a full setup UI is
out of this package's narrow "produce a checklist" scope, and a single
manual step for a one-school pilot is a reasonable, explicit limitation
rather than a defect to fix under this WP.

The `SchoolSettings::create([...])` snippet initially drafted was wrong
— `school_id` is deliberately not in `SchoolSettings`'s own `Fillable`
list (`app/Models/SchoolSettings.php`), so it must be created via
`$school->settings()->create([...])` (the `HasOne` relation) instead.
Caught by actually running the exact snippet in a throwaway Pest test
before leaving it in the checklist (removed afterward) — the corrected
version is verified working, not just written and assumed correct.

### Acceptance Criteria

- **Checklist is complete**: covers every area this package's own Scope
  line names — school setup, accounts, cards, devices, attendance rules,
  sync, privacy, support, backup — each with checked (verified, cites
  the specific test/prior WP) or unchecked (concrete required action or
  explicit blocker, never a vague TODO) items.
- **Known limitations are explicit**: `docs/PILOT-READINESS.md` Section 9
  gathers every limitation surfaced across the whole phase into one place
  (no setup UI, no self-registration, no in-app deletion, no real-device
  verification performed, no icon/screenshots/hosted privacy
  policy/Firebase/keystore, health check is liveness-only, single queue
  worker assumed).
- **Go/no-go criteria are clear**: `docs/PILOT-READINESS.md` Go/No-Go
  Criteria — six concrete Go conditions, explicit No-Go triggers, and a
  distinction between a private (sideloaded) pilot and a public Play
  Store listing, since several blockers (icon, screenshots, hosted
  privacy policy) apply only to the latter.

Verified: full Pest suite passing (403/406, 3 pre-existing skips
unrelated), re-confirmed after removing the verification probe test. No
`vendor/bin/pint`/`phpstan` diff — no application PHP files were changed
by this package (only the throwaway probe, added and removed within this
session, never committed).

No migrations. No new/changed API contract. This closes out phase 8
(WP-08-01 through WP-08-09, all complete).
