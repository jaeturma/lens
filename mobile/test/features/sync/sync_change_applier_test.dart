import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/database/app_database.dart';
import 'package:mobile/features/sync/data/sync_change_applier.dart';
import 'package:mobile/features/sync/data/sync_change_entry.dart';

SyncChangeEntry _entry({
  required String resourceType,
  required int resourceId,
  required String action,
  required Map<String, dynamic> payload,
}) {
  return SyncChangeEntry(
    resourceType: resourceType,
    resourceId: resourceId,
    action: action,
    payload: payload,
    createdAt: DateTime.utc(2026, 7, 22),
  );
}

void main() {
  late AppDatabase database;
  late SyncChangeApplier applier;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    applier = SyncChangeApplier(database);
  });

  tearDown(() => database.close());

  group('guardian', () {
    test('created upserts guardian_profile', () async {
      await applier.applyAll([
        _entry(
          resourceType: 'guardian',
          resourceId: 7,
          action: 'created',
          payload: {
            'uuid': 'guardian-uuid',
            'name': 'Maria Dela Cruz',
            'email': 'maria@example.com',
            'mobile_number': '09171234567',
            'status': 'active',
            'notify_attendance': true,
            'notify_announcements': true,
          },
        ),
      ]);

      final row = await database.select(database.guardianProfile).getSingle();
      expect(row.uuid, 'guardian-uuid');
      expect(row.notifyAttendance, isTrue);
    });

    test('deleted removes the local row', () async {
      await database.guardianProfileDao.upsert(
        GuardianProfileCompanion.insert(
          uuid: 'guardian-uuid',
          name: 'Maria Dela Cruz',
          email: 'maria@example.com',
          mobileNumber: '09171234567',
          status: 'active',
          notifyAttendance: true,
          notifyAnnouncements: true,
        ),
      );

      await applier.applyAll([
        _entry(
          resourceType: 'guardian',
          resourceId: 7,
          action: 'deleted',
          payload: {'uuid': 'guardian-uuid'},
        ),
      ]);

      final rows = await database.select(database.guardianProfile).get();
      expect(rows, isEmpty);
    });
  });

  group('student', () {
    test('created upserts students with its serverId', () async {
      await applier.applyAll([
        _entry(
          resourceType: 'student',
          resourceId: 42,
          action: 'created',
          payload: {
            'uuid': 'student-uuid',
            'lrn': '123456789012',
            'student_number': 'SN-0001',
            'name': 'Juan Dela Cruz',
            'sex': 'male',
            'grade': 'Grade 7',
            'section': 'Diamond',
            'school_year': '2026-2027',
            'status': 'active',
            'photo_url': null,
          },
        ),
      ]);

      final row = await database.select(database.students).getSingle();
      expect(row.uuid, 'student-uuid');
      expect(row.serverId, 42);
      expect(row.name, 'Juan Dela Cruz');
    });

    test(
      'deleted removes the student, their attendance, and their link',
      () async {
        await database.studentsDao.upsert(
          StudentsCompanion.insert(
            uuid: 'student-uuid',
            serverId: const Value(42),
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
        await database.attendanceRecordsDao.upsert(
          AttendanceRecordsCompanion.insert(
            studentUuid: 'student-uuid',
            date: DateTime.utc(2026, 7, 22),
            isLate: false,
            isAbsent: false,
          ),
        );
        await database.guardianStudentLinksDao.upsert(
          GuardianStudentLinksCompanion.insert(
            uuid: 'link-uuid',
            studentServerId: 42,
            relationshipType: 'mother',
            isPrimaryContact: true,
            status: 'active',
            notificationsEnabled: true,
          ),
        );

        await applier.applyAll([
          _entry(
            resourceType: 'student',
            resourceId: 42,
            action: 'deleted',
            payload: {'uuid': 'student-uuid'},
          ),
        ]);

        expect(await database.select(database.students).get(), isEmpty);
        expect(
          await database.select(database.attendanceRecords).get(),
          isEmpty,
        );
        expect(
          await database.select(database.guardianStudentLinks).get(),
          isEmpty,
        );
      },
    );
  });

  group('guardian_student_link', () {
    test(
      'created/updated upserts the link keyed by the student\'s server id',
      () async {
        await applier.applyAll([
          _entry(
            resourceType: 'guardian_student_link',
            resourceId: 5,
            action: 'created',
            payload: {
              'uuid': 'link-uuid',
              'student_id': 42,
              'guardian_id': 7,
              'relationship_type': 'mother',
              'is_primary_contact': true,
              'status': 'active',
              'notifications_enabled': true,
            },
          ),
        ]);

        final row = await database
            .select(database.guardianStudentLinks)
            .getSingle();
        expect(row.uuid, 'link-uuid');
        expect(row.studentServerId, 42);
        expect(row.relationshipType, 'mother');
      },
    );

    test(
      'revoked removes the student, their attendance, and the link itself '
      '("the revoked-link entry is exactly what tells the client to remove a student locally")',
      () async {
        await database.studentsDao.upsert(
          StudentsCompanion.insert(
            uuid: 'student-uuid',
            serverId: const Value(42),
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
        await database.attendanceRecordsDao.upsert(
          AttendanceRecordsCompanion.insert(
            studentUuid: 'student-uuid',
            date: DateTime.utc(2026, 7, 22),
            isLate: false,
            isAbsent: false,
          ),
        );
        await database.guardianStudentLinksDao.upsert(
          GuardianStudentLinksCompanion.insert(
            uuid: 'link-uuid',
            studentServerId: 42,
            relationshipType: 'mother',
            isPrimaryContact: true,
            status: 'active',
            notificationsEnabled: true,
          ),
        );

        await applier.applyAll([
          _entry(
            resourceType: 'guardian_student_link',
            resourceId: 5,
            action: 'revoked',
            payload: {
              'uuid': 'link-uuid',
              'student_id': 42,
              'guardian_id': 7,
              'relationship_type': 'mother',
              'is_primary_contact': true,
              'status': 'revoked',
              'notifications_enabled': true,
            },
          ),
        ]);

        expect(await database.select(database.students).get(), isEmpty);
        expect(
          await database.select(database.attendanceRecords).get(),
          isEmpty,
        );
        expect(
          await database.select(database.guardianStudentLinks).get(),
          isEmpty,
        );
      },
    );
  });

  group('attendance_daily_summary', () {
    test(
      'upserts by (student, date) once the student is known locally',
      () async {
        await database.studentsDao.upsert(
          StudentsCompanion.insert(
            uuid: 'student-uuid',
            serverId: const Value(42),
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

        await applier.applyAll([
          _entry(
            resourceType: 'attendance_daily_summary',
            resourceId: 99,
            action: 'created',
            payload: {
              'student_id': 42,
              'date': '2026-07-22',
              'arrival': '2026-07-22T00:05:00+00:00',
              'departure': null,
              'is_late': false,
              'is_absent': false,
            },
          ),
        ]);

        final row = await database
            .select(database.attendanceRecords)
            .getSingle();
        expect(row.studentUuid, 'student-uuid');
        expect(row.serverId, 99);
        expect(row.arrival, DateTime.utc(2026, 7, 22, 0, 5));
        expect(row.isLate, isFalse);
      },
    );

    test(
      'is skipped (not an error) when the student is not yet known locally',
      () async {
        await applier.applyAll([
          _entry(
            resourceType: 'attendance_daily_summary',
            resourceId: 99,
            action: 'created',
            payload: {
              'student_id': 999,
              'date': '2026-07-22',
              'arrival': null,
              'departure': null,
              'is_late': false,
              'is_absent': false,
            },
          ),
        ]);

        expect(
          await database.select(database.attendanceRecords).get(),
          isEmpty,
        );
      },
    );

    test('a corrected action upserts the same as updated', () async {
      await database.studentsDao.upsert(
        StudentsCompanion.insert(
          uuid: 'student-uuid',
          serverId: const Value(42),
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

      await applier.applyAll([
        _entry(
          resourceType: 'attendance_daily_summary',
          resourceId: 99,
          action: 'corrected',
          payload: {
            'student_id': 42,
            'date': '2026-07-22',
            'arrival': '2026-07-22T00:05:00+00:00',
            'departure': null,
            'is_late': true,
            'is_absent': false,
          },
        ),
      ]);

      final row = await database.select(database.attendanceRecords).getSingle();
      expect(row.isLate, isTrue);
    });
  });

  group('announcement', () {
    test('created/updated upserts announcements', () async {
      await applier.applyAll([
        _entry(
          resourceType: 'announcement',
          resourceId: 3,
          action: 'created',
          payload: {
            'uuid': 'announcement-uuid',
            'title': 'Foundation Day',
            'body': 'School closed for Foundation Day celebrations.',
            'status': 'published',
            'published_at': '2026-07-20T01:00:00Z',
            'expires_at': null,
          },
        ),
      ]);

      final row = await database.select(database.announcements).getSingle();
      expect(row.uuid, 'announcement-uuid');
      expect(row.title, 'Foundation Day');
    });

    test(
      'revoked removes the local copy (tombstone, not hidden-but-kept)',
      () async {
        await database.announcementsDao.upsert(
          AnnouncementsCompanion.insert(
            uuid: 'announcement-uuid',
            title: 'Foundation Day',
            body: 'School closed for Foundation Day celebrations.',
            status: 'published',
          ),
        );

        await applier.applyAll([
          _entry(
            resourceType: 'announcement',
            resourceId: 3,
            action: 'revoked',
            payload: {
              'uuid': 'announcement-uuid',
              'title': 'Foundation Day',
              'body': 'School closed for Foundation Day celebrations.',
              'status': 'withdrawn',
              'published_at': null,
              'expires_at': null,
            },
          ),
        ]);

        expect(await database.select(database.announcements).get(), isEmpty);
      },
    );

    test('expired also removes the local copy', () async {
      await database.announcementsDao.upsert(
        AnnouncementsCompanion.insert(
          uuid: 'announcement-uuid',
          title: 'Foundation Day',
          body: 'School closed for Foundation Day celebrations.',
          status: 'published',
        ),
      );

      await applier.applyAll([
        _entry(
          resourceType: 'announcement',
          resourceId: 3,
          action: 'expired',
          payload: {
            'uuid': 'announcement-uuid',
            'title': 'Foundation Day',
            'body': 'School closed for Foundation Day celebrations.',
            'status': 'expired',
            'published_at': null,
            'expires_at': null,
          },
        ),
      ]);

      expect(await database.select(database.announcements).get(), isEmpty);
    });
  });

  group('guardian_notification', () {
    test(
      'created/updated upserts notifications, encoding the nested payload',
      () async {
        await applier.applyAll([
          _entry(
            resourceType: 'guardian_notification',
            resourceId: 11,
            action: 'created',
            payload: {
              'uuid': 'notification-uuid',
              'guardian_id': 7,
              'type': 'arrival',
              'title': 'Arrived at school',
              'body': 'Juan arrived at 7:05 AM.',
              'payload': {'student_id': 42},
              'read_at': null,
              'delivery_status': 'sent',
            },
          ),
        ]);

        final row = await database.select(database.notifications).getSingle();
        expect(row.uuid, 'notification-uuid');
        expect(row.payload, '{"student_id":42}');
        expect(row.readAt, isNull);
      },
    );

    test('deleted removes the local row', () async {
      await database.notificationsDao.upsert(
        NotificationsCompanion.insert(
          uuid: 'notification-uuid',
          type: 'arrival',
          title: 'Arrived at school',
          body: 'Juan arrived at 7:05 AM.',
          deliveryStatus: 'sent',
        ),
      );

      await applier.applyAll([
        _entry(
          resourceType: 'guardian_notification',
          resourceId: 11,
          action: 'deleted',
          payload: {'uuid': 'notification-uuid'},
        ),
      ]);

      expect(await database.select(database.notifications).get(), isEmpty);
    });
  });

  test(
    'an unrecognized resource type is ignored rather than failing the batch',
    () async {
      await applier.applyAll([
        _entry(
          resourceType: 'school',
          resourceId: 1,
          action: 'updated',
          payload: const {},
        ),
      ]);

      // No exception thrown is the assertion; nothing to read back since no
      // local table corresponds to it.
    },
  );
}
