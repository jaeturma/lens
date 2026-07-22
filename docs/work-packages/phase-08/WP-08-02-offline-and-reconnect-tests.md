# WP-08-02 — Offline and Reconnect Tests

## Objective

Validate initial sync, offline reads, failed sync, reconnect, pagination, and cursor safety.

## Affected Layers

- [ ] Laravel
- [ ] Database
- [x] API
- [x] Flutter
- [ ] Android
- [ ] RFID Integration

## Scope

Use controlled failures and verify no cursor/data corruption.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

WP-07-08 through WP-07-12.

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

- Offline screens remain usable.
- Retry succeeds.
- Interrupted sync does not skip changes.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes

Flutter only — no Laravel/Database changes (this package validates, and
where genuinely missing, extends test coverage of sync behavior already
built across WP-07-08 through WP-07-13; nothing new is read from or
written to the server).

### Scenario → Evidence

| Objective scenario | Where it's proven |
| --- | --- |
| Initial sync (bootstrap) | `test/features/school_bootstrap/bootstrap_repository_test.dart` |
| Pagination (walks every page while `has_more`) | `test/features/sync/sync_engine_test.dart` |
| Cursor safety (cursor advances only with its page's own transaction; a request without a saved cursor falls back only as documented) | `test/features/sync/sync_engine_test.dart` |
| Failed sync / interrupted sync does not skip changes (mid-page failure keeps the previously committed cursor) | `test/features/sync/sync_engine_test.dart` |
| Retry / reconnect (resumes from the last committed cursor, not from the beginning or by skipping) | `test/features/sync/sync_engine_test.dart` |
| Offline reads (screens render from SQLite independent of any sync call) | `test/features/home/home_page_test.dart` (via `NoOpSyncApi`) |
| Offline screens remain usable when a sync actually fails (new) | `test/app/offline_and_reconnect_test.dart` |
| Retry succeeds end-to-end once connectivity returns (new) | `test/app/offline_and_reconnect_test.dart` |

Only one gap existed: every existing test either proved the sync
engine's own cursor/pagination/retry logic in isolation (`sync_engine_test.dart`,
against a fake `SyncApi`, no widget tree involved), or proved screens read
SQLite using a *successful* no-op sync (`NoOpSyncApi` in
`home_page_test.dart` and others). Nothing exercised the combination this
package's Objective actually names: a sync that **fails** while the full
`HomePage` widget tree is mounted. `HomePage` fires `startupSyncProvider`
on every build but never reads its result (by construction, per
`docs/ARCHITECTURE.md` Runtime Data Flow), so this was true by
construction but previously unverified end-to-end. Added
`test/app/offline_and_reconnect_test.dart`:

1. A failing `startupSyncProvider` (a `SyncApi` that always throws) still
   renders a previously-synced linked child from SQLite, with no crash,
   and leaves the previously saved cursor untouched.
2. Once connectivity returns, calling `syncEngineProvider.sync()` again
   (the same call `HomePage`'s pull-to-refresh makes) succeeds and
   applies the page it now receives.

No other screen fires a sync on its own build (`announcements`,
`attendance history`, and `notifications` all read SQLite only), so
`HomePage` is the only place "offline screens remain usable" needed
end-to-end proof.

Verified: `flutter analyze` clean; full mobile suite passing, 119/119
(`flutter test --concurrency=1`).

No migrations, no new API contracts.
