import 'dart:async';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/database/app_database.dart';
import 'package:mobile/core/network/api_exception.dart';
import 'package:mobile/features/push/application/push_registration_provider.dart';
import 'package:mobile/features/push/data/device_tokens_api.dart';
import 'package:mobile/features/push/data/push_messaging_service.dart';

class _FakePushMessagingService implements PushMessagingService {
  _FakePushMessagingService({this.granted = true, this.token});

  bool granted;
  String? token;
  final _refresh = StreamController<String>.broadcast();

  @override
  Future<bool> requestPermission() async => granted;

  @override
  Future<String?> getToken() async => token;

  @override
  Stream<String> get onTokenRefresh => _refresh.stream;

  @override
  Stream<void> get onMessage => const Stream.empty();

  @override
  Stream<void> get onMessageOpenedApp => const Stream.empty();

  @override
  Future<bool> openedFromTerminatedNotification() async => false;

  void emitRefresh(String newToken) => _refresh.add(newToken);

  Future<void> close() => _refresh.close();
}

class _FakeDeviceTokensApi extends DeviceTokensApi {
  _FakeDeviceTokensApi() : super(Dio());

  final registerCalls = <(String, String?)>[];
  final revokeCalls = <String>[];
  ApiException? registerError;

  @override
  Future<void> register(String token, {String? previousToken}) async {
    registerCalls.add((token, previousToken));
    if (registerError != null) throw registerError!;
  }

  @override
  Future<void> revoke(String token) async {
    revokeCalls.add(token);
  }
}

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  test(
    'granted permission registers the current token and persists it',
    () async {
      final messaging = _FakePushMessagingService(token: 'token-a');
      final api = _FakeDeviceTokensApi();
      final controller = PushController(
        messaging,
        api,
        database.appSettingsDao,
      );

      await controller.start();

      expect(api.registerCalls, [('token-a', null)]);
      expect(
        await database.appSettingsDao.read(
          PushController.deviceTokenSettingKey,
        ),
        'token-a',
      );

      controller.dispose();
      await messaging.close();
    },
  );

  test('denied permission never registers a token — "app remains usable '
      'without notification permission"', () async {
    final messaging = _FakePushMessagingService(
      granted: false,
      token: 'token-a',
    );
    final api = _FakeDeviceTokensApi();
    final controller = PushController(messaging, api, database.appSettingsDao);

    await controller.start();

    expect(api.registerCalls, isEmpty);

    controller.dispose();
    await messaging.close();
  });

  test('a Firebase-initiated token refresh re-registers with the previous '
      'token as previous_token', () async {
    final messaging = _FakePushMessagingService(token: 'token-a');
    final api = _FakeDeviceTokensApi();
    final controller = PushController(messaging, api, database.appSettingsDao);

    await controller.start();
    messaging.emitRefresh('token-b');
    await Future<void>.delayed(Duration.zero);

    expect(api.registerCalls, [
      ('token-a', null),
      ('token-b', 'token-a'),
    ]);
    expect(
      await database.appSettingsDao.read(PushController.deviceTokenSettingKey),
      'token-b',
    );

    controller.dispose();
    await messaging.close();
  });

  test(
    'restarting with the same, already-registered token is a no-op',
    () async {
      await database.appSettingsDao.write(
        PushController.deviceTokenSettingKey,
        'token-a',
      );
      final messaging = _FakePushMessagingService(token: 'token-a');
      final api = _FakeDeviceTokensApi();
      final controller = PushController(
        messaging,
        api,
        database.appSettingsDao,
      );

      await controller.start();

      expect(api.registerCalls, isEmpty);

      controller.dispose();
      await messaging.close();
    },
  );

  test('revokeAndForget revokes the stored token and clears the local cache '
      'so the next login re-registers it fresh', () async {
    await database.appSettingsDao.write(
      PushController.deviceTokenSettingKey,
      'token-a',
    );
    final messaging = _FakePushMessagingService();
    final api = _FakeDeviceTokensApi();
    final controller = PushController(messaging, api, database.appSettingsDao);

    await controller.revokeAndForget();

    expect(api.revokeCalls, ['token-a']);
    expect(
      await database.appSettingsDao.read(PushController.deviceTokenSettingKey),
      isNull,
    );

    controller.dispose();
    await messaging.close();
  });

  test(
    'revokeAndForget is a no-op when no token was ever registered',
    () async {
      final messaging = _FakePushMessagingService();
      final api = _FakeDeviceTokensApi();
      final controller = PushController(
        messaging,
        api,
        database.appSettingsDao,
      );

      await controller.revokeAndForget();

      expect(api.revokeCalls, isEmpty);

      controller.dispose();
      await messaging.close();
    },
  );
}
