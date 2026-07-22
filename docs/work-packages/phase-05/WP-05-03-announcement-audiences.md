# WP-05-03 — Announcement Audiences

## Objective

Target all guardians, grade, section, or selected student guardians.

## Affected Layers

- [x] Laravel
- [x] Database
- [x] API
- [ ] Flutter
- [ ] Android
- [ ] RFID Integration

## Scope

Resolve audiences without campaign-level complexity.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

WP-05-01, Phase 2.

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

- Each audience type is tested.
- Guardians see only matching announcements.
- Revoked links stop future access.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes

- Two migrations: `announcements` gained `audience_type` (string, default
  `all`), `audience_grade`/`audience_section` (nullable strings); new
  `announcement_student` pivot table (`announcement_id`/`student_id`,
  both `cascadeOnDelete`, unique pair).
- `App\Enums\AnnouncementAudienceType` (`All`/`Grade`/`Section`/
  `Students`); `Announcement` gained the cast, a `students(): BelongsToMany`
  relation, and defaults `audience_type` to `All` in the `creating` hook
  (same `??=` pattern as `status`).
- `App\Actions\Announcements\ResolveAnnouncementAudience` (announcement →
  matching active student IDs) and
  `App\Actions\Announcements\GuardianMatchesAnnouncementAudience`
  (announcement + guardian → bool, via `activeLinks()` intersection) —
  both pure audience matching, deliberately **not** considering `status`
  at all; pairing this with a `Published`-only check is WP-05-04's job
  when it wires guardian-facing visibility, matching WP-04-01/02's
  precedent of building resolvable logic well before the endpoint that
  uses it exists.
- `StoreAnnouncementRequest`/`UpdateAnnouncementRequest` gained
  `audience_type` (required), `audience_grade`/`audience_section`
  (`required_if` per type — `audience_grade` is required for both `grade`
  and `section`, since a section is only meaningful within a grade), and
  `student_ids` (`required_if:audience_type,students`, each validated
  against `students.id`). `AnnouncementController::store`/`update` pull
  `student_ids` out of the validated array before mass-assigning the rest
  (it isn't a column) and separately `sync()` the pivot.
- Frontend: create/edit forms gained an audience-type `<select>` plus
  always-visible (not conditionally shown/hidden — no page in this
  codebase uses `useState` for conditional fields yet, so this keeps the
  established plain-server-round-trip form style rather than introducing
  the first one) grade/section text inputs and a `<select multiple>` for
  students, each labeled with which audience type it applies to. Show
  page gained an audience summary line. `resources/js/types/announcement.ts`
  gained `audience_type`/`audience_grade`/`audience_section` and an
  optional `students` array (only populated on `show`/`edit`, via
  `Announcement::load('students:id,...')`).
- Tests: `ResolveAnnouncementAudienceTest.php` (4 — one per audience
  type, each proving active-only filtering), `GuardianMatchesAnnouncementAudienceTest.php`
  (5 — all/grade/students matching, no-links non-match, revoked-link
  stops matching immediately), plus 6 new cases in
  `AnnouncementAdministrationTest.php` (grade/students creation
  round-trip including the edit-page prefill assertion, and a
  `required_if` rejection test per conditional field) — 15 new tests, 49
  total in the announcements test surface.
- Verification: `vendor/bin/pint --dirty` (clean), `vendor/bin/phpstan
  analyse app` (0 errors), full `php artisan test` — 301 passed, 3
  pre-existing skips, 0 failures. `npm run lint:check` clean, `npm run
  build` succeeded.
