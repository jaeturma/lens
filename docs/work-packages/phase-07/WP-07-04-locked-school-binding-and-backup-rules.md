# WP-07-04 — Locked School Binding and Backup Rules

## Objective

Lock the school selection and ensure uninstall resets it.

## Affected Layers

- [ ] Laravel
- [ ] Database
- [ ] API
- [x] Flutter
- [x] Android
- [ ] RFID Integration

## Scope

Remove all app reset routes, preserve binding on logout, and exclude binding, secure state, and SQLite from Android backup/restore.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

WP-07-03.

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

- App restart does not ask again.
- Logout preserves school.
- No in-app change/remove option exists.
- Reinstall begins unbound.
- Android backup rules are tested or manually verified.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes

**Android backup exclusion** (the concretely actionable part of this
package right now):

- `AndroidManifest.xml`: `android:fullBackupContent="@xml/backup_rules"`
  (API 24-30) and `android:dataExtractionRules="@xml/data_extraction_rules"`
  (API 31+, takes precedence there and also governs device-to-device
  transfer, which `fullBackupContent` does not cover).
- Both files exclude `domain="root" path="app_flutter/"` (the Drift SQLite
  database — including the school binding in `school_profile`) and
  `domain="sharedpref" path="."` (flutter_secure_storage's
  `EncryptedSharedPreferences`, the access token).
- **Why `domain="root"`, not `domain="database"`**: verified against the
  actual resolved plugin versions (`pubspec.lock`), not assumed.
  `drift_flutter` opens the database via path_provider's
  `getApplicationDocumentsPath()`; `path_provider_android` 2.3.1
  (currently resolved) implements that as
  `Context.getDir("flutter", MODE_PRIVATE)`, which creates `app_flutter/`
  directly under the app's private data root — a sibling of `files/`, not
  inside it, and not created via `Context.openOrCreateDatabase()` either.
  Android's backup domain for that is `"root"` with a relative `path`,
  not `"database"` (reserved for `getDatabasePath()`) or `"file"`
  (reserved for `getFilesDir()`). Using the wrong domain here would have
  silently excluded nothing — Android's backup XML schema doesn't error on
  a domain/path that matches no real directory.
- `flutter_secure_storage` 10.3.1 confirmed via its own Android source
  (`FlutterSecureStorageConfig.java`) to use plain `SharedPreferences`
  (`sharedpref` domain), not a separate keystore file.

**What's automatable vs. not**: everything above is config, not code — it
cannot be exercised by `flutter test`. It has been reasoned through against
the exact resolved plugin versions above, but the acceptance criterion
"Android backup rules are tested or manually verified" is only satisfied
via manual verification, not automated test coverage. Recommend confirming
with `adb shell bmgr backupnow <applicationId>` followed by a reinstall
(or `adb backup`/`adb restore`) on a real device or emulator before
shipping — this repository has no Android emulator available to do that
here.

**The other four acceptance criteria**, given no login/logout/reset screen
exists yet (that's WP-07-06/07-07):

- **"App restart does not ask again"**: tested directly —
  `app_database_test.dart` now opens two independent `AppDatabase`
  instances against the same on-disk file (not `NativeDatabase.memory()`,
  which a real restart never has), the second standing in for what app
  startup constructs after a process restart, and confirms the school
  binding is still there. `SchoolBindingGate` (WP-07-03) already renders
  off exactly this data reactively, so this closes the loop back to the
  UI without needing a full integration test.
- **"Logout preserves school"**: there is no logout action yet. The one
  session-clearing primitive that exists today, `TokenStorage.clearAccessToken()`,
  has no reference to `AppDatabase`/`SchoolProfileDao` at all (confirmed by
  inspection — it only ever touches `flutter_secure_storage`), so nothing
  today is capable of touching the binding on "logout." Not something a
  runtime test can usefully cover before a real logout flow (WP-07-07)
  exists to test.
- **"No in-app change/remove option exists"**: `SchoolProfileDao` (WP-07-02)
  exposes `upsert`/`watch` only — no delete/clear method exists for it to
  call. `app_router_test.dart` (new) asserts the router's route table is
  exactly `[AppRoutes.foundation]` today, as a regression guard against a
  reset/change route being added later without a conscious decision to
  revisit this package.
- **"Remove all app reset routes"**: none exist to remove; verified by the
  same router test above.

Verification: `flutter analyze` clean, `dart format` applied, `flutter
test` — 15/15 passing (2 new: the restart-persistence test and the router
route-table test).
