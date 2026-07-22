# WP-08-04 — RFID Load and Duplicate Tests

## Objective

Test repeated and concurrent scan submissions at a practical pilot scale.

## Affected Layers

- [x] Laravel
- [x] Database
- [x] API
- [ ] Flutter
- [ ] Android
- [x] RFID Integration

## Scope

Measure basic throughput and verify idempotency and raw record preservation.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

Phase 3, Phase 4.

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

- Duplicate protection works.
- No expected raw records are lost.
- Findings are documented.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes

This package validates, and where genuinely missing, hardens duplicate
protection for RFID scan ingestion (WP-03-03/04). One real gap was found
and fixed, not just tested — Database is a checked Affected Layer for this
package specifically because closing it required a schema change.

### Scenario → Evidence

| Acceptance criterion | Where it's proven |
| --- | --- |
| Sequential replay (same request retried in order) returns the existing row, no duplicate | `tests/Feature/Actions/Rfid/IngestRfidScanTest.php`, `tests/Feature/Api/V1/Rfid/ScanIngestionTest.php` |
| Concurrent replay (new) — two requests racing on the same `(rfid_device_id, request_id)` | `tests/Feature/Actions/Rfid/IngestRfidScanTest.php` |
| A distinct request_id from a different device is never conflated with another device's replay | `tests/Feature/Actions/Rfid/IngestRfidScanTest.php` |
| Raw records are preserved even for a genuinely duplicate physical tap (`duplicate_window` classification) — never deleted, never merged | `tests/Feature/Actions/Rfid/IngestRfidScanTest.php` ("...within the duplicate window..." asserts `count()` is 2, not 1) |
| Many distinct scans at practical pilot scale, no record lost | `tests/Feature/Api/V1/Rfid/ScanIngestionTest.php` ("the scan endpoint is rate limited per device" — 120 sequential distinct requests, each its own row) |

### The One Real Gap: Idempotency Had No Database-Level Backstop

`App\Actions\Rfid\IngestRfidScan`'s replay protection was a plain
check-then-act (`SELECT` for an existing `(rfid_device_id, request_id)`
row, then `INSERT` if none found) with no unique index behind it. Under
genuine concurrency — a device retrying a request whose response timed
out, while the original request is still in flight — two requests can
both run the `SELECT`, both find nothing, and both `INSERT`, producing two
raw rows for what should be one idempotency key. A single Pest process
can't reproduce true concurrency directly (confirmed: this project's test
suite runs against `sqlite`/`:memory:`, one connection, per
`phpunit.xml`), so the race was reproduced deterministically instead, by
registering a one-off `RfidScan::creating` listener that inserts the
"other request"'s colliding row via a raw `DB::table()` statement at the
exact moment this action's own `create()` call is about to insert —
after its replay check already ran and found nothing. Confirmed this
failed before the fix (temporarily reverted the fix, watched the test
throw `UniqueConstraintViolationException` uncaught, restored it) — the
test is not vacuously passing.

Fixed:

- `database/migrations/2026_07_23_000000_add_unique_index_to_rfid_scans_table.php`
  adds a unique index on `(rfid_device_id, request_id)` — the same
  "proactive check + DB-constraint backstop" pattern
  `App\Actions\RfidCards\AssignRfidCard` already established for
  `active_uid` (WP-03-02).
- `IngestRfidScan` now catches `Illuminate\Database\UniqueConstraintViolationException`
  around its `create()` call and re-fetches by `(rfid_device_id,
  request_id)`, returning whichever row actually won the race — the
  caller (and the device) always gets back a real, persisted scan row
  either way.
- Added the concurrency test described above to
  `tests/Feature/Actions/Rfid/IngestRfidScanTest.php`.
- Updated `docs/api/RFID.md`'s "Idempotency and Classification" section to
  describe the database-level guarantee, not just the app-level check.

### Basic Throughput (Documented Finding)

Measured locally (this environment: SQLite `:memory:`, single process —
directional, not a production capacity claim; the API's own `rfid-scan`
rate limiter, 120 requests/minute per device, is the actual designed
ceiling regardless):

- Action-level (`IngestRfidScan` called directly, no HTTP/auth overhead):
  500 sequential distinct scans in ~0.35s (~1,440 scans/sec).
- Full HTTP stack (`POST /api/v1/rfid/scans`, Basic Auth + validation +
  classification): 100 sequential requests in ~0.33s (~300 req/sec,
  ~3.3ms/request average).

Both figures sit far above the per-device rate limit (2 req/sec), and a
pilot deployment's realistic tap rate at any single gate is far below
either number — the rate limiter, not raw processing capacity, is what
actually bounds practical throughput. No load-related bottleneck was
found; no further action taken.

Verified: `vendor/bin/pint --test` clean, `vendor/bin/phpstan analyse`
clean on changed files, full Pest suite passing (397/400, 3 pre-existing
skips unrelated to this change).

Migration required: `2026_07_23_000000_add_unique_index_to_rfid_scans_table.php`
(`php artisan migrate`). New contract detail (not a new endpoint):
`docs/api/RFID.md`'s idempotency section now documents the
database-enforced uniqueness backing the existing replay-check behavior.
