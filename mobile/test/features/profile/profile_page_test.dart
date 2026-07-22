import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/database/app_database.dart';
import 'package:mobile/core/database/database_provider.dart';
import 'package:mobile/features/profile/presentation/profile_page.dart';

import '../../support/app_test_harness.dart';

Future<void> _pump(WidgetTester tester, AppDatabase database) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const ProfilePage()),
    ],
  );

  return tester.pumpWidget(
    ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
}

Future<AppDatabase> _seedProfile({
  bool notifyAttendance = true,
  bool notifyAnnouncements = false,
}) async {
  final database = AppDatabase(NativeDatabase.memory());
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
      notifyAttendance: notifyAttendance,
      notifyAnnouncements: notifyAnnouncements,
    ),
  );

  return database;
}

void main() {
  testWidgets('the profile screen shows the guardian\'s details, notification '
      'preferences, and school info, all read from SQLite', (tester) async {
    final database = await _seedProfile();
    addTearDown(database.close);

    await _pump(tester, database);
    await tester.pumpAndSettle();

    expect(find.text('Maria Dela Cruz'), findsOneWidget);
    expect(find.text('maria@example.com'), findsOneWidget);
    expect(find.text('09171234567'), findsOneWidget);
    expect(find.text('Example School'), findsOneWidget);
    expect(find.text('SCH-0001'), findsOneWidget);

    await disposeAppUnderTest(tester);
  });

  testWidgets(
    'notification preference switches reflect the synced values and are '
    'not editable',
    (tester) async {
      final database = await _seedProfile(
        notifyAttendance: true,
        notifyAnnouncements: false,
      );
      addTearDown(database.close);

      await _pump(tester, database);
      await tester.pumpAndSettle();

      final switches = tester.widgetList<Switch>(find.byType(Switch)).toList();
      expect(switches, hasLength(2));
      expect(switches[0].value, isTrue);
      expect(switches[1].value, isFalse);
      // A `null` onChanged is what makes a Switch non-interactive —
      // "do not add ... unsupported profile editing" (WP-07-14's Scope).
      expect(switches.every((s) => s.onChanged == null), isTrue);

      await disposeAppUnderTest(tester);
    },
  );

  testWidgets('no school-change control is offered anywhere on this screen', (
    tester,
  ) async {
    final database = await _seedProfile();
    addTearDown(database.close);

    await _pump(tester, database);
    await tester.pumpAndSettle();

    expect(find.text('Change School'), findsNothing);
    expect(find.text('Reset School'), findsNothing);

    await disposeAppUnderTest(tester);
  });
}
