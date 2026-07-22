import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app/lens_app.dart';
import 'package:mobile/core/app_version_provider.dart';
import 'package:mobile/core/database/app_database.dart';
import 'package:mobile/core/database/database_provider.dart';
import 'package:mobile/features/auth/application/session_controller.dart';
import 'package:mobile/features/sync/data/sync_api.dart';

import '../../support/app_test_harness.dart';

Future<AppDatabase> seedBoundSchool(
  WidgetTester tester, {
  bool mobileEnabled = true,
  bool maintenanceMode = false,
  String? maintenanceMessage,
  String minimumAppVersion = '0.1.0',
}) async {
  final database = AppDatabase(NativeDatabase.memory());
  addTearDown(database.close);

  await database.schoolProfileDao.upsert(
    SchoolProfileCompanion.insert(
      uuid: 'school-uuid',
      publicId: 'SCH-0001',
      name: 'Example School',
      timezone: 'Asia/Manila',
      mobileEnabled: mobileEnabled,
      maintenanceMode: maintenanceMode,
      maintenanceMessage: Value(maintenanceMessage),
      notificationsEnabled: true,
      minimumAppVersion: minimumAppVersion,
    ),
  );

  return database;
}

void main() {
  testWidgets('mobile_enabled false blocks the app entirely', (tester) async {
    final database = await seedBoundSchool(tester, mobileEnabled: false);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          appVersionProvider.overrideWith((ref) async => '0.1.0'),
          sessionControllerProvider.overrideWith(FakeAuthenticatedSession.new),
          syncApiProvider.overrideWithValue(NoOpSyncApi()),
        ],
        child: const LensApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mobile Access Disabled'), findsOneWidget);
    expect(find.text('No linked children yet.'), findsNothing);

    await disposeAppUnderTest(tester);
  });

  testWidgets('an installed version below the school minimum blocks the app', (
    tester,
  ) async {
    final database = await seedBoundSchool(tester, minimumAppVersion: '9.0.0');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          appVersionProvider.overrideWith((ref) async => '0.1.0'),
          sessionControllerProvider.overrideWith(FakeAuthenticatedSession.new),
          syncApiProvider.overrideWithValue(NoOpSyncApi()),
        ],
        child: const LensApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Update Required'), findsOneWidget);
    expect(find.text('No linked children yet.'), findsNothing);

    await disposeAppUnderTest(tester);
  });

  testWidgets(
    'maintenance mode shows a non-blocking banner alongside normal content',
    (tester) async {
      final database = await seedBoundSchool(
        tester,
        maintenanceMode: true,
        maintenanceMessage: 'Down for scheduled maintenance.',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(database),
            appVersionProvider.overrideWith((ref) async => '0.1.0'),
            sessionControllerProvider.overrideWith(
              FakeAuthenticatedSession.new,
            ),
            syncApiProvider.overrideWithValue(NoOpSyncApi()),
          ],
          child: const LensApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Down for scheduled maintenance.'), findsOneWidget);
      expect(find.text('No linked children yet.'), findsOneWidget);

      await disposeAppUnderTest(tester);
    },
  );

  testWidgets('the normal case shows the bound school\'s name and content', (
    tester,
  ) async {
    final database = await seedBoundSchool(tester);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          appVersionProvider.overrideWith((ref) async => '0.1.0'),
          sessionControllerProvider.overrideWith(FakeAuthenticatedSession.new),
          syncApiProvider.overrideWithValue(NoOpSyncApi()),
        ],
        child: const LensApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Example School'), findsOneWidget);
    expect(find.text('No linked children yet.'), findsOneWidget);

    await disposeAppUnderTest(tester);
  });
}
