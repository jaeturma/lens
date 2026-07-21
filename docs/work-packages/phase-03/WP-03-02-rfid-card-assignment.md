# WP-03-02 — RFID Card Assignment

## Objective

Create `rfid_cards` as an append-mostly assignment history (not a single
mutable "the card" row per student) plus three actions —
`AssignRfidCard`/`DeactivateRfidCard`/`ReplaceRfidCard` — that call
`RecordAuditLog` directly, since this WP's acceptance criteria requires
"actions are audited" and no admin controller exists yet to do it
(WP-03-05). This is the one place so far where an Action calls audit
logging itself rather than a controller calling it after invoking the
action — justified the same way WP-02-01's `StudentObserver` auto-recorded
sync changes: the requirement is on this package, not deferred to a UI
that doesn't exist yet.

## Affected Layers

- [x] Laravel
- [x] Database
- [x] API
- [ ] Flutter
- [ ] Android
- [ ] RFID Integration

## Scope

- `rfid_cards` table/model: `uid`, `student_id` (FK), `status`
  (`App\Enums\RfidCardStatus`: Active/Deactivated/Replaced — three states,
  not two, so history shows *why* a card stopped being active: lost with
  no replacement yet (Deactivated) vs. swapped for a new physical card
  (Replaced)), `timestamps()`.
- Active-UID uniqueness enforced at the **database** level via a stored
  generated column (`active_uid`, `NULL` unless `status = 'active'`, with
  a `UNIQUE` index on it) — MySQL/SQLite both support this; a plain
  `unique('uid')` would be wrong here since the same `uid` legitimately
  appears in multiple historical (non-active) rows. This is what
  `docs/DATABASE.md`'s Rules literally call out: "unique indexes protect
  ... active RFID UID."
- `App\Actions\RfidCards\AssignRfidCard(Student, uid, ?actor)`: creates a
  new Active row; rejects (clean exception, not a raw unique-constraint
  `QueryException`) if the `uid` is already actively assigned to any
  student.
- `App\Actions\RfidCards\DeactivateRfidCard(RfidCard, ?actor)`: marks a
  card Deactivated.
- `App\Actions\RfidCards\ReplaceRfidCard(RfidCard currentCard, newUid,
  ?actor)`: in one transaction, marks `currentCard` Replaced and creates a
  new Active row with `newUid` for the same student — always a **new**
  row with a new `uid`, never reactivating the old one (a physical card
  replacement is a different physical card).
- No sync-feed participation (`#[ObservedBy]`) — RFID cards, like devices
  (WP-03-01), are never part of a guardian's mobile data.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

WP-02-01.

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

- Assigning a `uid` already actively held by another card is rejected.
- Deactivated/replaced rows are never deleted or reused; a replacement
  always creates a new row.
- Assign/deactivate/replace each record an audit log entry.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes

- `rfid_cards` migration (`2026_07_22_120000_create_rfid_cards_table.php`):
  `uid`, `student_id` (FK, `cascadeOnDelete`), `status` (default
  `active`, indexed), `active_uid` — a stored generated column
  (`storedAs("case when status = 'active' then uid else null end")`)
  with a `unique` index. Confirmed this works identically on both the
  SQLite test database and (by construction — standard `CASE`/generated-
  column SQL) MySQL; verified empirically via
  `tests/Feature/Models/RfidCardTest.php` before building anything on top
  of it, since this was the one piece of this WP with real cross-database
  risk. No `uuid` — not a synced resource, same as `RfidDevice`
  (WP-03-01).
- `App\Enums\RfidCardStatus`: `Active`/`Deactivated`/`Replaced` — three
  states, not two, specifically so "replacement history remains"
  distinguishably from "lost with no replacement issued yet."
- The three actions (`AssignRfidCard`, `DeactivateRfidCard`,
  `ReplaceRfidCard`) call `App\Actions\Audit\RecordAuditLog` directly —
  the first Action-calls-audit-log-itself case in the codebase (every
  prior audit call site was in a controller). Justified because this WP's
  own acceptance criteria requires "actions are audited" with no admin
  controller yet to do it from (WP-03-05); `actor` is an explicit nullable
  parameter rather than read from `auth()`, so the actions stay usable
  and testable outside an HTTP request.
- `App\Exceptions\RfidCards\RfidUidAlreadyActiveException`: a small
  domain exception rather than reusing `ValidationException` (which
  assumes an HTTP request context these actions don't have) or leaking a
  raw `QueryException`. Raised proactively (checked before insert) and as
  a fallback if a `QueryException` hits the unique constraint anyway
  (belt-and-suspenders against a race between two concurrent
  assign/replace calls for the same `uid` — the DB constraint is the real
  guarantee, the proactive check is just for a clean error message in the
  common case).
- Registered `'rfid_card' => RfidCard::class` in the `Relation::morphMap()`,
  ahead of any admin UI, same pattern as every other resource this
  session.
- No sync-feed participation — RFID cards are backend/admin-only, same
  reasoning as `RfidDevice`.
- Tests: `tests/Feature/Models/RfidCardTest.php` (two active rows can't
  share a `uid`; a deactivated row's `uid` can be reused by a new active
  row; multiple non-active rows can share a `uid`; status cast),
  `AssignRfidCardTest.php`, `DeactivateRfidCardTest.php` (including that
  deactivating frees the `uid` for reassignment),
  `ReplaceRfidCardTest.php` (old row becomes `Replaced`, new row created,
  audit entry on the new card references the old one; rejecting a
  taken `uid` leaves the old card untouched) — 11 new tests.
- `docs/api/RFID.md` documents the assignment-history model and all
  three actions' contracts.
- Verification: `vendor/bin/pint` (clean), `vendor/bin/phpstan analyse app`
  (0 errors), full `php artisan test` — 171 passed, 3 pre-existing skips, 0
  failures.
