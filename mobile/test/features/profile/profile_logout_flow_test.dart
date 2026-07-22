import 'package:dio/dio.dart';
import 'package:drift/native.dart';
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
import 'package:mobile/features/sync/data/sync_api.dart';

import '../../support/app_test_harness.dart';

class _FakeAuthApi extends AuthApi {
  _FakeAuthApi() : super(Dio());

  bool logoutCalled = false;

  @override
  Future<void> logout() async {
    logoutCalled = true;
  }
}

class _FakeTokenStorage extends TokenStorage {
  _FakeTokenStorage(this.token) : super(const FlutterSecureStorage());

  String? token;

  @override
  Future<String?> readAccessToken() async => token;

  @override
  Future<void> writeAccessToken(String value) async => token = value;

  @override
  Future<void> clearAccessToken() async => token = null;
}

void main() {
  testWidgets(
    '"Logout is available" (WP-07-14): the profile screen offers its own '
    'Log Out control, reached from the home screen\'s Profile action',
    (tester) async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      await database.schoolProfileDao.upsert(
        SchoolProfileCompanion.insert(
          uuid: 'school-uuid',
          publicId: 'SCH-0001',
          name: 'Example School',
          timezone: 'Asia/Manila',
          mobileEnabled: true,
          maintenanceMode: false,
          notificationsEnabled: true,
          minimumAppVersion: '0.1.0',
        ),
      );
      await database.guardianProfileDao.upsert(
        GuardianProfileCompanion.insert(
          uuid: 'guardian-uuid',
          name: 'Maria Dela Cruz',
          email: 'maria@example.com',
          mobileNumber: '09171234567',
          status: 'active',
          notifyAttendance: true,
          notifyAnnouncements: true,
        ),
      );

      final tokenStorage = _FakeTokenStorage('existing-token');
      final authApi = _FakeAuthApi();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(database),
            appVersionProvider.overrideWith((ref) async => '0.1.0'),
            sessionControllerProvider.overrideWith(
              FakeAuthenticatedSession.new,
            ),
            authApiProvider.overrideWithValue(authApi),
            tokenStorageProvider.overrideWithValue(tokenStorage),
            syncApiProvider.overrideWithValue(NoOpSyncApi()),
          ],
          child: const LensApp(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Profile'));
      await tester.pumpAndSettle();

      expect(find.text('Maria Dela Cruz'), findsOneWidget);

      await tester.tap(find.text('Log Out'));
      await tester.pumpAndSettle();

      expect(authApi.logoutCalled, isTrue);
      expect(tokenStorage.token, isNull);
      expect(find.text('Log in to Example School'), findsOneWidget);

      await disposeAppUnderTest(tester);
    },
  );
}
