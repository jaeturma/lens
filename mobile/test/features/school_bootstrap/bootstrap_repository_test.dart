import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/database/app_database.dart';
import 'package:mobile/features/school_bootstrap/data/bootstrap_api.dart';
import 'package:mobile/features/school_bootstrap/data/bootstrap_repository.dart';
import 'package:mobile/features/school_bootstrap/data/resolved_child.dart';
import 'package:mobile/features/school_bootstrap/data/resolved_guardian.dart';
import 'package:mobile/features/school_setup/data/resolved_school.dart';

const _resolvedSchool = ResolvedSchool(
  schoolId: 'SCH-0001',
  uuid: 'school-uuid',
  name: 'Example School',
  logoUrl: 'https://example.test/logo.png',
  timezone: 'Asia/Manila',
  mobileEnabled: true,
  maintenanceMode: false,
  maintenanceMessage: null,
  notificationsEnabled: true,
  minimumAppVersion: '0.1.0',
);

const _resolvedGuardian = ResolvedGuardian(
  uuid: 'guardian-uuid',
  name: 'Maria Dela Cruz',
  email: 'maria@example.com',
  mobileNumber: '09171234567',
  status: 'active',
  notifyAttendance: true,
  notifyAnnouncements: true,
);

const _resolvedChild = ResolvedChild(
  uuid: 'student-uuid',
  lrn: '123456789012',
  studentNumber: 'SN-0001',
  name: 'Juan Dela Cruz',
  sex: 'male',
  grade: 'Grade 7',
  section: 'Diamond',
  schoolYear: '2026-2027',
  status: 'active',
  photoUrl: null,
  relationshipType: 'mother',
  isPrimaryContact: true,
  todayAttendance: ResolvedTodayAttendance(
    arrival: null,
    departure: null,
    isLate: false,
    isAbsent: false,
  ),
);

class _FakeBootstrapApi extends BootstrapApi {
  _FakeBootstrapApi(this.result) : super(Dio());

  final BootstrapResult result;

  @override
  Future<BootstrapResult> fetch() async => result;
}

void main() {
  test(
    'sync caches the bootstrap response\'s school profile locally',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final repository = BootstrapRepository(
        _FakeBootstrapApi(
          const BootstrapResult(
            school: _resolvedSchool,
            guardian: null,
            children: [],
            nextCursor: 'cursor-1',
          ),
        ),
        database,
      );

      await repository.sync();

      final row = await database.select(database.schoolProfile).getSingle();
      expect(row.uuid, 'school-uuid');
      expect(row.publicId, 'SCH-0001');
      expect(row.name, 'Example School');
      expect(row.logoUrl, 'https://example.test/logo.png');
      expect(row.minimumAppVersion, '0.1.0');
    },
  );

  test(
    'sync saves the response\'s next_cursor as the sync engine\'s starting point (WP-07-08)',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final repository = BootstrapRepository(
        _FakeBootstrapApi(
          const BootstrapResult(
            school: _resolvedSchool,
            guardian: null,
            children: [],
            nextCursor: 'cursor-from-bootstrap',
          ),
        ),
        database,
      );

      await repository.sync();

      expect(await database.syncStateDao.readCursor(), 'cursor-from-bootstrap');
    },
  );

  test(
    'a repeated sync updates the cached school profile rather than duplicating it',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      await BootstrapRepository(
        _FakeBootstrapApi(
          const BootstrapResult(
            school: _resolvedSchool,
            guardian: null,
            children: [],
            nextCursor: 'cursor-1',
          ),
        ),
        database,
      ).sync();

      await BootstrapRepository(
        _FakeBootstrapApi(
          const BootstrapResult(
            school: ResolvedSchool(
              schoolId: 'SCH-0001',
              uuid: 'school-uuid',
              name: 'Renamed School',
              logoUrl: null,
              timezone: 'Asia/Manila',
              mobileEnabled: false,
              maintenanceMode: true,
              maintenanceMessage: 'Down for scheduled maintenance.',
              notificationsEnabled: true,
              minimumAppVersion: '0.2.0',
            ),
            guardian: null,
            children: [],
            nextCursor: 'cursor-2',
          ),
        ),
        database,
      ).sync();

      final rows = await database.select(database.schoolProfile).get();
      expect(rows, hasLength(1));
      expect(rows.single.name, 'Renamed School');
      expect(rows.single.mobileEnabled, isFalse);
      expect(rows.single.maintenanceMode, isTrue);
      expect(rows.single.minimumAppVersion, '0.2.0');
    },
  );

  test('when the response has a guardian, it is cached locally too', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final repository = BootstrapRepository(
      _FakeBootstrapApi(
        const BootstrapResult(
          school: _resolvedSchool,
          guardian: _resolvedGuardian,
          children: [],
          nextCursor: 'cursor-1',
        ),
      ),
      database,
    );

    await repository.sync();

    final row = await database.select(database.guardianProfile).getSingle();
    expect(row.uuid, 'guardian-uuid');
    expect(row.name, 'Maria Dela Cruz');
    expect(row.notifyAttendance, isTrue);
  });

  test(
    'when the response has no guardian (no profile yet), nothing is written to guardian_profile',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final repository = BootstrapRepository(
        _FakeBootstrapApi(
          const BootstrapResult(
            school: _resolvedSchool,
            guardian: null,
            children: [],
            nextCursor: 'cursor-1',
          ),
        ),
        database,
      );

      await repository.sync();

      final rows = await database.select(database.guardianProfile).get();
      expect(rows, isEmpty);
    },
  );

  test(
    'a linked child is cached as a student, an active link, and today\'s attendance',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final repository = BootstrapRepository(
        _FakeBootstrapApi(
          const BootstrapResult(
            school: _resolvedSchool,
            guardian: null,
            children: [_resolvedChild],
            nextCursor: 'cursor-1',
          ),
        ),
        database,
      );

      await repository.sync();

      final student = await database.select(database.students).getSingle();
      expect(student.uuid, 'student-uuid');
      expect(student.name, 'Juan Dela Cruz');
      // Bootstrap never exposes a numeric id — only a later student-type
      // sync entry backfills it (see tables.dart).
      expect(student.serverId, isNull);

      final link = await database
          .select(database.guardianStudentLinks)
          .getSingle();
      expect(link.studentUuid, 'student-uuid');
      expect(link.relationshipType, 'mother');
      expect(link.status, 'active');

      final attendance = await database
          .select(database.attendanceRecords)
          .getSingle();
      expect(attendance.studentUuid, 'student-uuid');
      expect(attendance.isAbsent, isFalse);
    },
  );

  test(
    'a child with no today_attendance yet writes no attendance row',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      const childWithoutAttendance = ResolvedChild(
        uuid: 'student-uuid',
        lrn: '123456789012',
        studentNumber: 'SN-0001',
        name: 'Juan Dela Cruz',
        sex: 'male',
        grade: 'Grade 7',
        section: 'Diamond',
        schoolYear: '2026-2027',
        status: 'active',
        photoUrl: null,
        relationshipType: 'mother',
        isPrimaryContact: true,
        todayAttendance: null,
      );

      final repository = BootstrapRepository(
        _FakeBootstrapApi(
          const BootstrapResult(
            school: _resolvedSchool,
            guardian: null,
            children: [childWithoutAttendance],
            nextCursor: 'cursor-1',
          ),
        ),
        database,
      );

      await repository.sync();

      expect(await database.select(database.students).get(), hasLength(1));
      expect(await database.select(database.attendanceRecords).get(), isEmpty);
    },
  );
}
