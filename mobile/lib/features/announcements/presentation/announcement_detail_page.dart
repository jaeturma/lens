import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/date_format.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../application/announcements_provider.dart';

/// "...and detail from SQLite" (WP-07-11) — reached by tapping a row on
/// [AnnouncementsPage]. If the announcement is withdrawn or expires while
/// this screen is open, `SyncChangeApplier` (WP-07-08) deletes the local
/// row out from under this reactive query — handled the same as "not
/// found," not as an error, since that tombstone is the expected way an
/// announcement stops being visible at all (`docs/api/SYNC.md`).
class AnnouncementDetailPage extends ConsumerWidget {
  const AnnouncementDetailPage({required this.announcementUuid, super.key});

  final String announcementUuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcement = ref.watch(announcementProvider(announcementUuid));

    return Scaffold(
      appBar: AppBar(title: const Text('Announcement')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: switch (announcement) {
            AsyncData(:final value) =>
              value == null
                  ? const _NoLongerAvailableView()
                  : _AnnouncementBody(announcement: value),
            AsyncError() => const AppErrorView(
              message: 'Unable to load this announcement.',
            ),
            _ => const AppLoadingIndicator(),
          },
        ),
      ),
    );
  }
}

class _AnnouncementBody extends StatelessWidget {
  const _AnnouncementBody({required this.announcement});

  final Announcement announcement;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            announcement.title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          if (announcement.publishedAt != null) ...[
            const SizedBox(height: 4),
            Text(
              formatCalendarDate(announcement.publishedAt!),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 16),
          Text(announcement.body),
        ],
      ),
    );
  }
}

class _NoLongerAvailableView extends StatelessWidget {
  const _NoLongerAvailableView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.campaign_outlined,
              size: 56,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            const Text(
              'This announcement is no longer available.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
