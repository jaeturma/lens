# WP-02-01 — Student Data Model

## Objective

Create the `students` table and model as the record every later phase-02+
work package (administration, guardian links, attendance, the guardian
mobile API) builds on, and wire it into WP-01-07's change feed so every
create/update/delete is synchronizable from the moment the model exists —
this package adds no admin UI (WP-02-04) or guardian-facing endpoint
(WP-02-06), only the data model and its sync participation.

## Affected Layers

- [x] Laravel
- [x] Database
- [x] API
- [ ] Flutter
- [ ] Android
- [ ] RFID Integration

## Scope

- `students` table/model: `uuid` (stable, immutable sync ID, same pattern as
  `School`), `lrn` (unique, max 12 chars), `student_number` (unique),
  `name`, `sex` (`App\Enums\StudentSex`: Male/Female), `grade`, `section`,
  `school_year` (free-text strings — DepEd grade/section/school-year labels
  vary too much to enumerate here without inventing a taxonomy nothing
  asked for), `status` (`App\Enums\StudentStatus`: Active/Inactive, default
  Active — matches WP-02-04's future "activate/deactivate", not a broader
  lifecycle), `photo_url` (nullable).
- `App\Observers\StudentObserver`: records a `RecordSyncChange` entry
  (`created`/`updated`/`deleted`) with a full-snapshot payload, registered
  via `#[ObservedBy]` on the model — so sync participation exists from this
  package, not deferred to whichever later package happens to remember to
  call it.
- Register a `Relation::morphMap()` (`student` => `Student`, plus `school`
  => `School`, already used as a stand-in target in WP-01-06/07 tests) so
  `sync_changes.resource_type`/`audit_logs.target_type` are stable short
  names instead of leaking `App\Models\*` class names into the documented
  API contract.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

Phase 1.

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

- `lrn`/`student_number` are unique; `status` is indexed; `uuid` is
  immutable once set.
- Every create/update/delete produces a `sync_changes` entry with
  `resource_type` `student`.
- `sync_changes.resource_type`/`audit_logs.target_type` use the morph-map
  alias, not the PHP class name.
- Tests pass.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes

- `students` migration (`2026_07_21_080000_create_students_table.php`):
  `uuid` (unique), `lrn` (`string(12)`, unique), `student_number`
  (`string(50)`, unique), `name`, `sex`, `grade`, `section`, `school_year`
  (plain strings — DepEd grade/section/school-year labels vary too much to
  enumerate without inventing an unrequested taxonomy), `status` (default
  `active`, indexed per the backend rule on frequently-filtered status
  columns), `photo_url` (nullable), normal `timestamps()` (unlike
  `audit_logs`/`sync_changes`, a student is a mutable entity, not a log).
- `App\Models\Student`: `uuid` generated on create and immutable thereafter
  (`booted()` `creating`/`updating` hooks), mirroring `School`'s existing
  pattern exactly. `sex`/`status` cast to `App\Enums\StudentSex` /
  `StudentStatus` (Active/Inactive only — matches WP-02-04's future
  "activate/deactivate," not a broader graduated/transferred lifecycle
  nothing has asked for yet).
- `App\Observers\StudentObserver`, registered via `#[ObservedBy]` on the
  model (matching the codebase's existing attribute-based model
  configuration style — `#[Fillable]`, `#[Hidden]` — rather than manual
  registration in a service provider): calls WP-01-07's `RecordSyncChange`
  on `created`/`updated`/`deleted` with a full-snapshot payload. This is
  the one place in the codebase so far where sync recording is automatic
  rather than an explicit call site (WP-01-06/07's audit/sync actions were
  deliberately left for callers to invoke) — justified here because this
  WP's own acceptance criteria requires "changes enter the sync feed" to
  hold from the moment the model exists, before any admin UI (WP-02-04)
  exists to remember to call it.
- Registered `Relation::morphMap(['school' => School::class, 'student' =>
  Student::class])` in `AppServiceProvider::boot()`. Before this,
  `sync_changes.resource_type`/`audit_logs.target_type` would have leaked
  `App\Models\School`/`App\Models\Student` (the Eloquent default) into the
  documented API contract; `docs/api/SYNC.md`'s own example already showed
  a short alias like `student`, so this was needed for the contract to be
  honest, not just for `Student`. `School` is included because WP-01-06/07
  tests already use it as a stand-in target — `morphMap()` (not
  `enforceMorphMap()`) so this is additive and cannot break anything using
  an unmapped model.
- Tests: `tests/Feature/Models/StudentTest.php` (uuid generated/immutable,
  enum casts, `lrn`/`student_number` uniqueness),
  `tests/Feature/Observers/StudentObserverTest.php` (create/update/delete
  each record the right `SyncChangeAction` with a snapshot payload
  reflecting current state) — 7 new tests.
- `docs/api/SYNC.md` gained a "Synchronized Resources" section documenting
  the `student` payload shape and replaced the earlier illustrative
  `announcement` example (a resource that doesn't exist yet) with a real
  `student` one now that one exists.
- Verification: `vendor/bin/pint` (clean), `vendor/bin/phpstan analyse app`
  (0 errors), full `php artisan test` — 96 passed, 3 pre-existing skips, 0
  failures (no regression, including WP-01-06/07's tests after the morph
  map change).
