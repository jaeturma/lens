import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';

/// "Last sync" and a "stale/offline indicator" (WP-07-09's own Scope
/// line, reused by WP-07-10's attendance history for "sync freshness"): a
/// lightweight, non-blocking banner — this app has no live connectivity
/// check, so "stale" is inferred purely from how long ago the last
/// successful sync committed, the same 15-minute cadence the Laravel
/// side's own periodic sweeps use (`routes/console.php`).
class SyncStatusBanner extends StatelessWidget {
  const SyncStatusBanner({required this.syncState, super.key});

  final SyncStateData? syncState;

  static const _staleAfter = Duration(minutes: 15);

  @override
  Widget build(BuildContext context) {
    final lastSyncedAt = syncState?.lastSyncedAt;
    final isStale =
        lastSyncedAt == null ||
        DateTime.now().difference(lastSyncedAt) > _staleAfter;

    if (!isStale) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          'Last synced ${_relativeTime(lastSyncedAt)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }

    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off, size: 18, color: scheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              lastSyncedAt == null
                  ? 'Not synced yet. Data may be incomplete.'
                  : 'Data may be out of date — last synced ${_relativeTime(lastSyncedAt)}.',
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  static String _relativeTime(DateTime dateTime) {
    final age = DateTime.now().difference(dateTime);

    if (age.inMinutes < 1) return 'just now';
    if (age.inMinutes < 60) {
      return '${age.inMinutes} minute${age.inMinutes == 1 ? '' : 's'} ago';
    }
    if (age.inHours < 24) {
      return '${age.inHours} hour${age.inHours == 1 ? '' : 's'} ago';
    }
    return '${age.inDays} day${age.inDays == 1 ? '' : 's'} ago';
  }
}
