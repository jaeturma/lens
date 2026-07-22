import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';

final pushMessagingServiceProvider = Provider<PushMessagingService>((ref) {
  return AppConfig.firebaseConfigured
      ? FirebasePushMessagingService()
      : NoOpPushMessagingService();
});

/// The device-level push transport (WP-07-13) — deliberately narrow: a
/// thin wrapper around whatever `FirebaseMessaging.instance` exposes,
/// exchanged for [NoOpPushMessagingService] whenever Firebase isn't
/// configured (this development environment included) or in tests, the
/// same "swap the real implementation for a fake behind a Riverpod
/// provider" shape `AuthApi`/`SyncApi` already use.
abstract class PushMessagingService {
  /// Requests notification permission. Never throws for a denial — a
  /// denial is a normal, supported outcome ("app remains usable without
  /// notification permission"), not a failure.
  Future<bool> requestPermission();

  /// The current FCM registration token, or `null` if permission was
  /// denied, Firebase isn't configured, or none is available yet.
  Future<String?> getToken();

  /// Fires whenever Firebase rotates this device's token.
  Stream<String> get onTokenRefresh;

  /// Fires while the app is in the foreground.
  Stream<void> get onMessage;

  /// Fires when a guardian taps a push notification and the app was
  /// already running (background, not terminated).
  Stream<void> get onMessageOpenedApp;

  /// Whether the app was launched by tapping a push notification from a
  /// fully terminated state.
  Future<bool> openedFromTerminatedNotification();
}

class FirebasePushMessagingService implements PushMessagingService {
  @override
  Future<bool> requestPermission() async {
    final settings = await FirebaseMessaging.instance.requestPermission();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  @override
  Future<String?> getToken() => FirebaseMessaging.instance.getToken();

  @override
  Stream<String> get onTokenRefresh =>
      FirebaseMessaging.instance.onTokenRefresh;

  @override
  Stream<void> get onMessage => FirebaseMessaging.onMessage;

  @override
  Stream<void> get onMessageOpenedApp => FirebaseMessaging.onMessageOpenedApp;

  @override
  Future<bool> openedFromTerminatedNotification() async {
    final message = await FirebaseMessaging.instance.getInitialMessage();
    return message != null;
  }
}

/// Used whenever `AppConfig.firebaseConfigured` is false — every method is
/// a safe, silent no-op, so push registration/sync-triggers/tap-navigation
/// simply never fire rather than throwing on an unconfigured Firebase
/// project (`Firebase.initializeApp` was never even called in that case —
/// see `main.dart`).
class NoOpPushMessagingService implements PushMessagingService {
  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<String?> getToken() async => null;

  @override
  Stream<String> get onTokenRefresh => const Stream.empty();

  @override
  Stream<void> get onMessage => const Stream.empty();

  @override
  Stream<void> get onMessageOpenedApp => const Stream.empty();

  @override
  Future<bool> openedFromTerminatedNotification() async => false;
}
