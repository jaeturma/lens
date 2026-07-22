import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import 'sync_change_entry.dart';

/// Applies `GET /sync/changes` entries to their matching local table
/// (WP-07-08's "all change types apply locally"). One instance's
/// [applyAll] is meant to run inside a single `AppDatabase.transaction()`
/// call per page (see `SyncEngine`) — this class does not open
/// transactions itself.
///
/// Entries are applied strictly in the given order (the feed's own
/// ascending `id` order, per `docs/api/SYNC.md`). This matters for two
/// resource types that reference a student by numeric id rather than
/// `uuid`: a brand-new student's own `student`-type entry is always
/// created before any `guardian_student_link`/`attendance_daily_summary`
/// entry that could reference it (a link or attendance record cannot
/// exist for a student that doesn't exist yet), so as long as a client
/// walks the feed in order without skipping, the referenced student is
/// always already applied locally by the time a dependent entry arrives.
class SyncChangeApplier {
  SyncChangeApplier(this._database);

  final AppDatabase _database;

  Future<void> applyAll(List<SyncChangeEntry> entries) async {
    for (final entry in entries) {
      await _apply(entry);
    }
  }

  Future<void> _apply(SyncChangeEntry entry) {
    switch (entry.resourceType) {
      case 'guardian':
        return _applyGuardian(entry);
      case 'student':
        return _applyStudent(entry);
      case 'guardian_student_link':
        return _applyGuardianStudentLink(entry);
      case 'attendance_daily_summary':
        return _applyAttendanceDailySummary(entry);
      case 'announcement':
        return _applyAnnouncement(entry);
      case 'guardian_notification':
        return _applyGuardianNotification(entry);
      default:
        // Unrecognized/not-yet-relevant resource type — e.g. `school`,
        // which has no observer emitting real entries today (verified
        // against current Laravel code, not just docs/api/SYNC.md, which
        // is stale on this point). Ignore rather than fail the whole page.
        return Future.value();
    }
  }

  Future<void> _applyGuardian(SyncChangeEntry entry) async {
    if (entry.action == 'deleted') {
      final uuid = entry.payload['uuid'] as String?;
      if (uuid != null) {
        await _database.guardianProfileDao.deleteByUuid(uuid);
      }
      return;
    }

    await _database.guardianProfileDao.upsert(
      GuardianProfileCompanion.insert(
        uuid: entry.payload['uuid'] as String,
        name: entry.payload['name'] as String,
        email: entry.payload['email'] as String,
        mobileNumber: entry.payload['mobile_number'] as String,
        status: entry.payload['status'] as String,
        notifyAttendance: entry.payload['notify_attendance'] as bool,
        notifyAnnouncements: entry.payload['notify_announcements'] as bool,
      ),
    );
  }

  Future<void> _applyStudent(SyncChangeEntry entry) async {
    final uuid = entry.payload['uuid'] as String?;
    if (uuid == null) {
      return;
    }

    if (entry.action == 'deleted') {
      await _database.attendanceRecordsDao.deleteForStudent(uuid);
      await _database.guardianStudentLinksDao.deleteByStudentUuid(uuid);
      await _database.studentsDao.deleteByUuid(uuid);
      return;
    }

    await _database.studentsDao.upsert(
      StudentsCompanion.insert(
        uuid: uuid,
        serverId: Value(entry.resourceId),
        lrn: entry.payload['lrn'] as String,
        studentNumber: entry.payload['student_number'] as String,
        name: entry.payload['name'] as String,
        sex: entry.payload['sex'] as String,
        grade: entry.payload['grade'] as String,
        section: entry.payload['section'] as String,
        schoolYear: entry.payload['school_year'] as String,
        status: entry.payload['status'] as String,
        photoUrl: Value(entry.payload['photo_url'] as String?),
      ),
    );
  }

