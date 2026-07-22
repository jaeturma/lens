# WP-06-05 — Firebase Push Signal Delivery

## Objective

Send minimal push signals that instruct the app to synchronize.

## Affected Layers

- [x] Laravel
- [ ] Database
- [x] API
- [x] Flutter
- [ ] Android
- [ ] RFID Integration

## Scope

Do not place authoritative attendance or announcement bodies solely in the push payload.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

WP-06-04.

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

- Push delivery is queued.
- Failure does not delete notification records.
- Payload triggers sync.
- Secrets are not committed.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes

- Laravel/API layer only, per explicit scoping for this session — the
  Flutter side (receiving the push, waking the app, triggering its own
  sync call) is separate follow-up work, not included here.
- Installed `kreait/laravel-firebase` (confirmed with you before adding
  it, given "do not install packages unless required" — this genuinely
  is required: sending real FCM v1 messages needs either this SDK or
  hand-rolling Google's OAuth2 service-account JWT flow). Published and
  then trimmed `config/firebase.php` down to only what Cloud Messaging
  uses — the package's default ships Firestore/Realtime Database/
  Storage/Auth-tenant config sections this app has and will have no use
  for.
- `App\Jobs\SendPushSignal` (`ShouldQueue`) — dispatched from
  `App\Observers\GuardianNotificationObserver::created()`. Sends one
  `sendMulticast()` call per notification, targeting every currently
  `Active` `DeviceToken` of the notification's guardian. Payload is
  data-only (`{"type": "sync_signal", "notification_type": "..."}"`, no
  `notification` block, never `title`/`body`) — see
  `docs/NOTIFICATIONS.md` for the full reasoning on why this reading of
  "do not place authoritative content in the push payload" was taken as
  strictly as possible.
- Failure handling: any thrown exception from the Firebase call is
  caught and logged, never re-thrown — `delivery_status` becomes
  `Failed`, the `GuardianNotification` row itself is never touched
  otherwise ("failure does not delete notification records"). Zero
  active tokens leaves the record `Pending` (no delivery was attempted,
  so `Failed` would be inaccurate). Invalid/unknown-token detection
  (`MulticastSendReport::invalidTokens()`) and retry logic were both
  deliberately left alone — both are WP-06-06's own named scope items
  ("invalid-token deactivation", "retry state"), not this package's.
- **Real engineering risk found and addressed before it could bite**:
  resolving `Kreait\Firebase\Contract\Messaging` with no credentials
  configured throws a local `RuntimeException` in about 2 seconds (measured
  directly) rather than hanging on a network call — but `QUEUE_CONNECTION=sync`
  in `phpunit.xml` means every dispatched job already runs inline during
  tests, and dozens of pre-existing tests (WP-06-01/02/03) create a
  `GuardianNotification` with no interest in push delivery at all. Left
  unaddressed, every one of those tests would have started attempting a
  real (doomed) Firebase call. Fixed by adding a global `Queue::fake()`
  in `tests/Pest.php`'s `beforeEach` — safe because `SendPushSignal` is
  the only queued job in the entire app, so this has no effect on
  anything else. `SendPushSignalTest.php` exercises the job's actual
  logic directly (calling `handle()` with a Mockery-mocked `Messaging`
  contract) rather than through the queue.
- `.gitignore` gained `firebase-credentials.json` and
  `/storage/app/firebase-credentials.json` — defense in depth alongside
  the already-excluded `.env*` patterns, since the real service-account
  secret must never be committed regardless of which filename convention
  an operator uses. No real Firebase project/credentials exist in this
  development environment.
- Tests: `SendPushSignalTest.php` (6 — successful send marks `Sent`,
  total failure marks `Failed` without deleting the record, zero active
  tokens stays `Pending` without attempting delivery, only active tokens
  are targeted, the serialized payload has no `notification` block and
  never contains the notification's own title/body text, creating a
  `GuardianNotification` queues the job) — 6 new tests.
- Verification: `vendor/bin/pint --dirty` (clean), `vendor/bin/phpstan
  analyse app` (0 errors), full `php artisan test` — 367 passed, 3
  pre-existing skips, 0 failures, ~24s (no meaningful slowdown from the
  new dependency or job).
