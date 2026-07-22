import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/database/app_database.dart';
import 'package:mobile/features/sync/application/sync_engine.dart';
import 'package:mobile/features/sync/data/sync_api.dart';
import 'package:mobile/features/sync/data/sync_change_entry.dart';

SyncChangeEntry _guardianEntry(String uuid) {
  return SyncChangeEntry(
    resourceType: 'guardian',
    resourceId: 7,
    action: 'created',
    payload: {
      'uuid': uuid,
      'name': 'Maria Dela Cruz',
      'email': 'maria@example.com',
      'mobile_number': '09171234567',
      'status': 'active',
      'notify_attendance': true,
      'notify_announcements': true,
    },
    createdAt: DateTime.utc(2026, 7, 22),
  );
}

/// Serves a scripted sequence of pages/failures, one per call, and
/// records which cursor each call was made with — so tests can assert
/// both what the engine wrote locally and exactly how it walked the feed.
class _ScriptedSyncApi extends SyncApi {
  _ScriptedSyncApi(this._script) : super(Dio());

  final List<Object> _script;
  final List<String> requestedCursors = [];
  int _calls = 0;

  @override
  Future<SyncChangesPage> fetchChanges({
    required String cursor,
    int limit = 100,
  }) async {
    requestedCursors.add(cursor);
    final next = _script[_calls++];
    if (next is Exception) {
      throw next;
    }
    return next as SyncChangesPage;
  }
}

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  test(
    'a single non-paginated sync applies its changes and saves the new cursor',
    () async {
      final api = _ScriptedSyncApi([
        SyncChangesPage(
          nextCursor: 'cursor-1',
          hasMore: false,
          changes: [_guardianEntry('guardian-uuid')],
        ),
      ]);

      await SyncEngine(api, database).sync();

      expect(await database.syncStateDao.readCursor(), 'cursor-1');
      final row = await database.select(database.guardianProfile).getSingle();
      expect(row.uuid, 'guardian-uuid');
    },
  );

  test('pagination: walks every page while has_more is true, requesting each '
      'page\'s own nextCursor as the following request\'s cursor', () async {
    final api = _ScriptedSyncApi([
      SyncChangesPage(
        nextCursor: 'cursor-1',
        hasMore: true,
        changes: [_guardianEntry('guardian-uuid')],
      ),
      SyncChangesPage(nextCursor: 'cursor-2', hasMore: false, changes: []),
    ]);

    await SyncEngine(api, database).sync();

    expect(api.requestedCursors, [
      SyncEngine.fallbackInitialCursor,
      'cursor-1',
    ]);
    expect(await database.syncStateDao.readCursor(), 'cursor-2');
  });

  test(
    'starts from the previously saved cursor rather than the fallback, '
    'when one already exists (the normal case — bootstrap already saved one)',
    () async {
      await database.syncStateDao.saveCursor('cursor-from-bootstrap');

      final api = _ScriptedSyncApi([
        SyncChangesPage(nextCursor: 'cursor-1', hasMore: false, changes: []),
      ]);

      await SyncEngine(api, database).sync();

      expect(api.requestedCursors, ['cursor-from-bootstrap']);
    },
  );

  test('a mid-pagination failure keeps the previously committed cursor — '
      '"failed sync keeps previous cursor"', () async {
    final api = _ScriptedSyncApi([
      SyncChangesPage(
        nextCursor: 'cursor-1',
        hasMore: true,
        changes: [_guardianEntry('guardian-uuid')],
      ),
      Exception('network unreachable'),
    ]);

    await expectLater(SyncEngine(api, database).sync(), throwsException);

    // The first page's changes and cursor did commit (atomically,
    // together) — only the second page's failure is visible.
    expect(await database.syncStateDao.readCursor(), 'cursor-1');
    final row = await database.select(database.guardianProfile).getSingle();
    expect(row.uuid, 'guardian-uuid');
  });

  test('retrying after an interruption resumes from the last committed cursor, '
      'not from the beginning', () async {
    final firstAttempt = _ScriptedSyncApi([
      SyncChangesPage(
        nextCursor: 'cursor-1',
        hasMore: true,
        changes: [_guardianEntry('guardian-uuid')],
      ),
      Exception('network unreachable'),
    ]);
    await expectLater(
      SyncEngine(firstAttempt, database).sync(),
      throwsException,
    );

    final retry = _ScriptedSyncApi([
      SyncChangesPage(nextCursor: 'cursor-2', hasMore: false, changes: []),
    ]);
    await SyncEngine(retry, database).sync();

    expect(retry.requestedCursors, ['cursor-1']);
    expect(await database.syncStateDao.readCursor(), 'cursor-2');
  });
}
