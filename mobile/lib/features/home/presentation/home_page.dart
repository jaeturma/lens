import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/school_timezone.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../auth/application/session_controller.dart';
import '../../sync/application/sync_engine.dart';
import '../application/linked_children_provider.dart';
import 'linked_child_card.dart';
import 'sync_status_banner.dart';

/// The parent home screen (WP-07-09) — "screens render without live API":
/// every piece of this screen (linked children, today's status, last
/// sync) comes from a reactive SQLite query, so it renders identically
/// whether the device is online or not (`docs/ARCHITECTURE.md` Runtime
/// Data Flow). Replaces the WP-07-01/05 placeholder foundation page as
/// the authenticated screen `SchoolBindingGate` shows.
class HomePage extends ConsumerWidget {
  const HomePage({required this.school, super.key});

  final SchoolProfileData school;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // "Support startup" (WP-07-08): fires once, the first time this
    // screen renders after login.
    ref.watch(startupSyncProvider);

    final today = todayIn(school.timezone);
    final children = ref.watch(linkedChildrenProvider(today));
    final syncState = ref.watch(syncStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(school.name),
        leading: school.logoUrl != null
            ? Padding(
                padding: const EdgeInsets.all(8),
                child: Image.network(
                  school.logoUrl!,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.school_outlined),
                ),
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log Out',
            onPressed: () =>
                ref.read(sessionControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(syncEngineProvider).sync(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (school.maintenanceMode) ...[
                  _MaintenanceBanner(message: school.maintenanceMessage),
                  const SizedBox(height: 12),
                ],
                SyncStatusBanner(syncState: syncState.value),
                switch (children) {
                  AsyncData(:final value) =>
                    value.isEmpty
                        ? const _EmptyChildrenView()
                        : Column(
                            children: value
                                .map((child) => LinkedChildCard(child: child))
                                .toList(),
                          ),
                  AsyncError() => const AppErrorView(
                    message: 'Unable to load linked children.',
                  ),
                  _ => const AppLoadingIndicator(),
                },
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyChildrenView extends StatelessWidget {
  const _EmptyChildrenView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(
            Icons.family_restroom_outlined,
            size: 56,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          const Text('No linked children yet.', textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _MaintenanceBanner extends StatelessWidget {
  const _MaintenanceBanner({required this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: scheme.onErrorContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message ?? 'This school is currently under maintenance.',
              style: TextStyle(color: scheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}
