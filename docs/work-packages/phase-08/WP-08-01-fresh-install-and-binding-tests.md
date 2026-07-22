# WP-08-01 — Fresh Install and Binding Tests

## Objective

Validate first install, School ID resolution, lock, restart, logout, app-data clear, uninstall, and reinstall behavior.

## Affected Layers

- [ ] Laravel
- [ ] Database
- [x] API
- [x] Flutter
- [x] Android
- [ ] RFID Integration

## Scope

Include manual device checks where automation is impractical.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

Phase 7.

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

- All binding scenarios are documented and pass.
- Android backup does not restore binding after reinstall.
- No reset option is exposed.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes

Flutter/Android only — no Laravel/Database changes (this package
validates, and where genuinely missing, extends test coverage of binding
behavior already built across WP-07-03/04/06/07/14; nothing new is read
from or written to the server).

### Scenario → Evidence

| Objective scenario | Where it's proven |
| --- | --- |
| First install (unbound → School ID setup shown) | `test/features/school_setup/school_id_setup_page_test.dart` |
| School ID resolution (resolve → confirm → persists → proceeds) | `test/features/school_setup/school_id_setup_page_test.dart`, `school_id_setup_controller_test.dart` |
| Lock (bound install never re-prompts; gating states render correctly) | `test/features/school_setup/school_binding_gate_test.dart` |
| Restart (binding survives a fresh process over the same file) | `test/core/database/app_database_test.dart` (file-backed, two `AppDatabase` instances) |
| Logout (preserves school binding, returns to login) | `test/features/auth/logout_flow_test.dart`, `test/features/profile/profile_logout_flow_test.dart` |
| App-data clear / uninstall+reinstall (begins unbound) | `test/app/fresh_install_and_binding_test.dart` (new) |
| No reset option exposed | `test/app/router/app_router_test.dart` |
| Android backup excludes binding + SQLite + secure storage | `android/app/src/main/res/xml/backup_rules.xml`/`data_extraction_rules.xml` (config, re-verified below, not test-covered) |

Only one row above needed new code: **app-data clear / uninstall+reinstall**
had no assertion anywhere tying "empty local storage" explicitly to this
package's own acceptance criterion, even though it's the same code path as
first install by construction. Added
`test/app/fresh_install_and_binding_test.dart`.

### Re-verified, Not Re-authored: Android Backup Exclusion

`backup_rules.xml`/`data_extraction_rules.xml` (WP-07-04) exclude the
entire `app_flutter/` directory (domain `root`) and all of `sharedpref`
(domain `sharedpref`, path `.`). Re-checked against everything added since
WP-07-04 (Announcements, Notifications, SyncState, AppSettings tables,
the WP-07-13 push-device-token cache) — all of it lives in the same one
Drift SQLite file under `app_flutter/`, or in `flutter_secure_storage`'s
`SharedPreferences` (confirmed unchanged at 10.3.1 in `pubspec.lock`), so
both exclusion rules remain complete with no edits needed.

### A Test That Was Attempted and Deliberately Dropped

A widget-level "restart" test (a file-backed `NativeDatabase`, pumped
through the full `LensApp` tree, to close the loop from `app_database_test.dart`'s
database-only proof to the full UI) reproducibly hung `pumpAndSettle` past
its 10-minute timeout — in both an initial two-pumpWidget-per-test version
and a simplified single-pump version — something specific to a file-backed
`NativeDatabase` inside a widget test that doesn't occur with
`NativeDatabase.memory()` (used by every other passing test in this
suite). Rather than force a fragile, hanging test into the suite for
marginal additional confidence, it was dropped: the restart invariant
remains proven by the existing combination of
`app_database_test.dart`'s file-backed, non-widget proof plus every other
passing widget test's proof that `SchoolBindingGate` reacts correctly to
`schoolProfileDao.watch()`.

### Manual Device Verification Checklist (Automation Impractical)

No Android emulator/device is attached to this development machine (only
Windows desktop and web targets — confirmed via `flutter devices`), so
the following remain manual, pre-release checks, same conclusion WP-07-04
already reached for backup rules specifically:

1. Fresh install on a real device/emulator → confirm the School ID setup
   screen appears exactly once, before any content.
2. Force-stop and relaunch the app → confirm no re-prompt (restart, on
   real Android process lifecycle rather than a Dart-level simulation).
3. `adb shell bmgr backupnow <applicationId>`, then uninstall and
   reinstall (or `adb backup`/`adb restore`) → confirm the School ID
   setup screen appears again, i.e. the binding, SQLite database, and
   secure-storage token were **not** restored.
4. Settings → App info → Storage → Clear storage, without uninstalling →
   confirm the app behaves exactly like a fresh install on next launch.
5. Uninstall and reinstall without any backup step → confirm a clean
   unbound state (same as #1).

### No Reset Option, Confirmed

`app_router_test.dart`'s route-table assertion (kept up to date as every
subsequent phase-07 package added its own route) continues to guard
against a reset/change-school route being added without a conscious
decision to revisit this package.

Verified: `flutter analyze` clean; full mobile suite passing, 117/117
(`flutter test --concurrency=1`).

No migrations, no new API contracts. Unresolved risk: items 1-5 above
remain unverified on a real device/emulator in this environment.
