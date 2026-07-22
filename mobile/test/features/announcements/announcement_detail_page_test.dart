import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/database/app_database.dart';
import 'package:mobile/core/database/database_provider.dart';
import 'package:mobile/features/announcements/presentation/announcement_detail_page.dart';

import '../../support/app_test_harness.dart';

Future<void> _pump(WidgetTester tester, AppDatabase database) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
      child: const MaterialApp(
        home: AnnouncementDetailPage(announcementUuid: 'announcement-uuid'),
      ),
    ),
  );
}

void main() {
  testWidgets('shows the announcement\'s title and body', (tester) async {
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

    expect(find.text('Foundation Day'), findsWidgets);
    expect(
      find.text('School closed for Foundation Day celebrations.'),
      findsOneWidget,
    );

    await disposeAppUnderTest(tester);
  });

  testWidgets(
    'an announcement that no longer exists locally shows the not-available state',
    (tester) async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      await _pump(tester, database);
      await tester.pumpAndSettle();

      expect(
        find.text('This announcement is no longer available.'),
        findsOneWidget,
      );

      await disposeAppUnderTest(tester);
    },
  );

  testWidgets(
    'a withdrawal/expiry tombstone while the screen is open switches to the not-available state',
    (tester) async {
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

      expect(find.text('Foundation Day'), findsWidgets);

      // Mirrors what SyncChangeApplier does on a revoked/expired entry
      // (WP-07-08) — deletes the local row outright.
      await database.announcementsDao.deleteByUuid('announcement-uuid');
      await tester.pumpAndSettle();

      expect(
        find.text('This announcement is no longer available.'),
        findsOneWidget,
      );

      await disposeAppUnderTest(tester);
    },
  );
}
