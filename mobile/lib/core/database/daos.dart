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
}

/// Repository boundary for [Students]: the guardian's linked children.
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
}

/// Repository boundary for [SyncState]: the single local cursor row.
@DriftAccessor(tables: [SyncState])
class SyncStateDao extends DatabaseAccessor<AppDatabase>
    with _$SyncStateDaoMixin {
  SyncStateDao(super.db);

  static const _rowId = 0;

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
