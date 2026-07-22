import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

/// A guardian's linked child, flattened with their own
/// `guardian_student_link` fields — bootstrap's `LinkedStudentResource`
/// shape (`docs/api/SYNC.md`), the same flattening `docs/DATABASE.md`'s
/// local `students`/`guardian_student_links` split otherwise keeps apart
/// (see `tables.dart`) — bootstrap is simply the one place both arrive
/// together, since a guardian only ever sees their own link for a child.
class ResolvedChild {
  const ResolvedChild({
    required this.uuid,
    required this.lrn,
    required this.studentNumber,
    required this.name,
    required this.sex,
    required this.grade,
    required this.section,
    required this.schoolYear,
    required this.status,
    required this.photoUrl,
    required this.relationshipType,
    required this.isPrimaryContact,
    required this.todayAttendance,
  });

  factory ResolvedChild.fromJson(Map<String, dynamic> json) {
    final attendanceJson = json['today_attendance'] as Map<String, dynamic>?;

    return ResolvedChild(
      uuid: json['uuid'] as String,
      lrn: json['lrn'] as String,
      studentNumber: json['student_number'] as String,
      name: json['name'] as String,
      sex: json['sex'] as String,
      grade: json['grade'] as String,
      section: json['section'] as String,
      schoolYear: json['school_year'] as String,
      status: json['status'] as String,
      photoUrl: json['photo_url'] as String?,
      relationshipType: json['relationship_type'] as String,
      isPrimaryContact: json['is_primary_contact'] as bool,
      todayAttendance: attendanceJson == null
          ? null
          : ResolvedTodayAttendance.fromJson(attendanceJson),
    );
  }

  final String uuid;
  final String lrn;
  final String studentNumber;
  final String name;
  final String sex;
  final String grade;
  final String section;
  final String schoolYear;
  final String status;
  final String? photoUrl;
  final String relationshipType;
  final bool isPrimaryContact;
  final ResolvedTodayAttendance? todayAttendance;

  StudentsCompanion toStudentCompanion() {
    return StudentsCompanion.insert(
      uuid: uuid,
      lrn: lrn,
      studentNumber: studentNumber,
      name: name,
      sex: sex,
      grade: grade,
      section: section,
      schoolYear: schoolYear,
      status: status,
      photoUrl: Value(photoUrl),
    );
  }

  /// `notifications_enabled` has no equivalent field in
  /// `LinkedStudentResource` — defaulted `true` here, the same "bootstrap
  /// gives an incomplete snapshot, a later sync entry backfills the rest"
  /// pattern `Students.serverId`/`GuardianStudentLinks.uuid` already use.
  GuardianStudentLinksCompanion toLinkCompanion() {
    return GuardianStudentLinksCompanion.insert(
      studentUuid: uuid,
      relationshipType: relationshipType,
      isPrimaryContact: isPrimaryContact,
      status: 'active',
      notificationsEnabled: true,
    );
  }
}

class ResolvedTodayAttendance {
  const ResolvedTodayAttendance({
    required this.arrival,
    required this.departure,
    required this.isLate,
    required this.isAbsent,
  });

  factory ResolvedTodayAttendance.fromJson(Map<String, dynamic> json) {
    final arrival = json['arrival'] as String?;
    final departure = json['departure'] as String?;

    return ResolvedTodayAttendance(
      arrival: arrival == null ? null : DateTime.parse(arrival),
      departure: departure == null ? null : DateTime.parse(departure),
      isLate: json['is_late'] as bool,
      isAbsent: json['is_absent'] as bool,
    );
  }

  final DateTime? arrival;
  final DateTime? departure;
  final bool isLate;
  final bool isAbsent;
}
