// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daos.dart';

// ignore_for_file: type=lint
mixin _$AppSettingsDaoMixin on DatabaseAccessor<AppDatabase> {
  $AppSettingsTable get appSettings => attachedDatabase.appSettings;
  AppSettingsDaoManager get managers => AppSettingsDaoManager(this);
}

class AppSettingsDaoManager {
  final _$AppSettingsDaoMixin _db;
  AppSettingsDaoManager(this._db);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db.attachedDatabase, _db.appSettings);
}

mixin _$SchoolProfileDaoMixin on DatabaseAccessor<AppDatabase> {
  $SchoolProfileTable get schoolProfile => attachedDatabase.schoolProfile;
  SchoolProfileDaoManager get managers => SchoolProfileDaoManager(this);
}

class SchoolProfileDaoManager {
  final _$SchoolProfileDaoMixin _db;
  SchoolProfileDaoManager(this._db);
  $$SchoolProfileTableTableManager get schoolProfile =>
      $$SchoolProfileTableTableManager(_db.attachedDatabase, _db.schoolProfile);
}

mixin _$GuardianProfileDaoMixin on DatabaseAccessor<AppDatabase> {
  $GuardianProfileTable get guardianProfile => attachedDatabase.guardianProfile;
  GuardianProfileDaoManager get managers => GuardianProfileDaoManager(this);
}

class GuardianProfileDaoManager {
  final _$GuardianProfileDaoMixin _db;
  GuardianProfileDaoManager(this._db);
  $$GuardianProfileTableTableManager get guardianProfile =>
      $$GuardianProfileTableTableManager(
        _db.attachedDatabase,
        _db.guardianProfile,
      );
}

mixin _$StudentsDaoMixin on DatabaseAccessor<AppDatabase> {
  $StudentsTable get students => attachedDatabase.students;
  StudentsDaoManager get managers => StudentsDaoManager(this);
}

class StudentsDaoManager {
  final _$StudentsDaoMixin _db;
  StudentsDaoManager(this._db);
  $$StudentsTableTableManager get students =>
      $$StudentsTableTableManager(_db.attachedDatabase, _db.students);
}

mixin _$AttendanceRecordsDaoMixin on DatabaseAccessor<AppDatabase> {
  $StudentsTable get students => attachedDatabase.students;
  $AttendanceRecordsTable get attendanceRecords =>
      attachedDatabase.attendanceRecords;
  AttendanceRecordsDaoManager get managers => AttendanceRecordsDaoManager(this);
}

class AttendanceRecordsDaoManager {
  final _$AttendanceRecordsDaoMixin _db;
  AttendanceRecordsDaoManager(this._db);
  $$StudentsTableTableManager get students =>
      $$StudentsTableTableManager(_db.attachedDatabase, _db.students);
  $$AttendanceRecordsTableTableManager get attendanceRecords =>
      $$AttendanceRecordsTableTableManager(
        _db.attachedDatabase,
        _db.attendanceRecords,
      );
}

mixin _$AnnouncementsDaoMixin on DatabaseAccessor<AppDatabase> {
  $AnnouncementsTable get announcements => attachedDatabase.announcements;
  AnnouncementsDaoManager get managers => AnnouncementsDaoManager(this);
}

class AnnouncementsDaoManager {
  final _$AnnouncementsDaoMixin _db;
  AnnouncementsDaoManager(this._db);
  $$AnnouncementsTableTableManager get announcements =>
      $$AnnouncementsTableTableManager(_db.attachedDatabase, _db.announcements);
}

mixin _$NotificationsDaoMixin on DatabaseAccessor<AppDatabase> {
  $NotificationsTable get notifications => attachedDatabase.notifications;
  NotificationsDaoManager get managers => NotificationsDaoManager(this);
}

class NotificationsDaoManager {
  final _$NotificationsDaoMixin _db;
  NotificationsDaoManager(this._db);
  $$NotificationsTableTableManager get notifications =>
      $$NotificationsTableTableManager(_db.attachedDatabase, _db.notifications);
}

mixin _$SyncStateDaoMixin on DatabaseAccessor<AppDatabase> {
  $SyncStateTable get syncState => attachedDatabase.syncState;
  SyncStateDaoManager get managers => SyncStateDaoManager(this);
}

class SyncStateDaoManager {
  final _$SyncStateDaoMixin _db;
  SyncStateDaoManager(this._db);
  $$SyncStateTableTableManager get syncState =>
      $$SyncStateTableTableManager(_db.attachedDatabase, _db.syncState);
}
