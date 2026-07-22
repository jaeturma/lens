import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import 'sync_change_entry.dart';

final syncApiProvider = Provider<SyncApi>((ref) {
  return SyncApi(ref.watch(dioProvider));
});

/// `GET /sync/changes` (`docs/api/SYNC.md`) — authenticated, paginated by
/// an opaque cursor. Callers must never decode, construct, or compare
/// cursor strings themselves (`docs/OFFLINE-SYNC.md` Cursor Rules) — pass
/// back exactly what a previous call returned as `nextCursor`.
class SyncApi {
  SyncApi(this._dio);

  final Dio _dio;

  Future<SyncChangesPage> fetchChanges({
    required String cursor,
    int limit = 100,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/sync/changes',
        queryParameters: {'cursor': cursor, 'limit': limit},
      );

      return SyncChangesPage.fromJson(
        response.data!['data'] as Map<String, dynamic>,
      );
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }
}
