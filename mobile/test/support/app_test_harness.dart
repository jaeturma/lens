import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/auth/application/session_controller.dart';

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
