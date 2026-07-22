import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/school_timezone.dart';
import 'bootstrap_api.dart';

final bootstrapRepositoryProvider = Provider<BootstrapRepository>((ref) {
  return BootstrapRepository(
    ref.watch(bootstrapApiProvider),
    ref.watch(appDatabaseProvider),
  );
});

/// "Download and store mobile school configuration and branding"
/// (WP-07-05), extended by WP-07-06 for "guardian profile is stored
/// locally" and by WP-07-09 for the guardian's linked children: fetches
/// the bootstrap response and writes its `school`, `guardian`, and
/// `children` portions into `school_profile`/`guardian_profile`/
/// `students`+`guardian_student_links` (+`attendance_records`, for each
/// child's `today_attendance` snapshot). Screens read the cached result
/// reactively via each DAO's `watch()` — this class only ever writes, it
/// is never read from directly.
///
/// This is the *only* place a guardian's linked children ever enter local
/// storage for the first time: the incremental sync engine (WP-07-08)
/// only walks the feed forward from this call's own `next_cursor`, so it
/// can never backfill a child (or their attendance) that already existed
/// before this login.
///
/// Known limitation: if a link was revoked entirely while this guardian
/// was signed out (not via this app's own logout, which already clears
/// everything — WP-07-07), a stale local child can persist until an
/// eventual `guardian_student_link` `revoked` entry is walked, since this
/// method only ever adds/updates children present in the response, it
/// does not reconcile ones no longer present.
class BootstrapRepository {
  BootstrapRepository(this._api, this._database);

  final BootstrapApi _api;
  final AppDatabase _database;

  Future<void> sync() async {
    final result = await _api.fetch();

    await _database.schoolProfileDao.upsert(result.school.toCompanion());

    final guardian = result.guardian;
    if (guardian != null) {
      await _database.guardianProfileDao.upsert(guardian.toCompanion());
    }

    final today = todayIn(result.school.timezone);
    for (final child in result.children) {
      await _database.studentsDao.upsert(child.toStudentCompanion());
      await _database.guardianStudentLinksDao.upsert(child.toLinkCompanion());

      final attendance = child.todayAttendance;
      if (attendance != null) {
        await _database.attendanceRecordsDao.upsert(
          AttendanceRecordsCompanion.insert(
            studentUuid: child.uuid,
            date: today,
            arrival: Value(attendance.arrival),
            departure: Value(attendance.departure),
            isLate: attendance.isLate,
            isAbsent: attendance.isAbsent,
          ),
        );
      }
    }

    // The incremental sync engine's (WP-07-08) starting point — without
    // this, its first call would have no cursor of its own and would have
    // to fall back to SyncCursor.initial(), re-walking the guardian's
    // entire history instead of picking up from here.
    await _database.syncStateDao.saveCursor(result.nextCursor);
  }
}
