import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/database/app_database.dart';
import 'package:mobile/features/school_bootstrap/data/bootstrap_api.dart';
import 'package:mobile/features/school_bootstrap/data/bootstrap_repository.dart';
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

class _FakeBootstrapApi extends BootstrapApi {
  _FakeBootstrapApi(this.result) : super(Dio());

  final ResolvedSchool result;

  @override
  Future<ResolvedSchool> fetchSchool() async => result;
}

void main() {
  test(
    'syncSchoolProfile caches the bootstrap response\'s school profile locally',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final repository = BootstrapRepository(
        _FakeBootstrapApi(_resolvedSchool),
        database,
      );

      await repository.syncSchoolProfile();

      final row = await database.select(database.schoolProfile).getSingle();
      expect(row.uuid, 'school-uuid');
      expect(row.publicId, 'SCH-0001');
      expect(row.name, 'Example School');
      expect(row.logoUrl, 'https://example.test/logo.png');
      expect(row.minimumAppVersion, '0.1.0');
    },
  );

  test(
    'a repeated sync updates the cached profile rather than duplicating it',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final repository = BootstrapRepository(
        _FakeBootstrapApi(_resolvedSchool),
        database,
      );

      await repository.syncSchoolProfile();
      await BootstrapRepository(
        _FakeBootstrapApi(
          const ResolvedSchool(
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
        ),
        database,
      ).syncSchoolProfile();

      final rows = await database.select(database.schoolProfile).get();
      expect(rows, hasLength(1));
      expect(rows.single.name, 'Renamed School');
      expect(rows.single.mobileEnabled, isFalse);
      expect(rows.single.maintenanceMode, isTrue);
      expect(rows.single.minimumAppVersion, '0.2.0');
    },
  );
}
