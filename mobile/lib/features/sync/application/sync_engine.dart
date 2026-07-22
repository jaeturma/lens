import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../data/sync_api.dart';
import '../data/sync_change_applier.dart';

final syncEngineProvider = Provider<SyncEngine>((ref) {
  return SyncEngine(ref.watch(syncApiProvider), ref.watch(appDatabaseProvider));
});

/// "Support startup" (WP-07-08's own Scope line): run once, the first time
/// something watches it — naturally the authenticated screen's first
/// build. A silent background sync; anything it writes reaches the UI
/// through the tables it updates being watched directly, not through this
/// provider's own result (`docs/ARCHITECTURE.md` Runtime Data Flow).
/// "Resume" and "push signal" triggers are for whichever work package
/// builds the real home screen / wires push (WP-07-09/13) to call
/// `syncEngineProvider`'s `sync()` from — this only needs to be ready for
/// that, not wire it today.
final startupSyncProvider = FutureProvider<void>((ref) {
  return ref.read(syncEngineProvider).sync();
});

/// The incremental sync engine (WP-07-08): walks `GET /sync/changes` from
/// the locally saved cursor, one page at a time, applying every entry and
/// advancing the cursor only once that page's changes have actually
/// committed — both in the *same* transaction, so the two can never end
/// up out of step with each other.
///
/// "Failed sync keeps previous cursor" falls out of this for free: if a
/// page's request or transaction throws, nothing after it runs, so
/// `sync_state` is left exactly where the last successful page left it.
/// Calling [sync] again later (startup, resume, pull-to-refresh, a push
/// signal, or just retrying) resumes from there — there is no separate
/// "retry" code path to get wrong.
///
/// Applying a resource type this engine doesn't recognize (or one with no
/// current real-world entries, like `school` — see `SyncChangeApplier`) is
/// a no-op, not a failure, so an older client isn't broken by a future
/// resource type it doesn't understand yet.
class SyncEngine {
  SyncEngine(this._api, this._database);

  final SyncApi _api;
  final AppDatabase _database;

  /// Mirrors the server's own `SyncCursor::initial()` encoding
  /// (`docs/api/SYNC.md`) — used only as a defensive fallback. In normal
  /// operation `sync_state.cursor` is never actually null by the time this
  /// runs: `BootstrapRepository` (WP-07-05/06/08) already saves the
  /// bootstrap response's own `next_cursor` right after login.
  static const fallbackInitialCursor = 'MA==';

  Future<void> sync({int limit = 100}) async {
    var cursor =
        await _database.syncStateDao.readCursor() ?? fallbackInitialCursor;
    var hasMore = true;

    while (hasMore) {
      final page = await _api.fetchChanges(cursor: cursor, limit: limit);

      await _database.transaction(() async {
        await SyncChangeApplier(_database).applyAll(page.changes);
        await _database.syncStateDao.saveCursor(page.nextCursor);
      });

      cursor = page.nextCursor;
      hasMore = page.hasMore;
    }
  }
}
