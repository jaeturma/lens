# WP-00-01 — Project Baseline

## Objective

Document the existing Laravel, Flutter, database, authentication, package, and test baseline without changing behavior.

## Affected Layers

- [x] Laravel
- [x] Database
- [ ] API
- [x] Flutter
- [x] Android
- [ ] RFID Integration

## Scope

Inspect only enough files and commands to establish the current state and risks.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

None.

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

- Baseline document exists.
- Current Flutter foundation is recorded.
- Existing documentation conflicts are identified.
- No application behavior changes.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes

- Re-baselined for the v1.1 offline-first/school-binding package. Read-only
  inspection only — no application code, config, dependencies, or database
  schema changed.
- **Backend:** Laravel Framework 13.20.0, PHP 8.3.16 (unchanged since v1.0
  baseline). `composer.json` name is still `laravel/react-starter-kit`.
  Fortify `^1.37.2` provides web/Inertia session auth; `laravel/sanctum` is
  **not installed** and `App\Models\User` has no `HasApiTokens` trait — still
  required for guardian mobile auth per `docs/SECURITY.md` and
  `docs/API-STANDARD.md` (Phase 01). Only `routes/{web,settings,console}.php`
  exist; no `routes/api.php` / `/api/v1` prefix yet (expected, Phase 01).
- **Database:** default connection falls back to `sqlite`
  (`config/database.php`), migrated with only the three default Laravel
  tables (`users`, `cache`, `jobs`). None of the LENS domain tables in
  `docs/DATABASE.md` exist yet. **Gap:** `docs/ARCHITECTURE.md` specifies
  MySQL as the source database, but the current installation runs on SQLite —
  the engine switch is not yet done and should be tracked before/at Phase 01
  rather than assumed.
- **Tests:** only the default starter-kit tests under `tests/Feature/{Auth,
  Settings}`, `DashboardTest.php`, `ExampleTest.php`, and
  `tests/Unit/ExampleTest.php`. No LENS-specific Pest tests yet.
- **Mobile (Flutter, `mobile/`):** Flutter 3.44.6 / Dart 3.12.2 (unchanged).
  Feature-first foundation already scaffolded (`lib/app` — GoRouter,
  `lib/core/{config,network,storage,theme,widgets}` — Dio client +
  `ApiException`, secure token storage, theme, shared widgets,
  `lib/features/foundation`). Dependencies match
  `CLAUDE-LENS-ADDENDUM.md`: `flutter_riverpod` 3.3.2, `go_router` 17.3.0,
  `dio` ^5.10.0, `flutter_secure_storage` 10.3.1. **Drift/SQLite is not yet
  installed** — required by WP-07-02 (Drift SQLite Foundation) before any
  offline-first screen work. Only `mobile/test/app_smoke_test.dart` exists.
- **Android:** `applicationId`/`namespace` in
  `mobile/android/app/build.gradle.kts` is still the placeholder
  `com.example.mobile`, pending WP-00-02 (Product Identity and Play Store
  Identity).
- **Documentation state:** the prior v1.0 doc tree was archived to
  `docs-archive/before-offline-first-v1.1/` and replaced by the v1.1 set
  listed in `PACKAGE-MANIFEST.md`; no duplicate/legacy work-package docs
  remain in the active `docs/` tree. `docs/PROJECT-BASELINE.md` was
  intentionally retired in favor of recording the baseline here, since it is
  not listed in `PACKAGE-MANIFEST.md`. Core docs inspected
  (`PROJECT-SCOPE.md`, `ARCHITECTURE.md`, `API-STANDARD.md`, `DATABASE.md`,
  `SECURITY.md`, `EXECUTION-ORDER.md`) are internally consistent aside from
  the MySQL/SQLite gap noted above.
- Leftover, unmodified directories still present at the repo root from the
  previous foundation install: `lens-flutter-foundation/` and
  `_foundation_backup_20260719-202508/`. Not touched — flagged for cleanup
  once no longer needed as a reference.
