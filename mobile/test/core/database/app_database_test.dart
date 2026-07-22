import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/database/app_database.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  test('the database opens and migrates every table into existence', () async {
    await database.select(database.appSettings).get();
    await database.select(database.schoolProfile).get();
    await database.select(database.guardianProfile).get();
    await database.select(database.students).get();
    await database.select(database.attendanceRecords).get();
    await database.select(database.announcements).get();
    await database.select(database.notifications).get();
    await database.select(database.syncState).get();
  });

  test(
    'a school profile upsert by uuid updates in place rather than duplicating',
    () async {
      final entry = SchoolProfileCompanion.insert(
        uuid: 'school-uuid',
        publicId: 'SCH-0001',
        name: 'Example School',
        timezone: 'Asia/Manila',
        mobileEnabled: true,
        maintenanceMode: false,
        notificationsEnabled: true,
        minimumAppVersion: '0.1.0',
      );

      await database.schoolProfileDao.upsert(entry);
      await database.schoolProfileDao.upsert(
        entry.copyWith(name: const Value('Renamed School')),
      );

      final rows = await database.select(database.schoolProfile).get();
      expect(rows, hasLength(1));
      expect(rows.single.name, 'Renamed School');
    },
  );

  test(
    'a student upsert by uuid updates in place rather than duplicating',
    () async {
      final entry = StudentsCompanion.insert(
        uuid: 'student-uuid',
        lrn: '123456789012',
        studentNumber: 'SN-0001',
        name: 'Juan Dela Cruz',
        sex: 'male',
        grade: 'Grade 7',
        section: 'Diamond',
        schoolYear: '2026-2027',
        status: 'active',
        relationshipType: 'mother',
        isPrimaryContact: true,
      );

      await database.studentsDao.upsert(entry);
      await database.studentsDao.upsert(
        entry.copyWith(grade: const Value('Grade 8')),
      );

      final rows = await database.select(database.students).get();
      expect(rows, hasLength(1));
      expect(rows.single.grade, 'Grade 8');
    },
  );

  test(
    'a notification upsert by uuid updates in place rather than duplicating',
    () async {
      final entry = NotificationsCompanion.insert(
        uuid: 'notification-uuid',
        type: 'attendance.arrival',
        title: 'Arrived at school',
        body: 'Juan arrived at 7:05 AM.',
        deliveryStatus: 'pending',
      );

      await database.notificationsDao.upsert(entry);
      await database.notificationsDao.upsert(
        entry.copyWith(deliveryStatus: const Value('sent')),
      );

      final rows = await database.select(database.notifications).get();
      expect(rows, hasLength(1));
      expect(rows.single.deliveryStatus, 'sent');
    },
  );

  test(
    'an attendance record upserts by (student, date) rather than duplicating, '
    'even though its own primary key is a local autoincrement id',
    () async {
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
          relationshipType: 'mother',
          isPrimaryContact: true,
        ),
      );

      final date = DateTime.utc(2026, 7, 22);
      final entry = AttendanceRecordsCompanion.insert(
        studentUuid: 'student-uuid',
        date: date,
        isLate: false,
        isAbsent: false,
      );

      await database.attendanceRecordsDao.upsert(entry);
      await database.attendanceRecordsDao.upsert(
        entry.copyWith(arrival: Value(DateTime.utc(2026, 7, 22, 7, 5))),
      );

      final rows = await database.select(database.attendanceRecords).get();
      expect(rows, hasLength(1));
      expect(rows.single.arrival, DateTime.utc(2026, 7, 22, 7, 5));
    },
  );

  test(
    'the sync cursor is a single row that is overwritten, not appended to',
    () async {
      await database.syncStateDao.saveCursor('cursor-a');
      await database.syncStateDao.saveCursor('cursor-b');

      final rows = await database.select(database.syncState).get();
      expect(rows, hasLength(1));
      expect(await database.syncStateDao.readCursor(), 'cursor-b');
    },
  );

  test('the school binding survives an app restart (WP-07-04: "app restart '
      'does not ask again") — a fresh AppDatabase over the same file still '
      'has it', () async {
    final directory = await Directory.systemTemp.createTemp('lens_db_test');
    final path = '${directory.path}/restart_test.sqlite';
    addTearDown(() => directory.delete(recursive: true));

    final firstRun = AppDatabase(NativeDatabase(File(path)));
    await firstRun.schoolProfileDao.upsert(
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
    await firstRun.close();

    // A brand new AppDatabase instance, exactly as app startup would
    // construct one after a process restart — not the same Dart object.
    final secondRun = AppDatabase(NativeDatabase(File(path)));
    addTearDown(secondRun.close);

    final school = await secondRun.schoolProfileDao.watch().first;
    expect(school, isNotNull);
    expect(school!.uuid, 'school-uuid');
  });
}
