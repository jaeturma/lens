# WP-08-08 — Laravel Deployment Queue and Scheduler

## Objective

Document and verify production API, queue worker, scheduler, Firebase credentials, backup, and rollback.

## Affected Layers

- [x] Laravel
- [x] Database
- [x] API
- [ ] Flutter
- [ ] Android
- [ ] RFID Integration

## Scope

Keep it suitable for the initial deployment environment.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

Phases 1 through 6.

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

- Required services and commands are documented.
- Attendance absence jobs and push queues run.
- Backup and rollback procedures exist.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes

Pure documentation — no Laravel code changes. Per this package's own
Scope line ("keep it suitable for the initial deployment environment,"
single school, no multi-tenancy), the deliverable is `docs/DEPLOYMENT.md`,
written from what the application actually requires (its own config
defaults and scheduled commands), not assumed.

### Acceptance Criteria

- **Required services and commands are documented**: `docs/DEPLOYMENT.md`
  Required Services + Deployment Commands. The one finding worth flagging:
  `config/queue.php`'s default connection is `database`, meaning
  `App\Jobs\SendPushSignal` (the app's only queued job) silently does
  nothing forever without a persistent `queue:work` process — not obvious
  from the app alone, so documented explicitly, including the concrete
  Supervisor config to keep one alive.
- **Attendance absence jobs and push queues run**: verified, not assumed
  — `attendance:mark-absences`, `announcements:expire`, and
  `notifications:retry-failed-push` are all already registered in
  `routes/console.php` (`everyFifteenMinutes()`) and already have passing
  command-level tests (`tests/Feature/Console/*CommandTest.php`, 5
  tests, re-run clean). Nothing new needed — this package documents *how*
  they run in production (the cron entry + queue worker requirement
  above), since the commands running correctly in a test doesn't by
  itself make them run in production without that cron entry existing.
- **Backup and rollback procedures exist**: `docs/DEPLOYMENT.md` Backup +
  Rollback. Rollback guidance deliberately distinguishes a bad code
  deploy (redeploy previous release, no DB action) from a bad migration
  (`migrate:rollback`, confirmed mechanically available — all 28
  migrations have a working `down()`) from data already damaged by a
  destructive migration (restore from backup, not a hand-reversal).

Verified: full Pest suite passing (403/406, 3 pre-existing skips
unrelated), re-confirming nothing regressed even though this package
changed no application code. No `vendor/bin/pint`/`phpstan` diff to check
— no PHP files were touched.

No migrations. No new/changed API contract — `docs/DEPLOYMENT.md`
references `GET /api/v1/health` (pre-existing, WP-01) as-is, noting its
actual scope (liveness only, not a DB/queue readiness check) rather than
overstating what it verifies. Unresolved risk, explicitly flagged rather
than fixed here: no real production database, queue infrastructure, or
Firebase project has been provisioned in any environment this session had
access to — this package documents the requirements and procedures, it
does not stand up real infrastructure.
