import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../sync/application/sync_state_provider.dart';
import '../../sync/presentation/sync_status_banner.dart';
import '../application/attendance_history_provider.dart';
import 'attendance_day_tile.dart';

/// "Build child attendance status and history from SQLite" (WP-07-10) —
/// reached by tapping a child on the home screen (WP-07-09). Everything
/// here — the student's name, the day-by-day list, and "sync freshness" —
/// is a reactive SQLite query; there is no live API call on this screen
/// at all, so it renders identically online or offline.
class AttendanceHistoryPage extends ConsumerWidget {
  const AttendanceHistoryPage({required this.studentUuid, super.key});

  final String studentUuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final student = ref.watch(attendanceStudentProvider(studentUuid));
    final records = ref.watch(attendanceHistoryProvider(studentUuid));
    final syncState = ref.watch(syncStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: switch (student) {
          AsyncData(:final value) => Text(value?.name ?? 'Attendance'),
          _ => const Text('Attendance'),
        },
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SyncStatusBanner(syncState: syncState.value),
              Expanded(
                child: switch (records) {
                  AsyncData(:final value) =>
                    value.isEmpty
                        ? const _EmptyHistoryView()
                        : ListView.separated(
                            itemCount: value.length,
                            separatorBuilder: (context, _) => const Divider(),
                            itemBuilder: (context, index) =>
                                AttendanceDayTile(record: value[index]),
                          ),
                  AsyncError() => const AppErrorView(
                    message: 'Unable to load attendance history.',
                  ),
                  _ => const AppLoadingIndicator(),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyHistoryView extends StatelessWidget {
  const _EmptyHistoryView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 56,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            const Text(
              'No attendance recorded yet.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
