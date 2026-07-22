import '../data/resolved_school.dart';

sealed class SchoolIdSetupState {
  const SchoolIdSetupState();
}

/// Waiting for a School ID to be entered and resolved. [errorMessage] is
/// set after a resolve attempt failed — a safe, server-provided message
/// (see `SchoolResolverApi.resolve`), never raw exception detail.
class SchoolIdSetupIdle extends SchoolIdSetupState {
  const SchoolIdSetupIdle({this.errorMessage});

  final String? errorMessage;
}

class SchoolIdSetupResolving extends SchoolIdSetupState {
  const SchoolIdSetupResolving();
}

/// A school resolved successfully and is awaiting the guardian's explicit
/// confirmation before the binding is persisted.
class SchoolIdSetupResolved extends SchoolIdSetupState {
  const SchoolIdSetupResolved(this.school);

  final ResolvedSchool school;
}

class SchoolIdSetupConfirming extends SchoolIdSetupState {
  const SchoolIdSetupConfirming(this.school);

  final ResolvedSchool school;
}
