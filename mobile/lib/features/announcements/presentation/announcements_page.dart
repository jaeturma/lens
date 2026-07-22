import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../../../core/date_format.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../sync/application/sync_state_provider.dart';
import '../../sync/presentation/sync_status_banner.dart';
import '../application/announcements_provider.dart';

/// "Build announcement list ... from SQLite" (WP-07-11) — reactive,
/// straight off the local `announcements` table; there is no live API
/// call on this screen. "Offline data is readable" holds for the same
/// reason every other screen in this app does: the data was already here
/// before this screen ever mounted.
class AnnouncementsPage extends ConsumerWidget {
  const AnnouncementsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcements = ref.watch(announcementsProvider);
    final syncState = ref.watch(syncStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Announcements')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SyncStatusBanner(syncState: syncState.value),
              Expanded(
                child: switch (announcements) {
                  AsyncData(:final value) =>
                    value.isEmpty
                        ? const _EmptyAnnouncementsView()
                        : ListView.separated(
                            itemCount: value.length,
                            separatorBuilder: (context, _) => const Divider(),
                            itemBuilder: (context, index) {
                              final announcement = value[index];
                              return ListTile(
                                title: Text(announcement.title),
                                subtitle: Text(
                                  announcement.publishedAt == null
                                      ? announcement.body
                                      : formatCalendarDate(
                                          announcement.publishedAt!,
                                        ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () => context.push(
                                  AppRoutes.announcementDetailPath(
                                    announcement.uuid,
                                  ),
                                ),
                              );
                            },
                          ),
                  AsyncError() => const AppErrorView(
                    message: 'Unable to load announcements.',
                  ),
                  _ => const AppLoadingIndicator(),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyAnnouncementsView extends StatelessWidget {
  const _EmptyAnnouncementsView();

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
            const Text('No announcements yet.', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
