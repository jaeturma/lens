import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app/lens_app.dart';
import 'package:mobile/core/app_version_provider.dart';
import 'package:mobile/core/database/app_database.dart';
import 'package:mobile/core/database/database_provider.dart';
import 'package:mobile/features/auth/application/session_controller.dart';
import 'package:mobile/features/sync/data/sync_api.dart';
import 'package:mobile/features/sync/data/sync_change_entry.dart';

import '../support/app_test_harness.dart';

/// WP-08-05's own validation of "missed push does not lose the
/// notification": every existing push test
/// (`test/features/push/push_sync_trigger_flow_test.dart`) proves sync
/// happening *because a push arrived*. None of them prove the other half of
/// this package's own Scope line — "recovery through app resume or manual
/// sync" — where **no push ever arrives at all** (delivery failure, the
/// device offline at the moment Firebase tried, notification permission
/// denied, app killed) and the guardian only learns about the new
/// notification through the ordinary `startupSyncProvider` call every
/// `HomePage` build already makes regardless of push. This file's own test
/// never touches `PushMessagingService` — proving the recovery path holds
/// with zero push involvement, not just alongside it.
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

void main() {
  testWidgets(
    'a notification missed by push still arrives via the ordinary startup '
    'sync (app resume), with no push message ever received',
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

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(database),
            appVersionProvider.overrideWith((ref) async => '0.1.0'),
            sessionControllerProvider.overrideWith(
              FakeAuthenticatedSession.new,
            ),
            syncApiProvider.overrideWithValue(_SingleNotificationSyncApi()),
          ],
          child: const LensApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('1'), findsOneWidget); // The unread-count badge.

      await tester.tap(find.byTooltip('Notifications'));
      await tester.pumpAndSettle();

      expect(find.text('Arrived at school'), findsOneWidget);

      await disposeAppUnderTest(tester);
    },
  );
}
