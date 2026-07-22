import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/database/app_database.dart';
import 'package:mobile/core/database/database_provider.dart';
import 'package:mobile/core/network/api_exception.dart';
import 'package:mobile/core/storage/token_storage.dart';
import 'package:mobile/features/auth/application/login_controller.dart';
import 'package:mobile/features/auth/application/login_state.dart';
import 'package:mobile/features/auth/application/session_controller.dart';
import 'package:mobile/features/auth/data/auth_api.dart';
import 'package:mobile/features/school_bootstrap/data/bootstrap_api.dart';
import 'package:mobile/features/school_bootstrap/data/resolved_guardian.dart';
import 'package:mobile/features/school_setup/data/resolved_school.dart';

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
  _FakeAuthApi({this.token, this.error}) : super(Dio());

  final String? token;
  final ApiException? error;

  @override
  Future<String> login({
    required String schoolId,
    required String email,
    required String password,
  }) async {
    if (error != null) throw error!;
    return token!;
  }
}

class _FakeBootstrapApi extends BootstrapApi {
  _FakeBootstrapApi() : super(Dio());

  @override
  Future<BootstrapResult> fetch() async {
    return const BootstrapResult(
      school: _resolvedSchool,
      guardian: _resolvedGuardian,
      children: [],
      announcements: [],
      nextCursor: 'cursor-1',
    );
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

void main() {
  late AppDatabase database;
  late _FakeTokenStorage tokenStorage;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    tokenStorage = _FakeTokenStorage();
  });

  tearDown(() => database.close());

  ProviderContainer buildContainer({required AuthApi authApi}) {
    final container = ProviderContainer(
      overrides: [
        authApiProvider.overrideWithValue(authApi),
        bootstrapApiProvider.overrideWithValue(_FakeBootstrapApi()),
        appDatabaseProvider.overrideWithValue(database),
        tokenStorageProvider.overrideWithValue(tokenStorage),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test(
    'a successful login stores the token, caches the profiles, and marks the session authenticated',
    () async {
      final container = buildContainer(
        authApi: _FakeAuthApi(token: '1|abcdef'),
      );

      // Establish the session controller's initial (unauthenticated) state
      // before login runs, the same way the real app would have it already
      // resolved by the time a guardian submits the login form.
      await container.read(sessionControllerProvider.future);

      await container
          .read(loginControllerProvider.notifier)
          .login(
            schoolId: 'SCH-0001',
            email: 'maria@example.com',
            password: 'secret',
          );

      expect(tokenStorage.token, '1|abcdef');
      expect(container.read(sessionControllerProvider).value, isTrue);

      final school = await database.select(database.schoolProfile).getSingle();
      expect(school.uuid, 'school-uuid');
      final guardian = await database
          .select(database.guardianProfile)
          .getSingle();
      expect(guardian.uuid, 'guardian-uuid');
    },
  );

  test(
    'a failed login leaves Idle with the safe error message, and never marks the session authenticated',
    () async {
      final container = buildContainer(
        authApi: _FakeAuthApi(
          error: const ApiException(
            message: 'Wrong email or password.',
            statusCode: 422,
          ),
        ),
      );

      await container.read(sessionControllerProvider.future);

      await container
          .read(loginControllerProvider.notifier)
          .login(
            schoolId: 'SCH-0001',
            email: 'maria@example.com',
            password: 'wrong',
          );

      final state = container.read(loginControllerProvider);
      expect(state, isA<LoginIdle>());
      expect((state as LoginIdle).errorMessage, 'Wrong email or password.');

      expect(tokenStorage.token, isNull);
      expect(container.read(sessionControllerProvider).value, isFalse);
    },
  );
}
