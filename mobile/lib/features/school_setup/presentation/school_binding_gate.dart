import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_version.dart';
import '../../../core/app_version_provider.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../foundation/presentation/foundation_page.dart';
import 'school_id_setup_page.dart';
import 'school_status_blocked_page.dart';

final schoolBindingProvider = StreamProvider((ref) {
  return ref.watch(appDatabaseProvider).schoolProfileDao.watch();
});

/// The app's actual startup gate (`docs/ARCHITECTURE.md` First Launch /
/// Binding Rules): renders the School ID setup flow until a school is
/// bound locally — reactively, straight off `school_profile`, per
/// `docs/ARCHITECTURE.md`'s Runtime Data Flow — then whatever comes after.
/// Currently that's the placeholder foundation page; later work packages
/// (WP-07-06/07) replace it with real login/home routing.
class SchoolBindingGate extends ConsumerWidget {
  const SchoolBindingGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final binding = ref.watch(schoolBindingProvider);

    return switch (binding) {
      AsyncData(:final value) =>
        value == null
            ? const SchoolIdSetupPage()
            : _BoundSchoolGate(school: value),
      AsyncError() => const AppErrorView(
        message: 'Unable to load local school data.',
      ),
      _ => const AppLoadingIndicator(),
    };
  }
}

/// `docs/api/SCHOOL-RESOLVER.md`'s Client Responsibility section, applied
/// to every screen behind the binding (WP-07-05): block mobile use when
/// disabled, and require an app update below the school's configured
/// minimum — both re-checked against the locally cached school profile on
/// every rebuild, so a school re-enabling mobile use (say) takes effect
/// the next time this table syncs, with no extra plumbing.
class _BoundSchoolGate extends ConsumerWidget {
  const _BoundSchoolGate({required this.school});

  final SchoolProfileData school;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!school.mobileEnabled) {
      return const SchoolStatusBlockedPage(
        title: 'Mobile Access Disabled',
        message:
            'Your school has temporarily disabled mobile access. '
            'Please check back later.',
      );
    }

    final appVersion = ref.watch(appVersionProvider);

    return switch (appVersion) {
      AsyncData(:final value) =>
        isBelowMinimumAppVersion(value, school.minimumAppVersion)
            ? const SchoolStatusBlockedPage(
                title: 'Update Required',
                message:
                    'A newer version of this app is required to continue. '
                    'Please update from the Play Store.',
              )
            : FoundationPage(school: school),
      // A version-lookup failure is a plugin/platform hiccup unrelated to
      // whether the app is actually compatible — fail open rather than
      // lock the guardian out of a working app over it.
      _ => FoundationPage(school: school),
    };
  }
}
