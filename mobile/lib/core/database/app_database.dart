import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'daos.dart';
import 'tables.dart';

part 'app_database.g.dart';

/// The mobile runtime source of truth (`docs/ARCHITECTURE.md`): every
/// screen reads from here, never directly from a network response. Laravel
/// incremental sync writes into this database through the DAOs below; it
/// never populates the UI on its own (see `docs/ARCHITECTURE.md` Runtime
/// Data Flow).
@DriftDatabase(
  tables: [
    AppSettings,
    SchoolProfile,
    GuardianProfile,
    Students,
    AttendanceRecords,
    Announcements,
    Notifications,
    SyncState,
  ],
  daos: [
    AppSettingsDao,
    SchoolProfileDao,
    GuardianProfileDao,
    StudentsDao,
    AttendanceRecordsDao,
    AnnouncementsDao,
    NotificationsDao,
    SyncStateDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'lens');
  }
}
