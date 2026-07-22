import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/storage/token_storage.dart';
import '../data/auth_api.dart';

final sessionControllerProvider =
    AsyncNotifierProvider<SessionController, bool>(SessionController.new);

/// Whether a session currently exists.
///
/// `build()` is "session restores when valid" (WP-07-07): a stored token
/// is re-checked against `GET /auth/me` before being trusted, rather than
/// WP-07-06's original naive "does a token exist" check. Only a `401`
/// (the server explicitly rejecting it) is treated as "expired token
/// returns to login" and clears the stored token; any other failure
/// (network unreachable, server error) fails open and keeps the guardian
/// signed in — offline-first (`docs/OFFLINE-SYNC.md` Offline Behavior)
/// means a lost connection must not look like a logout.
class SessionController extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final token = await ref.watch(tokenStorageProvider).readAccessToken();
    if (token == null) {
      return false;
    }

    try {
      await ref.read(authApiProvider).currentUser();
      return true;
    } on ApiException catch (exception) {
      if (exception.statusCode == 401) {
        await ref.read(tokenStorageProvider).clearAccessToken();
        return false;
      }
      return true;
    }
  }

  void markAuthenticated() {
    state = const AsyncData(true);
  }

  /// "Logout must preserve school binding and school profile while
  /// clearing token and guardian-owned synchronized data" (WP-07-07's own
  /// Scope line). The server-side revoke is best-effort: local logout
  /// proceeds even if it fails (unreachable server, already-expired
  /// token) — the guardian's own device state is what a guardian expects
  /// "log out" to actually change.
  Future<void> logout() async {
    try {
      await ref.read(authApiProvider).logout();
    } on ApiException {
      // Best-effort — see doc comment above.
    }

    await ref.read(tokenStorageProvider).clearAccessToken();
    await ref.read(appDatabaseProvider).clearGuardianOwnedData();

    state = const AsyncData(false);
  }
}
