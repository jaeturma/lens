import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

/// The school profile and mobile status data returned by
/// `GET /schools/resolve/{publicId}` (`docs/api/SCHOOL-RESOLVER.md`) — the
/// same shape `GET /sync/bootstrap`'s `school` field uses, per
/// `docs/api/SYNC.md` (both are serialized by the same
/// `SchoolResolverResource` on the Laravel side).
class ResolvedSchool {
  const ResolvedSchool({
    required this.schoolId,
    required this.uuid,
    required this.name,
    required this.logoUrl,
    required this.timezone,
    required this.mobileEnabled,
    required this.maintenanceMode,
    required this.maintenanceMessage,
    required this.notificationsEnabled,
    required this.minimumAppVersion,
  });

  factory ResolvedSchool.fromJson(Map<String, dynamic> json) {
    return ResolvedSchool(
      schoolId: json['school_id'] as String,
      uuid: json['uuid'] as String,
      name: json['name'] as String,
      logoUrl: json['logo_url'] as String?,
      timezone: json['timezone'] as String,
      mobileEnabled: json['mobile_enabled'] as bool,
      maintenanceMode: json['maintenance_mode'] as bool,
      maintenanceMessage: json['maintenance_message'] as String?,
      notificationsEnabled: json['notifications_enabled'] as bool,
      minimumAppVersion: json['minimum_app_version'] as String,
    );
  }

  final String schoolId;
  final String uuid;
  final String name;
  final String? logoUrl;
  final String timezone;
  final bool mobileEnabled;
  final bool maintenanceMode;
  final String? maintenanceMessage;
  final bool notificationsEnabled;
  final String minimumAppVersion;

  SchoolProfileCompanion toCompanion() {
    return SchoolProfileCompanion.insert(
      uuid: uuid,
      publicId: schoolId,
      name: name,
      logoUrl: Value(logoUrl),
      timezone: timezone,
      mobileEnabled: mobileEnabled,
      maintenanceMode: maintenanceMode,
      maintenanceMessage: Value(maintenanceMessage),
      notificationsEnabled: notificationsEnabled,
      minimumAppVersion: minimumAppVersion,
    );
  }
}
