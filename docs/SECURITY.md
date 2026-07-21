# Security Baseline

## Roles and Permission Matrix

One Laravel installation is bound to exactly one school (no multi-school
tenancy). Initial-release roles and their boundaries:

| Role | Account Type | Scope | Excluded |
|---|---|---|---|
| System Administrator | Laravel web user | Full access to this installation: school configuration, administrator accounts, RFID device registry, system-level settings. | N/A |
| School Administrator | Laravel web user | Operational access to school data: students, guardians, RFID card assignment, attendance, announcements. | Cannot manage administrator accounts or system-level settings. |
| Parent/Guardian | Mobile Sanctum-authenticated user | Read access, via the mobile API only, to their own active linked students: attendance, announcements, notifications. | No web administration access. No access to unlinked or inactive student links. |
| RFID Device | Not a user account | Authenticates with a dedicated device credential (see below) to submit raw scan events only. | Cannot log in as a user. No access to any endpoint other than scan ingestion. |

Excluded/future roles (not implemented in this release, per
`docs/PROJECT-SCOPE.md`): Teacher, Student (no student login).

## Audit Logging

`App\Actions\Audit\RecordAuditLog` (WP-01-06) is the shared write path for
the `audit_logs` table: `(new RecordAuditLog)($actor, $action, $target,
$metadata)`, where `$actor` is the acting `User` (nullable, for
system-initiated entries), `$action` is a free-form string
(`"student.created"`, `"rfid_card.deactivated"`), `$target` is the affected
Eloquent model (nullable), and `$metadata` is arbitrary JSON-safe context.
Well-known secret-shaped metadata keys (password, token, secret, recovery
codes, remember token) are redacted before storage at any nesting depth, so
callers do not need to pre-sanitize. Entries are append-only (no
`updated_at`). Work packages that add administrative mutations — student
administration (WP-02-04), guardian/link administration (WP-02-05), RFID
device registry and card assignment (WP-03-01, WP-03-02), attendance
corrections (WP-04-05), announcement administration (WP-05-02), and any
administrator account changes — call this action at their mutation points;
WP-01-06 itself does not add those call sites. No audit-log viewer UI/API is
in scope for the initial release.

- Laravel Sanctum for guardian sessions.
- Dedicated RFID device credentials.
- School-bound login and resource authorization.
- Guardians access only active linked students.
- Rate limits on login, resolver, sync, and device scan endpoints.
- Raw device secrets are never displayed after creation.
- Sensitive administrative actions are audited.
- Push tokens can be revoked.
- SQLite must not contain unnecessary sensitive data.
- Secure storage holds authentication secrets, not the complete local dataset.
- Android backup must exclude school binding, authentication state, and SQLite data.
- The Play Store release requires a privacy policy and account/data deletion process.
