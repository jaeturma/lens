# WP-06-03 — Announcement Notifications

## Objective

Create notifications when a targeted announcement is published.

## Affected Layers

- [x] Laravel
- [x] Database
- [x] API
- [ ] Flutter
- [ ] Android
- [ ] RFID Integration

## Scope

Define publish and republish behavior.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

Phase 5, WP-06-01.

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

- Drafts do not notify.
- Audience receives one notification each.
- Republish behavior is tested.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes

- New `App\Actions\Notifications\NotifyGuardiansOfAnnouncement`: resolves
  the announcement's audience (WP-05-03's `ResolveAnnouncementAudience`),
  then currently-active `notify_announcements`-enabled guardians, deduped
  per guardian (not per matching child — an announcement's content is the
  same regardless of which child it matched through). Title/body mirror
  the announcement's own fields directly rather than inventing separate
  notification copy.
- Triggering lives in `App\Observers\AnnouncementObserver`, reusing the
  `$leftDraft` check already computed there for the `SyncChangeAction::Created`
  decision (WP-05-01) — no new state-detection logic needed, just an
  additional call at the same point. Also handles the
  admin-UI-unreachable case of a `created()` call already carrying
  `status: Published` (mirrors how WP-05-01's own sync-feed logic already
  treats that the same as leaving `Draft`).
- **"Define publish and republish behavior" — decided as: republish
  isn't supported.** Editing an already-`Published` announcement (title,
  body, or audience) never triggers additional notifications in this
  release. Considered building "notify only newly-matching guardians when
  the audience widens after publish" instead, but that requires tracking
  which guardians were already notified for a given announcement and
  diffing against the newly-resolved audience — real complexity for a
  package whose sibling (WP-05-03) was explicitly told to avoid exactly
  that ("without campaign-level complexity"). The simpler, fully
  consistent-with-precedent choice: an admin wanting a wider or different
  audience withdraws and creates a new announcement, extending WP-05-01's
  own "a withdrawn/expired announcement isn't resurrected" terminal-state
  philosophy to cover audience changes too.
- Tests: `NotifyGuardiansOfAnnouncementTest.php` (4 — recipient filtering
  by active-link/notify_announcements, one-notification-per-guardian
  dedup across multiple matching children, no-match no-op, payload shape)
  and `Notifications/AnnouncementNotificationRulesTest.php` (6 — publish
  notifies, drafts never notify (create or edit), editing a Published
  announcement doesn't re-notify even when the audience widens,
  withdraw/expire don't notify, a directly-created Published row still
  notifies, opted-out guardian receives nothing) — 10 new tests.
- Verification: `vendor/bin/pint --dirty` (clean), `vendor/bin/phpstan
  analyse app` (0 errors), full `php artisan test` — 340 passed, 3
  pre-existing skips, 0 failures. Full existing announcement test surface
  (59 tests) re-run with no regressions from the observer change.
