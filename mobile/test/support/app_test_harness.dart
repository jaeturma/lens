import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

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