  /// A `revoked` (or hard `deleted`) link "is exactly what tells the
  /// client to remove a student locally" (`docs/api/SYNC.md`) — not just
  /// the link record, the student and their attendance history too.
  ///
  /// Keyed by `studentUuid` throughout (`tables.dart`), resolved from the
  /// payload's numeric `student_id` the same way `attendance_daily_summary`
  /// is — if the student isn't known locally yet, this entry is skipped
  /// for the same reason (see this class's doc comment on ordering).
  Future<void> _applyGuardianStudentLink(SyncChangeEntry entry) async {
    final uuid = entry.payload['uuid'] as String?;
    final studentServerId = entry.payload['student_id'] as int?;
    if (studentServerId == null) {
      return;
    }

    final studentUuid = await _database.studentsDao.findUuidByServerId(
      studentServerId,
    );
    if (studentUuid == null) {
      return;
    }

    if (entry.action == 'revoked' || entry.action == 'deleted') {
      await _database.attendanceRecordsDao.deleteForStudent(studentUuid);
      await _database.studentsDao.deleteByUuid(studentUuid);
      await _database.guardianStudentLinksDao.deleteByStudentUuid(studentUuid);
      return;
    }

    await _database.guardianStudentLinksDao.upsert(
      GuardianStudentLinksCompanion.insert(
        studentUuid: studentUuid,
        uuid: Value(uuid),
        studentServerId: Value(studentServerId),
        relationshipType: entry.payload['relationship_type'] as String,
        isPrimaryContact: entry.payload['is_primary_contact'] as bool,
        status: entry.payload['status'] as String,
        notificationsEnabled: entry.payload['notifications_enabled'] as bool,
      ),
    );
  }

  Future<void> _applyAttendanceDailySummary(SyncChangeEntry entry) async {
    final studentServerId = entry.payload['student_id'] as int?;
    if (studentServerId == null) {
      return;
    }

    final studentUuid = await _database.studentsDao.findUuidByServerId(
      studentServerId,
    );
    if (studentUuid == null) {
      // The referenced student isn't known locally yet — see this class's
      // doc comment on ordering. Skip; a later entry for the same summary
      // (attendance keeps getting updated) will re-apply once it is.
      return;
    }

    final arrival = entry.payload['arrival'] as String?;
    final departure = entry.payload['departure'] as String?;

    await _database.attendanceRecordsDao.upsert(
      AttendanceRecordsCompanion.insert(
        studentUuid: studentUuid,
        date: DateTime.parse(entry.payload['date'] as String),
        serverId: Value(entry.resourceId),
        arrival: Value(arrival == null ? null : DateTime.parse(arrival)),
        departure: Value(departure == null ? null : DateTime.parse(departure)),
        isLate: entry.payload['is_late'] as bool,
        isAbsent: entry.payload['is_absent'] as bool,
      ),
    );
  }

  /// A `revoked`/`expired` announcement is a tombstone — the client
  /// "removes its local copy on either" (`docs/api/SYNC.md`), the same as
  /// a `guardian_student_link` revocation, not "hidden but kept."
  Future<void> _applyAnnouncement(SyncChangeEntry entry) async {
    final uuid = entry.payload['uuid'] as String?;
    if (uuid == null) {
      return;
    }

    if (entry.action == 'revoked' || entry.action == 'expired') {
      await _database.announcementsDao.deleteByUuid(uuid);
      return;
    }

    final publishedAt = entry.payload['published_at'] as String?;
    final expiresAt = entry.payload['expires_at'] as String?;

    await _database.announcementsDao.upsert(
      AnnouncementsCompanion.insert(
        uuid: uuid,
        title: entry.payload['title'] as String,
        body: entry.payload['body'] as String,
        status: entry.payload['status'] as String,
        publishedAt: Value(
          publishedAt == null ? null : DateTime.parse(publishedAt),
        ),
        expiresAt: Value(expiresAt == null ? null : DateTime.parse(expiresAt)),
      ),
    );
  }

  Future<void> _applyGuardianNotification(SyncChangeEntry entry) async {
    final uuid = entry.payload['uuid'] as String?;
    if (uuid == null) {
      return;
    }

    if (entry.action == 'deleted') {
      await _database.notificationsDao.deleteByUuid(uuid);
      return;
    }

    final readAt = entry.payload['read_at'] as String?;
    final notificationPayload = entry.payload['payload'];

    await _database.notificationsDao.upsert(
      NotificationsCompanion.insert(
        uuid: uuid,
        serverId: Value(entry.resourceId),
        type: entry.payload['type'] as String,
        title: entry.payload['title'] as String,
        body: entry.payload['body'] as String,
        payload: Value(
          notificationPayload == null ? null : jsonEncode(notificationPayload),
        ),
        readAt: Value(readAt == null ? null : DateTime.parse(readAt)),
        deliveryStatus: entry.payload['delivery_status'] as String,
      ),
    );
  }
}
