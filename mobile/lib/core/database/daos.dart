import 'package:drift/drift.dart';

import 'app_database.dart';
import 'tables.dart';

part 'daos.g.dart';

/// Repository boundary for [AppSettings]: a generic key/value store, so
/// callers get/set by key rather than reaching into the table directly.
@DriftAccessor(tables: [AppSettings])
class AppSettingsDao extends DatabaseAccessor<AppDatabase>
    with _$AppSettingsDaoMixin {
  AppSettingsDao(super.db);

  Future<String?> read(String key) async {
    final row = await (select(
      appSettings,
    )..where((row) => row.key.equals(key))).getSingleOrNull();

    return row?.value;
  }

  Future<void> write(String key, String? value) {
    return into(appSettings).insertOnConflictUpdate(
      AppSettingsCompanion.insert(key: key, value: Value(value)),
    );
  }
}

/// Repository boundary for [SchoolProfile]: exactly one row, the school
/// this installation is bound to.
@DriftAccessor(tables: [SchoolProfile])
class SchoolProfileDao extends DatabaseAccessor<AppDatabase>
    with _$SchoolProfileDaoMixin {
  SchoolProfileDao(super.db);

  Stream<SchoolProfileData?> watch() =>
      select(schoolProfile).watchSingleOrNull();

  Future<void> upsert(SchoolProfileCompanion entry) {
    return into(schoolProfile).insertOnConflictUpdate(entry);
  }
}

/// Repository boundary for [GuardianProfile]: exactly one row, the signed-in
/// guardian's own profile.
@DriftAccessor(tables: [GuardianProfile])
class GuardianProfileDao extends DatabaseAccessor<AppDatabase>
    with _$GuardianProfileDaoMixin {
  GuardianProfileDao(super.db);

  Stream<GuardianProfileData?> watch() =>
      select(guardianProfile).watchSingleOrNull();

  Future<void> upsert(GuardianProfileCompanion entry) {
    return into(guardianProfile).insertOnConflictUpdate(entry);
  }

  Future<void> deleteByUuid(String uuid) {
    return (delete(
      guardianProfile,
    )..where((row) => row.uuid.equals(uuid))).go();
  }
}

/// Repository boundary for [Students].
@DriftAccessor(tables: [Students])
class StudentsDao extends DatabaseAccessor<AppDatabase>
    with _$StudentsDaoMixin {
  StudentsDao(super.db);

  Stream<List<Student>> watchAll() => select(students).watch();

  Future<void> upsert(StudentsCompanion entry) {
    return into(students).insertOnConflictUpdate(entry);
  }

  Future<void> deleteByUuid(String uuid) {
    return (delete(students)..where((row) => row.uuid.equals(uuid))).go();
  }

  /// Resolves a `student`-type resource's numeric server id to the local
  /// row's `uuid` — needed because `attendance_daily_summary` and
  /// `guardian_student_link` payloads key a student by that numeric id,
  /// never by `uuid` (`docs/api/SYNC.md`).
  Future<String?> findUuidByServerId(int serverId) async {
    final row = await (select(
      students,
    )..where((row) => row.serverId.equals(serverId))).getSingleOrNull();

    return row?.uuid;
  }
}

/// Repository boundary for [GuardianStudentLinks].
@DriftAccessor(tables: [GuardianStudentLinks])
class GuardianStudentLinksDao extends DatabaseAccessor<AppDatabase>
    with _$GuardianStudentLinksDaoMixin {
  GuardianStudentLinksDao(super.db);

  Stream<List<GuardianStudentLink>> watchAll() =>
      select(guardianStudentLinks).watch();

  Future<void> upsert(GuardianStudentLinksCompanion entry) {
    return into(guardianStudentLinks).insertOnConflictUpdate(entry);
  }

  Future<void> deleteByStudentUuid(String studentUuid) {
    return (delete(
      guardianStudentLinks,
    )..where((row) => row.studentUuid.equals(studentUuid))).go();
  }
}

