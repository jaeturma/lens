import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/network/api_exception.dart';
import '../data/notifications_api.dart';

/// "Inbox works offline" (WP-07-12) — reactive, straight off the local
/// `notifications` table, newest first. Populated entirely by the
/// incremental sync engine (WP-07-08); this provider never calls the API
/// itself.
final notificationsProvider = StreamProvider<List<NotificationRow>>((ref) {
  return ref.watch(appDatabaseProvider).notificationsDao.watchAll();
});

/// "Unread count updates" (WP-07-12) — a live count, not a snapshot, so a
/// badge built on this rebuilds the moment a read (local tap, or another
/// device's read syncing down) or a new notification lands.
final unreadNotificationsCountProvider = StreamProvider<int>((ref) {
  return ref.watch(appDatabaseProvider).notificationsDao.watchUnreadCount();
});

final notificationsControllerProvider = Provider<NotificationsController>((
  ref,
) {
  return NotificationsController(
    ref.watch(appDatabaseProvider),
    ref.watch(notificationsApiProvider),
  );
});

/// "Read state reconciles after sync" (WP-07-12): the local write happens
/// first and is what the guardian immediately sees, exactly the same
/// local-first / best-effort split `SessionController.logout` already
/// established for the server side of a client-initiated action. The
/// server's own acknowledgement reaches every device (including this one,
/// on its next sync) as an ordinary `guardian_notification` `updated`
/// entry through the existing sync feed — no special-casing of "my own
/// change coming back" is needed, since re-applying an already-read
/// `read_at` is a no-op both locally (`markReadLocally`'s own `WHERE
/// read_at IS NULL`) and server-side (`MarkNotificationRead`).
class NotificationsController {
  NotificationsController(this._database, this._api);

  final AppDatabase _database;
  final NotificationsApi _api;

  /// Safe to call for a notification that's already read, locally or on
  /// the server (both sides are no-ops in that case) — callers do not need
  /// to check current read state first. `NotificationsPage` relies on this
  /// to call it on every tap: a failed server call above simply gets
  /// retried the next time the same row is tapped, with no separate retry
  /// mechanism needed.
  Future<void> markRead(String uuid) async {
    await _database.notificationsDao.markReadLocally(uuid);

    try {
      await _api.markRead(uuid);
    } on ApiException {
      // Best-effort — see doc comment above.
    }
  }
}
