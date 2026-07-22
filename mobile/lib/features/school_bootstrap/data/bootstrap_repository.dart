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
/// locally", by WP-07-09 for the guardian's linked children, and by
/// WP-07-11 for currently-published announcements: fetches the bootstrap
/// response and writes `school`, `guardian`, `children` (+ each child's
/// `today_attendance` snapshot), and `announcements` into their matching
/// local tables. Screens read the cached result reactively via each
/// DAO's `watch()` — this class only ever writes, it is never read from
/// directly.
///
/// This is the *only* place a guardian's linked children or currently-
/// published announcements ever enter local storage for the first time:
/// the incremental sync engine (WP-07-08) only walks the feed forward
/// from this call's own `next_cursor`, so it can never backfill anything
/// that already existed before this login.
///
/// Known limitation: if a link was revoked, or an announcement withdrawn/
/// expired, entirely while this guardian was signed out (not via this
/// app's own logout, which already clears everything — WP-07-07), the
/// stale local row can persist until an eventual `revoked`/`expired`
/// entry is walked, since this method only ever adds/updates what the
/// response currently contains — it does not reconcile rows no longer
/// present.
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

    for (final announcement in result.announcements) {
      await _database.announcementsDao.upsert(announcement.toCompanion());
    }

    // The incremental sync engine's (WP-07-08) starting point — without
    // this, its first call would have no cursor of its own and would have
    // to fall back to SyncCursor.initial(), re-walking the guardian's
    // entire history instead of picking up from here.
    await _database.syncStateDao.saveCursor(result.nextCursor);
  }
}
