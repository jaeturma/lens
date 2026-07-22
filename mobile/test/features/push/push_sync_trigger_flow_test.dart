import 'dart:async';

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
import 'package:mobile/features/push/data/push_messaging_service.dart';
import 'package:mobile/features/sync/data/sync_api.dart';
import 'package:mobile/features/sync/data/sync_change_entry.dart';

import '../../support/app_test_harness.dart';

/// A push-driven notification never carries the notification's own
/// content (`docs/NOTIFICATIONS.md`) — only a `guardian_notification` sync
/// entry, delivered by the ordinary sync feed once triggered, proves a
/// sync actually ran. Always returns the same single page regardless of
/// cursor: a repeat call from a second trigger (e.g. both
/// `startupSyncProvider` and a push firing) just re-upserts the same row.
class _SingleNotificationSyncApi extends SyncApi {
  _SingleNotificationSyncApi() : super(Dio());

  @override
  Future<SyncChangesPage> fetchChanges({
    required String cursor,
    int limit = 100,
  }) async {
    return SyncChangesPage(
      nextCursor: 'cursor-1',
      hasMore: false,
      changes: [
        SyncChangeEntry(
          resourceType: 'guardian_notification',
          resourceId: 1,
          action: 'created',
          payload: {
            'uuid': 'notification-uuid',
            'guardian_id': 7,
            'type': 'arrival',
            'title': 'Arrived at school',
            'body': 'Juan arrived at 7:05 AM.',
            'payload': null,
            'read_at': null,
            'delivery_status': 'sent',
          },
          createdAt: DateTime.utc(2026, 7, 22),
        ),
      ],
    );
  }
}

class _FakePushMessagingService implements PushMessagingService {
  _FakePushMessagingService({this.openedFromTerminated = false});

  bool openedFromTerminated;
  final _message = StreamController<void>.broadcast();
  final _openedApp = StreamController<void>.broadcast();

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<String?> getToken() async => null;

  @override
  Stream<String> get onTokenRefresh => const Stream.empty();

  @override
  Stream<void> get onMessage => _message.stream;

  @override
  Stream<void> get onMessageOpenedApp => _openedApp.stream;

  @override
  Future<bool> openedFromTerminatedNotification() async => openedFromTerminated;

  void emitForegroundMessage() => _message.add(null);

  void emitOpenedFromBackground() => _openedApp.add(null);
}

class _FakeTokenStorage extends TokenStorage {
  _FakeTokenStorage() : super(const FlutterSecureStorage());

  @override
  Future<String?> readAccessToken() async => 'existing-token';

  @override
  Future<void> writeAccessToken(String value) async {}

  @override
  Future<void> clearAccessToken() async {}
}

Future<AppDatabase> _seedBoundSchool() async {
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

  return database;
}

void main() {
  testWidgets('a foreground push message triggers a sync', (tester) async {
    final database = await _seedBoundSchool();
    final messaging = _FakePushMessagingService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          appVersionProvider.overrideWith((ref) async => '0.1.0'),
          sessionControllerProvider.overrideWith(FakeAuthenticatedSession.new),
          tokenStorageProvider.overrideWithValue(_FakeTokenStorage()),
          syncApiProvider.overrideWithValue(_SingleNotificationSyncApi()),
          pushMessagingServiceProvider.overrideWithValue(messaging),
        ],
        child: const LensApp(),
      ),
    );
    await tester.pumpAndSettle();

    messaging.emitForegroundMessage();
    await tester.pumpAndSettle();

    expect(find.text('1'), findsOneWidget); // The unread-count badge.

    await disposeAppUnderTest(tester);
  });

  testWidgets(
    'tapping a push notification while backgrounded syncs, then opens the '
    'notification inbox — "relevant destination opens after data is '
    'synchronized"',
    (tester) async {
      final database = await _seedBoundSchool();
      final messaging = _FakePushMessagingService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(database),
            appVersionProvider.overrideWith((ref) async => '0.1.0'),
            sessionControllerProvider.overrideWith(
              FakeAuthenticatedSession.new,
            ),
            tokenStorageProvider.overrideWithValue(_FakeTokenStorage()),
            syncApiProvider.overrideWithValue(_SingleNotificationSyncApi()),
            pushMessagingServiceProvider.overrideWithValue(messaging),
          ],
          child: const LensApp(),
        ),
      );
      await tester.pumpAndSettle();

      messaging.emitOpenedFromBackground();
      await tester.pumpAndSettle();

      expect(find.text('Notifications'), findsOneWidget); // The AppBar title.
      expect(find.text('Arrived at school'), findsOneWidget);

      await disposeAppUnderTest(tester);
    },
  );

  testWidgets(
    'launching the app from a terminated-state notification tap syncs, '
    'then opens the notification inbox',
    (tester) async {
      final database = await _seedBoundSchool();
      final messaging = _FakePushMessagingService(openedFromTerminated: true);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(database),
            appVersionProvider.overrideWith((ref) async => '0.1.0'),
            sessionControllerProvider.overrideWith(
              FakeAuthenticatedSession.new,
            ),
            tokenStorageProvider.overrideWithValue(_FakeTokenStorage()),
            syncApiProvider.overrideWithValue(_SingleNotificationSyncApi()),
            pushMessagingServiceProvider.overrideWithValue(messaging),
          ],
          child: const LensApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Arrived at school'), findsOneWidget);

      await disposeAppUnderTest(tester);
    },
  );
}
