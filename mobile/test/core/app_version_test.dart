import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/app_version.dart';

void main() {
  test('equal versions compare as zero', () {
    expect(compareAppVersions('0.1.0', '0.1.0'), 0);
  });

  test('a lower version compares as negative', () {
    expect(compareAppVersions('0.1.0', '0.2.0'), lessThan(0));
    expect(compareAppVersions('1.9.9', '2.0.0'), lessThan(0));
  });

  test('a higher version compares as positive', () {
    expect(compareAppVersions('0.2.0', '0.1.0'), greaterThan(0));
  });

  test('a missing trailing component compares as zero', () {
    expect(compareAppVersions('1.2', '1.2.0'), 0);
    expect(compareAppVersions('1.2.0', '1.2'), 0);
  });

  test('isBelowMinimumAppVersion is true only when strictly lower', () {
    expect(isBelowMinimumAppVersion('0.1.0', '0.2.0'), isTrue);
    expect(isBelowMinimumAppVersion('0.2.0', '0.2.0'), isFalse);
    expect(isBelowMinimumAppVersion('0.3.0', '0.2.0'), isFalse);
  });
}
