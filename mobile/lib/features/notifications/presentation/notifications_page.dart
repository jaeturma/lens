import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../sync/application/sync_state_provider.dart';
import '../../sync/presentation/sync_status_banner.dart';
import '../application/notifications_provider.dart';

/// "Build notification inbox and unread state from SQLite" (WP-07-12) —
/// reactive, straight off the local `notifications` table, same
/// local-first shape every other phase-07 screen already uses. Tapping a
/// row marks it read both locally (instant, offline-friendly) and on the
/// server (best-effort) via `NotificationsController.markRead`.
class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);
    final syncState = ref.watch(syncStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SyncStatusBanner(syncState: syncState.value),
              Expanded(
                child: switch (notifications) {
                  AsyncData(:final value) =>
                    value.isEmpty
                        ? const _EmptyNotificationsView()
                        : ListView.separated(
                            itemCount: value.length,
                            separatorBuilder: (context, _) => const Divider(),
                            itemBuilder: (context, index) {
                              final notification = value[index];
                              final isUnread = notification.readAt == null;

                              return ListTile(
                                leading: isUnread
                                    ? Icon(
                                        Icons.circle,
                                        size: 10,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      )
                                    : const SizedBox(width: 10),
                                title: Text(
                                  notification.title,
                                  style: TextStyle(
                                    fontWeight: isUnread
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                subtitle: Text(
                                  notification.body,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () => ref
                                    .read(notificationsControllerProvider)
                                    .markRead(notification.uuid),
                              );
                            },
                          ),
                  AsyncError() => const AppErrorView(
                    message: 'Unable to load notifications.',
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

class _EmptyNotificationsView extends StatelessWidget {
  const _EmptyNotificationsView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_none_outlined,
              size: 56,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            const Text('No notifications yet.', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
