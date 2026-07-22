import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';

/// "Active targeted announcements display" (WP-07-11): every currently
/// cached announcement, reactive off SQLite. There is no client-side
/// status filter here on purpose — the local table only ever contains
/// audience-matching, currently-published rows in the first place: the
/// server only ever sends a guardian a `Published` one (bootstrap and
/// `AnnouncementObserver` alike never emit `Draft`), and
/// `SyncChangeApplier` deletes the local row outright the moment one is
/// withdrawn or expires. "Hide or remove expired and withdrawn
/// announcements" is therefore already the local table's own invariant,
/// not something this query re-checks.
final announcementsProvider = StreamProvider<List<Announcement>>((ref) {
  return ref.watch(appDatabaseProvider).announcementsDao.watchAll();
});

final announcementProvider = StreamProvider.family<Announcement?, String>((
  ref,
  uuid,
) {
  return ref.watch(appDatabaseProvider).announcementsDao.watchByUuid(uuid);
});
