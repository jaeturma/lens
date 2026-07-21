# WP-02-04 — Student Administration

## Objective

Build the first admin-facing web UI on the existing Inertia + React +
Wayfinder + Tailwind stack (previously only Fortify auth/settings pages
existed): list/search/filter, create, view, edit, activate, and deactivate
students, restricted to System/School Administrator accounts via a new
`StudentPolicy`. Status changes go through dedicated activate/deactivate
actions, not the edit form — matches WP-02-01's `StudentStatus` being
Active/Inactive only.

## Affected Layers

- [x] Laravel
- [x] Database
- [ ] API
- [ ] Flutter
- [ ] Android
- [ ] RFID Integration

## Scope

- `App\Policies\StudentPolicy` (`viewAny`/`view`/`create`/`update` →
  `$user->isAdministrator()`; no `delete` ability — there is no destroy
  route, matching "activate/deactivate" instead of hard delete).
- `Route::resource('students', StudentController::class)->except('destroy')`
  plus dedicated `PATCH students/{student}/activate` and `.../deactivate`
  routes, all under `auth`+`verified` web middleware, in a new
  `routes/students.php`.
- `App\Http\Controllers\Students\StudentController` (`authorizeResource` in
  the constructor) for index/create/store/show/edit/update, plus
  `ActivateStudentController`/`DeactivateStudentController` (each
  authorizing `update` on the specific student).
- Form Requests: `StoreStudentRequest`, `UpdateStudentRequest` (unique
  `lrn`/`student_number` excluding self on update), `IndexStudentsRequest`
  (validates `q`/`grade`/`section`/`school_year`/`status` filters).
- Every create/update/activate/deactivate calls WP-01-06's
  `RecordAuditLog` with the acting admin as actor — the first real call
  site for that action, per `docs/SECURITY.md`'s existing note that WP-02-04
  would add it. `Student`'s own sync-feed participation (WP-02-01) already
  fires automatically via the model observer; this adds the
  actor-accountability side audit logging exists for, which the sync feed
  does not capture.
- Inertia pages: `resources/js/pages/students/{index,create,edit,show}.tsx`,
  using the existing `Form` component + Wayfinder actions, `Input`/`Label`
  components, and plain native `<select>` for the fixed-choice `sex`
  field and `status` filter (the codebase has no existing example of the
  Radix `Select` component wired into a native-FormData `<Form>`; a native
  `<select>` needs no extra plumbing and is fully equivalent here since
  Male/Female is a 2-option UI). "Students" added to the sidebar nav,
  shown only when `auth.user.role` is an administrator role.
- No photo upload widget — `photo_url` (from WP-02-01) is a plain optional
  URL text field; building real file upload/storage was not asked for and
  would be speculative.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

WP-02-01, WP-01-05.

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

- A guardian-role account is rejected (`403`) from every `students.*`
  route; an administrator can list/search/filter/create/view/edit/
  activate/deactivate.
- Search (`q` against name/LRN/student number) and grade/section/
  school_year/status filters narrow the list correctly; pagination
  preserves the active filters.
