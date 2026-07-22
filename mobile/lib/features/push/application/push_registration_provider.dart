import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/daos.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/network/api_exception.dart';
import '../data/device_tokens_api.dart';
import '../data/push_messaging_service.dart';

final pushControllerProvider = Provider<PushController>((ref) {
  final controller = PushController(
    ref.watch(pushMessagingServiceProvider),
    ref.watch(deviceTokensApiProvider),
    ref.watch(appDatabaseProvider).appSettingsDao,
  );
  ref.onDispose(controller.dispose);
  return controller;
});

/// Fires once per app session, the first time something watches it —
/// `HomePage`, the same "support startup" shape `startupSyncProvider`
/// already uses. "Token registration and refresh work" (WP-07-13):
/// requests notification permission, registers the current FCM token if
/// granted, and keeps listening for Firebase-initiated token rotation for
/// as long as the app runs. A no-op end to end when
/// `AppConfig.firebaseConfigured` is false (`NoOpPushMessagingService`
/// never grants permission or produces a token).
final pushRegistrationProvider = FutureProvider<void>((ref) {
  return ref.read(pushControllerProvider).start();
});

class PushController {
  PushController(this._messaging, this._api, this._settings);

  /// Public so `SessionController.logout` (a different feature) and tests
  /// can read/verify the same key without duplicating the string.
  static const deviceTokenSettingKey = 'push_device_token';

  final PushMessagingService _messaging;
  final DeviceTokensApi _api;
  final AppSettingsDao _settings;
  StreamSubscription<String>? _refreshSubscription;

  Future<void> start() async {
    final granted = await _messaging.requestPermission();
    if (!granted) {
      // "App remains usable without notification permission" — every
      // other screen already reads from locally synced data regardless;
      // simply never registering a token is enough.
      return;
    }

    final token = await _messaging.getToken();
    if (token != null) {
      await _registerAndPersist(token);
    }

    _refreshSubscription = _messaging.onTokenRefresh.listen(
      _registerAndPersist,
    );
  }

  Future<void> _registerAndPersist(String token) async {
    final previousToken = await _settings.read(deviceTokenSettingKey);
    if (previousToken == token) {
      return;
    }

    try {
      await _api.register(token, previousToken: previousToken);
      await _settings.write(deviceTokenSettingKey, token);
    } on ApiException {
      // Best-effort: a failed registration is retried the next time
      // `start()` runs (app restart) or Firebase rotates the token again.
    }
  }

  /// `SessionController.logout`'s own best-effort device-token revoke
  /// (`docs/NOTIFICATIONS.md`'s "revoking is the client's responsibility").
  /// Clears the locally cached token too — not just cosmetic: leaving a
  /// stale match there would make the next login's `_registerAndPersist`
  /// see "no change" and skip re-registering an now-revoked token.
  Future<void> revokeAndForget() async {
    final token = await _settings.read(deviceTokenSettingKey);
    if (token == null) {
      return;
    }

    try {
      await _api.revoke(token);
    } on ApiException {
      // Best-effort — see `_registerAndPersist`.
    }

    await _settings.write(deviceTokenSettingKey, null);
  }

  void dispose() {
    _refreshSubscription?.cancel();
  }
}
