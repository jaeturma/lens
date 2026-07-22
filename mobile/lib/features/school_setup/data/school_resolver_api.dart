import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import 'resolved_school.dart';

final schoolResolverApiProvider = Provider<SchoolResolverApi>((ref) {
  return SchoolResolverApi(ref.watch(dioProvider));
});

class SchoolResolverApi {
  SchoolResolverApi(this._dio);

  final Dio _dio;

  /// Throws [ApiException] when [schoolId] does not resolve to a school —
  /// the resolver's `404` message is already safe to show as-is (see
  /// `docs/api/SCHOOL-RESOLVER.md`: generic, no information leak).
  Future<ResolvedSchool> resolve(String schoolId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/schools/resolve/$schoolId',
      );

      final data = response.data!['data'] as Map<String, dynamic>;
      return ResolvedSchool.fromJson(data);
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }
}
