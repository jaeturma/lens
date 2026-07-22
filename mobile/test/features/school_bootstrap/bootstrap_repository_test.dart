import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/database/app_database.dart';
import 'package:mobile/features/school_bootstrap/data/bootstrap_api.dart';
import 'package:mobile/features/school_bootstrap/data/bootstrap_repository.dart';
import 'package:mobile/features/school_bootstrap/data/resolved_guardian.dart';
import 'package:mobile/features/school_setup/data/resolved_school.dart';

const _resolvedSchool = ResolvedSchool(
  schoolId: 'SCH-0001',
  uuid: 'school-uuid',
  name: 'Example School',
  logoUrl: 'https://example.test/logo.png',
  timezone: 'Asia/Manila',
  mobileEnabled: true,
  maintenanceMode: false,
  maintenanceMessage: null,
  notificationsEnabled: true,
  minimumAppVersion: '0.1.0',
);

const _resolvedGuardian = ResolvedGuardian(
  uuid: 'guardian-uuid',
  name: 'Maria Dela Cruz',
  email: 'maria@example.com',
  mobileNumber: '09171234567',
  status: 'active',
  notifyAttendance: true,
  notifyAnnouncements: true,
);

class _FakeBootstrapApi extends BootstrapApi {
  _FakeBootstrapApi(this.result) : super(Dio());

  final BootstrapResult result;

  @override
  Future<BootstrapResult> fetch() async => result;
}

void main() {
  test(
    'sync caches the bootstrap response\'s school profile locally',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final repository = BootstrapRepository(
        _FakeBootstrapApi(
          const BootstrapResult(school: _resolvedSchool, guardian: null),
        ),
        database,
      );

      await repository.sync();

      final row = await database.select(database.schoolProfile).getSingle();
      expect(row.uuid, 'school-uuid');
      expect(row.publicId, 'SCH-0001');
      expect(row.name, 'Example School');
      expect(row.logoUrl, 'https://example.test/logo.png');
      expect(row.minimumAppVersion, '0.1.0');
    },
  );

  test(
    'a repeated sync updates the cached school profile rather than duplicating it',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      await BootstrapRepository(
        _FakeBootstrapApi(
          const BootstrapResult(school: _resolvedSchool, guardian: null),
        ),
        database,
      ).sync();

      await BootstrapRepository(
        _FakeBootstrapApi(
          const BootstrapResult(
            school: ResolvedSchool(
              schoolId: 'SCH-0001',
              uuid: 'school-uuid',
              name: 'Renamed School',
              logoUrl: null,
              timezone: 'Asia/Manila',
              mobileEnabled: false,
              maintenanceMode: true,
              maintenanceMessage: 'Down for scheduled maintenance.',
              notificationsEnabled: true,
              minimumAppVersion: '0.2.0',
            ),
            guardian: null,
          ),
        ),
        database,
      ).sync();

      final rows = await database.select(database.schoolProfile).get();
      expect(rows, hasLength(1));
      expect(rows.single.name, 'Renamed School');
      expect(rows.single.mobileEnabled, isFalse);
      expect(rows.single.maintenanceMode, isTrue);
      expect(rows.single.minimumAppVersion, '0.2.0');
    },
  );

  test('when the response has a guardian, it is cached locally too', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final repository = BootstrapRepository(
      _FakeBootstrapApi(
        const BootstrapResult(
          school: _resolvedSchool,
          guardian: _resolvedGuardian,
        ),
      ),
      database,
    );

    await repository.sync();

    final row = await database.select(database.guardianProfile).getSingle();
    expect(row.uuid, 'guardian-uuid');
    expect(row.name, 'Maria Dela Cruz');
    expect(row.notifyAttendance, isTrue);
  });

  test(
    'when the response has no guardian (no profile yet), nothing is written to guardian_profile',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final repository = BootstrapRepository(
        _FakeBootstrapApi(
          const BootstrapResult(school: _resolvedSchool, guardian: null),
        ),
        database,
      );

      await repository.sync();

      final rows = await database.select(database.guardianProfile).get();
      expect(rows, isEmpty);
    },
  );
}
