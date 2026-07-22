import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';

/// The student's own record, reactive — a route reached by `uuid` alone
/// (WP-07-10) needs this to render a header/title.
final attendanceStudentProvider = StreamProvider.family<Student?, String>((
  ref,
  studentUuid,
) {
  return ref.watch(appDatabaseProvider).studentsDao.watchByUuid(studentUuid);
});

/// "Child attendance status and history" (WP-07-10) — every attendance
/// record ever synced for this student, newest first, reactive straight
/// off SQLite. A correction lands here the same way any other update
/// does: `SyncChangeApplier` (WP-07-08) upserts the same row in place, so
/// this stream reflects it without any special-casing.
final attendanceHistoryProvider =
    StreamProvider.family<List<AttendanceRecord>, String>((ref, studentUuid) {
      return ref
          .watch(appDatabaseProvider)
          .attendanceRecordsDao
          .watchForStudent(studentUuid);
    });
