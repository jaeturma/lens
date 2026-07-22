import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/daos.dart';
import '../../../core/database/database_provider.dart';

/// A guardian's actively-linked children, each with today's attendance if
/// any has landed locally yet — reactive, straight off SQLite
/// (`docs/ARCHITECTURE.md` Runtime Data Flow), never a live API call.
/// Parameterized by "today" rather than computing it internally so the
/// caller (which already knows the bound school's timezone) is the single
/// source of what date this actually means (`core/school_timezone.dart`).
final linkedChildrenProvider =
    StreamProvider.family<List<LinkedChild>, DateTime>((ref, today) {
      return ref
          .watch(appDatabaseProvider)
          .linkedChildrenDao
          .watchActive(today);
    });

/// "Last sync" / staleness (WP-07-09).
final syncStateProvider = StreamProvider<SyncStateData?>((ref) {
  return ref.watch(appDatabaseProvider).syncStateDao.watch();
});
