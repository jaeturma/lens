import 'package:drift/drift.dart';

/// Local device state — not a synchronized resource, so rows here carry no
/// server ID. A generic key/value shape, since the concrete settings this
/// app needs (school binding lock, theme, etc.) belong to the work packages
/// that actually introduce them (WP-07-03/04/14) rather than being invented
/// here.
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text().nullable()();

  @override
  Set<Column> get primaryKey => {key};
}

/// One row: the single school this installation is bound to (see
/// `docs/ARCHITECTURE.md` Binding Rules). Keyed by `uuid` — the
/// client-facing stable identifier every synced resource in
/// `docs/api/SYNC.md` uses, not the server's internal numeric id.
class SchoolProfile extends Table {
  TextColumn get uuid => text()();
  TextColumn get publicId => text()();
  TextColumn get name => text()();
  TextColumn get logoUrl => text().nullable()();
  TextColumn get timezone => text()();
  BoolColumn get mobileEnabled => boolean()();
  BoolColumn get maintenanceMode => boolean()();
  TextColumn get maintenanceMessage => text().nullable()();
  BoolColumn get notificationsEnabled => boolean()();
  TextColumn get minimumAppVersion => text()();

  @override
  Set<Column> get primaryKey => {uuid};
}

/// The signed-in guardian's own profile. Keyed by `uuid`, matching the
/// `guardian` sync resource in `docs/api/SYNC.md`.
class GuardianProfile extends Table {
  TextColumn get uuid => text()();
  TextColumn get name => text()();
  TextColumn get email => text()();
  TextColumn get mobileNumber => text()();
  TextColumn get status => text()();
  BoolColumn get notifyAttendance => boolean()();
  BoolColumn get notifyAnnouncements => boolean()();

  @override
  Set<Column> get primaryKey => {uuid};
}

/// A guardian's linked children, flattened with their own
/// `guardian_student_link` fields — matching the shape
/// `LinkedStudentResource` already sends over bootstrap, since a guardian
/// only ever sees their own link for a given child.
///
/// [serverId] is nullable: bootstrap (`docs/api/SYNC.md`) never exposes a
/// student's numeric database id, only `uuid` — it only appears later, as
/// `resource_id` on a `student`-type change-feed entry. Cross-referencing
/// `attendance_daily_summary` payloads (which key `student_id` by that same
/// numeric id, not `uuid`) needs it, so it is carried here once known
/// rather than invented at bootstrap time.
class Students extends Table {
  TextColumn get uuid => text()();
  IntColumn get serverId => integer().nullable().unique()();
  TextColumn get lrn => text()();
  TextColumn get studentNumber => text()();
  TextColumn get name => text()();
  TextColumn get sex => text()();
  TextColumn get grade => text()();
  TextColumn get section => text()();
  TextColumn get schoolYear => text()();
  TextColumn get status => text()();
  TextColumn get photoUrl => text().nullable()();
  TextColumn get relationshipType => text()();
  BoolColumn get isPrimaryContact => boolean()();

  @override
  Set<Column> get primaryKey => {uuid};
}

/// One row per `(student, date)` — matching `attendance_daily_summary`'s own
/// invariant in `docs/api/SYNC.md` ("created once per (student_id, date)").
///
/// Keyed by a local autoincrement id, not the server's `resource_id`:
/// bootstrap embeds today's attendance directly on each child with no id at
/// all (see `LinkedStudentResource::todayAttendance()`), so `resource_id`
/// is only ever known once a matching change-feed entry has arrived. It is
/// carried here nullable, alongside the `(studentUuid, date)` unique key
/// that is always derivable and is what bootstrap-sourced rows upsert by.
class AttendanceRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get serverId => integer().nullable().unique()();
  TextColumn get studentUuid => text().references(Students, #uuid)();
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get arrival => dateTime().nullable()();
  DateTimeColumn get departure => dateTime().nullable()();
  BoolColumn get isLate => boolean()();
  BoolColumn get isAbsent => boolean()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {studentUuid, date},
  ];
}

/// Every currently published, audience-matching announcement. Keyed by
/// `uuid`, matching the `announcement` sync resource.
class Announcements extends Table {
  TextColumn get uuid => text()();
  TextColumn get title => text()();
  TextColumn get body => text()();
  TextColumn get status => text()();
  DateTimeColumn get publishedAt => dateTime().nullable()();
  DateTimeColumn get expiresAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {uuid};
}

/// The guardian's own notification inbox. Keyed by `uuid`, matching the
/// `guardian_notification` sync resource (WP-06-06). No guardian foreign
/// key: server-side scoping already guarantees every synced entry belongs
/// to the one signed-in guardian this installation holds a session for.
///
/// Named `Notifications` (not the singular-friendly `NotificationRecords`)
/// to keep the SQL table name aligned with `docs/DATABASE.md`; the
/// generated data class is renamed away from the default `Notification` via
/// `@DataClassName` since that name collides with Flutter's own
/// `Notification` widget-tree type.
@DataClassName('NotificationRow')
class Notifications extends Table {
  TextColumn get uuid => text()();
  TextColumn get type => text()();
  TextColumn get title => text()();
  TextColumn get body => text()();
  TextColumn get payload => text().nullable()();
  DateTimeColumn get readAt => dateTime().nullable()();
  TextColumn get deliveryStatus => text()();

  @override
  Set<Column> get primaryKey => {uuid};
}

/// Single-row local sync position — the opaque cursor from
/// `docs/OFFLINE-SYNC.md`'s Cursor Rules, saved only after a full local
/// transaction commits. Not a synchronized resource itself, so it carries
/// no server ID of its own.
class SyncState extends Table {
  IntColumn get id => integer().withDefault(const Constant(0))();
  TextColumn get cursor => text().nullable()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
