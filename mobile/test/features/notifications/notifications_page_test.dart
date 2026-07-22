import 'package:dio/dio.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/database/app_database.dart';
import 'package:mobile/core/database/database_provider.dart';
import 'package:mobile/features/notifications/data/notifications_api.dart';
import 'package:mobile/features/notifications/presentation/notifications_page.dart';

import '../../support/app_test_harness.dart';

class _FakeNotificationsApi extends NotificationsApi {
  _FakeNotificationsApi() : super(Dio());

  final markReadCalls = <String>[];

  @override
  Future<void> markRead(String uuid) async {
    markReadCalls.add(uuid);
  }
}

Future<void> _pump(
  WidgetTester tester,
  AppDatabase database,
  NotificationsApi api,
) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const NotificationsPage(),
      ),
    ],
  );

  return tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        notificationsApiProvider.overrideWithValue(api),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
}

void main() {
  testWidgets('no notifications shows the empty state', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await _pump(tester, database, _FakeNotificationsApi());
    await tester.pumpAndSettle();

    expect(find.text('No notifications yet.'), findsOneWidget);

    await disposeAppUnderTest(tester);
  });

  testWidgets('notifications are listed newest first', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await database.notificationsDao.upsert(
      NotificationsCompanion.insert(
        uuid: 'older',
        serverId: const Value(1),
        type: 'attendance.arrival',
        title: 'Arrived at school',
        body: 'Juan arrived at 7:05 AM.',
        deliveryStatus: 'sent',
      ),
    );
    await database.notificationsDao.upsert(
      NotificationsCompanion.insert(
        uuid: 'newer',
        serverId: const Value(2),
        type: 'attendance.departure',
        title: 'Left school',
        body: 'Juan left at 4:05 PM.',
        deliveryStatus: 'sent',
      ),
    );

    await _pump(tester, database, _FakeNotificationsApi());
    await tester.pumpAndSettle();

    final titles = tester
        .widgetList<Text>(find.byType(Text))
        .map((widget) => widget.data)
        .where((data) => data == 'Arrived at school' || data == 'Left school')
        .toList();
    expect(titles, ['Left school', 'Arrived at school']);

    await disposeAppUnderTest(tester);
  });

  testWidgets(
    'tapping an unread notification marks it read locally and calls the '
    'server, best-effort',
    (tester) async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final api = _FakeNotificationsApi();

      await database.notificationsDao.upsert(
        NotificationsCompanion.insert(
          uuid: 'notification-uuid',
          type: 'attendance.arrival',
          title: 'Arrived at school',
          body: 'Juan arrived at 7:05 AM.',
          deliveryStatus: 'sent',
        ),
      );

      await _pump(tester, database, api);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Arrived at school'));
      await tester.pumpAndSettle();

      expect(api.markReadCalls, ['notification-uuid']);

      final row = await (database.select(
        database.notifications,
      )..where((r) => r.uuid.equals('notification-uuid'))).getSingle();
      expect(row.readAt, isNotNull);

      await disposeAppUnderTest(tester);
    },
  );
}
