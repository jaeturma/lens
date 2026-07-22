# WP-07-08 — Incremental Sync Engine

## Objective

Implement cursor-based sync into one SQLite transaction.

## Affected Layers

- [ ] Laravel
- [ ] Database
- [x] API
- [x] Flutter
- [ ] Android
- [ ] RFID Integration

## Scope

Support startup, resume, pull-to-refresh, push signal, pagination, retries, tombstones, corrections, and cursor commit safety.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

WP-01-08, WP-07-02, WP-07-07.

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

- Cursor advances only after commit.
- Failed sync keeps previous cursor.
- All change types apply locally.
- Tests cover interruption and retry.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes

**Corrected by WP-07-09**: `GuardianStudentLinks` as originally built here was
keyed by the link's own `uuid`, with `studentServerId` as a required
`NOT NULL` column. Bootstrap's `children[]` (the *only* place a guardian's
linked students first enter local storage — WP-07-09) gives no link-level
uuid and no numeric student id at all, only the student's own `uuid` plus
the relationship fields flattened onto it — a row from bootstrap couldn't
have been written against that schema. Re-keyed by `studentUuid` (both
`uuid` and `studentServerId` now nullable, backfilled once an actual
`guardian_student_link`-type sync entry supplies them); `SyncChangeApplier`
now resolves `studentUuid` from the payload's numeric `student_id` for the
create/update path too, not just revoke. See `tables.dart` and
`WP-07-09-offline-home-and-linked-children.md` for the current shape — this
section is left as a historical record of what shipped in this WP's own
session, not the shape actually in the codebase today.

Researched the actual current Laravel code (not just `docs/api/SYNC.md`,
which is stale in two respects — see below) before writing anything, since
getting a payload shape or action mapping wrong here silently corrupts
local data with no server-side signal that anything went wrong:

- `guardian_notification` **is** fully wired server-side (observer, morph
  map, `ScopeChangesToGuardian` branch) — the doc's "Not Yet Implemented"
  section is outdated.
- `school` has a morph-map alias and a `ScopeChangesToGuardian` branch, but
  **no observer exists** — it never produces a real entry today. The
  applier ignores unrecognized/not-yet-relevant resource types as a no-op
  rather than erroring, so this (or any future resource type an older
  client doesn't understand yet) can't break a sync run.

**Schema correction** (`mobile/lib/core/database/tables.dart`): WP-07-02
flattened `guardian_student_link` fields into `Students`, matching
bootstrap's `LinkedStudentResource` shape. But a `student`-type sync entry
carries none of those fields, so upserting one alone would either violate
`Students`' `NOT NULL` columns or silently keep stale link data. Split into
two tables — `Students` (exactly the `student` payload) and new
`GuardianStudentLinks` (exactly the `guardian_student_link` payload) —
mirroring the server's own two independent resource types. `schemaVersion`
stays `1`: this project is pre-release with no shipped installs to
migrate. `docs/DATABASE.md` updated to list the new table.

**`SyncChangeApplier`** (`features/sync/data/`) — one branch per resource
type, all "all change types apply locally":

- `guardian`/`guardian_notification`: straightforward upsert-by-uuid or
  delete-by-uuid.
- `student`: upserts with `serverId = resourceId` (the envelope's own id).
  `deleted` also cleans up the student's attendance and link rows.
- `guardian_student_link`: keyed by `student_id` (numeric, not `uuid` —
  resolved via `Students.findUuidByServerId`). `revoked`/hard `deleted`
  removes the student, their attendance, and the link itself — per
  `docs/api/SYNC.md`, a revoked link "is exactly what tells the client to
  remove a student locally," not just the link record.
- `attendance_daily_summary`: same `student_id` resolution, upserts by
  `(studentUuid, date)`. If the student isn't known locally yet, the entry
  is **skipped, not failed** — reasoned through, not just hoped: a
  student's own creation is always recorded before any link/attendance
  entry that could reference it (one can't exist without the other), and
  the feed is walked in strict ascending order, so in practice the
  referenced student is always already applied by the time a dependent
  entry is reached. `corrected` is applied identically to `updated`.
- `announcement`: `revoked`/`expired` delete the local row (tombstone —
  "removes its local copy... not hidden but kept," same as a link
  revocation); everything else upserts.

**`SyncEngine`** (`features/sync/application/`): loops
`GET /sync/changes` while `has_more`, applying each page's entries and
saving its `next_cursor` **in the same transaction** — "cursor advances
only after commit" and "failed sync keeps previous cursor" both fall out
of this for free, since a request or transaction failure leaves nothing
after it to run, and the two writes can never end up out of step with
each other. Extended `BootstrapRepository` (WP-07-05/06) to persist the
bootstrap response's own `next_cursor`, so the engine has a real starting
point after login rather than needing `SyncCursor::initial()`'s literal
encoding (`"MA=="`, kept only as a defensive fallback).

**Triggers wired**: "startup" (`startupSyncProvider`, fires once when the
authenticated screen first renders) and "pull-to-refresh" (a
`RefreshIndicator` on the placeholder `FoundationPage`, standing in until
WP-07-09 builds the real home screen). **Not wired**: "resume" (bolting
app-lifecycle plumbing onto a placeholder screen that WP-07-09 will
replace felt like the wrong place to commit to that UX) and "push signal"
(WP-07-13's own job — needs FCM listener setup, out of this package's
scope). `syncEngineProvider` is ready for both to call.

**Test-suite side effect**: `FoundationPage` now fires a sync on every
build, which would otherwise hit the real (unmocked in tests) network and
hang for a full connect-timeout in every existing test that renders it.
Added `NoOpSyncApi` to the shared test harness and overrode
`syncApiProvider` with it in the five pre-existing test files affected
(WP-07-03/05/06/07's gate/login/logout flow tests) — not a functional
regression, just a test-isolation gap the new trigger exposed, same
pattern as the `sessionControllerProvider` fakes WP-07-06 needed.

Tests: `sync_change_applier_test.dart` (one group per resource type —
upsert, delete/tombstone, the student-not-yet-known skip, the
guardian-student-link revoke cascade, unrecognized-type no-op);
`sync_engine_test.dart` (single page; multi-page pagination requesting
each page's own cursor next; starting from a previously saved cursor;
a mid-pagination failure keeping the prior committed cursor; retrying
after that failure resuming from it, not from the beginning).

Verification: `flutter analyze` clean, `dart format` applied, `flutter
test` — 62/62 passing.
