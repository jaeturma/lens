# WP-02-03 — Student Guardian Relationships

## Objective

Create the `guardian_student` link table connecting `Student` (WP-02-01)
and `Guardian` (WP-02-02) records, with its own sync participation. This is
the data model and relationship mechanics only — no admin UI to create
links (WP-02-05) or guardian-facing endpoint that reads them (WP-02-06)
exists yet.

## Affected Layers

- [x] Laravel
- [x] Database
- [x] API
- [ ] Flutter
- [ ] Android
- [ ] RFID Integration

## Scope

- `guardian_student` table/model (`App\Models\GuardianStudentLink`,
  a first-class model, not a bare pivot — it has its own `uuid` and sync
  participation): `student_id`/`guardian_id` (FKs, unique together — see
  below), `relationship_type` (`App\Enums\GuardianRelationshipType`:
  Mother/Father/Guardian/Other), `is_primary_contact` (boolean),
  `status` (`App\Enums\GuardianStudentLinkStatus`: Active/Revoked, default
  Active — the "access status" bullet), `notifications_enabled` (boolean,
  default true — a per-link override distinct from `Guardian`'s own
  `notify_attendance`/`notify_announcements`, which are global across all
  of a guardian's children; this lets one specific link be muted without
  touching the guardian's overall preferences).
- Unique index on `(student_id, guardian_id)` — one row per pair, ever.
  Re-linking after a revocation updates that row's `status` back to Active
  rather than inserting a second row; this is what makes "duplicate active
  links are prevented" true unconditionally, without needing a
  conditional/partial unique index.
- `App\Observers\GuardianStudentLinkObserver`: records `RecordSyncChange`
  on create/update/delete, same pattern as WP-02-01/02 — except an update
  that changes `status` to Revoked records `SyncChangeAction::Revoked`
  (not `Updated`), the first real use of that action case.
- `Guardian::activeLinks()`/`Student::activeLinks()` relations (scoped to
  `status = Active`) for WP-02-06 to build on — "guardians access only
  active links" is a query-scoping mechanism now, consumed by an endpoint
  later, matching how WP-01-07's change feed was built before WP-01-08
  exposed it.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

WP-02-01, WP-02-02.

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

- A `(student_id, guardian_id)` pair cannot have more than one link row.
- Revoking a link records a `Revoked` sync change; other field changes
  record `Updated`.
- `Guardian::activeLinks()`/`Student::activeLinks()` exclude revoked links.
- Tests pass.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes

- `guardian_student` migration
  (`2026_07_21_100000_create_guardian_student_table.php`): `uuid` (unique),
  `student_id`/`guardian_id` (FKs, `cascadeOnDelete`), `relationship_type`,
  `is_primary_contact` (boolean), `status` (default `active`, indexed),
  `notifications_enabled` (boolean, default `true`), `timestamps()`. Unique
  index on `(student_id, guardian_id)` — deliberately unconditional (not a
  partial/conditional index limited to active rows), since MySQL doesn't
  support partial unique indexes cleanly; one row per pair for the whole
  relationship lifetime is simpler and still exactly satisfies "duplicate
  active links are prevented."
- `App\Models\GuardianStudentLink`: explicit `protected $table =
  'guardian_student'` (Eloquent's default pluralization of the class name
  would not produce this table name), `uuid` generated/immutable via the
  same pattern as `School`/`Student`/`Guardian`, plain `belongsTo` on both
  sides rather than a `belongsToMany` pivot — matches this codebase's
  existing relation style (no `belongsToMany` used anywhere yet) and lets
  the link have its own `uuid`/sync participation without the extra
  complexity of a custom Pivot subclass.
- `App\Observers\GuardianStudentLinkObserver`: `created`/`deleted` record
  `Created`/`Deleted` as usual; `updated` checks
  `$link->wasChanged('status') && $link->status ===
  GuardianStudentLinkStatus::Revoked` and records `SyncChangeAction::Revoked`
  instead of `Updated` in that case — the first real use of the `Revoked`
  case defined back in WP-01-07.
- `Guardian::links()`/`activeLinks()` and `Student::links()`/`activeLinks()`
  added (`HasMany`, the latter scoped to `status = Active`) — infrastructure
  for WP-02-06 to build the guardian-facing "linked children" endpoint on;
  no such endpoint exists yet, matching the pattern from WP-01-07
  (change-feed mechanism before WP-01-08 exposed it).
- Registered `'guardian_student_link' => GuardianStudentLink::class` in the
  `Relation::morphMap()`.
- Tests: `tests/Feature/Models/GuardianStudentLinkTest.php` (uuid
  generated/immutable, unique pair constraint, `activeLinks()` excludes
  revoked), `tests/Feature/Observers/GuardianStudentLinkObserverTest.php`
  (create/delete/non-status-update record the expected action; a status
  change to Revoked records `Revoked` specifically) — 8 new tests.
- `docs/api/SYNC.md` documents the `guardian_student_link` payload shape
  and the revoke-records-`Revoked` behavior.
- Verification: `vendor/bin/pint` (clean), `vendor/bin/phpstan analyse app`
  (0 errors), full `php artisan test` — 115 passed, 3 pre-existing skips, 0
  failures (no regression).
