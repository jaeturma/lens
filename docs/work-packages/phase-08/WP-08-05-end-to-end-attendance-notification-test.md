# WP-08-05 — End to End Attendance Notification Test

## Objective

Verify scan to raw record to attendance to notification to push signal to sync to SQLite to screen.

## Affected Layers

- [x] Laravel
- [x] Database
- [x] API
- [x] Flutter
- [x] Android
- [x] RFID Integration

## Scope

Test both successful push and missed-push recovery through app resume or manual sync.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

Phases 3 through 7.

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

- Complete flow passes.
- Missed push does not lose the notification.
- Failures are traceable.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes

Pure test coverage — no production code, contract, or migration changes.
Every individual link in the chain (scan ingestion, attendance
processing, notification creation, push delivery, sync scoping, SQLite
apply, screen rendering) already had thorough unit-level coverage from
phases 3–7; what this package specifically adds is exercising the *whole*
chain together, starting from the real entrypoints (the HTTP scan
endpoint on the server, the ordinary startup sync on the client) rather
than each Action/Observer called directly in isolation.

### Scenario → Evidence

| Objective/acceptance scenario | Where it's proven |
| --- | --- |
| Complete flow passes: scan → raw record → attendance → notification → push signal → sync (new, Laravel side) | `tests/Feature/EndToEnd/ScanToNotificationPipelineTest.php` |
| Push signal → sync → SQLite → screen (successful push) | `mobile/test/features/push/push_sync_trigger_flow_test.dart` (WP-07-13) |
| Missed push does not lose the notification, recovery through app resume/manual sync (new, both sides) | Laravel: `ScanToNotificationPipelineTest.php`'s second test. Flutter: `mobile/test/app/missed_push_recovery_test.dart` |
| Failures are traceable (a push delivery failure) | `tests/Feature/Jobs/SendPushSignalTest.php` (unit level, pre-existing) — re-confirmed reached from the real HTTP entrypoint by `ScanToNotificationPipelineTest.php`'s second test |

### The Two Gaps: Full-Chain Proof Was Missing on Both Ends

Every existing test entered this chain at a lower level — `ProcessRfidScan`
called directly with a hand-built `RfidScan`, `NotifyGuardiansOfAttendanceEvent`
called directly with a hand-built summary, `SendPushSignal::handle()`
called directly with a hand-built notification — never all wired together
starting from the actual public entrypoint. Nothing was *wrong*; the
combination had just never been exercised as one flow.

**Laravel** (`tests/Feature/EndToEnd/ScanToNotificationPipelineTest.php`,
new): `POST /api/v1/rfid/scans` → asserts, in order, the raw `RfidScan`
row, the `AttendanceEvent`, the `AttendanceDailySummary`, the
`GuardianNotification`, `sync_changes` entries for both the summary and
the notification, the queued `SendPushSignal` job (`tests/Pest.php`
globally fakes the queue for every Feature test — see below — so the job
is asserted queued and then invoked directly, exactly like
`SendPushSignalTest.php` already does), a successful delivery attempt,
and finally that the guardian's own `GET /sync/changes` call actually
returns both changes. A second test repeats the same flow but with
`Messaging::sendMulticast` throwing: confirms the notification is never
lost (still fully present and still reaches the guardian over sync) and
the failure itself is queryable (`PushDeliveryAttempt.succeeded = false`,
`.error_message`), not just logged and forgotten.

Note on `Queue::fake()`: `tests/Pest.php`'s global `beforeEach` fakes the
queue for every single Feature test specifically so `SendPushSignal`
never fires a real Firebase call as a side effect of unrelated tests —
this is why `SendPushSignalTest.php` already calls `handle()` directly
rather than relying on a dispatched job actually running, and this
package's new tests follow the same established shape rather than fight
the global fake.

**Flutter** (`mobile/test/app/missed_push_recovery_test.dart`, new):
`test/features/push/push_sync_trigger_flow_test.dart` (WP-07-13) proves
three ways a **received** push triggers a sync. None of them prove the
scenario this package's own Scope line explicitly names — "recovery
through app resume or manual sync" — where no push is ever received at
all (delivery failure, device offline at the moment of send, permission
denied, app killed). `HomePage` fires `startupSyncProvider` on every
build regardless of push (`lib/features/home/presentation/home_page.dart`),
so the recovery path already existed; it just had no test proving it
independent of push. Added: a `guardian_notification` sync entry arrives
through the ordinary startup sync alone, with no `PushMessagingService`
interaction anywhere in the test, and shows up as the unread badge and in
the notification inbox exactly as if it had arrived via push.

Verified: backend — `vendor/bin/pint --test` clean, full Pest suite
passing (399/402, 3 pre-existing skips unrelated); mobile — `flutter
analyze` clean, full suite passing (120/120, `flutter test
--concurrency=1`).

No migrations. No new or changed API/mobile contracts — the endpoints and
payload shapes these tests exercise already existed and are documented in
`docs/api/RFID.md`, `docs/api/SYNC.md`, and `docs/NOTIFICATIONS.md`.
