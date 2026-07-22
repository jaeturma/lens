import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/auth/application/session_controller.dart';
import 'package:mobile/features/sync/data/sync_api.dart';
import 'package:mobile/features/sync/data/sync_change_entry.dart';

/// ProviderScope's disposal cancels any active drift stream-query
/// subscription (e.g. the school-binding gate's), which drift schedules
/// onto a zero-duration timer (`StreamQueryStore.markAsClosed`). Left to
/// flutter_test's own end-of-test teardown, that timer is still pending
/// when the framework's leak check runs — swap the tree out and pump here
/// instead, while the test still controls pumping.
Future<void> disposeAppUnderTest(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
}

/// `SessionController`'s real `build()` reads secure storage, whose
/// platform channel has no test-time mock — tests that don't care about
/// authentication state (e.g. WP-07-05's school-status gate tests) should
/// override `sessionControllerProvider` with one of these rather than let
/// it fail and fall through to the "unauthenticated" branch by accident.
class FakeAuthenticatedSession extends SessionController {
  @override
  Future<bool> build() async => true;
}

class FakeUnauthenticatedSession extends SessionController {
  @override
  Future<bool> build() async => false;
}

/// `FoundationPage` fires a sync on every build (WP-07-08's "support
/// startup"), which would otherwise reach the real `dioProvider` and hang
/// for a full connect-timeout in any test that renders it. Override
/// `syncApiProvider` with this in such tests unless the test is
/// specifically exercising sync behavior itself.
class NoOpSyncApi extends SyncApi {
  NoOpSyncApi() : super(Dio());

  @override
  Future<SyncChangesPage> fetchChanges({
    required String cursor,
    int limit = 100,
  }) async {
    return SyncChangesPage(
      nextCursor: cursor,
      hasMore: false,
      changes: const [],
    );
  }
}
