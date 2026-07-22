import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/database/app_database.dart';
import 'package:mobile/features/attendance/presentation/attendance_text.dart';

void main() {
  test('formatTimeOfDay renders 12-hour local time with AM/PM', () {
    expect(formatTimeOfDay(DateTime.utc(2026, 7, 22, 0, 5)), isNotEmpty);
    // Exercise both halves of the 12-hour wraparound directly in UTC,
    // since the actual AM/PM boundary depends on the runner's local
    // timezone offset — assert the format shape, not a specific string.
    final formatted = formatTimeOfDay(DateTime.utc(2026, 7, 22, 12, 0));
    expect(formatted, matches(RegExp(r'^\d{1,2}:\d{2} (AM|PM)$')));
  });

  test('formatAttendanceDate renders month name, day, year', () {
    expect(formatAttendanceDate(DateTime.utc(2026, 7, 22)), 'Jul 22, 2026');
    expect(formatAttendanceDate(DateTime.utc(2026, 1, 1)), 'Jan 1, 2026');
  });

  group('attendanceStatusText', () {
    late AppDatabase database;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
    });

    tearDown(() => database.close());

    test('no record uses the default message, or a caller-supplied one', () {
      expect(attendanceStatusText(null), 'No attendance recorded.');
      expect(
        attendanceStatusText(
          null,
          noRecordText: 'No attendance recorded yet today.',
        ),
        'No attendance recorded yet today.',
      );
    });

    Future<AttendanceRecord> record({
      DateTime? arrival,
      DateTime? departure,
      bool isLate = false,
      bool isAbsent = false,
    }) async {
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
      await database.attendanceRecordsDao.upsert(
        AttendanceRecordsCompanion.insert(
          studentUuid: 'student-uuid',
          date: DateTime.utc(2026, 7, 22),
          arrival: Value(arrival),
          departure: Value(departure),
          isLate: isLate,
          isAbsent: isAbsent,
        ),
      );
      return database.select(database.attendanceRecords).getSingle();
    }

    test('absent takes precedence', () async {
      final absent = await record(isAbsent: true);
      expect(attendanceStatusText(absent), 'Absent.');
    });

    test('no arrival yet', () async {
      final notYetArrived = await record();
      expect(attendanceStatusText(notYetArrived), 'Not yet arrived.');
    });

    test('arrived only, not late', () async {
      final arrived = await record(arrival: DateTime.utc(2026, 7, 22, 0, 5));
      expect(attendanceStatusText(arrived), startsWith('Arrived at'));
      expect(attendanceStatusText(arrived), isNot(contains('Late')));
      expect(attendanceStatusText(arrived), isNot(contains('departed')));
    });

    test('arrived late', () async {
      final late = await record(
        arrival: DateTime.utc(2026, 7, 22, 1, 0),
        isLate: true,
      );
      expect(attendanceStatusText(late), contains('(Late)'));
    });

    test('arrived and departed', () async {
      final full = await record(
        arrival: DateTime.utc(2026, 7, 22, 0, 5),
        departure: DateTime.utc(2026, 7, 22, 6, 0),
      );
      expect(attendanceStatusText(full), contains('departed at'));
    });
  });
}
