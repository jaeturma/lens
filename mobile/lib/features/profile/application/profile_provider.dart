import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';

/// "Profile is accurate from SQLite" (WP-07-14) — reactive, straight off
/// the locally synced `guardian_profile` row; there is no live API call
/// on this screen. `schoolBindingProvider`
/// (`features/school_setup/presentation/school_binding_gate.dart`) and
/// `syncStateProvider` (`features/sync/application/sync_state_provider.dart`)
/// already cover the school and last-sync halves of this page.
final guardianProfileProvider = StreamProvider<GuardianProfileData?>((ref) {
  return ref.watch(appDatabaseProvider).guardianProfileDao.watch();
});
