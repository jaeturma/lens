# Laravel Deployment, Queue, and Scheduler (WP-08-08)

Operational documentation for running the LENS backend in a real
environment — sized for the initial deployment: one school, one Laravel
installation, no multi-tenancy (`docs/SECURITY.md`). No infrastructure
was provisioned by this package (no real database, queue, cron, or
Firebase project exists in this development environment) — this
documents what a deployment must run and how, verified against what the
application actually requires by inspecting its own configuration and
scheduled commands, not assumed.

## Required Services

| Service | Required? | Why |
| --- | --- | --- |
| PHP-FPM (or equivalent) + web server (Nginx/Apache) | Yes | Serves the Laravel app and the mobile/admin HTTP surface — standard Laravel hosting, nothing app-specific here. |
| MySQL | Yes | The only supported database (`CLAUDE.md`); every table, migration, and query in this codebase targets it. |
| A **persistent** queue worker process | Yes | `config/queue.php`'s default connection is `database` (`QUEUE_CONNECTION` unset in production defaults to it) — jobs are written to the `jobs` table and sit there **forever** until something runs `php artisan queue:work`. `App\Jobs\SendPushSignal` (WP-06-05) is the only queued job today; without a running worker, no push notification is ever actually sent (guardians still eventually see the underlying change via ordinary sync — WP-08-05's "missed push does not lose the notification" — but push delivery itself silently does nothing, indefinitely, with no error surfaced anywhere). |
| A cron entry running the scheduler | Yes | `routes/console.php` registers three `everyFifteenMinutes()` commands (below) via Laravel's scheduler, which itself does nothing unless something invokes `php artisan schedule:run` every minute — the standard single cron entry, not one cron line per command. |
| Firebase credentials (`FIREBASE_CREDENTIALS` env var → a real service account JSON path) | Optional, but required for push to function | `docs/NOTIFICATIONS.md`: `config/firebase.php` reads this env var; unset, `SendPushSignal` throws quickly and records the attempt as `Failed` (traceable, WP-08-06) rather than crashing anything. The app is fully usable via ordinary sync with no Firebase project configured at all — this is a real, supported deployment state (e.g. an early pilot), not just a dev-environment fallback. |

## Scheduled Commands (require the cron entry above)

All three already exist, are tested (`tests/Feature/Console/*CommandTest.php`),
and are registered in `routes/console.php`:

- `attendance:mark-absences` — `App\Console\Commands\MarkDailyAttendanceAbsences`.
  Runs every 15 minutes rather than once at a fixed time because the
  absence cutoff is a configurable time-of-day (`AttendanceRule`), not a
  constant — the command itself decides whether "now" is past today's
  cutoff, so running it repeatedly is safe (idempotent — it only marks a
  student absent once).
- `announcements:expire` — `App\Console\Commands\ExpireAnnouncements`.
  Same "poll frequently, decide internally" shape — `expires_at` is an
  admin-set instant, not a fixed clock time.
- `notifications:retry-failed-push` — `App\Console\Commands\RetryFailedPushDeliveries`.
  Re-dispatches `SendPushSignal` for notifications still `Failed` from a
  previous attempt (`docs/NOTIFICATIONS.md`'s "retry state," WP-06-06) —
  this is also queue-worker-dependent: re-dispatching does nothing
  without a worker to process the resulting job.

Cron entry (the one line every Laravel deployment needs, regardless of
how many `Schedule::command()` calls exist):

```
* * * * * cd /path/to/lens && php artisan schedule:run >> /dev/null 2>&1
```

## Deployment Commands

```
composer install --no-dev --optimize-autoloader
php artisan migrate --force
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

`--force` is required for `migrate` to run non-interactively when
`APP_ENV=production` (Laravel's own safety prompt otherwise blocks it).
The three `:cache` commands are standard Laravel production
optimizations — safe to run on every deploy since each is idempotent and
rebuilds from source. No `storage:link` step: `School.logo_url` is a
plain external URL column, not Laravel's own storage disk — this app
serves no locally-stored public files.

## Queue Worker Supervision

A worker process must be kept running and restarted if it dies —
`php artisan queue:work` alone exits on an unhandled error and is not
self-restarting. Supervisor (the standard choice for this exact problem)
config:

```ini
[program:lens-queue-worker]
process_name=%(program_name)s_%(process_num)02d
command=php /path/to/lens/artisan queue:work --sleep=3 --tries=1 --max-time=3600
autostart=true
autorestart=true
numprocs=1
redirect_stderr=true
stdout_logfile=/path/to/lens/storage/logs/queue-worker.log
```

`--tries=1` matches `App\Jobs\SendPushSignal`'s own documented design (no
built-in Laravel job retry — "retry state" is the separate
`notifications:retry-failed-push` scheduled sweep, WP-06-05/06-06's own
decision, not something a queue-level retry should second-guess).
`--max-time=3600` recycles the worker hourly (picks up code deploys
without a manual restart, standard practice) — Supervisor's
`autorestart` brings it back immediately.

Single `numprocs=1` is sized for this deployment: one queued job type,
pilot scale (WP-08-04's own throughput findings — the whole pipeline
comfortably outpaces realistic tap volume), no evidence of a queue
backlog risk that would justify more workers.

## Backup

- **Database**: `mysqldump` on a schedule appropriate to acceptable data
  loss (attendance/notification data is generated continuously during
  school hours — nightly is a reasonable pilot-scale default,
  more frequent if the school's own risk tolerance demands it). Standard
  command:
  ```
  mysqldump --single-transaction -u <user> -p <database> | gzip > lens-$(date +%Y%m%d-%H%M%S).sql.gz
  ```
  `--single-transaction` avoids locking tables during the dump (InnoDB,
  which every migration in this project uses by default).
- **Secrets**: `.env` and the Firebase credentials JSON are **not**
  reconstructable from a database backup — back them up separately,
  encrypted, wherever the deployment's own secret-management practice
  already stores them (never alongside the plain SQL dump).
- **Retention**: keep enough generations to recover from "the last N
  backups were also bad" (a corrupted backup discovered late) — a
  specific number is an operational decision for whoever runs the real
  deployment, not fixed here.

## Rollback

Two distinct rollback needs, handled differently:

- **A bad code deploy** (application bug, no schema change involved):
  redeploy the previous release (git revert / redeploy the prior tag) —
  no database action needed since the schema didn't change.
- **A bad migration**: `php artisan migrate:rollback` reverses the most
  recent batch — every migration in this codebase has a working `down()`
  (confirmed: all 28, `database/migrations/`), so this is mechanically
  available. Prefer a **forward-fixing migration** over rolling back in
  production whenever the mistake is additive (a new column/table) rather
  than destructive — rolling back drops data the reverted migration's own
  columns/tables were holding, which a forward fix does not. Reserve
  `migrate:rollback` for a migration that hasn't yet accumulated
  meaningful data, or restore from the most recent backup instead when it
  has.
- **Full restore**: for anything `migrate:rollback` can't cleanly undo
  (a destructive migration already run against real data), restore the
  most recent `mysqldump` backup rather than attempting to hand-reverse
  data loss.

## Health Check

`GET /api/v1/health` (unauthenticated, no throttle) — confirms the
Laravel app itself is booting and routing correctly. It does **not**
check database or queue connectivity (`App\Http\Controllers\Api\V1\HealthController`
returns a static `{"status": "ok", ...}` body) — suitable for a load
balancer's "is the process alive" probe, not a full readiness check. A
deployment relying on this for more than liveness should monitor the
queue worker process and `jobs`/`failed_jobs` table depth separately
(Supervisor's own process state covers the former).
