# WP-00-02 — Product Identity and Play Store Identity

## Objective

Set permanent LENS naming, Android application ID, display name, version strategy, and organization identifier.

## Affected Layers

- [x] Laravel
- [ ] Database
- [ ] API
- [x] Flutter
- [x] Android
- [ ] RFID Integration

## Scope

Replace example identity and document development versus production API configuration.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

WP-00-01.

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

- `com.example.mobile` is removed.
- Permanent app identity is documented.
- Release version strategy exists.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes

- **Android application ID / namespace:** permanently set to `com.lens.mobile`
  in `mobile/android/app/build.gradle.kts` (`namespace` and
  `defaultConfig.applicationId`). `com.example.mobile` is fully removed;
  `MainActivity.kt` moved from
  `mobile/android/app/src/main/kotlin/com/example/mobile/` to
  `mobile/android/app/src/main/kotlin/com/lens/mobile/` with its `package`
  declaration updated to match. This ID is permanent post-first-release —
  changing it after a Play Store publish would require a new listing.
- **Display name:** `LENS`. Set as `android:label` in
  `mobile/android/app/src/main/AndroidManifest.xml` (Android home screen /
  launcher label) and as `mobile/pubspec.yaml` `description`. Laravel
  `config/app.php` default `'name'` fallback changed from `'Laravel'` to
  `'LENS'` (actual value still comes from the `APP_NAME` env var per
  environment; `.env` / `.env.example` are not touched here — set
  `APP_NAME=LENS` there per environment). `composer.json` `name` changed to
  `lens/lens` and `description` to `LENS Digital School System API`.
- **Flutter package name unchanged:** `pubspec.yaml` `name: mobile` (the Dart
  package identifier used in every `import 'package:mobile/...'` statement)
  was deliberately left as-is. It is an internal build identifier, not
  user-facing product identity, and renaming it would require touching every
  file under `lib/` for no functional benefit within this package's scope.
- **Release version strategy:** Semantic Versioning
  (`MAJOR.MINOR.PATCH+BUILD`), pre-release track starting at `0.1.0+1`
  (`mobile/pubspec.yaml` `version`) until the first production Play Store
  release, at which point the mobile app moves to `1.0.0`. `BUILD`
  (Android `versionCode`, taken from the pubspec build number) increments on
  every release build, including within the same `MAJOR.MINOR.PATCH`.
  `MAJOR` increments on breaking changes to the offline sync contract or
  school-binding flow, `MINOR` on backward-compatible feature additions,
  `PATCH` on backward-compatible fixes.
