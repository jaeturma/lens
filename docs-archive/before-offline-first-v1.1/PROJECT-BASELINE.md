# LENS Project Baseline

Produced by WP-00-01 — Project Baseline. Read-only inspection; no application
behavior was changed. Supersedes ad-hoc notes; treat this as the current
snapshot, not a permanent contract.

## Backend (Laravel)

- Laravel Framework 13.20.0, PHP 8.3.16 (CLI, ZTS).
- `composer.json` name is `laravel/react-starter-kit`: the repo was
  bootstrapped from that starter kit, which explains the bundled Inertia +
  React web frontend used for administrator/school-admin web login
  (`docs/PROJECT-SCOPE.md` includes "administrator authentication" in scope).
- **Auth (web):** Laravel Fortify `^1.37` is installed and wired via
  `App\Providers\FortifyServiceProvider`, `App\Actions\Fortify\CreateNewUser`,
  `ResetUserPassword`. Provides session-based login, registration, password
  reset, 2FA, and profile/security settings for the Inertia web app.
- **Auth (mobile API): NOT installed.** No `laravel/sanctum` package, no
  `config/sanctum.php`, and `App\Models\User` has no `HasApiTokens` trait.
  `docs/SECURITY.md` and `docs/API-STANDARD.md` both require Sanctum for
  parent mobile auth — this is the responsibility of a later Phase 01 work
  package (Authentication Foundation), not this baseline.
- Other backend packages: `inertiajs/inertia-laravel` ^3.0, `laravel/wayfinder`
  ^0.1 (typed route helpers for the frontend), `laravel/chisel`.
- Dev tooling: Pest 4.7 + `pest-plugin-laravel`, Larastan/PHPStan
  (`phpstan.neon`), Pint (`pint.json`), Laravel Boost, Sail, Pail.
- **Routes:** only `routes/web.php`, `routes/settings.php`, `routes/console.php`
  exist. There is no `routes/api.php` and no `/api/v1` prefix yet
  (`docs/API-STANDARD.md` convention is not implemented yet — expected).
  `web.php` currently defines `/` (welcome), `/dashboard` (auth+verified), and
  requires `settings.php`.
- **Database:** default connection is `sqlite`
  (`database/database.sqlite`, already migrated). Only the three default
  Laravel migrations exist — `users`, `cache`, `jobs`. None of the LENS
  domain tables listed in `docs/DATABASE.md` (schools, students, guardians,
  rfid_*, attendance_*, announcements, notifications, audit_logs, etc.) exist
  yet; they are introduced in Phases 01-06.
- **Tests:** `tests/Feature/{Auth,Settings}`, `tests/Feature/DashboardTest.php`,
  `tests/Feature/ExampleTest.php`, `tests/Unit/ExampleTest.php` — all are the
  default starter-kit tests for Fortify/Inertia/Dashboard. No LENS-specific
  tests exist yet.

## Mobile (Flutter, `mobile/`)

- Flutter 3.44.6 (stable), Dart 3.12.2.
- A feature-first foundation is already scaffolded:
  - `lib/app/` — app widget + `go_router` router.
  - `lib/core/{config,network,storage,theme,widgets}` — app config, Dio API
    client + `ApiException`, secure token storage, theme, shared loading/error
    widgets.
  - `lib/features/foundation/` — placeholder foundation feature/page.
- Dependencies: `flutter_riverpod` 3.3.2, `go_router` 17.3.0, `dio` ^5.10.0,
  `flutter_secure_storage` 10.3.1 — matches
  `CLAUDE-LENS-ADDENDUM.md` ("Riverpod, GoRouter, Dio, and secure storage
  already installed").
- **Package name:** Android `applicationId`/`namespace` in
  `mobile/android/app/build.gradle.kts` is still the placeholder
  `com.example.mobile`. Expected to be set by WP-00-02 (Product Identity), not
  this work package.
- Tests: only `mobile/test/app_smoke_test.dart` exists.

## Risks / Gaps Affecting Later Phases

1. No Sanctum, no `/api/v1` routes, and no LENS database tables exist yet.
   Expected at this stage — tracked by Phases 01-06 — but flagged so later
   work packages don't assume any of it is already in place.
2. **Duplicate/legacy work-package docs** exist outside the canonical
   `docs/work-packages/phase-XX/` tree that `docs/EXECUTION-ORDER.md` drives:
   `docs/work-packages/WP-00-01-project-baseline.md`,
   `docs/work-packages/WP-00-02-architecture-alignment.md`,
   `docs/work-packages/WP-01-01-mobile-authentication.md`,
   `docs/mobile/work-packages/WP-MOB-00-01-api-contract-baseline.md`, and
   `docs/mobile/work-packages/WP-MOB-01-01-authentication.md`. These look like
   leftovers from merging more than one exported package (per
   `README-FIRST.md` / `STEP-BY-STEP.md`) and are not referenced by
   `EXECUTION-ORDER.md`. Left untouched (deleting/reorganizing docs is outside
   this work package's scope), but the project owner should confirm only the
   `phase-XX` tree is authoritative to avoid a future session implementing the
   wrong copy.
3. **Leftover installer/backup directories** at the repo root:
   `lens-flutter-foundation/` (the foundation installer package itself) and
   `_foundation_backup_20260719-202508/` (a backup of a prior `mobile/lib` and
   `mobile/test`). Neither is referenced by the app or build. Left untouched
   here since removal is a destructive action outside this work package's
   scope.
4. Android package name is still the placeholder `com.example.mobile` — must
   be renamed before release packaging; tracked by WP-00-02.

## Commands Used (read-only, no state changed)

- `php -v`
- `php artisan --version`
- `php artisan migrate:status`
- `flutter --version`
- Directory/file listings and file reads only.
