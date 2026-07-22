import '../../../core/database/app_database.dart';
import '../../../core/date_format.dart';

/// Shared with [LinkedChildCard] (`features/home/`) — one phrasing for an
/// attendance row wherever it's shown, today's status or history alike.
/// [noRecordText] lets a "today" caller be more specific ("...yet today")
/// than a history row, where any date could have no record.
String attendanceStatusText(
  AttendanceRecord? record, {
  String noRecordText = 'No attendance recorded.',
}) {
  if (record == null) {
    return noRecordText;
  }
  if (record.isAbsent) {
    return 'Absent.';
  }
  if (record.arrival == null) {
    return 'Not yet arrived.';
  }

  final arrival = formatTimeOfDay(record.arrival!);
  final late = record.isLate ? ' (Late)' : '';

  if (record.departure != null) {
    return 'Arrived at $arrival$late, departed at ${formatTimeOfDay(record.departure!)}.';
  }

  return 'Arrived at $arrival$late.';
}

String formatTimeOfDay(DateTime utcTime) {
  final local = utcTime.toLocal();
  final hour24 = local.hour;
  final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  final period = hour24 < 12 ? 'AM' : 'PM';
  return '$hour12:$minute $period';
}

String formatAttendanceDate(DateTime date) => formatCalendarDate(date);
