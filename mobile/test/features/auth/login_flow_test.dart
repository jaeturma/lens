import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app/lens_app.dart';
import 'package:mobile/core/app_version_provider.dart';
import 'package:mobile/core/database/app_database.dart';
import 'package:mobile/core/database/database_provider.dart';
import 'package:mobile/core/storage/token_storage.dart';
import 'package:mobile/features/auth/application/session_controller.dart';
import 'package:mobile/features/auth/data/auth_api.dart';
import 'package:mobile/features/school_bootstrap/data/bootstrap_api.dart';
import 'package:mobile/features/school_bootstrap/data/resolved_guardian.dart';
import 'package:mobile/features/school_setup/data/resolved_school.dart';

import '../../support/app_test_harness.dart';

const _resolvedGuardian = ResolvedGuardian(
  uuid: 'guardian-uuid',
  name: 'Maria Dela Cruz',
  email: 'maria@example.com',
  mobileNumber: '09171234567',
  status: 'active',
  notifyAttendance: true,
  notifyAnnouncements: true,
);

class _FakeAuthApi extends AuthApi {
  _FakeAuthApi() : super(Dio());

  @override
  Future<String> login({
    required String schoolId,
    required String email,
    required String password,
  }) async => '1|abcdef';
}

class _FakeBootstrapApi extends BootstrapApi {
  _FakeBootstrapApi(this._school) : super(Dio());

  final ResolvedSchool _school;

  @override
  Future<BootstrapResult> fetch() async {
    return BootstrapResult(school: _school, guardian: _resolvedGuardian);
  }
}

class _FakeTokenStorage extends TokenStorage {
  _FakeTokenStorage() : super(const FlutterSecureStorage());

  String? token;

  @override
  Future<String?> readAccessToken() async => token;

  @override
  Future<void> writeAccessToken(String value) async => token = value;

  @override
  Future<void> clearAccessToken() async => token = null;
}

Future<AppDatabase> seedBoundSchool() async {
  final database = AppDatabase(NativeDatabase.memory());
  addTearDown(database.close);

  const school = ResolvedSchool(
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
  await database.schoolProfileDao.upsert(school.toCompanion());

  return database;
}

void main() {
  testWidgets('a bound but unauthenticated install shows the login screen', (
    tester,
  ) async {
    final database = await seedBoundSchool();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          appVersionProvider.overrideWith((ref) async => '0.1.0'),
          sessionControllerProvider.overrideWith(
            FakeUnauthenticatedSession.new,
          ),
        ],
        child: const LensApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Log in to Example School'), findsOneWidget);

    await disposeAppUnderTest(tester);
  });

  testWidgets(
    'submitting the login form with an empty password shows a validation error',
    (tester) async {
      final database = await seedBoundSchool();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(database),
            appVersionProvider.overrideWith((ref) async => '0.1.0'),
            sessionControllerProvider.overrideWith(
              FakeUnauthenticatedSession.new,
            ),
          ],
          child: const LensApp(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'maria@example.com',
      );
      await tester.tap(find.text('Log In'));
      await tester.pumpAndSettle();

      expect(find.text('Enter your password.'), findsOneWidget);

      await disposeAppUnderTest(tester);
    },
  );

  testWidgets(
    'a successful login caches the guardian profile and shows the authenticated screen',
    (tester) async {
      final database = await seedBoundSchool();
      final tokenStorage = _FakeTokenStorage();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(database),
            appVersionProvider.overrideWith((ref) async => '0.1.0'),
            sessionControllerProvider.overrideWith(
              FakeUnauthenticatedSession.new,
            ),
            authApiProvider.overrideWithValue(_FakeAuthApi()),
            bootstrapApiProvider.overrideWithValue(
              _FakeBootstrapApi(
                const ResolvedSchool(
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
                ),
              ),
            ),
            tokenStorageProvider.overrideWithValue(tokenStorage),
          ],
          child: const LensApp(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'maria@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'secret',
      );
      await tester.tap(find.text('Log In'));
      await tester.pumpAndSettle();

      expect(find.text('Log in to Example School'), findsNothing);
      expect(find.text('Foundation Ready'), findsOneWidget);
      expect(tokenStorage.token, '1|abcdef');

      final guardian = await database
          .select(database.guardianProfile)
          .getSingle();
      expect(guardian.uuid, 'guardian-uuid');

      await disposeAppUnderTest(tester);
    },
  );
}
