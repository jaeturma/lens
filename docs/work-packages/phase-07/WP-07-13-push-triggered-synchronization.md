# WP-07-13 — Push Triggered Synchronization

## Objective

Configure Firebase and trigger sync on foreground, background, resume, and notification open.

## Affected Layers

- [ ] Laravel
- [ ] Database
- [x] API
- [x] Flutter
- [x] Android
- [ ] RFID Integration

## Scope

Push is a signal; repositories fetch authoritative records.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

WP-06-05, WP-07-12.

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

- Token registration and refresh work.
- Push triggers sync.
- App remains usable without notification permission.
- Relevant destination opens after data is synchronized.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes

Flutter only (Laravel/API/Database already existed — WP-06-04 device
tokens, WP-06-05 push signal delivery — nothing server-side was needed).

- Added `firebase_core`/`firebase_messaging`. `AppConfig` gained
  `--dart-define`-sourced Firebase options and a `firebaseConfigured`
  getter; no `google-services.json`/Gradle plugin was added, so the
  Android build stays green with nothing configured (same "no real
  Firebase project in this environment" gap `docs/NOTIFICATIONS.md`
  already documents server-side).
- New `features/push/`: `DeviceTokensApi` (register/refresh/revoke),
  `PushMessagingService` (real Firebase impl + `NoOpPushMessagingService`
  swapped in whenever unconfigured or in tests), `PushController`
  (permission request, token registration/refresh, persisted locally via
  `app_settings`), `PushSyncTriggerController` (foreground/tap/terminated
  sync triggers + tap-opens-inbox navigation),
  `firebaseMessagingBackgroundHandler` (top-level background-isolate
  handler, builds its own Dio/AppDatabase/SyncEngine).
- `SessionController.logout` now also revokes this device's token,
  best-effort (`docs/NOTIFICATIONS.md`'s "revoking is the client's
  responsibility").
- `HomePage` watches the two new providers (same "fires once per
  session" shape as `startupSyncProvider`); `LensApp` gained a
  `WidgetsBindingObserver` for the resume trigger, unconditionally (no
  Firebase dependency for that one).
- `docs/NOTIFICATIONS.md` gained a "Flutter Push Registration and Sync
  Triggers (WP-07-13)" section.

Verified: `flutter analyze` clean; full mobile suite
(`flutter test --concurrency=1`) passing, including new
`test/features/push/` unit tests (registration/refresh/revoke) and
widget-level flow tests (foreground push syncs; a tap, backgrounded or
from terminated, syncs then opens the inbox).

Unresolved risk: no real Firebase project/credentials exist in this
environment and no Android emulator/device was attached, so actual push
delivery, real FCM token issuance, the background-isolate handler, and
the native Android Gradle build itself are unverified — everything above
was only checked at the Dart static-analysis/unit/widget-test level, with
`PushMessagingService` faked. Provisioning a real Firebase Android app
per environment remains a separate ops/deployment task.
