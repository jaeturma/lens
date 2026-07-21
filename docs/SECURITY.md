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
