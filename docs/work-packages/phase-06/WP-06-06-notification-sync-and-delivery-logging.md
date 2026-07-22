# WP-06-06 — Notification Sync and Delivery Logging

## Objective

Synchronize notification records and log push attempts.

## Affected Layers

- [x] Laravel
- [x] Database
- [x] API
- [ ] Flutter
- [ ] Android
- [ ] RFID Integration

## Scope

Include unread updates, invalid-token deactivation, and retry state.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

WP-06-05, WP-01-08.

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

- Inbox changes synchronize.
- Read state is consistent.
- Invalid tokens are deactivated safely.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes

Laravel/API layer complete:

- `ScopeChangesToGuardian` gained a `guardian_notification` branch (a guardian's own notifications, including read-state updates, are visible via bootstrap/incremental sync; others' are not).
- `SendPushSignal` now deactivates only the device tokens Firebase's own response identifies as invalid/unknown (never on a general delivery exception), and logs every attempt (`PushDeliveryAttempt`: attempt number, success, error message).
- `RetryFailedPushSignals` (`notifications:retry-failed-push`, scheduled every fifteen minutes) re-dispatches `SendPushSignal` for Failed notifications with fewer than 3 logged attempts; a notification is left permanently Failed once it exhausts that cap, with no separate "gave up" status.
- New migration/model/factory: `push_delivery_attempts` / `PushDeliveryAttempt`.

Fixed during verification: `RetryFailedPushSignals` originally used `withCount()->having()`, which raised `HAVING clause on a non-aggregate query` on SQLite; replaced with `->has('pushDeliveryAttempts', '<', self::MAX_ATTEMPTS)`.

Added test coverage that was missing: `tests/Feature/Console/RetryFailedPushDeliveriesCommandTest.php` (under-cap retry, exhausted-cap no-retry, non-Failed no-retry).

Targeted tests: 143 passed (Notification/PushSignal/DeviceToken/Sync filter). No new PHPStan errors (2 pre-existing, unrelated: `config/sanctum.php`, `UserFactory.php`).

Flutter/Android boxes unchecked: `mobile/lib` has no Drift/SQLite database, repository layer, or sync engine yet (only the WP-07-01 app shell exists), so there is no local store for a notification repository to synchronize into. That build-out is WP-07-12 (Offline Notification Inbox), whose own Dependencies line names this package and WP-07-08 (Incremental Sync Engine) — building it here would mean improvising WP-07-02/07-08's foundation out of sequence. Deferred to when phase-07 is picked up in order.
