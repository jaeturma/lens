import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app/lens_app.dart';

void main() {
  testWidgets('shows the foundation page', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: LensApp()));
    await tester.pumpAndSettle();

    expect(find.text('Foundation Ready'), findsOneWidget);
    expect(find.text('Project LENS'), findsOneWidget);
  });
}
