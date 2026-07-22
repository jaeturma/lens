import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app/lens_app.dart';
import 'package:mobile/core/database/app_database.dart';
import 'package:mobile/core/database/database_provider.dart';
import 'package:mobile/features/auth/application/session_controller.dart';
import 'package:mobile/features/school_setup/data/resolved_school.dart';
import 'package:mobile/features/school_setup/data/school_resolver_api.dart';
import 'package:mobile/features/sync/data/sync_api.dart';

import '../../support/app_test_harness.dart';

const _resolvedSchool = ResolvedSchool(
  schoolId: 'SCH-0001',
  uuid: 'school-uuid',
  name: 'Example School',
  logoUrl: null,
  timezone: 'Asia/Manila',
  mobileEnabled: true,
  maintenanceMode: false,
  maintenanceMessage: null,
  notificationsEnabled: true,
  minimumAppVersion: '0.1.0',
);

class _FakeSchoolResolverApi extends SchoolResolverApi {
  _FakeSchoolResolverApi() : super(Dio());

  @override
  Future<ResolvedSchool> resolve(String schoolId) async => _resolvedSchool;
}

void main() {
  testWidgets('submitting an empty School ID shows a validation error', (
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

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Enter your School ID.'), findsOneWidget);

    await disposeAppUnderTest(tester);
  });

  testWidgets(
    'resolving and confirming a School ID persists the binding and leaves the setup screen',
    (tester) async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(database),
            schoolResolverApiProvider.overrideWithValue(
              _FakeSchoolResolverApi(),
            ),
            sessionControllerProvider.overrideWith(
              FakeAuthenticatedSession.new,
            ),
            syncApiProvider.overrideWithValue(NoOpSyncApi()),
          ],
          child: const LensApp(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'SCH-0001');
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Example School'), findsOneWidget);

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(find.text('Set Up Your School'), findsNothing);
      expect(find.text('Foundation Ready'), findsOneWidget);

      await disposeAppUnderTest(tester);
    },
  );
}
