import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';

final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi(ref.watch(dioProvider));
});

/// `POST /auth/login` (`docs/api/AUTHENTICATION.md`) — school-bound: the
/// caller supplies the already locally-resolved `school_id`, not a
/// re-entered one (there is no School ID field on the login form; the
/// installation is already bound, per WP-07-03/04).
class AuthApi {
  AuthApi(this._dio);

  final Dio _dio;

  /// Returns the issued Sanctum token. Throws [ApiException] for every
  /// documented failure — wrong credentials, wrong school, non-guardian or
  /// inactive-guardian accounts, maintenance/disabled/version rejections,
  /// and rate limiting — each already carrying a safe, server-provided
  /// message.
  Future<String> login({
    required String schoolId,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {'school_id': schoolId, 'email': email, 'password': password},
      );

      final data = response.data!['data'] as Map<String, dynamic>;
      return data['token'] as String;
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  /// `GET /auth/me` — confirms the stored token is still accepted by the
  /// server. Throws [ApiException] (`statusCode` `401`) when it isn't;
  /// callers use that specifically to tell "expired/revoked" apart from a
  /// merely unreachable server.
  Future<void> currentUser() async {
    try {
      await _dio.get<Map<String, dynamic>>('/auth/me');
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  /// `POST /auth/logout` — revokes the token used to make the request.
  /// Callers should treat this as best-effort: local logout (clearing the
  /// stored token and guardian-owned data) proceeds even if this fails.
  Future<void> logout() async {
    try {
      await _dio.post<Map<String, dynamic>>('/auth/logout');
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }
}
