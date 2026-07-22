import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app/lens_app.dart';
import 'package:mobile/core/app_version_provider.dart';
import 'package:mobile/core/database/app_database.dart';
import 'package:mobile/core/database/database_provider.dart';
import 'package:mobile/core/school_timezone.dart';
import 'package:mobile/features/auth/application/session_controller.dart';
import 'package:mobile/features/sync/data/sync_api.dart';

import '../../support/app_test_harness.dart';

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
  testWidgets('no linked children shows the empty state', (tester) async {
    final database = await _seedBoundSchool();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          appVersionProvider.overrideWith((ref) async => '0.1.0'),
          sessionControllerProvider.overrideWith(FakeAuthenticatedSession.new),
          syncApiProvider.overrideWithValue(NoOpSyncApi()),
        ],
        child: const LensApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No linked children yet.'), findsOneWidget);

    await disposeAppUnderTest(tester);
  });

  testWidgets('multiple linked children each render their own status', (
    tester,
  ) async {
    final database = await _seedBoundSchool();

    await database.studentsDao.upsert(
      StudentsCompanion.insert(
        uuid: 'student-1',
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
    await database.guardianStudentLinksDao.upsert(
      GuardianStudentLinksCompanion.insert(
        studentUuid: 'student-1',
        relationshipType: 'mother',
        isPrimaryContact: true,
        status: 'active',
        notificationsEnabled: true,
      ),
    );

    await database.studentsDao.upsert(
      StudentsCompanion.insert(
        uuid: 'student-2',
        lrn: '987654321098',
        studentNumber: 'SN-0002',
        name: 'Maria Dela Cruz',
        sex: 'female',
        grade: 'Grade 5',
        section: 'Emerald',
        schoolYear: '2026-2027',
        status: 'active',
      ),
    );
    await database.guardianStudentLinksDao.upsert(
      GuardianStudentLinksCompanion.insert(
        studentUuid: 'student-2',
        relationshipType: 'mother',
        isPrimaryContact: true,
        status: 'active',
        notificationsEnabled: true,
      ),
    );
    await database.attendanceRecordsDao.upsert(
      AttendanceRecordsCompanion.insert(
        studentUuid: 'student-2',
        date: todayIn('Asia/Manila'),
        isLate: false,
        isAbsent: true,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          appVersionProvider.overrideWith((ref) async => '0.1.0'),
          sessionControllerProvider.overrideWith(FakeAuthenticatedSession.new),
          syncApiProvider.overrideWithValue(NoOpSyncApi()),
        ],
        child: const LensApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No linked children yet.'), findsNothing);
    expect(find.text('Juan Dela Cruz'), findsOneWidget);
    expect(find.text('Maria Dela Cruz'), findsOneWidget);
    expect(find.text('No attendance recorded yet today.'), findsOneWidget);
    expect(find.text('Absent today.'), findsOneWidget);

    await disposeAppUnderTest(tester);
  });
}
