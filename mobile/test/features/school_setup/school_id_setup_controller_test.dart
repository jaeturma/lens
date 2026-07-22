import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/database/app_database.dart';
import 'package:mobile/core/database/database_provider.dart';
import 'package:mobile/core/network/api_exception.dart';
import 'package:mobile/features/school_setup/application/school_id_setup_controller.dart';
import 'package:mobile/features/school_setup/application/school_id_setup_state.dart';
import 'package:mobile/features/school_setup/data/resolved_school.dart';
import 'package:mobile/features/school_setup/data/school_resolver_api.dart';

const _resolvedSchool = ResolvedSchool(
  schoolId: 'SCH-0001',
  uuid: 'school-uuid',
  name: 'Example School',
  logoUrl: null,
  timezone: 'Asia/Manila',
  mobileEnabled: true,
  maintenanceMode: false,
  maintenanceMessage: null,
  notificationsEnabled: true,
  minimumAppVersion: '0.1.0',
);

class _FakeSchoolResolverApi extends SchoolResolverApi {
  _FakeSchoolResolverApi({this.result, this.error}) : super(Dio());

  final ResolvedSchool? result;
  final ApiException? error;

  @override
  Future<ResolvedSchool> resolve(String schoolId) async {
    if (error != null) throw error!;
    return result!;
  }
}

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  ProviderContainer buildContainer(SchoolResolverApi api) {
    final container = ProviderContainer(
      overrides: [
        schoolResolverApiProvider.overrideWithValue(api),
        appDatabaseProvider.overrideWithValue(database),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('a successful resolve moves to the Resolved state', () async {
    final container = buildContainer(
      _FakeSchoolResolverApi(result: _resolvedSchool),
    );

    await container
        .read(schoolIdSetupControllerProvider.notifier)
        .resolve('SCH-0001');

    final state = container.read(schoolIdSetupControllerProvider);
    expect(state, isA<SchoolIdSetupResolved>());
    expect((state as SchoolIdSetupResolved).school.name, 'Example School');
  });

  test(
    'a failed resolve returns to Idle carrying the safe error message',
    () async {
      final container = buildContainer(
        _FakeSchoolResolverApi(
          error: const ApiException(
            message: 'School ID not found.',
            statusCode: 404,
          ),
        ),
      );

      await container
          .read(schoolIdSetupControllerProvider.notifier)
          .resolve('unknown');

      final state = container.read(schoolIdSetupControllerProvider);
      expect(state, isA<SchoolIdSetupIdle>());
      expect((state as SchoolIdSetupIdle).errorMessage, 'School ID not found.');
    },
  );

  test('confirming a resolved school persists it to school_profile', () async {
    final container = buildContainer(
      _FakeSchoolResolverApi(result: _resolvedSchool),
    );
    final controller = container.read(schoolIdSetupControllerProvider.notifier);

    await controller.resolve('SCH-0001');
    await controller.confirm();

    final row = await database.select(database.schoolProfile).getSingle();
    expect(row.uuid, 'school-uuid');
    expect(row.publicId, 'SCH-0001');
    expect(row.name, 'Example School');
  });

  test('editAgain returns to Idle without persisting anything', () async {
    final container = buildContainer(
      _FakeSchoolResolverApi(result: _resolvedSchool),
    );
    final controller = container.read(schoolIdSetupControllerProvider.notifier);

    await controller.resolve('SCH-0001');
    controller.editAgain();

    expect(
      container.read(schoolIdSetupControllerProvider),
      isA<SchoolIdSetupIdle>(),
    );
    final rows = await database.select(database.schoolProfile).get();
    expect(rows, isEmpty);
  });
}
