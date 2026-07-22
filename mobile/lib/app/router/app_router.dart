import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/announcements/presentation/announcement_detail_page.dart';
import '../../features/announcements/presentation/announcements_page.dart';
import '../../features/attendance/presentation/attendance_history_page.dart';
import '../../features/school_setup/presentation/school_binding_gate.dart';

abstract final class AppRoutes {
  static const foundation = '/';
  static const attendanceHistory = '/attendance/:studentUuid';
  static const announcements = '/announcements';
  static const announcementDetail = '/announcements/:announcementUuid';

  static String attendanceHistoryPath(String studentUuid) =>
      '/attendance/$studentUuid';

  static String announcementDetailPath(String announcementUuid) =>
      '/announcements/$announcementUuid';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.foundation,
    routes: [
      GoRoute(
        path: AppRoutes.foundation,
        builder: (context, state) => const SchoolBindingGate(),
      ),
      GoRoute(
        path: AppRoutes.attendanceHistory,
        builder: (context, state) => AttendanceHistoryPage(
          studentUuid: state.pathParameters['studentUuid']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.announcements,
        builder: (context, state) => const AnnouncementsPage(),
      ),
      GoRoute(
        path: AppRoutes.announcementDetail,
        builder: (context, state) => AnnouncementDetailPage(
          announcementUuid: state.pathParameters['announcementUuid']!,
        ),
      ),
    ],
  );
});
