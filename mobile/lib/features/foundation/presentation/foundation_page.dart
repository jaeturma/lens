import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/database/app_database.dart';
import '../../auth/application/session_controller.dart';
import '../../sync/application/sync_engine.dart';

class FoundationPage extends ConsumerWidget {
  const FoundationPage({required this.school, super.key});

  final SchoolProfileData school;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // "Support startup": fires once, the first time this screen renders
    // after login. Deliberately not awaited/surfaced here — a failure
    // just means the next trigger (pull-to-refresh, next startup) tries
    // again; anything it does write reaches the screen through the
    // tables it updates, not through this.
    ref.watch(startupSyncProvider);

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
        // "Support pull-to-refresh": the placeholder home screen's stand-in
        // for it, until WP-07-09 builds the real one.
        child: RefreshIndicator(
          onRefresh: () => ref.read(syncEngineProvider).sync(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (school.maintenanceMode) ...[
                      _MaintenanceBanner(message: school.maintenanceMessage),
                      const SizedBox(height: 16),
                    ],
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Icon(
                              Icons.school_outlined,
                              size: 72,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Foundation Ready',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'The Flutter application now has routing, state management, secure token storage, API configuration, reusable states, and a testable feature-first structure.',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            _InfoRow(label: 'API', value: AppConfig.apiBaseUrl),
                            const _InfoRow(label: 'Target', value: 'Android'),
                            const _InfoRow(
                              label: 'Architecture',
                              value: 'Feature-first',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
