# WP-02-05 — Guardian and Link Administration

## Objective

Extend the admin web UI (Inertia + React, same stack and conventions as
WP-02-04) to guardian accounts and their student links: since guardians
have no self-registration (per `docs/PROJECT-SCOPE.md`, mobile only has
"parent login," never sign-up), an administrator creates the `User` +
`Guardian` pair together. Link management (add/revoke) is embedded in the
guardian's own show page rather than a separate module, since a link only
ever makes sense in the context of one specific guardian.

## Affected Layers

- [x] Laravel
- [x] Database
- [ ] API
- [ ] Flutter
- [ ] Android
- [ ] RFID Integration

## Scope

- `App\Policies\GuardianPolicy` (`viewAny`/`view`/`create`/`update` →
  `isAdministrator()`, no `delete` — matches `StudentPolicy`). Managing a
  guardian's links is authorized against the guardian itself (`update`),
  not a separate link policy — there is no link management outside the
  context of a specific guardian.
- `Route::resource('guardians', GuardianController::class)->except('destroy')`
  plus `PATCH guardians/{guardian}/activate`/`deactivate`
  (`Guardian`'s own status, same pattern as `Student`'s), `POST
  guardians/{guardian}/links` (add/reactivate a link), and `PATCH
  guardians/{guardian}/links/{link}/revoke`.
- `store` creates the `User` (role `guardian`) and `Guardian` profile
  together in one `DB::transaction()` — the create form collects one
  `name`/`email`/`password` (becomes both the login credential and the
  guardian's own contact fields) plus `mobile_number`. `edit`/`update`
  only ever touch `Guardian`'s own `name`/`email`/`mobile_number`/
  notification preferences, never `User`'s login credentials — resetting a
  guardian's password is a separate, more sensitive concern not asked for
  here.
- Adding a link for a `(guardian, student)` pair that already has a
  **revoked** row reactivates that row (updates it back to `active` with
  the newly submitted relationship/preference fields) rather than
  inserting a second row, per WP-02-03's one-row-per-pair design. Adding a
  link for a pair that is already **active** is rejected as a validation
  error, not a raw unique-constraint `QueryException`.
- Every mutation (guardian create/update/activate/deactivate, link
  create/reactivate/revoke) calls `RecordAuditLog` with the acting admin,
  same as WP-02-04.
- Frontend: `resources/js/pages/guardians/{index,create,edit,show}.tsx`.
  `show.tsx` includes a "Linked students" section: existing links (with a
  Revoke action) and a form to add one, listing active students by
  name/LRN (no search/pagination on that picker — acceptable at the scale
  a single school's roster implies; a searchable picker would be a
  reasonable future improvement, not required by this WP's acceptance
  criteria). "Guardians" added to the sidebar nav alongside "Students".

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

WP-02-02, WP-02-03.

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

- A guardian-role account is rejected (`403`) from every `guardians.*`
  route; an administrator can list/search/filter/create/view/edit/
  activate/deactivate guardians and add/revoke their links.
- A duplicate active link is rejected as a validation error; revoking and
  re-adding a link reuses the same row (no second row for the same pair).
- Every mutation is audit-logged with the acting admin.
- Tests pass.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes

- `App\Policies\GuardianPolicy`: same shape as `StudentPolicy` (WP-02-04).
  Link management authorizes against the parent `Guardian` (`update`
  ability) — no separate link policy.
- `GuardianController::store()` creates `User` (role `guardian`) and
  `Guardian` in one `DB::transaction()`. Reused
  `App\Concerns\ProfileValidationRules`/`PasswordValidationRules` (already
  used by Fortify's `CreateNewUser` and the settings controllers) for
  `name`/`email`/`password` rules rather than re-writing them — the
  `email` uniqueness check there is against `users`, correctly guarding the
  login credential.
- `edit`/`update` intentionally never touch `User` — only `Guardian`'s own
  `name`/`email`/`mobile_number`/notification preferences. Resetting a
  guardian's password is a separate, more sensitive concern not asked for
  here.
- Applied both WP-02-04 lessons directly this time: authorization lives in
  each `FormRequest::authorize()` (`store`/`update`/`index`/link-store), not
  an inline controller-body call that would run after validation; and
  `GuardianController::store()` explicitly sets `'status' =>
  GuardianStatus::Active}` rather than relying on the migration's DB-level
  default (same in-memory-model gap that broke `StudentObserver` in
  WP-02-04 — `Guardian`'s status column has the identical default pattern,
  so this would have reproduced the exact same bug).
- Link lifecycle: `StoreGuardianStudentLinkController` looks up an existing
  `(guardian, student)` row first. Active → `ValidationException` (`422`,
  not a raw unique-constraint `QueryException`). Revoked → `update()`s the
  same row back to `active` with the newly submitted fields. Neither →
  `create()`s a new row. `RevokeGuardianStudentLinkController` checks
  `$link->guardian_id === $guardian->id` and 404s otherwise, so a link ID
  can't be revoked through the wrong guardian's URL.
- `GuardianController::show()` passes `links` (with `student` eager-loaded)
  and `linkableStudents` (all students, id/name/lrn only) as separate
  props — the "add link" picker has no search/pagination, acceptable at a
  single school's roster scale; a searchable/paginated picker would be a
  reasonable future improvement but isn't required by this WP's acceptance
  criteria.
- Every mutation calls `RecordAuditLog` with the acting admin:
  `guardian.created`/`updated`/`activated`/`deactivated`,
  `guardian_student_link.created` (covers both new links and
  reactivations), `guardian_student_link.revoked`.
- Frontend: `resources/js/pages/guardians/{index,create,edit,show}.tsx`,
  same conventions as `students/*` (WP-02-04): `Form` + Wayfinder
  `.form()`, native `<select>` for `relationship_type` (same reasoning as
  `sex`/`status` in WP-02-04 — no existing Radix-`Select`-in-`Form`
  pattern to build on), `Checkbox` for the two boolean toggles (this one
  *is* an established pattern — `resources/js/pages/auth/login.tsx`'s
  "Remember me" checkbox already renders a Radix `Checkbox` with a `name`
  prop inside a `Form`, since Radix's checkbox includes a hidden native
  input for exactly this). `show.tsx` embeds the links table and add-link
  form directly rather than a separate page — a link only exists in the
  context of one guardian. "Guardians" added to the sidebar nav next to
  "Students".
- Tests: `tests/Feature/Guardians/GuardianAdministrationTest.php` —
  guardian rejected (`403`) from all 10 routes, index/search/filter,
  create (success + validation + unique email), view with links, update
  (including a notification-preference toggle), activate/deactivate,
  link create, duplicate-active-link rejected, revoke-then-relink reuses
  the same row, revoke, and cross-guardian revoke returns `404` — 12
  tests.
- Verification: `vendor/bin/pint` (clean), `vendor/bin/phpstan analyse app`
  (0 errors), full `php artisan test` — 139 passed, 3 pre-existing skips, 0
  failures. Frontend: `tsc --noEmit`, `eslint .`, `prettier --check`
  (clean after `npm run format`), `vite build` — all clean. Same browser-
  verification caveat as WP-02-04: the Chrome extension was not connected
  in this environment, so the UI was not visually confirmed in an actual
  browser.
