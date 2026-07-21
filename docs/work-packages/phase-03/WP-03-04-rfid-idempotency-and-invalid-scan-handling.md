# WP-03-04 — RFID Idempotency and Invalid Scan Handling

## Objective

Extend WP-03-03's ingestion pipeline with the classification logic it
deliberately deferred: distinguish a replayed request (idempotent no-op)
from a genuine repeat tap (stored, but flagged) from a scan of a card
that's unknown or no longer active (also stored, also flagged). Every
well-formed scan is still stored — this WP changes *how it's labeled*,
never *whether it's kept*. No attendance event exists yet to actually
prevent duplicates of (WP-04) — this WP produces the classification that
work package will read.

## Affected Layers

- [x] Laravel
- [x] Database
- [x] API
- [ ] Flutter
- [ ] Android
- [ ] RFID Integration

## Scope

- `App\Actions\Rfid\IngestRfidScan` replaces `IngestRfidScanController`'s
  direct `RfidScan::create()` call (from WP-03-03):
  1. **Duplicate request** (same `rfid_device_id` + `request_id` already
     stored — a network-level retry of a request the server already
     handled): return the **existing** row; no new row, no
     reclassification. This is the "idempotent" case — replaying a
     request must not create a second raw record, because it isn't a
     second real-world event.
  2. Otherwise, a genuinely new request is stored (a new row, always —
     "preserve every meaningful raw record"), with a computed
     `classification` (`App\Enums\RfidScanClassification`):
     - `duplicate_window`: the same `uid` was already scanned within the
       last 5 seconds (any device) — a real second request, but almost
       certainly one physical tap read twice by the hardware, not two
       separate events.
     - `unknown_card`: `uid` has never appeared in `rfid_cards` at all.
     - `inactive_card`: `uid` matches an `rfid_cards` row, but none of
       them are currently `active` (reuses WP-03-02's `active_uid`
       generated column for the lookup).
     - `valid`: none of the above.
- New `rfid_scans.classification` column (indexed, default `valid`).
- No change to the endpoint's request/response shape or its `401`/`422`
  failure modes (WP-03-03) — classification is server-side bookkeeping,
  not something the device needs to see or act on.
- "Raw scans are not deleted": trivially true already — no destroy route
  or delete action exists for `RfidScan`; nothing new to build for this
  specific bullet, just confirmed and documented.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

WP-03-03.

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

- Submitting the same `(device, request_id)` twice stores exactly one row
  and returns the same `id` both times.
- A scan of a `uid` with no `rfid_cards` row is stored as `unknown_card`;
  one whose only rows are non-active is stored as `inactive_card` — both
  queryable, not silently dropped.
- No delete/destroy path exists for `RfidScan`.
- Tests pass.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes

- Migration `2026_07_22_140000_add_classification_to_rfid_scans_table.php`
  adds `classification` (default `valid`, indexed) to the existing
  `rfid_scans` table from WP-03-03, rather than folding it into that
  table's original migration — keeps each WP's schema change in its own,
  separately-reviewable migration, consistent with every other WP this
  session.
- `App\Enums\RfidScanClassification`: `Valid`/`DuplicateWindow`/
  `UnknownCard`/`InactiveCard` — no `DuplicateRequest` case, deliberately:
  a true duplicate request never reaches classification at all (the
  action returns the existing row immediately), so a case for it would be
  permanently unused/dead.
- `App\Actions\Rfid\IngestRfidScan`: replay lookup first
  (`rfid_device_id` + `request_id`), then `classify()` for anything new.
  `classify()` checks the duplicate-window first (a 5-second constant,
  `self::DUPLICATE_WINDOW_SECONDS`, chosen as a reasonable debounce for
  one physical tap misread as two — not specified anywhere in scope, a
  judgment call worth flagging), then reuses WP-03-02's `active_uid`
  generated column (`RfidCard::where('active_uid', $uid)->exists()`) to
  decide `valid` vs. needing the unknown/inactive distinction (a second,
  plain `uid` lookup only runs when there's no active card).
- `IngestRfidScanController` updated to call the new action instead of
  `RfidScan::create()` directly, parsing `device_timestamp` via
  `Carbon::parse()` before passing it through (the FormRequest only
  validates it's a valid date string, it doesn't cast it). No change to
  the response shape, status codes, or the `401`/`422`/`429` failure
  paths from WP-03-03.
- Tests: `tests/Feature/Actions/Rfid/IngestRfidScanTest.php` (all four
  classification outcomes, duplicate-window boundary using
  `$this->travel()` rather than manually rewriting `created_at`, replay
  returns the same row, same `request_id` from a *different* device is
  not treated as a replay), plus two new end-to-end cases added to
  `tests/Feature/Api/V1/Rfid/ScanIngestionTest.php` (HTTP-level replay
  returns the same `id` with one stored row; an unknown-card scan is
  visible in the database with the right classification) — 9 new tests.
- `docs/api/RFID.md` documents the classification rules and the
  replay-short-circuit, and is explicit that none of this changes the
  device-visible response — classification is purely server-side.
- Verification: `vendor/bin/pint` (clean), `vendor/bin/phpstan analyse app`
  (0 errors), full `php artisan test` — 187 passed, 3 pre-existing skips, 0
  failures (no regression, including WP-03-03's original ingestion tests).
