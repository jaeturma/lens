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

/// A student's own record — exactly the `student` sync resource's payload
/// shape (`docs/api/SYNC.md`), one table per independent server resource
/// type (WP-07-08), not flattened with the guardian's link to them (see
/// [GuardianStudentLinks]) — a `student`-type change carries none of the
/// link's own fields, so a table requiring them couldn't apply one alone.
///
/// [serverId] is nullable: bootstrap never exposes a student's numeric
/// database id, only `uuid` — it only appears later, as `resource_id` on a
/// `student`-type change-feed entry. Cross-referencing
/// `attendance_daily_summary`/`guardian_student_link` payloads (which key
/// by that same numeric id, not `uuid`) needs it, so it is carried here
/// once known rather than invented at bootstrap time.
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

  @override
  Set<Column> get primaryKey => {uuid};
}

/// The guardian's own link to a student — the `guardian_student_link` sync
/// resource (`docs/api/SYNC.md`), kept as its own table rather than
/// flattened into [Students] (see there for why).
///
/// Keyed by [studentUuid] (a hard FK — unlike [AttendanceRecords], a link
/// is only ever written once its student row already exists, both from
/// bootstrap, which supplies both together, and from incremental sync,
/// which resolves `student_id` to a local `uuid` before writing, per
/// `SyncChangeApplier`), not by the link's own `uuid`: bootstrap's
/// `LinkedStudentResource` gives no link-level uuid or numeric id at all,
/// only the student's own `uuid` plus the relationship fields flattened
/// onto it (WP-07-09) — a table that required either as a key couldn't
/// have a row written for it at bootstrap time. [uuid] and
/// [studentServerId] are nullable for the same reason, filled in once an
/// actual `guardian_student_link`-type change-feed entry supplies them.
class GuardianStudentLinks extends Table {
  TextColumn get studentUuid => text().references(Students, #uuid)();
  TextColumn get uuid => text().nullable().unique()();
  IntColumn get studentServerId => integer().nullable().unique()();
  TextColumn get relationshipType => text()();
  BoolColumn get isPrimaryContact => boolean()();
  TextColumn get status => text()();
  BoolColumn get notificationsEnabled => boolean()();

  @override
  Set<Column> get primaryKey => {studentUuid};
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
  // The server's own sync_changes-ordered id (`entry.resourceId`) — the
  // only signal available for "newest first" ordering, since the payload
  // carries no created-at timestamp of its own (`GuardianNotificationObserver`
  // never emits one). Nullable for the same reason as `Students.serverId`,
  // even though every row here in practice always has it set by
  // `SyncChangeApplier` (notifications never arrive via bootstrap).
  IntColumn get serverId => integer().nullable()();
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
