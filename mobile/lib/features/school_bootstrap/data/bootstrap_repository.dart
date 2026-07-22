import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import 'bootstrap_api.dart';

final bootstrapRepositoryProvider = Provider<BootstrapRepository>((ref) {
  return BootstrapRepository(
    ref.watch(bootstrapApiProvider),
    ref.watch(appDatabaseProvider),
  );
});

/// "Download and store mobile school configuration and branding"
/// (WP-07-05), extended by WP-07-06 for "guardian profile is stored
/// locally": fetches the bootstrap response and writes its `school` and
/// `guardian` portions into `school_profile`/`guardian_profile`. Screens
/// read the cached result reactively via each DAO's `watch()` — this class
/// only ever writes, it is never read from directly.
class BootstrapRepository {
  BootstrapRepository(this._api, this._database);

  final BootstrapApi _api;
  final AppDatabase _database;

  Future<void> sync() async {
    final result = await _api.fetch();

    await _database.schoolProfileDao.upsert(result.school.toCompanion());

    final guardian = result.guardian;
    if (guardian != null) {
      await _database.guardianProfileDao.upsert(guardian.toCompanion());
    }
  }
}
