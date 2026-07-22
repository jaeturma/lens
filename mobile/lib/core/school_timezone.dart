import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

bool _initialized = false;

/// The current date in [ianaTimezone] (e.g. `"Asia/Manila"`,
/// `school_profile.timezone`), truncated to just year/month/day and
/// normalized as a UTC `DateTime` — matching how `AttendanceRecords.date`
/// is stored (`tables.dart`), so a bootstrap-sourced "today" row keys the
/// same way a later `attendance_daily_summary` sync entry for the same day
/// does (that payload's own `date` field is the school's server-side
/// timezone-correct date, per `docs/api/SYNC.md`).
///
/// Falls back to the device's own local date if [ianaTimezone] isn't a
/// recognized IANA identifier — a malformed value shouldn't crash the
/// whole home screen over a display nicety.
DateTime todayIn(String ianaTimezone) {
  if (!_initialized) {
    tz_data.initializeTimeZones();
    _initialized = true;
  }

  try {
    final location = tz.getLocation(ianaTimezone);
    final now = tz.TZDateTime.now(location);
    return DateTime.utc(now.year, now.month, now.day);
  } on tz.LocationNotFoundException {
    final now = DateTime.now();
    return DateTime.utc(now.year, now.month, now.day);
  }
}
