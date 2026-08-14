import 'package:flutter_test/flutter_test.dart';
import 'package:tinytunes/core/updates/app_semver.dart';

void main() {
  test('normalize strips v prefix and build/prerelease suffixes', () {
    expect(AppSemver.normalize('v1.2.0'), '1.2.0');
    expect(AppSemver.normalize('1.2.0+12'), '1.2.0');
    expect(AppSemver.normalize('1.3.0-rc.1'), '1.3.0');
    expect(AppSemver.normalize('not-a-version'), isNull);
  });

  test('isNewer uses numeric semver not string order', () {
    expect(AppSemver.isNewer('1.10.0', '1.2.0'), isTrue);
    expect(AppSemver.isNewer('v1.2.0', '1.2.0'), isFalse);
    expect(AppSemver.isNewer('1.2.0', '1.2.1'), isFalse);
    expect(AppSemver.isNewer('2.0.0', '1.9.9'), isTrue);
    expect(AppSemver.isNewer('garbage', '1.0.0'), isFalse);
  });
}
