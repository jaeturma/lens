import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../../sync/application/sync_engine.dart';
import '../data/push_messaging_service.dart';

final pushSyncTriggerControllerProvider = Provider<PushSyncTriggerController>((
  ref,
) {
  final controller = PushSyncTriggerController(
    ref.watch(pushMessagingServiceProvider),
    ref.watch(syncEngineProvider),
    ref.watch(appRouterProvider),
  );
  ref.onDispose(controller.dispose);
  return controller;
});

/// Fires once per app session (`HomePage`, same shape as
/// `startupSyncProvider`/`pushRegistrationProvider`). "Push triggers sync"
/// and "relevant destination opens after data is synchronized"
/// (WP-07-13). A no-op end to end when Firebase isn't configured
/// (`NoOpPushMessagingService`'s streams never emit).
final pushSyncTriggerProvider = FutureProvider<void>((ref) {
  return ref.read(pushSyncTriggerControllerProvider).start();
});

/// The push payload is deliberately content-free — "purely a wake-up
/// trigger" (`docs/NOTIFICATIONS.md`, WP-06-05) — so there is no specific
/// notification, student, or announcement to deep-link to. The one
/// destination guaranteed to reflect whatever just synced, regardless of
/// which `NotificationType` triggered it, is the notification inbox
/// itself (`AppRoutes.notifications`); that is "the relevant destination"
/// this class opens after a tap.
class PushSyncTriggerController {
  PushSyncTriggerController(this._messaging, this._syncEngine, this._router);

  final PushMessagingService _messaging;
  final SyncEngine _syncEngine;
  final GoRouter _router;
  StreamSubscription<void>? _foregroundSubscription;
  StreamSubscription<void>? _openedSubscription;

  Future<void> start() async {
    _foregroundSubscription = _messaging.onMessage.listen((_) => _sync());
    _openedSubscription = _messaging.onMessageOpenedApp.listen(
      (_) => _syncThenOpenInbox(),
    );

    if (await _messaging.openedFromTerminatedNotification()) {
      await _syncThenOpenInbox();
    }
  }

  Future<void> _sync() async {
    try {
      await _syncEngine.sync();
    } catch (_) {
      // Best-effort — a push is just a "go check" signal
      // (`docs/NOTIFICATIONS.md`); a failed sync here is no worse than a
      // failed pull-to-refresh, and the next successful one (startup,
      // resume, or another push) catches up from the same saved cursor.
    }
  }

  Future<void> _syncThenOpenInbox() async {
    await _sync();
    _router.push(AppRoutes.notifications);
  }

  void dispose() {
    _foregroundSubscription?.cancel();
    _openedSubscription?.cancel();
  }
}
