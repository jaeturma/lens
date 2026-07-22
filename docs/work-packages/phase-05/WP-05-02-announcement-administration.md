# WP-05-02 — Announcement Administration

## Objective

Allow school administrators to manage announcements.

## Affected Layers

- [x] Laravel
- [x] Database
- [ ] API
- [ ] Flutter
- [ ] Android
- [ ] RFID Integration

## Scope

Use the existing web stack and keep attachment support out unless already available.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

WP-05-01.

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

- Administrators can create, edit, publish, withdraw, and expire.
- Actions are authorized.
- Important changes are audited.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes

- `App\Policies\AnnouncementPolicy` (`viewAny`/`view`/`create`/`update`,
  all `isAdministrator()`), three Form Requests
  (`Index`/`Store`/`UpdateAnnouncementRequest`), `AnnouncementController`
  (`index`/`create`/`store`/`show`/`edit`/`update`) — mirrors
  `StudentController`/`RfidDeviceController` exactly. `store` always
  creates a `Draft` with `author_id` from the acting user; `update` only
  ever touches `title`/`body`/`expires_at`.
- New `App\Actions\Announcements\ExpireAnnouncement` (manual, single-row,
  admin-triggered — distinct from WP-05-01's bulk/scheduled
  `ExpireDueAnnouncements`) plus three single-purpose controllers
  (`Publish`/`Withdraw`/`ExpireAnnouncementController`) that call the
  three lifecycle actions and catch
  `InvalidAnnouncementTransitionException`, converting it to a `422`
  validation error (mirroring `ReplaceRfidCardController`'s
  `RfidUidAlreadyActiveException` handling) rather than letting it bubble
  to a `500`.
- **Audit calls live in the controllers, not the WP-05-01 lifecycle
  actions** — a deliberate convention choice: this codebase has two
  competing precedents (`AssignRfidCard`/`ReplaceRfidCard` self-audit;
  `StudentController`/`RfidDeviceController` audit at the controller). I
  followed the latter since it's the closer sibling ("Administration"
  packages) and it means `PublishAnnouncement`/`WithdrawAnnouncement`
  (already shipped and tested in WP-05-01) didn't need their signatures
  touched at all.
- `routes/announcements.php` (new, required from `web.php` after
  `attendance.php`): standard resource routes minus `destroy`, plus
  `PATCH .../publish`, `.../withdraw`, `.../expire`.
- Frontend: `resources/js/pages/announcements/{index,create,edit,show}.tsx`
  (Inertia/React, shadcn components — no new component/package added; a
  plain `<textarea>` styled to match the existing `<select>` convention
  covers the body field, since no Textarea component existed yet),
  `resources/js/types/announcement.ts`, sidebar nav entry
  (`app-sidebar.tsx`, Megaphone icon). `php artisan wayfinder:generate`
  regenerated the TypeScript action helpers the pages import.
- `docs/ANNOUNCEMENTS.md` gained an "Administration" section (including
  why manual vs. scheduled expiration are two separate actions);
  `docs/api/ANNOUNCEMENTS.md` clarified these are administrator **web**
  screens, not a mobile/JSON API surface.
- Tests: `ExpireAnnouncementTest.php` (manual expire + 2 invalid-transition
  cases), `AnnouncementAdministrationTest.php` (guardian forbidden from
  every route, index search/filter, create/update with audit-log
  assertions, validation, publish→withdraw round trip, manual expire, two
  invalid-transition-returns-422 cases) — 12 new tests.
- Verification: `vendor/bin/pint --dirty` (clean), `vendor/bin/phpstan
  analyse app` (0 errors), full `php artisan test`. `npm run types:check`
  flags `Property 'form' does not exist` on every new page's
  `Controller.form()` call — confirmed **pre-existing across the entire
  codebase** (identical error on every other admin page: students,
  guardians, rfid, settings, auth), not something this package
  introduced; not investigated further as out of scope for this WP.
