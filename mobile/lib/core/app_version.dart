/// Compares dotted numeric version strings (e.g. "0.1.0" vs "0.2.0"), the
/// format `docs/api/SCHOOL-RESOLVER.md`'s `minimum_app_version` uses.
/// Missing trailing components compare as zero ("1.2" == "1.2.0").
int compareAppVersions(String a, String b) {
  final partsA = a.split('.').map(int.parse).toList();
  final partsB = b.split('.').map(int.parse).toList();
  final length = partsA.length > partsB.length ? partsA.length : partsB.length;

  for (var i = 0; i < length; i++) {
    final valueA = i < partsA.length ? partsA[i] : 0;
    final valueB = i < partsB.length ? partsB[i] : 0;
    final comparison = valueA.compareTo(valueB);
    if (comparison != 0) {
      return comparison;
    }
  }

  return 0;
}

bool isBelowMinimumAppVersion(String current, String minimum) {
  return compareAppVersions(current, minimum) < 0;
}
