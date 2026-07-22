import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/daos.dart';

/// One linked child's "cached child status" (WP-07-09's own Scope line) —
/// always from the joined [LinkedChild] the reactive query already
/// assembled, never a live lookup.
class LinkedChildCard extends StatelessWidget {
  const LinkedChildCard({required this.child, super.key});

  final LinkedChild child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final attendance = child.todayAttendance;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: child.student.photoUrl != null
                  ? NetworkImage(child.student.photoUrl!)
                  : null,
              child: child.student.photoUrl == null
                  ? const Icon(Icons.person_outline)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    child.student.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '${child.student.grade} - ${child.student.section}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _statusText(attendance),
                    style: TextStyle(
                      color: attendance?.isAbsent == true ? scheme.error : null,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _statusText(AttendanceRecord? attendance) {
    if (attendance == null) {
      return 'No attendance recorded yet today.';
    }
    if (attendance.isAbsent) {
      return 'Absent today.';
    }
    if (attendance.arrival == null) {
      return 'Not yet arrived.';
    }

    final arrival = _formatTime(attendance.arrival!);
    final late = attendance.isLate ? ' (Late)' : '';

    if (attendance.departure != null) {
      return 'Arrived at $arrival$late, departed at ${_formatTime(attendance.departure!)}.';
    }

    return 'Arrived at $arrival$late.';
  }

  static String _formatTime(DateTime utcTime) {
    final local = utcTime.toLocal();
    final hour24 = local.hour;
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = hour24 < 12 ? 'AM' : 'PM';
    return '$hour12:$minute $period';
  }
}
