import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/storage/token_storage.dart';
import '../../school_bootstrap/data/bootstrap_repository.dart';
import '../data/auth_api.dart';
import 'login_state.dart';
import 'session_controller.dart';

final loginControllerProvider = NotifierProvider<LoginController, LoginState>(
  LoginController.new,
);

class LoginController extends Notifier<LoginState> {
  @override
  LoginState build() => const LoginIdle();

  Future<void> login({
    required String schoolId,
    required String email,
    required String password,
  }) async {
    state = const LoginSubmitting();

    try {
      final token = await ref
          .read(authApiProvider)
          .login(schoolId: schoolId, email: email, password: password);

      await ref.read(tokenStorageProvider).writeAccessToken(token);

      // "Guardian profile is stored locally": the login response itself
      // carries no Guardian data (only id/name/email), so the guardian's
      // own profile comes from the same bootstrap call WP-07-05 already
      // uses for the school profile.
      await ref.read(bootstrapRepositoryProvider).sync();

      ref.read(sessionControllerProvider.notifier).markAuthenticated();

      // No further state transition: the authentication gate reactively
      // watches sessionControllerProvider and swaps away from this screen
      // once it flips, per docs/ARCHITECTURE.md's Runtime Data Flow.
    } on ApiException catch (exception) {
      state = LoginIdle(errorMessage: exception.message);
    }
  }
}
