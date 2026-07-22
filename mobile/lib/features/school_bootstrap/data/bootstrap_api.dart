import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../school_setup/data/resolved_school.dart';
import 'resolved_guardian.dart';

final bootstrapApiProvider = Provider<BootstrapApi>((ref) {
  return BootstrapApi(ref.watch(dioProvider));
});

class BootstrapResult {
  const BootstrapResult({required this.school, required this.guardian});

  final ResolvedSchool school;
  final ResolvedGuardian? guardian;
}

/// `GET /sync/bootstrap` (`docs/api/SYNC.md`) — authenticated, so this is
/// only ever called once a guardian session exists (WP-07-06, right after
/// login). This package's own scope is the `school` and `guardian` fields
/// of that response; the rest (`children`, `announcements`, `next_cursor`)
/// belongs to whichever later work package consumes it (WP-07-08/09/11).
class BootstrapApi {
  BootstrapApi(this._dio);

  final Dio _dio;

  Future<BootstrapResult> fetch() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/sync/bootstrap');

      final data = response.data!['data'] as Map<String, dynamic>;
      final school = ResolvedSchool.fromJson(
        data['school'] as Map<String, dynamic>,
      );
      final guardianJson = data['guardian'] as Map<String, dynamic>?;
      final guardian = guardianJson == null
          ? null
          : ResolvedGuardian.fromJson(guardianJson);

      return BootstrapResult(school: school, guardian: guardian);
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }
}
