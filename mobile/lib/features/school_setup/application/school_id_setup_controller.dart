import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/network/api_exception.dart';
import '../data/resolved_school.dart';
import '../data/school_resolver_api.dart';
import 'school_id_setup_state.dart';

final schoolIdSetupControllerProvider =
    NotifierProvider<SchoolIdSetupController, SchoolIdSetupState>(
      SchoolIdSetupController.new,
    );

class SchoolIdSetupController extends Notifier<SchoolIdSetupState> {
  @override
  SchoolIdSetupState build() => const SchoolIdSetupIdle();

  Future<void> resolve(String schoolId) async {
    state = const SchoolIdSetupResolving();

    try {
      final school = await ref
          .read(schoolResolverApiProvider)
          .resolve(schoolId);
      state = SchoolIdSetupResolved(school);
    } on ApiException catch (exception) {
      state = SchoolIdSetupIdle(errorMessage: exception.message);
    }
  }

  /// Returns to the entry form — the guardian decided the resolved school
  /// wasn't the right one after all.
  void editAgain() {
    state = const SchoolIdSetupIdle();
  }

  Future<void> confirm() async {
    final current = state;
    if (current is! SchoolIdSetupResolved) return;

    final school = current.school;
    state = SchoolIdSetupConfirming(school);

    await ref
        .read(appDatabaseProvider)
        .schoolProfileDao
        .upsert(_toCompanion(school));

    // No further state transition: the school-binding gate reactively
    // watches school_profile and swaps away from this screen once the row
    // it just wrote lands, per docs/ARCHITECTURE.md's Runtime Data Flow.
  }

  SchoolProfileCompanion _toCompanion(ResolvedSchool school) {
    return SchoolProfileCompanion.insert(
      uuid: school.uuid,
      publicId: school.schoolId,
      name: school.name,
      logoUrl: Value(school.logoUrl),
      timezone: school.timezone,
      mobileEnabled: school.mobileEnabled,
      maintenanceMode: school.maintenanceMode,
      maintenanceMessage: Value(school.maintenanceMessage),
      notificationsEnabled: school.notificationsEnabled,
      minimumAppVersion: school.minimumAppVersion,
    );
  }
}
