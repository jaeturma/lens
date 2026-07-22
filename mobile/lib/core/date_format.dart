const _monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// Shared by attendance history (WP-07-10) and announcements (WP-07-11).
/// `date` is expected to already be a UTC-normalized calendar date (as
/// `AttendanceRecords.date`/`Announcements.publishedAt` are — see
/// `tables.dart`) — no `.toLocal()` here, that would risk shifting a pure
/// calendar date onto the wrong day.
String formatCalendarDate(DateTime date) {
  return '${_monthNames[date.month - 1]} ${date.day}, ${date.year}';
}