/// Repository boundary for [AttendanceRecords]: one row per linked child per
/// day.
@DriftAccessor(tables: [AttendanceRecords])
class AttendanceRecordsDao extends DatabaseAccessor<AppDatabase>
    with _$AttendanceRecordsDaoMixin {
  AttendanceRecordsDao(super.db);

  Stream<List<AttendanceRecord>> watchForStudent(String studentUuid) {
    return (select(
      attendanceRecords,
    )..where((row) => row.studentUuid.equals(studentUuid))).watch();
  }

  /// The table's own primary key is a local autoincrement id, not the
  /// `(studentUuid, date)` pair every row is actually unique on (see
  /// `tables.dart`), so the conflict target is given explicitly —
  /// `insertOnConflictUpdate` alone would only de-duplicate by that local id.
  Future<void> upsert(AttendanceRecordsCompanion entry) {
    return into(attendanceRecords).insert(
      entry,
      onConflict: DoUpdate(
        (_) => entry,
        target: [attendanceRecords.studentUuid, attendanceRecords.date],
      ),
    );
  }

  /// Used when a student is removed locally (their `guardian_student_link`
  /// was revoked or deleted) — their attendance history goes with them.
  Future<void> deleteForStudent(String studentUuid) {
    return (delete(
      attendanceRecords,
    )..where((row) => row.studentUuid.equals(studentUuid))).go();
  }
}

class LinkedChild {
  const LinkedChild({
    required this.student,
    required this.link,
    this.todayAttendance,
  });

  final Student student;
  final GuardianStudentLink link;
  final AttendanceRecord? todayAttendance;
}

/// Cross-table repository boundary for the parent home screen (WP-07-09):
/// a guardian's actively-linked children, each joined with today's
/// attendance if any has landed yet. Spans three tables because that's
/// what the home screen's own "linked child" concept does — no single
/// table/DAO above represents it on its own.
@DriftAccessor(tables: [Students, GuardianStudentLinks, AttendanceRecords])
class LinkedChildrenDao extends DatabaseAccessor<AppDatabase>
    with _$LinkedChildrenDaoMixin {
  LinkedChildrenDao(super.db);

  Stream<List<LinkedChild>> watchActive(DateTime today) {
    final query =
        select(students).join([
            innerJoin(
              guardianStudentLinks,
              guardianStudentLinks.studentUuid.equalsExp(students.uuid),
            ),
            leftOuterJoin(
              attendanceRecords,
              attendanceRecords.studentUuid.equalsExp(students.uuid) &
                  attendanceRecords.date.equals(today),
            ),
          ])
          ..where(guardianStudentLinks.status.equals('active'))
          ..orderBy([OrderingTerm.asc(students.name)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return LinkedChild(
          student: row.readTable(students),
          link: row.readTable(guardianStudentLinks),
          todayAttendance: row.readTableOrNull(attendanceRecords),
        );
      }).toList();
    });
  }
}

/// Repository boundary for [Announcements]: currently published,
/// audience-matching announcements.
@DriftAccessor(tables: [Announcements])
class AnnouncementsDao extends DatabaseAccessor<AppDatabase>
    with _$AnnouncementsDaoMixin {
  AnnouncementsDao(super.db);

  Stream<List<Announcement>> watchAll() => select(announcements).watch();

  Future<void> upsert(AnnouncementsCompanion entry) {
    return into(announcements).insertOnConflictUpdate(entry);
  }

  Future<void> deleteByUuid(String uuid) {
    return (delete(announcements)..where((row) => row.uuid.equals(uuid))).go();
  }
}

/// Repository boundary for [Notifications]: the guardian's own inbox.
@DriftAccessor(tables: [Notifications])
class NotificationsDao extends DatabaseAccessor<AppDatabase>
    with _$NotificationsDaoMixin {
  NotificationsDao(super.db);

  Stream<List<NotificationRow>> watchAll() => select(notifications).watch();

  Future<void> upsert(NotificationsCompanion entry) {
    return into(notifications).insertOnConflictUpdate(entry);
  }

  Future<void> deleteByUuid(String uuid) {
    return (delete(notifications)..where((row) => row.uuid.equals(uuid))).go();
  }
}

/// Repository boundary for [SyncState]: the single local cursor row.
@DriftAccessor(tables: [SyncState])
class SyncStateDao extends DatabaseAccessor<AppDatabase>
    with _$SyncStateDaoMixin {
  SyncStateDao(super.db);

  static const _rowId = 0;

  /// For "last sync"/staleness display (WP-07-09) — the single row,
  /// reactively, rather than a one-time read.
  Stream<SyncStateData?> watch() {
    return (select(
      syncState,
    )..where((row) => row.id.equals(_rowId))).watchSingleOrNull();
  }

  Future<String?> readCursor() async {
    final row = await (select(
      syncState,
    )..where((row) => row.id.equals(_rowId))).getSingleOrNull();

    return row?.cursor;
  }

  Future<void> saveCursor(String cursor) {
    return into(syncState).insertOnConflictUpdate(
      SyncStateCompanion.insert(
        id: const Value(_rowId),
        cursor: Value(cursor),
        lastSyncedAt: Value(DateTime.now()),
      ),
    );
  }
}
