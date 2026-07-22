import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/database/app_database.dart';
import 'package:mobile/core/database/database_provider.dart';
import 'package:mobile/features/attendance/presentation/attendance_history_page.dart';

import '../../support/app_test_harness.dart';

Future<AppDatabase> _seedStudent() async {
  final database = AppDatabase(NativeDatabase.memory());
  addTearDown(database.close);

  await database.studentsDao.upsert(
    StudentsCompanion.insert(
      uuid: 'student-uuid',
      lrn: '123456789012',
      studentNumber: 'SN-0001',
      name: 'Juan Dela Cruz',
      sex: 'male',
      grade: 'Grade 7',
      section: 'Diamond',
      schoolYear: '2026-2027',
      status: 'active',
    ),
  );

  return database;
}

Future<void> _pump(WidgetTester tester, AppDatabase database) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
      child: const MaterialApp(
        home: AttendanceHistoryPage(studentUuid: 'student-uuid'),
      ),
    ),
  );
}

void main() {
  testWidgets('shows the student\'s name as the title', (tester) async {
    final database = await _seedStudent();

    await _pump(tester, database);
    await tester.pumpAndSettle();

    expect(find.text('Juan Dela Cruz'), findsOneWidget);

    await disposeAppUnderTest(tester);
  });

  testWidgets('no attendance yet shows the empty state', (tester) async {
    final database = await _seedStudent();

    await _pump(tester, database);
    await tester.pumpAndSettle();

    expect(find.text('No attendance recorded yet.'), findsOneWidget);

    await disposeAppUnderTest(tester);
  });

  testWidgets(
    'multiple days are listed newest first, and a correction updates the row in place',
    (tester) async {
      final database = await _seedStudent();

      await database.attendanceRecordsDao.upsert(
        AttendanceRecordsCompanion.insert(
          studentUuid: 'student-uuid',
          date: DateTime.utc(2026, 7, 21),
          isLate: false,
          isAbsent: true,
        ),
      );
      await database.attendanceRecordsDao.upsert(
        AttendanceRecordsCompanion.insert(
          studentUuid: 'student-uuid',
          date: DateTime.utc(2026, 7, 22),
          arrival: Value(DateTime.utc(2026, 7, 22, 0, 5)),
          isLate: false,
          isAbsent: false,
        ),
      );

      await _pump(tester, database);
      await tester.pumpAndSettle();

      final tiles = tester.widgetList<ListTile>(find.byType(ListTile)).toList();
      expect(tiles, hasLength(2));
      // Newest (Jul 22) first.
      expect((tiles[0].title! as Text).data, 'Jul 22, 2026');
      expect((tiles[1].title! as Text).data, 'Jul 21, 2026');

      // A correction (e.g. Jul 21 was actually not absent) upserts the
      // same row in place — SyncChangeApplier's job, exercised here at
      // the DAO level the same way it would apply one.
      await database.attendanceRecordsDao.upsert(
        AttendanceRecordsCompanion.insert(
          studentUuid: 'student-uuid',
          date: DateTime.utc(2026, 7, 21),
          arrival: Value(DateTime.utc(2026, 7, 21, 0, 10)),
          isLate: true,
          isAbsent: false,
        ),
      );
      await tester.pumpAndSettle();

      final updatedTiles = tester
          .widgetList<ListTile>(find.byType(ListTile))
          .toList();
      expect(updatedTiles, hasLength(2));
      expect((updatedTiles[1].subtitle! as Text).data, contains('(Late)'));

      await disposeAppUnderTest(tester);
    },
  );
}