- Every mutation produces both an audit log entry (actor) and a
  `sync_changes` entry (already automatic via WP-02-01's observer).
- Tests pass.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes

- `App\Policies\StudentPolicy`: `viewAny`/`view`/`create`/`update` all
  reduce to `$user->isAdministrator()`. No `delete` ability — no destroy
  route exists.
- **Authorization placement fix during implementation**: `authorizeResource()`
  (tried first, matching Laravel's usual resource-controller convention)
  throws `Call to undefined method ...::middleware()` — Laravel 11+ changed
  controller middleware registration and the base `App\Http\Controllers\Controller`
  here only has `AuthorizesRequests` (`$this->authorize()`), not the
  `middleware()` method `authorizeResource()` needs internally. Switched to
  explicit `$this->authorize(...)` calls, matching the codebase's existing
  convention (`MeController`, `Activate/DeactivateStudentController`).
- **Authorization ordering fix**: for `store`/`update`/`index`, a
  `FormRequest`'s own validation runs at dependency-injection time, before
  any code in the controller method body — so an inline `$this->authorize()`
  placed first in the method body still runs *after* validation. An
  unauthorized request with invalid/missing data was getting `422`
  (validation) instead of `403` (authorization), which a test caught. Fixed
  by moving authorization into each `FormRequest::authorize()` (the
  correct, idiomatic place — Laravel evaluates it before `rules()`) using
  `$this->user()?->can(...)`. `create()`/`show()` have no `FormRequest`, so
  they keep inline `$this->authorize()`.
- **`status` default bug**: `Student::create($request->validated())`
  omits `status` (deliberately, per the design decision that status is
  admin-set only via activate/deactivate). The migration's DB-level
  `default('active')` does not populate the in-memory model's `status`
  attribute after insert, so `StudentObserver::payload()` crashed reading
  `$student->status->value` on a null cast. Fixed by explicitly passing
  `'status' => StudentStatus::Active` in `store()` rather than relying on
  the DB default — a test (`an administrator can create a student`) caught
  this before it reached anything resembling production.
- `RecordAuditLog` (WP-01-06) is called in `store`/`update`/
  `Activate/DeactivateStudentController` with the acting admin as actor —
  the action's first real call site, exactly as `docs/SECURITY.md` said
  this package would add. `Student`'s own sync-feed observer (WP-02-01)
  needed no changes; it already fires on every mutation regardless of
  which controller triggers it.
- Frontend: `resources/js/pages/students/{index,create,edit,show}.tsx`
  using the existing `Form` component + generated Wayfinder actions
  (`php artisan wayfinder:generate --with-form` — the default generate
  without `--with-form` does not emit the `.form()` helper the rest of the
  app's pages rely on). Filter/search bar is a GET `<Form>` with
  `preserveState`. `sex`/`status` use a plain native `<select>`, not the
  Radix `Select` component — the latter has no existing example wired into
  a native-FormData `<Form>` in this codebase and would need extra
  plumbing (controlled state + hidden input) for a 2/3-option field with no
  real UX benefit here.
- `edit.tsx`/`show.tsx` breadcrumbs use `setLayoutProps()` (called inside
  the component body) instead of the static `Page.layout = {...}` pattern
  the rest of the app uses (`Dashboard`, `Profile`, `Security`) — those
  pages have breadcrumbs known at module-load time; these need the specific
  `student` prop, which only exists once the component renders.
- `resources/js/types/auth.ts` `User` type gained `role`; new
  `resources/js/types/student.ts` (`Student`, `StudentFilters`,
  `Paginated<T>`). "Students" added to the sidebar nav
  (`resources/js/components/app-sidebar.tsx`), shown only when
  `auth.user.role` is `system_administrator`/`school_administrator` — a
  guardian could still reach the sidebar today since nothing in this
  codebase restricts Fortify web login by role (a pre-existing gap, not
  introduced or fixed here), but they would hit a `403` on every
  `students.*` route regardless of what the sidebar shows.
- Tests: `tests/Feature/Students/StudentAdministrationTest.php` — guardian
  rejected (`403`) from all 8 routes, administrator access (both roles),
  search, each filter, create (success + validation + unique-excluding-self
  on update), view, update, activate/deactivate (with audit log
  assertions), and an audit-metadata-shape check — 12 tests.
- Verification: `vendor/bin/pint` (clean), `vendor/bin/phpstan analyse app`
  (0 errors), full `php artisan test` — 127 passed, 3 pre-existing skips, 0
  failures. Frontend: `tsc --noEmit` (clean), `eslint .` (clean),
  `prettier --check` (clean after `npm run format`), `vite build` (clean).
  Browser extension was not connected in this environment, so the UI was
  **not** visually verified in an actual browser — verification is limited
  to the full server-side HTTP/Inertia response cycle exercised by the Pest
  tests (which did catch two real runtime bugs) plus static/build checks,
  not actual React rendering or client-side interaction. Ran
  `php artisan migrate --force` and `db:seed --force` against the local
  dev SQLite database to attempt a manual smoke test (blocked by the
  browser extension); this is additive/non-destructive but does change
  local dev DB state from before this session.
