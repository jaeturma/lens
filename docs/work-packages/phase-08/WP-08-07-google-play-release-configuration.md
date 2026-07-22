# WP-08-07 — Google Play Release Configuration

## Objective

Prepare application ID, signing, AAB, versions, icons, screenshots, privacy policy references, and Data Safety inputs.

## Affected Layers

- [ ] Laravel
- [ ] Database
- [ ] API
- [x] Flutter
- [x] Android
- [ ] RFID Integration

## Scope

Document release and environment commands without committing secrets.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

WP-08-01, WP-08-06.

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

- Release AAB builds.
- Versioning is correct.
- Privacy and account/data deletion requirements are documented.
- Store listing checklist exists.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes

Per this package's own Scope line ("document release and environment
commands without committing secrets"), no real keystore, Firebase
project, or Play Console content was created — those require secrets or
brand/design assets this package cannot supply itself. The primary
deliverable is `docs/RELEASE.md`; see it for full detail, summarized
below.

### Code Changes

- `mobile/android/app/build.gradle.kts`: release `signingConfig` now
  reads `android/key.properties` (gitignored) when present, falling back
  to debug signing when absent — the original scaffold's `TODO: Add your
  own signing config` is now a working, secret-free mechanism rather than
  a permanent stub.
- `mobile/android/key.properties.example` (new, tracked, no secrets):
  the exact keys a release engineer must supply.
- `mobile/.gitignore`: added `/android/key.properties`, `*.jks`,
  `*.keystore`.
- `mobile/android/gradle.properties`: added `kotlin.incremental=false` —
  required to get a release build to actually complete in this
  environment (a Windows cross-drive path bug in Kotlin's incremental
  compiler, project on `D:`, Pub cache on `C:` — unrelated to app code or
  signing; see `docs/RELEASE.md` Build Commands for detail). Safe in any
  environment, affects only build caching.

### Acceptance Criteria

- **Release AAB builds**: verified directly —
  `flutter build appbundle --release` (no `--dart-define`, no
  `key.properties`) produced `app-release.aab` (56.9MB, debug-signed) in
  this environment. A production-signed, production-configured AAB
  requires a real keystore and `--dart-define` values supplied later, out
  of band — see `docs/RELEASE.md` Build Commands.
- **Versioning is correct**: `pubspec.yaml`'s `0.1.0+1` already maps
  correctly to `versionName`/`versionCode` via the unmodified scaffold
  `defaultConfig` — confirmed by the successful build above (a
  version/build-number mismatch would have failed it). Bump policy
  documented in `docs/RELEASE.md` Versioning.
- **Privacy and account/data deletion requirements are documented**: yes
  — `docs/RELEASE.md` Data Safety Declaration + Account and Data
  Deletion. Deletion is a request-to-administrator process, not a new
  in-app feature — deliberate, since guardian accounts are
  administrator-provisioned, not self-registered
  (`docs/SECURITY.md`), and attendance/RFID-derived records are the
  school's own operational records, not solely the guardian's to erase
  unilaterally. No new deletion endpoint was built; this documents the
  existing process (deactivation, WP-08-03's `EnsureGuardianAccountIsActive`,
  plus an administrative erasure request).
- **Store listing checklist exists**: `docs/RELEASE.md` Store Listing
  Checklist — icons and screenshots are explicitly marked pending
  (blocked on real brand assets and device/emulator access respectively,
  neither fabricated), everything else either documented or completed.

Verified: `flutter analyze` clean (no Dart files changed by this
package). No Dart test suite change needed or run — this package touched
only Android/Gradle configuration and documentation, nothing the Flutter
test suite exercises.

No migrations. No new/changed API contract — `docs/RELEASE.md`
cross-references existing `--dart-define` conventions
(`docs/NOTIFICATIONS.md`, WP-07-13) rather than introducing new ones.
Unresolved, explicitly flagged risks (not fixed here, by design): no real
app icon/brand assets, no captured screenshots, no hosted privacy policy
page, no real release keystore or Firebase project/Play Console
credentials — all require assets or decisions outside this package's
authority to invent.
