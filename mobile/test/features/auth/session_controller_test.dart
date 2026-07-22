import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/database/app_database.dart';
import 'package:mobile/core/database/database_provider.dart';
import 'package:mobile/core/network/api_exception.dart';
import 'package:mobile/core/storage/token_storage.dart';
import 'package:mobile/features/auth/application/session_controller.dart';
import 'package:mobile/features/auth/data/auth_api.dart';
import 'package:mobile/features/push/application/push_registration_provider.dart';
import 'package:mobile/features/push/data/device_tokens_api.dart';

class _FakeTokenStorage extends TokenStorage {
  _FakeTokenStorage([this._token]) : super(const FlutterSecureStorage());

  String? _token;

  @override
  Future<String?> readAccessToken() async => _token;

  @override
  Future<void> writeAccessToken(String token) async => _token = token;

  @override
  Future<void> clearAccessToken() async => _token = null;
}

class _FakeAuthApi extends AuthApi {
  _FakeAuthApi({this.currentUserError, this.logoutError}) : super(Dio());

  final ApiException? currentUserError;
  final ApiException? logoutError;
  bool logoutCalled = false;

  @override
  Future<void> currentUser() async {
    if (currentUserError != null) throw currentUserError!;
  }

  @override
  Future<void> logout() async {
    logoutCalled = true;
    if (logoutError != null) throw logoutError!;
  }
}

class _FakeDeviceTokensApi extends DeviceTokensApi {
  _FakeDeviceTokensApi() : super(Dio());

  final revokeCalls = <String>[];

  @override
  Future<void> revoke(String token) async {
    revokeCalls.add(token);
  }
}

void main() {
  test(
    'no stored token means no session, without checking the server',
    () async {
      final container = ProviderContainer(
        overrides: [
          tokenStorageProvider.overrideWithValue(_FakeTokenStorage()),
          authApiProvider.overrideWithValue(_FakeAuthApi()),
        ],
      );
      addTearDown(container.dispose);

      final session = await container.read(sessionControllerProvider.future);
      expect(session, isFalse);
    },
  );

  test(
    'a stored token confirmed by GET /auth/me restores the session',
    () async {
      final container = ProviderContainer(
        overrides: [
          tokenStorageProvider.overrideWithValue(
            _FakeTokenStorage('existing-token'),
          ),
          authApiProvider.overrideWithValue(_FakeAuthApi()),
        ],
      );
      addTearDown(container.dispose);

      final session = await container.read(sessionControllerProvider.future);
      expect(session, isTrue);
    },
  );

  test(
    'a 401 from GET /auth/me clears the stored token and returns to login (expired token)',
    () async {
      final tokenStorage = _FakeTokenStorage('expired-token');
      final container = ProviderContainer(
        overrides: [
          tokenStorageProvider.overrideWithValue(tokenStorage),
          authApiProvider.overrideWithValue(
            _FakeAuthApi(
              currentUserError: const ApiException(
                message: 'Unauthenticated.',
                statusCode: 401,
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final session = await container.read(sessionControllerProvider.future);
      expect(session, isFalse);
      expect(await tokenStorage.readAccessToken(), isNull);
    },
  );

  test(
    'an unreachable server (non-401) fails open and keeps the guardian signed in',
    () async {
      final tokenStorage = _FakeTokenStorage('existing-token');
      final container = ProviderContainer(
        overrides: [
          tokenStorageProvider.overrideWithValue(tokenStorage),
          authApiProvider.overrideWithValue(
            _FakeAuthApi(
              currentUserError: const ApiException(
                message: 'Unable to complete the request.',
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final session = await container.read(sessionControllerProvider.future);
      expect(session, isTrue);
      expect(await tokenStorage.readAccessToken(), 'existing-token');
    },
  );

  test('markAuthenticated flips the state to true immediately', () async {
    final container = ProviderContainer(
      overrides: [
        tokenStorageProvider.overrideWithValue(_FakeTokenStorage()),
        authApiProvider.overrideWithValue(_FakeAuthApi()),
      ],
    );
    addTearDown(container.dispose);

    await container.read(sessionControllerProvider.future);
    container.read(sessionControllerProvider.notifier).markAuthenticated();

    expect(container.read(sessionControllerProvider).value, isTrue);
  });

  test(
    'logout revokes the token server-side, clears it locally, clears guardian-owned '
    'data, preserves the school binding, and flips the session to false',
    () async {
      final tokenStorage = _FakeTokenStorage('existing-token');
      final authApi = _FakeAuthApi();
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

      final container = ProviderContainer(
        overrides: [
          tokenStorageProvider.overrideWithValue(tokenStorage),
          authApiProvider.overrideWithValue(authApi),
          appDatabaseProvider.overrideWithValue(database),
        ],
      );
      addTearDown(container.dispose);

      await container.read(sessionControllerProvider.future);
      await container.read(sessionControllerProvider.notifier).logout();

      expect(authApi.logoutCalled, isTrue);
      expect(await tokenStorage.readAccessToken(), isNull);
      expect(container.read(sessionControllerProvider).value, isFalse);

      final guardianRows = await database
          .select(database.guardianProfile)
          .get();
      expect(guardianRows, isEmpty);

      final schoolRows = await database.select(database.schoolProfile).get();
      expect(schoolRows, hasLength(1));
      expect(schoolRows.single.uuid, 'school-uuid');
    },
  );

  test('logout also revokes this device\'s push token (WP-07-13), when one was '
      'registered, and forgets it locally', () async {
    final tokenStorage = _FakeTokenStorage('existing-token');
    final authApi = _FakeAuthApi();
    final deviceTokensApi = _FakeDeviceTokensApi();
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    await database.appSettingsDao.write(
      PushController.deviceTokenSettingKey,
      'push-token-a',
    );

    final container = ProviderContainer(
      overrides: [
        tokenStorageProvider.overrideWithValue(tokenStorage),
        authApiProvider.overrideWithValue(authApi),
        appDatabaseProvider.overrideWithValue(database),
        deviceTokensApiProvider.overrideWithValue(deviceTokensApi),
      ],
    );
    addTearDown(container.dispose);

    await container.read(sessionControllerProvider.future);
    await container.read(sessionControllerProvider.notifier).logout();

    expect(deviceTokensApi.revokeCalls, ['push-token-a']);
    expect(
      await database.appSettingsDao.read(PushController.deviceTokenSettingKey),
      isNull,
    );
  });

  test(
    'logout proceeds locally even when the server-side revoke fails',
    () async {
      final tokenStorage = _FakeTokenStorage('existing-token');
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final container = ProviderContainer(
        overrides: [
          tokenStorageProvider.overrideWithValue(tokenStorage),
          authApiProvider.overrideWithValue(
            _FakeAuthApi(
              logoutError: const ApiException(
                message: 'Unable to complete the request.',
              ),
            ),
          ),
          appDatabaseProvider.overrideWithValue(database),
        ],
      );
      addTearDown(container.dispose);

      await container.read(sessionControllerProvider.future);
      await container.read(sessionControllerProvider.notifier).logout();

      expect(await tokenStorage.readAccessToken(), isNull);
      expect(container.read(sessionControllerProvider).value, isFalse);
    },
  );
}
