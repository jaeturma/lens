import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../school_setup/data/resolved_school.dart';

final bootstrapApiProvider = Provider<BootstrapApi>((ref) {
  return BootstrapApi(ref.watch(dioProvider));
});

/// `GET /sync/bootstrap` (`docs/api/SYNC.md`) — authenticated, so this is
/// only ever called once a guardian session exists (WP-07-06). This
/// package's own scope is only the `school` field of that response; the
/// rest (`guardian`, `children`, `announcements`, `next_cursor`) belongs to
/// whichever later work package consumes it (WP-07-08/09/11).
class BootstrapApi {
  BootstrapApi(this._dio);

  final Dio _dio;

  Future<ResolvedSchool> fetchSchool() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/sync/bootstrap');

      final data = response.data!['data'] as Map<String, dynamic>;
      final school = data['school'] as Map<String, dynamic>;
      return ResolvedSchool.fromJson(school);
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }
}
