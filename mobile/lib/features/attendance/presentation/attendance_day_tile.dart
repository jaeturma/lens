import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import 'attendance_text.dart';

class AttendanceDayTile extends StatelessWidget {
  const AttendanceDayTile({required this.record, super.key});

  final AttendanceRecord record;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // Color via the subtitle Text's own `style`, not ListTile's
    // `subtitleTextStyle` — the latter feeds an AnimatedDefaultTextStyle
    // that ListTile itself owns, and toggling it between a bare
    // TextStyle(color: ...) (inherit: true) and null (falls back to the
    // theme's merged style, inherit: false) makes Flutter try to
    // interpolate between mismatched `inherit` values when a correction
    // changes isAbsent and this tile rebuilds, which throws.
    return ListTile(
      title: Text(formatAttendanceDate(record.date)),
      subtitle: Text(
        attendanceStatusText(record),
        style: TextStyle(color: record.isAbsent ? scheme.error : null),
      ),
      leading: Icon(
        record.isAbsent ? Icons.event_busy : Icons.event_available,
        color: record.isAbsent ? scheme.error : scheme.primary,
      ),
    );
  }
}
