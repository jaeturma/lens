# WP-02-06 — Guardian Profile and Linked Children API

## Objective

Extend WP-01-08's bootstrap/incremental-sync endpoints with the two things
that didn't exist until this phase: the guardian's own profile (`Guardian`,
not just `User`) and their active linked children, and — since real
guardian-owned resources now exist (WP-02-01/02/03) — implement the
guardian-scoped resource authorization for incremental sync that
`docs/api/SYNC.md` explicitly deferred ("there is nothing to scope yet").
`Affected Layers` checks Flutter because the contract is *for* Flutter to
consume, not because this package writes Dart: `mobile/lib/` currently has
only the WP-07-01 identity/theme/routing shell (no login, no SQLite/Drift,
no sync engine — those are WP-07-02/06/08), so there is no local repository
to wire up yet. Actual Flutter consumption is WP-07-08/07-09, later.

## Affected Layers

- [x] Laravel
- [ ] Database
- [x] API
- [x] Flutter
- [ ] Android
- [ ] RFID Integration

## Scope

- `App\Http\Resources\V1\GuardianResource` (`uuid`, `name`, `email`,
  `mobile_number`, `status`, notification preferences) and
  `LinkedStudentResource` (flattened: the linked `Student`'s own fields
  plus that link's `relationship_type`/`is_primary_contact` — matches
  `docs/OFFLINE-SYNC.md`'s Local Resources treating "linked students" as
  one flat local concept, not two joined tables). `BootstrapResource`
  gains `guardian` (nullable — a guardian-role `User` with no `Guardian`
  profile yet, same backward-compatible case WP-02-02/04/05 already
  handle, gets `null`) and `children` (`Guardian::activeLinks()`, empty
  when there is no profile).
- `App\Actions\Sync\ScopeChangesToGuardian`: filters a page of
  `SyncChange` to what one guardian may see. `school` changes are visible
  to everyone (install-wide, not guardian-owned). `student` changes are
  visible only if the student is in the guardian's **currently active**
  linked set. `guardian` changes only for their own record.
  `guardian_student_link` changes for links they **own regardless of
  current status** — this is deliberate, not an inconsistency: the
  revoked-link entry is exactly what tells the client to drop a student
  locally, so scoping that by "currently active" would hide the one event
  that needs to reach the client. Any resource type not listed here is
  denied by default (opt-in, not opt-out) — a future work package that
  adds a new synchronized resource type must add a branch here, or its
  entries are silently invisible to guardians rather than accidentally
  leaked.
- Applied as a post-filter in `ChangesController` after
  `FetchSyncChanges`, not inside WP-01-07's action itself — keeps that
  action generic/resource-agnostic. Means a returned page can contain
  fewer than `limit` entries even when more exist; `next_cursor`/
  `has_more` still reflect the true underlying feed position, so
  continued polling converges correctly (documented in `docs/api/SYNC.md`).

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

WP-02-03, WP-01-08.

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

- `bootstrap.children` contains only actively linked students, never
  revoked ones.
- `sync.changes` never contains another guardian's `student`/`guardian`
  entries; a guardian always sees their own `guardian_student_link`
  entries including revocations, even after the link is no longer active.
- Every returned student/guardian/link entry carries its stable `uuid`.
- Tests pass.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes

- `App\Http\Resources\V1\GuardianResource` and `LinkedStudentResource`
  added. `LinkedStudentResource` wraps a `GuardianStudentLink` (with
  `student` eager-loaded) and flattens the student's own fields alongside
  `relationship_type`/`is_primary_contact` — one flat shape for the
  client's local "linked students" concept, not a nested
  `{link: {...}, student: {...}}` structure.
- `BootstrapResource` gained `guardian` (nullable) and `children`
  (`LinkedStudentResource::collection`). `BootstrapController` resolves
  `$user->guardian` and, when present, `$guardian->activeLinks()->with('student')->get()`;
  when absent, an empty `Collection` — no new query branches needed beyond
  the existing null-guardian handling pattern from WP-02-02/04/05.
- `App\Actions\Sync\ScopeChangesToGuardian`: the core new piece.
  Deliberately **not** merged into `FetchSyncChanges` (WP-01-07) — that
  action stays generic/resource-agnostic; this one is guardian-specific
  business logic layered on top in `ChangesController`. Preloads the
  guardian's active student IDs and owned link IDs once per request
  (`pluck()`, not N+1 per change) before filtering the in-memory page.
  `student` scoping uses **current** active-link status; `guardian_student_link`
  scoping uses **ownership regardless of status** — these are
  intentionally different rules for a reason documented inline and in
  `docs/api/SYNC.md`: filtering the link's own revoke event by "currently
  active" would hide the one entry that tells the client to remove a
  student. Unknown/future `resource_type`s are denied by default
  (opt-in) rather than passed through, so a future work package that adds
  a synchronized resource without updating this action fails safe
  (invisible) rather than leaking.
- Confirmed no changes were needed to WP-01-07's `FetchSyncChanges` or its
  tests — the layering held up exactly as designed back then.
- Tests: `tests/Feature/Actions/Sync/ScopeChangesToGuardianTest.php` (all
  four resource-type branches, the ownership-vs-active-status distinction
  for links specifically, a no-profile guardian seeing nothing but school
  changes, and the unknown-type default-deny), extended
  `tests/Feature/Api/V1/Sync/BootstrapTest.php` (`guardian`/`children`
  null/empty with no profile; populated with only active children when a
  profile and mixed active/revoked links exist) and `ChangesTest.php`
  (end-to-end: only the guardian's own active-linked student's changes
  come back; a revoked link's own `revoked` entry still comes back) — 12
  new tests. The two new `ChangesTest` cases needed a cursor captured
  *after* test setup, since creating the `Guardian`/`Student`/
  `GuardianStudentLink` fixtures themselves fires their observers
  (WP-02-01/02/03) and produces additional, correctly-visible sync
  entries that would otherwise contaminate the count — not a bug, a test
  design detail worth flagging for whoever writes the next sync test.
- `docs/api/SYNC.md`: documented the new bootstrap fields, added a
  "Guardian-Scoped Authorization" section explaining the filtering rules
  and the limit/has_more interaction with post-pagination filtering,
  removed the now-resolved "Not Yet Implemented" note about scoping (it
  now names what's still actually missing: attendance/announcement/
  notification resource types).
- Verification: `vendor/bin/pint` (clean), `vendor/bin/phpstan analyse app`
  (0 errors), full `php artisan test` — 151 passed, 3 pre-existing skips, 0
  failures (no regression, including WP-01-07/01-08's existing sync tests
  after this change).
