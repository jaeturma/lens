# WP-05-04 — Announcement Sync Contract

## Objective

Deliver new, updated, expired, and withdrawn announcements through sync.

## Affected Layers

- [x] Laravel
- [ ] Database
- [x] API
- [x] Flutter
- [ ] Android
- [ ] RFID Integration

## Scope

Define local deletion or inactive-state behavior.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

WP-05-03, WP-01-08.

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

- Incremental announcement changes work.
- Expired/withdrawn records are removed or hidden locally.
- Tests pass.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes

- Laravel/API layer only, per explicit scoping for this session — Flutter
  consumption of this contract is separate follow-up work, not included
  here (same split as WP-04-06).
- `App\Actions\Sync\ScopeChangesToGuardian` gained an `announcement`
  branch and a constructor dependency on
  `App\Actions\Announcements\GuardianMatchesAnnouncementAudience`
  (WP-05-03) — re-resolves against the change's `resource` relation (the
  live `Announcement`), deliberately not the `payload` snapshot, since
  audience/pivot membership can be edited after the sync row was written
  and a stale check would drift from reality. Existing tests using `new
  ScopeChangesToGuardian` were switched to `app(ScopeChangesToGuardian::class)`
  for the new constructor dependency.
- `App\Http\Resources\V1\AnnouncementResource` (new) mirrors
  `AnnouncementObserver`'s sync payload shape exactly, so bootstrap and
  incremental sync serialize the same way.
  `App\Http\Controllers\Api\V1\Sync\BootstrapController` gained a
  top-level `announcements` list: every `Published` announcement filtered
  through `GuardianMatchesAnnouncementAudience` per guardian (not
  per-child — one announcement can match through several linked
  students).
- **"Define local deletion or inactive-state behavior" resolved as
  deletion**: `docs/api/SYNC.md`'s own pre-existing "Tombstones" section
  already classified `revoked` and `expired` as tombstone actions before
  this package existed (WP-01-07) — and WP-05-01 already emits exactly
  those two actions for withdraw/expire. So no new code was needed for
  this scope item; it only needed to be decided and documented rather
  than left ambiguous, since "removed or hidden locally" (the acceptance
  criteria's own phrasing) left both readings open. Chose "removed" over
  a kept-but-hidden archive, since nothing asked for an announcement
  history feature and building one would be exactly the "campaign-level
  complexity" WP-05-03 was told to avoid.
- `docs/api/SYNC.md`: documented the `announcements` bootstrap field, the
  `announcement` Guardian-Scoped Authorization branch, and a full
  `announcement` entry under Synchronized Resources; trimmed "Not Yet
  Implemented" to just notifications. `docs/ANNOUNCEMENTS.md` gained a
  "Parent Announcement Sync Contract" section and now marks phase 5
  complete (Laravel/API side).
- Tests: `ScopeChangesToGuardianTest.php` (+4 — audience match/no-match/
  revoked-link/no-guardian), `BootstrapTest.php` (+3 — matching
  announcement included, non-matching excluded, draft/withdrawn/expired
  all excluded), `ChangesTest.php` (+2 — end-to-end audience-scoped
  visibility, withdraw synchronizes as `revoked`) — 9 new tests.
- Verification: `vendor/bin/pint --dirty` (clean), `vendor/bin/phpstan
  analyse app` (0 errors), full `php artisan test` — 310 passed, 3
  pre-existing skips, 0 failures.
