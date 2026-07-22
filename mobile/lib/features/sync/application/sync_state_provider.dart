import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';

/// "Last sync" / staleness (WP-07-09), reused wherever synced data is
/// shown (the home screen, per-child attendance history — WP-07-10).
final syncStateProvider = StreamProvider<SyncStateData?>((ref) {
  return ref.watch(appDatabaseProvider).syncStateDao.watch();
});
