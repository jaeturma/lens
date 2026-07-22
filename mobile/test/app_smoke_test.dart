import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app/lens_app.dart';
import 'package:mobile/core/database/app_database.dart';
import 'package:mobile/core/database/database_provider.dart';

import 'support/app_test_harness.dart';

void main() {
  testWidgets('an unbound install shows the School ID setup screen', (
    tester,
  ) async {
    // overrideWithValue bypasses appDatabaseProvider's own body, so its
    // ref.onDispose(database.close) never registers — close it explicitly.
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: const LensApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Set Up Your School'), findsOneWidget);
    expect(find.text('Enter your School ID'), findsOneWidget);

    await disposeAppUnderTest(tester);
  });
}
