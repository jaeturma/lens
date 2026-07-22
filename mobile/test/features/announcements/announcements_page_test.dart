import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/database/app_database.dart';
import 'package:mobile/core/database/database_provider.dart';
import 'package:mobile/features/announcements/presentation/announcement_detail_page.dart';
import 'package:mobile/features/announcements/presentation/announcements_page.dart';

import '../../support/app_test_harness.dart';

Future<void> _pump(WidgetTester tester, AppDatabase database) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const AnnouncementsPage(),
      ),
      GoRoute(
        path: '/announcements/:announcementUuid',
        builder: (context, state) => AnnouncementDetailPage(
          announcementUuid: state.pathParameters['announcementUuid']!,
        ),
      ),
    ],
  );

  return tester.pumpWidget(
    ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
}

void main() {
  testWidgets('no announcements shows the empty state', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await _pump(tester, database);
    await tester.pumpAndSettle();

    expect(find.text('No announcements yet.'), findsOneWidget);

    await disposeAppUnderTest(tester);
  });

  testWidgets('announcements are listed, and tapping one opens its detail', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await database.announcementsDao.upsert(
      AnnouncementsCompanion.insert(
        uuid: 'announcement-uuid',
        title: 'Foundation Day',
        body: 'School closed for Foundation Day celebrations.',
        status: 'published',
      ),
    );

    await _pump(tester, database);
    await tester.pumpAndSettle();

    expect(find.text('Foundation Day'), findsOneWidget);

    await tester.tap(find.text('Foundation Day'));
    await tester.pumpAndSettle();

    expect(
      find.text('School closed for Foundation Day celebrations.'),
      findsOneWidget,
    );

    await disposeAppUnderTest(tester);
  });
}
