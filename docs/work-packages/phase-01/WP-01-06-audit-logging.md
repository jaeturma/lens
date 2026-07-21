# WP-01-06 — Audit Logging

## Objective

Provide the shared audit-log data model and recording action that later
administration work packages (WP-02-04 Student Administration, WP-03-02 RFID
Card Assignment, WP-04-05 Attendance Corrections, WP-05-02 Announcement
Administration, and any admin-account changes) call into to record actor,
action, target, timestamp, and metadata. This package builds the
infrastructure only; it does not add a viewer UI/API (no such requirement
exists in scope) and does not retrofit the auditing calls into those later
packages themselves — each does that when it is implemented.

## Affected Layers

- [x] Laravel
- [x] Database
- [ ] API
- [ ] Flutter
- [ ] Android
- [ ] RFID Integration

## Scope

- `audit_logs` table: nullable `actor_id` (FK to `users`, null for
  system-initiated entries), `action` (free-form string, e.g.
  `student.created`), nullable polymorphic `target` (`target_type`/
  `target_id`), nullable `metadata` (JSON), `created_at` only (append-only,
  no `updated_at`).
- `App\Models\AuditLog` (actor/target relations, array-cast metadata).
- `App\Actions\Audit\RecordAuditLog`: the single call site future work
  packages use to write an entry. Redacts well-known secret-shaped metadata
  keys (password, token, secret, recovery codes, remember token) before
  storing, so a caller that accidentally passes a secret does not leak it.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

WP-01-05.

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

- `RecordAuditLog` persists actor, action, target, timestamp, and metadata,
  and works with a null actor for system-initiated entries.
- Well-known secret-shaped metadata keys are redacted before storage, at any
  nesting depth.
- Audit log rows are append-only (no `updated_at`).
- Representative tests pass.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes

- `audit_logs` migration (`2026_07_21_060000_create_audit_logs_table.php`):
  `actor_id` (nullable FK to `users`, `nullOnDelete`), `action` (string,
  indexed), nullable polymorphic `target` (`nullableMorphs('target')`,
  auto-indexed), `metadata` (JSON, nullable), `created_at` only (via
  `useCurrent()`) with an index — no `updated_at` column, enforced on the
  model with `const UPDATED_AT = null`.
- `App\Models\AuditLog`: `actor()` (`BelongsTo` User), `target()` (`MorphTo`),
  `metadata` cast to `array`.
- `App\Actions\Audit\RecordAuditLog`: the single call site future
  administration work packages use. Redacts `password`,
  `password_confirmation`, `token`, `secret`, `two_factor_secret`,
  `two_factor_recovery_codes`, and `remember_token` (case-insensitive key
  match, any nesting depth) by replacing the value with `"[redacted]"` —
  chosen over dropping the key so a reviewer can see a secret was present
  without seeing its value.
- No call sites were added in this package — nothing in the codebase yet
  performs an administrative mutation to audit (confirmed: only
  authentication endpoints exist so far). The four downstream work packages
  that reference "audited" in their acceptance criteria (WP-02-04, WP-03-02,
  WP-04-05, WP-05-02) add their own `RecordAuditLog` calls when implemented.
  This mirrors how WP-01-04 built Sanctum auth before WP-01-05 added the
  role check that uses it.
- No audit-log viewer UI or API endpoint was added — nothing in
  `docs/PROJECT-SCOPE.md`, `docs/EXECUTION-ORDER.md`, or any work package
  requires one for the initial release; `Affected Layers` above intentionally
  leaves API/Flutter/Android unchecked.
- `docs/SECURITY.md` gained an "Audit Logging" section documenting the
  `RecordAuditLog` contract and the deferred call sites, so later work
  packages don't need to rediscover this by reading `app/Actions/Audit/`.
- Tests: `tests/Feature/Actions/Audit/RecordAuditLogTest.php` — records
  actor/action/target/metadata, allows a null actor and target, redacts
  nested secret-shaped keys, and confirms rows are append-only (no
  `updated_at` column). 4 tests.
- Verification: `vendor/bin/pint` (clean), `vendor/bin/phpstan analyse app`
  (0 errors), full `php artisan test` — 62 passed, 3 pre-existing skips, 0
  failures (no regression).
