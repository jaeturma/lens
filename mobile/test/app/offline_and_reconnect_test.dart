import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app/lens_app.dart';
import 'package:mobile/core/app_version_provider.dart';
import 'package:mobile/core/database/app_database.dart';
import 'package:mobile/core/database/database_provider.dart';
import 'package:mobile/core/network/api_exception.dart';
import 'package:mobile/features/auth/application/session_controller.dart';
import 'package:mobile/features/sync/application/sync_engine.dart';
import 'package:mobile/features/sync/data/sync_api.dart';
import 'package:mobile/features/sync/data/sync_change_entry.dart';

import '../support/app_test_harness.dart';

/// WP-08-02's own validation suite for `docs/OFFLINE-SYNC.md`. Most of the
/// Objective's named scenarios ("initial sync", "pagination", "cursor
/// safety", "failed sync"/"interrupted sync does not skip changes", and
/// "retry"/"reconnect" resuming from the last committed cursor) already
/// have full, passing coverage and are deliberately **not** duplicated
/// here:
/// - `test/features/school_bootstrap/bootstrap_repository_test.dart`
///   proves the initial (bootstrap) sync.
/// - `test/features/sync/sync_engine_test.dart` proves pagination, cursor
///   safety, that a mid-page failure leaves the previous cursor
///   untouched, and that retrying afterward resumes from exactly that
///   cursor rather than skipping or repeating from the start.
///
/// What had no assertion anywhere is this package's remaining acceptance
/// criterion, "offline screens remain usable": `HomePage` fires a sync on
/// every build (`ref.watch(startupSyncProvider)`,
/// `lib/features/home/presentation/home_page.dart`) but never reads that
/// future's result — by construction the screen always renders from its
/// own reactive SQLite queries regardless of whether that sync succeeds
/// (`docs/ARCHITECTURE.md` Runtime Data Flow: "Flutter screens do not use
/// network responses as their primary view model"). That was true by
/// construction but never exercised end-to-end with a sync call that
/// actually fails, so it remained an unverified claim rather than a
/// proven one.
class _ThrowingSyncApi extends SyncApi {
  _ThrowingSyncApi() : super(Dio());

  @override
  Future<SyncChangesPage> fetchChanges({
    required String cursor,
    int limit = 100,
  }) async {
    throw ApiException(message: 'network unreachable', statusCode: null);
  }
}

/// Fails exactly like a real disconnected device until connectivity is
/// restored (`isOffline` flipped to `false`), then serves one page — the
/// same instance the whole widget tree keeps using via
/// `syncApiProvider`, so "reconnect" here means what it means on a real
/// device: the network comes back, nothing about the app's own wiring
/// changes.
class _FlakySyncApi extends SyncApi {
  _FlakySyncApi() : super(Dio());

  bool isOffline = true;

  @override
  Future<SyncChangesPage> fetchChanges({
    required String cursor,
    int limit = 100,
  }) async {
    if (isOffline) {
      throw ApiException(message: 'network unreachable', statusCode: null);
    }

    return SyncChangesPage(
      nextCursor: 'cursor-1',
      hasMore: false,
      changes: [
        SyncChangeEntry(
          resourceType: 'guardian',
          resourceId: 7,
          action: 'created',
          payload: {
            'uuid': 'guardian-uuid',
            'name': 'Maria Dela Cruz',
            'email': 'maria@example.com',
            'mobile_number': '09171234567',
            'status': 'active',
            'notify_attendance': true,
            'notify_announcements': true,
          },
          createdAt: DateTime.utc(2026, 7, 22),
        ),
      ],
    );
  }
}

Future<AppDatabase> _seedBoundSchoolWithPreviouslySyncedChild() async {
  final database = AppDatabase(NativeDatabase.memory());
  addTearDown(database.close);

  await database.schoolProfileDao.upsert(
    SchoolProfileCompanion.insert(
      uuid: 'school-uuid',
      publicId: 'SCH-0001',
      name: 'Example School',
      timezone: 'Asia/Manila',
      mobileEnabled: true,
      maintenanceMode: false,
      notificationsEnabled: true,
      minimumAppVersion: '0.1.0',
    ),
  );
  await database.studentsDao.upsert(
    StudentsCompanion.insert(
      uuid: 'student-1',
      lrn: '123456789012',
      studentNumber: 'SN-0001',
      name: 'Juan Dela Cruz',
      sex: 'male',
      grade: 'Grade 7',
      section: 'Diamond',
      schoolYear: '2026-2027',
      status: 'active',
    ),
  );
  await database.guardianStudentLinksDao.upsert(
    GuardianStudentLinksCompanion.insert(
      studentUuid: 'student-1',
      relationshipType: 'mother',
      isPrimaryContact: true,
      status: 'active',
      notificationsEnabled: true,
    ),
  );
  await database.syncStateDao.saveCursor('cursor-from-earlier-session');

  return database;
}

void main() {
  testWidgets('a failing startup sync (no connection) still renders previously '
      'synced data, rather than blocking or crashing the home screen', (
    tester,
  ) async {
    final database = await _seedBoundSchoolWithPreviouslySyncedChild();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          appVersionProvider.overrideWith((ref) async => '0.1.0'),
          sessionControllerProvider.overrideWith(FakeAuthenticatedSession.new),
          syncApiProvider.overrideWithValue(_ThrowingSyncApi()),
        ],
        child: const LensApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Juan Dela Cruz'), findsOneWidget);
    expect(find.text('No linked children yet.'), findsNothing);

    // The failed sync must not have touched the cursor saved by an
    // earlier, successful session.
    expect(
      await database.syncStateDao.readCursor(),
      'cursor-from-earlier-session',
    );

    await disposeAppUnderTest(tester);
  });

  testWidgets(
    'retrying after a failed sync succeeds and applies the changes it '
    'brings, once connectivity returns',
    (tester) async {
      final database = await _seedBoundSchoolWithPreviouslySyncedChild();
      final api = _FlakySyncApi();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(database),
            appVersionProvider.overrideWith((ref) async => '0.1.0'),
            sessionControllerProvider.overrideWith(
              FakeAuthenticatedSession.new,
            ),
            syncApiProvider.overrideWithValue(api),
          ],
          child: const LensApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        await database.syncStateDao.readCursor(),
        'cursor-from-earlier-session',
      );

      // Connectivity returns. The same retry path this package's Objective
      // calls out ("reconnect") is `syncEngineProvider.sync()` — the exact
      // call `HomePage`'s pull-to-refresh makes.
      api.isOffline = false;
      final container = ProviderScope.containerOf(
        tester.element(find.byType(LensApp)),
      );
      await container.read(syncEngineProvider).sync();

      expect(await database.syncStateDao.readCursor(), 'cursor-1');
      final row = await database.select(database.guardianProfile).getSingle();
      expect(row.uuid, 'guardian-uuid');

      await disposeAppUnderTest(tester);
    },
  );
}
