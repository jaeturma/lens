import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';

final deviceTokensApiProvider = Provider<DeviceTokensApi>((ref) {
  return DeviceTokensApi(ref.watch(dioProvider));
});

/// `POST`/`DELETE /notifications/device-tokens` (`docs/NOTIFICATIONS.md`
/// WP-06-04) — the Flutter-side client that endpoint's own documentation
/// deferred: "that's Flutter-side work, out of scope for this session
/// (Laravel/API only)." This is that session.
class DeviceTokensApi {
  DeviceTokensApi(this._dio);

  final Dio _dio;

  /// Register a brand-new token, or refresh one Firebase has rotated
  /// (`previousToken` given) — both handled by the same server-side action
  /// (`RegisterDeviceToken`), so this is a single call either way.
  Future<void> register(String token, {String? previousToken}) async {
    try {
      await _dio.post<Map<String, dynamic>>(
        '/notifications/device-tokens',
        data: {'token': token, 'previous_token': previousToken},
      );
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  /// Revokes a token this device no longer wants push delivered to (a
  /// guardian's own logout, `SessionController.logout`). Idempotent
  /// server-side — safe to call for a token that's already revoked or
  /// unknown.
  Future<void> revoke(String token) async {
    try {
      await _dio.delete<Map<String, dynamic>>(
        '/notifications/device-tokens',
        data: {'token': token},
      );
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }
}
