import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../auth/application/session_controller.dart';
import '../../school_setup/presentation/school_binding_gate.dart';
import '../../sync/application/sync_state_provider.dart';
import '../../sync/presentation/sync_status_banner.dart';
import '../application/profile_provider.dart';

/// "Build local-first profile, notification preference display, last-sync
/// information, and logout" (WP-07-14) — every value here comes from a
/// locally synced table; nothing on this screen is editable. Notification
/// preferences are **display-only** (disabled switches): changing them is
/// not part of this package's scope, and school binding has no edit or
/// remove control at all — the same "no in-app change/remove option
/// exists" precedent WP-07-04 already established.
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guardian = ref.watch(guardianProfileProvider);
    final school = ref.watch(schoolBindingProvider);
    final syncState = ref.watch(syncStateProvider);

    if (guardian is AsyncError || school is AsyncError) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const AppErrorView(message: 'Unable to load your profile.'),
      );
    }

    final guardianValue = guardian.value;
    final schoolValue = school.value;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: guardianValue == null || schoolValue == null
            ? const AppLoadingIndicator()
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  SyncStatusBanner(syncState: syncState.value),
                  _Section(
                    title: 'Guardian',
                    children: [
                      _InfoRow(label: 'Name', value: guardianValue.name),
                      _InfoRow(label: 'Email', value: guardianValue.email),
                      _InfoRow(
                        label: 'Mobile Number',
                        value: guardianValue.mobileNumber,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _Section(
                    title: 'Notification Preferences',
                    children: [
                      _PreferenceRow(
                        label: 'Attendance Notifications',
                        enabled: guardianValue.notifyAttendance,
                      ),
                      _PreferenceRow(
                        label: 'Announcement Notifications',
                        enabled: guardianValue.notifyAnnouncements,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _Section(
                    title: 'School',
                    children: [
                      _InfoRow(label: 'School', value: schoolValue.name),
                      _InfoRow(label: 'School ID', value: schoolValue.publicId),
                    ],
                  ),
                  const SizedBox(height: 32),
                  OutlinedButton.icon(
                    onPressed: () async {
                      // Unlike `HomePage`'s own Log Out button, this
                      // screen is reached via `context.push` — it stays
                      // on top of the navigation stack even once the
                      // guardian's session flips to false underneath, so
                      // its own (now-deleted) data would otherwise leave
                      // it stuck rendering the loading state forever.
                      // `context.go` replaces the entire stack, landing
                      // back on `SchoolBindingGate`'s already-correct
                      // "no session" branch (the login screen).
                      await ref
                          .read(sessionControllerProvider.notifier)
                          .logout();
                      if (context.mounted) {
                        context.go(AppRoutes.foundation);
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Log Out'),
                  ),
                ],
              ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...children,
      ],
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
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

/// A disabled `Switch` — visually a toggle, but `onChanged: null` makes it
/// non-interactive, so it reads unambiguously as display-only rather than
/// an editable preference (`docs/NOTIFICATIONS.md`/`docs/api/SYNC.md`: a
/// guardian's notification preferences are set elsewhere and only synced
/// down, never written from this app).
class _PreferenceRow extends StatelessWidget {
  const _PreferenceRow({required this.label, required this.enabled});

  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Switch(value: enabled, onChanged: null),
        ],
      ),
    );
  }
}
