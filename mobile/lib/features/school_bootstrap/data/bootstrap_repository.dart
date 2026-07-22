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
/// (WP-07-05): fetches the bootstrap response and writes its `school`
/// portion into the local `school_profile` table. Screens then read the
/// cached result reactively via `SchoolProfileDao.watch()` — this class
/// only ever writes, it is never read from directly.
class BootstrapRepository {
  BootstrapRepository(this._api, this._database);

  final BootstrapApi _api;
  final AppDatabase _database;

  Future<void> syncSchoolProfile() async {
    final school = await _api.fetchSchool();
    await _database.schoolProfileDao.upsert(school.toCompanion());
  }
}
