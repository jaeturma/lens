import '../../../core/database/app_database.dart';

/// The guardian's own profile, from `GET /sync/bootstrap`'s `guardian`
/// field (`docs/api/SYNC.md`) — `null` when the authenticated account has
/// no `Guardian` profile yet (a guardian-role login does not require one,
/// per WP-02-02/04/05).
class ResolvedGuardian {
  const ResolvedGuardian({
    required this.uuid,
    required this.name,
    required this.email,
    required this.mobileNumber,
    required this.status,
    required this.notifyAttendance,
    required this.notifyAnnouncements,
  });

  factory ResolvedGuardian.fromJson(Map<String, dynamic> json) {
    return ResolvedGuardian(
      uuid: json['uuid'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      mobileNumber: json['mobile_number'] as String,
      status: json['status'] as String,
      notifyAttendance: json['notify_attendance'] as bool,
      notifyAnnouncements: json['notify_announcements'] as bool,
    );
  }

  final String uuid;
  final String name;
  final String email;
  final String mobileNumber;
  final String status;
  final bool notifyAttendance;
  final bool notifyAnnouncements;

  GuardianProfileCompanion toCompanion() {
    return GuardianProfileCompanion.insert(
      uuid: uuid,
      name: name,
      email: email,
      mobileNumber: mobileNumber,
      status: status,
      notifyAttendance: notifyAttendance,
      notifyAnnouncements: notifyAnnouncements,
    );
  }
}
