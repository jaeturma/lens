import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

/// A currently-published, audience-matching announcement from bootstrap's
/// top-level `announcements` array (`docs/api/SYNC.md`) — the same shape
/// `AnnouncementObserver`'s own sync-feed payload uses, deliberately, per
/// that doc, so this reuses the exact field set rather than a second one.
class ResolvedAnnouncement {
  const ResolvedAnnouncement({
    required this.uuid,
    required this.title,
    required this.body,
    required this.status,
    required this.publishedAt,
    required this.expiresAt,
  });

  factory ResolvedAnnouncement.fromJson(Map<String, dynamic> json) {
    final publishedAt = json['published_at'] as String?;
    final expiresAt = json['expires_at'] as String?;

    return ResolvedAnnouncement(
      uuid: json['uuid'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      status: json['status'] as String,
      publishedAt: publishedAt == null ? null : DateTime.parse(publishedAt),
      expiresAt: expiresAt == null ? null : DateTime.parse(expiresAt),
    );
  }

  final String uuid;
  final String title;
  final String body;
  final String status;
  final DateTime? publishedAt;
  final DateTime? expiresAt;

  AnnouncementsCompanion toCompanion() {
    return AnnouncementsCompanion.insert(
      uuid: uuid,
      title: title,
      body: body,
      status: status,
      publishedAt: Value(publishedAt),
      expiresAt: Value(expiresAt),
    );
  }
}
