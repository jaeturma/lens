import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';

final notificationsApiProvider = Provider<NotificationsApi>((ref) {
  return NotificationsApi(ref.watch(dioProvider));
});

/// `PATCH /notifications/{uuid}/read` (`docs/api/NOTIFICATIONS.md`,
/// WP-07-12) — the only notifications endpoint this Flutter layer calls;
/// there is no "list" or "unread count" endpoint by design, since the
/// inbox and its badge are both derived from the already-synced local
/// table (`docs/ARCHITECTURE.md` Runtime Data Flow).
class NotificationsApi {
  NotificationsApi(this._dio);

  final Dio _dio;

  /// Throws [ApiException] on failure. Callers treat this as best-effort
  /// (`NotificationsController.markRead`) — the local read state is what a
  /// guardian actually sees, and is set before this is even called.
  Future<void> markRead(String uuid) async {
    try {
      await _dio.patch<Map<String, dynamic>>('/notifications/$uuid/read');
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }
}
