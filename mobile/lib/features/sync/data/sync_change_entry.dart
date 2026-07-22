/// One entry from `GET /sync/changes` (`docs/api/SYNC.md`) — a snapshot of
/// a single resource change. `resourceId` is the resource's own **numeric**
/// database id (never its `uuid`); `payload` is the resource-specific
/// full-snapshot shape documented per resource type there.
class SyncChangeEntry {
  const SyncChangeEntry({
    required this.resourceType,
    required this.resourceId,
    required this.action,
    required this.payload,
    required this.createdAt,
  });

  factory SyncChangeEntry.fromJson(Map<String, dynamic> json) {
    return SyncChangeEntry(
      resourceType: json['resource_type'] as String,
      resourceId: json['resource_id'] as int,
      action: json['action'] as String,
      payload: (json['payload'] as Map<String, dynamic>?) ?? const {},
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  final String resourceType;
  final int resourceId;
  final String action;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
}

class SyncChangesPage {
  const SyncChangesPage({
    required this.nextCursor,
    required this.hasMore,
    required this.changes,
  });

  factory SyncChangesPage.fromJson(Map<String, dynamic> json) {
    final changes = (json['changes'] as List)
        .cast<Map<String, dynamic>>()
        .map(SyncChangeEntry.fromJson)
        .toList();

    return SyncChangesPage(
      nextCursor: json['next_cursor'] as String,
      hasMore: json['has_more'] as bool,
      changes: changes,
    );
  }

  final String nextCursor;
  final bool hasMore;
  final List<SyncChangeEntry> changes;
}
