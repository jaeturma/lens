import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/app/router/app_router.dart';

void main() {
  test('no school reset/change route exists (WP-07-04: "no in-app change/'
      'remove option exists")', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final router = container.read(appRouterProvider);
    final paths = router.configuration.routes
        .whereType<GoRoute>()
        .map((route) => route.path)
        .toList();

    expect(paths, [
      AppRoutes.foundation,
      AppRoutes.attendanceHistory,
      AppRoutes.announcements,
      AppRoutes.announcementDetail,
      AppRoutes.notifications,
      AppRoutes.profile,
    ]);
  });
}
