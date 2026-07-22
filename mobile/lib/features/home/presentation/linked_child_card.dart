import 'package:flutter/material.dart';

import '../../../core/database/daos.dart';
import '../../attendance/presentation/attendance_text.dart';

/// One linked child's "cached child status" (WP-07-09's own Scope line) —
/// always from the joined [LinkedChild] the reactive query already
/// assembled, never a live lookup. Tapping opens that child's attendance
/// history (WP-07-10).
class LinkedChildCard extends StatelessWidget {
  const LinkedChildCard({required this.child, required this.onTap, super.key});

  final LinkedChild child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final attendance = child.todayAttendance;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
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
                      attendanceStatusText(
                        attendance,
                        noRecordText: 'No attendance recorded yet today.',
                      ),
                      style: TextStyle(
                        color: attendance?.isAbsent == true
                            ? scheme.error
                            : null,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: scheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}
