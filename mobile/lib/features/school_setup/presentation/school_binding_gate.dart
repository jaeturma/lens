import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_version.dart';
import '../../../core/app_version_provider.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../auth/application/session_controller.dart';
import '../../auth/presentation/login_page.dart';
import '../../home/presentation/home_page.dart';
import 'school_id_setup_page.dart';
import 'school_status_blocked_page.dart';

final schoolBindingProvider = StreamProvider((ref) {
  return ref.watch(appDatabaseProvider).schoolProfileDao.watch();
});

/// The app's actual startup gate (`docs/ARCHITECTURE.md` First Launch /
/// Binding Rules): renders the School ID setup flow until a school is
/// bound locally — reactively, straight off `school_profile`, per
/// `docs/ARCHITECTURE.md`'s Runtime Data Flow — then whatever comes after:
/// login, or the real home screen (WP-07-09).
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
            : _AuthenticationGate(school: school),
      // A version-lookup failure is a plugin/platform hiccup unrelated to
      // whether the app is actually compatible — fail open rather than
      // lock the guardian out of a working app over it.
      _ => _AuthenticationGate(school: school),
    };
  }
}

/// "Authenticated routing" (WP-07-06): a bound, non-blocked installation
/// still needs a guardian session before showing app content.
/// `sessionControllerProvider`'s own check re-validates an existing token
/// against the server (WP-07-07 — see `SessionController`).
class _AuthenticationGate extends ConsumerWidget {
  const _AuthenticationGate({required this.school});

  final SchoolProfileData school;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);

    return switch (session) {
      AsyncData(:final value) =>
        value ? HomePage(school: school) : LoginPage(school: school),
      // An unreadable session is treated the same as no session — fail
      // safe by asking the guardian to log in again, not by assuming
      // they're still authenticated. Loading (the initial secure-storage
      // read) gets its own branch so an already-logged-in guardian never
      // sees a login-screen flash while it resolves.
      AsyncError() => LoginPage(school: school),
      _ => const AppLoadingIndicator(),
    };
  }
}
