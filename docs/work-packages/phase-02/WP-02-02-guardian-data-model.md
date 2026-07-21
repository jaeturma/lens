# WP-02-02 — Guardian Data Model

## Objective

Create the `guardians` profile table as the domain record layered on top of
the `User` row that already handles login (per WP-01-04's architecture
decision: guardians authenticate as `User` rows, not a separate
Authenticatable model — this package adds the linked profile, not a
competing identity). "School-bound" is already structural: the whole
Laravel install is one school (no `school_id` column needed, matching
`School`/`SchoolSettings`/`User` — multi-school tenancy is explicitly
excluded per `docs/PROJECT-SCOPE.md`).

## Affected Layers

- [x] Laravel
- [x] Database
- [x] API
- [ ] Flutter
- [ ] Android
- [ ] RFID Integration

## Scope

- `guardians` table/model: `user_id` (unique FK to `users`, cascade delete —
  the identity link), `uuid` (stable, immutable sync ID, same pattern as
  `School`/`Student`), `name` and `email` (own contact fields — distinct
  from `User.email`, the login credential; an admin UI will typically keep
  them aligned but nothing enforces that here), `mobile_number`, `status`
  (`App\Enums\GuardianStatus`: Active/Inactive, default Active),
  `notify_attendance` and `notify_announcements` (booleans, default true —
  the two notification-triggering domains per WP-06-02/WP-06-03; not a
  single generic toggle since those are the two concrete preferences
  anything downstream asks for).
- `App\Observers\GuardianObserver`: records `RecordSyncChange`
  (`created`/`updated`/`deleted`) with a full-snapshot payload, same
  pattern as `StudentObserver` (WP-02-01).
- `LoginController` additionally rejects an inactive guardian's login
  (`403`) — enforcing "Active/inactive state is enforced" concretely, the
  same way WP-01-05 enforces the role check. A guardian-role `User` with no
  `Guardian` profile yet (the current state of every existing account,
  since no admin UI creates one until WP-02-05) is unaffected — login does
  not require a profile to exist, only rejects one that explicitly says
  inactive.
- Register `guardian` in the `Relation::morphMap()` added in WP-02-01.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

WP-01-04.

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

- `user_id` is unique (one profile per account); `uuid` is immutable.
- An inactive guardian's login is rejected with `403`; an account with no
  profile yet still logs in (no regression to existing behavior).
- Every create/update/delete produces a `sync_changes` entry with
  `resource_type` `guardian`.
- Tests pass.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes

- `guardians` migration (`2026_07_21_090000_create_guardians_table.php`):
  `user_id` (`foreignId->unique()->constrained()->cascadeOnDelete()` — one
  profile per account, deleted with the account), `uuid` (unique), `name`,
  `email`, `mobile_number`, `status` (default `active`, indexed),
  `notify_attendance`/`notify_announcements` (booleans, default `true`),
  normal `timestamps()`.
- Judgment call on `name`/`email`: the scope text lists them as literal
  fields (same treatment as WP-02-01's field list), so `Guardian` has its
  own copy rather than reading through `user->email`. This does create two
  places an email could theoretically diverge; documented here rather than
  silently assumed, since nothing in scope asked for a sync mechanism
  between them and the future admin UI (WP-02-05) is expected to just set
  both at once.
- `App\Models\Guardian`: `uuid` generated/immutable via the same
  `booted()` pattern as `School`/`Student`. `App\Observers\GuardianObserver`
  registered via `#[ObservedBy]`, same shape as `StudentObserver`
  (WP-02-01) — full-snapshot payload on every create/update/delete.
- No `school_id` column — "school-bound" is already structural (one
  Laravel install = one school, no model in this codebase has an explicit
  school FK; adding one would be the multi-tenancy `docs/PROJECT-SCOPE.md`
  explicitly excludes).
- `App\Models\User::guardian()` (`HasOne`) added. `LoginController` now
  additionally rejects `403` when `$user->guardian?->status ===
  GuardianStatus::Inactive`; a guardian-role `User` with no profile at all
  is unaffected (`$user->guardian` is `null`, condition short-circuits) —
  verified by a dedicated regression test plus every pre-existing login
  test (which create bare `User::factory()` accounts) continuing to pass
  unmodified.
- Registered `'guardian' => Guardian::class` in the `Relation::morphMap()`
  from WP-02-01.
- Tests: `tests/Feature/Models/GuardianTest.php` (uuid generated/immutable,
  status cast, `user_id` uniqueness, the `User::guardian()` relation),
  `tests/Feature/Observers/GuardianObserverTest.php` (create/update/delete
  record the right `SyncChangeAction` with a snapshot payload), three new
  cases in `MobileLoginTest.php` (no-profile still logs in, inactive
  rejected `403`, active with a profile logs in) — 11 new tests.
- `docs/api/AUTHENTICATION.md` documents the new `403` failure case.
  `docs/api/SYNC.md` documents the `guardian` payload shape and the
  `name`/`email` duplication decision.
- Verification: `vendor/bin/pint` (clean), `vendor/bin/phpstan analyse app`
  (0 errors), full `php artisan test` — 107 passed, 3 pre-existing skips, 0
  failures (no regression).
