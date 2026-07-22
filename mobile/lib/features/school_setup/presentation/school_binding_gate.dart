import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../foundation/presentation/foundation_page.dart';
import 'school_id_setup_page.dart';

final schoolBindingProvider = StreamProvider((ref) {
  return ref.watch(appDatabaseProvider).schoolProfileDao.watch();
});

/// The app's actual startup gate (`docs/ARCHITECTURE.md` First Launch /
/// Binding Rules): renders the School ID setup flow until a school is
/// bound locally — reactively, straight off `school_profile`, per
/// `docs/ARCHITECTURE.md`'s Runtime Data Flow — then whatever comes after.
/// Currently that's the placeholder foundation page; later work packages
/// (WP-07-01/06/07) replace it with real login/home routing.
class SchoolBindingGate extends ConsumerWidget {
  const SchoolBindingGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final binding = ref.watch(schoolBindingProvider);

    return switch (binding) {
      AsyncData(:final value) =>
        value == null ? const SchoolIdSetupPage() : const FoundationPage(),
      AsyncError() => const AppErrorView(
        message: 'Unable to load local school data.',
      ),
      _ => const AppLoadingIndicator(),
    };
  }
}
