import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../school_setup/data/resolved_school.dart';
import 'resolved_child.dart';
import 'resolved_guardian.dart';

final bootstrapApiProvider = Provider<BootstrapApi>((ref) {
  return BootstrapApi(ref.watch(dioProvider));
});

class BootstrapResult {
  const BootstrapResult({
    required this.school,
    required this.guardian,
    required this.children,
    required this.nextCursor,
  });

  final ResolvedSchool school;
  final ResolvedGuardian? guardian;
  final List<ResolvedChild> children;

  /// The change-feed position as of this bootstrap call
  /// (`docs/api/SYNC.md`) — the incremental sync engine's (WP-07-08)
  /// starting point, so its first call never re-fetches what bootstrap
  /// already returned.
  final String nextCursor;
}

/// `GET /sync/bootstrap` (`docs/api/SYNC.md`) — authenticated, so this is
/// only ever called once a guardian session exists (WP-07-06, right after
/// login). This package's own scope is the `school`, `guardian`,
/// `children`, and `next_cursor` fields of that response; `announcements`
/// belongs to whichever later work package consumes it (WP-07-11).
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
      final children = (data['children'] as List)
          .cast<Map<String, dynamic>>()
          .map(ResolvedChild.fromJson)
          .toList();

      return BootstrapResult(
        school: school,
        guardian: guardian,
        children: children,
        nextCursor: data['next_cursor'] as String,
      );
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }
}
