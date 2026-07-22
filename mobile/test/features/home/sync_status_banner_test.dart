import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/database/app_database.dart';
import 'package:mobile/features/home/presentation/sync_status_banner.dart';

Future<void> _pumpBanner(WidgetTester tester, SyncStateData? syncState) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: SyncStatusBanner(syncState: syncState)),
    ),
  );
}

void main() {
  testWidgets('never synced shows the "not synced yet" message', (
    tester,
  ) async {
    await _pumpBanner(tester, null);

    expect(
      find.text('Not synced yet. Data may be incomplete.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'a recent sync shows a plain "last synced" line, not the stale banner',
    (tester) async {
      final recent = DateTime.now().subtract(const Duration(minutes: 2));
      await _pumpBanner(
        tester,
        SyncStateData(id: 0, cursor: 'cursor-1', lastSyncedAt: recent),
      );

      expect(find.textContaining('Last synced'), findsOneWidget);
      expect(find.textContaining('out of date'), findsNothing);
    },
  );

  testWidgets('a sync older than 15 minutes shows the stale banner', (
    tester,
  ) async {
    final stale = DateTime.now().subtract(const Duration(minutes: 20));
    await _pumpBanner(
      tester,
      SyncStateData(id: 0, cursor: 'cursor-1', lastSyncedAt: stale),
    );

    expect(find.textContaining('Data may be out of date'), findsOneWidget);
  });
}
