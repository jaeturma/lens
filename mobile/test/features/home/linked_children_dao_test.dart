import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/database/app_database.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  Future<void> seedStudent({
    required String uuid,
    String name = 'Juan Dela Cruz',
  }) {
    return database.studentsDao.upsert(
      StudentsCompanion.insert(
        uuid: uuid,
        lrn: '123456789012',
        studentNumber: 'SN-0001',
        name: name,
        sex: 'male',
        grade: 'Grade 7',
        section: 'Diamond',
        schoolYear: '2026-2027',
        status: 'active',
      ),
    );
  }

  test('only actively-linked students are returned', () async {
    await seedStudent(uuid: 'active-uuid', name: 'Active Child');
    await database.guardianStudentLinksDao.upsert(
      GuardianStudentLinksCompanion.insert(
        studentUuid: 'active-uuid',
        relationshipType: 'mother',
        isPrimaryContact: true,
        status: 'active',
        notificationsEnabled: true,
      ),
    );

    await seedStudent(uuid: 'revoked-uuid', name: 'Revoked Child');
    await database.guardianStudentLinksDao.upsert(
      GuardianStudentLinksCompanion.insert(
        studentUuid: 'revoked-uuid',
        relationshipType: 'mother',
        isPrimaryContact: true,
        status: 'revoked',
        notificationsEnabled: true,
      ),
    );

    final children = await database.linkedChildrenDao
        .watchActive(DateTime.utc(2026, 7, 22))
        .first;

    expect(children, hasLength(1));
    expect(children.single.student.name, 'Active Child');
  });

  test(
    'a child with no attendance row for the given date has a null todayAttendance',
    () async {
      await seedStudent(uuid: 'student-uuid');
      await database.guardianStudentLinksDao.upsert(
        GuardianStudentLinksCompanion.insert(
          studentUuid: 'student-uuid',
          relationshipType: 'mother',
          isPrimaryContact: true,
          status: 'active',
          notificationsEnabled: true,
        ),
      );

      final children = await database.linkedChildrenDao
          .watchActive(DateTime.utc(2026, 7, 22))
          .first;

      expect(children, hasLength(1));
      expect(children.single.todayAttendance, isNull);
    },
  );

  test(
    'a child\'s attendance for the given date is joined in; a different date is not',
    () async {
      await seedStudent(uuid: 'student-uuid');
      await database.guardianStudentLinksDao.upsert(
        GuardianStudentLinksCompanion.insert(
          studentUuid: 'student-uuid',
          relationshipType: 'mother',
          isPrimaryContact: true,
          status: 'active',
          notificationsEnabled: true,
        ),
      );
      await database.attendanceRecordsDao.upsert(
        AttendanceRecordsCompanion.insert(
          studentUuid: 'student-uuid',
          date: DateTime.utc(2026, 7, 22),
          isLate: false,
          isAbsent: false,
        ),
      );
      await database.attendanceRecordsDao.upsert(
        AttendanceRecordsCompanion.insert(
          studentUuid: 'student-uuid',
          date: DateTime.utc(2026, 7, 21),
          isLate: false,
          isAbsent: true,
        ),
      );

      final todayChildren = await database.linkedChildrenDao
          .watchActive(DateTime.utc(2026, 7, 22))
          .first;
      expect(todayChildren.single.todayAttendance?.isAbsent, isFalse);

      final yesterdayChildren = await database.linkedChildrenDao
          .watchActive(DateTime.utc(2026, 7, 21))
          .first;
      expect(yesterdayChildren.single.todayAttendance?.isAbsent, isTrue);
    },
  );

  test('multiple linked children are all returned, ordered by name', () async {
    await seedStudent(uuid: 'z-uuid', name: 'Zoe Santos');
    await database.guardianStudentLinksDao.upsert(
      GuardianStudentLinksCompanion.insert(
        studentUuid: 'z-uuid',
        relationshipType: 'mother',
        isPrimaryContact: true,
        status: 'active',
        notificationsEnabled: true,
      ),
    );
    await seedStudent(uuid: 'a-uuid', name: 'Ana Reyes');
    await database.guardianStudentLinksDao.upsert(
      GuardianStudentLinksCompanion.insert(
        studentUuid: 'a-uuid',
        relationshipType: 'mother',
        isPrimaryContact: true,
        status: 'active',
        notificationsEnabled: true,
      ),
    );

    final children = await database.linkedChildrenDao
        .watchActive(DateTime.utc(2026, 7, 22))
        .first;

    expect(children.map((c) => c.student.name), ['Ana Reyes', 'Zoe Santos']);
  });
}
