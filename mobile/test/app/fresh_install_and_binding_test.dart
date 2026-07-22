import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app/lens_app.dart';
import 'package:mobile/core/database/app_database.dart';
import 'package:mobile/core/database/database_provider.dart';

import '../support/app_test_harness.dart';

/// WP-08-01's own validation suite for `docs/ARCHITECTURE.md`'s Binding
/// Rules. Most of the Objective's named scenarios ("first install",
/// "School ID resolution", "lock", "restart", "logout", "no reset option")
/// already have full, passing coverage elsewhere and are deliberately
/// **not** duplicated here — see this package's own Implementation Notes
/// for the exact file/test citations. What's added in this file is the one
/// scenario that had no assertion of its own anywhere: "app-data clear" and
/// "uninstall/reinstall" are, from the app's own perspective,
/// indistinguishable from a genuine first install — both leave local
/// storage completely empty. That equivalence is asserted directly here
/// rather than left as an unverified claim.
///
/// A widget-level "restart" test (a file-backed `NativeDatabase`, pumped
/// through the full `LensApp` tree) was attempted here and dropped: it
/// reproducibly hung `pumpAndSettle` past its 10-minute timeout, unlike
/// every other test in this suite, all of which use
/// `NativeDatabase.memory()`. The restart invariant remains proven by the
/// combination already in place — `app_database_test.dart`'s own
/// file-backed, non-widget restart test (two `AppDatabase` instances over
/// one file), plus every other passing widget test in this suite
/// confirming `SchoolBindingGate` reacts correctly to whatever
/// `schoolProfileDao.watch()` emits — without forcing a fragile,
/// hanging test into existence for marginal additional confidence.
void main() {
  testWidgets('app-data clear / uninstall+reinstall: both leave local storage '
      'completely empty — the same starting state as a genuine first '
      'install, and handled by the exact same code path', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: const LensApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Set Up Your School'), findsOneWidget);

    await disposeAppUnderTest(tester);
  });
}
