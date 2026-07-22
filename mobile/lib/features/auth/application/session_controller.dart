import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/token_storage.dart';

final sessionControllerProvider =
    AsyncNotifierProvider<SessionController, bool>(SessionController.new);

/// Whether a session currently exists — an access token has been stored.
/// WP-07-06's own concern is only ever setting this `true`, right after a
/// successful login (`markAuthenticated`); re-validating an existing
/// token's continued validity against the server and clearing it on
/// logout is WP-07-07's job (Session Restoration and Logout).
class SessionController extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final token = await ref.watch(tokenStorageProvider).readAccessToken();
    return token != null;
  }

  void markAuthenticated() {
    state = const AsyncData(true);
  }
}
