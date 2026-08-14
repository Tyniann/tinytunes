/// Semver helpers for GitHub release tags vs [PackageInfo.version].
///
/// Purpose: Compare `1.10.0` and `1.2.0` correctly (string compare cannot) and
/// treat a leading `v` as optional so tags match pubspec versions.
/// Usage Context: [UpdateCheck] prompt decisions; GitHub `tag_name` vs installed
/// version. Build numbers (`+12`) are ignored — tags are the source of truth.
abstract final class AppSemver {
  /// Strips a leading `v`/`V` and any `+build` / `-prerelease` suffix.
  ///
  /// Returns the `major.minor.patch` core, or `null` when [raw] has no numeric
  /// major component.
  static String? normalize(String raw) {
    final parsed = _parse(raw);
    if (parsed == null) return null;
    return '${parsed[0]}.${parsed[1]}.${parsed[2]}';
  }

  /// Whether [latest] is a higher core version than [installed].
  ///
  /// Unparseable values are not newer — never prompt on garbage tags.
  static bool isNewer(String latest, String installed) {
    final a = _parse(latest);
    final b = _parse(installed);
    if (a == null || b == null) return false;
    for (var i = 0; i < 3; i++) {
      if (a[i] != b[i]) return a[i] > b[i];
    }
    return false;
  }

  static List<int>? _parse(String raw) {
    var s = raw.trim();
    if (s.isEmpty) return null;
    if (s.startsWith('v') || s.startsWith('V')) {
      s = s.substring(1);
    }
    final plus = s.indexOf('+');
    if (plus >= 0) s = s.substring(0, plus);
    final dash = s.indexOf('-');
    if (dash >= 0) s = s.substring(0, dash);
    final parts = s.split('.');
    if (parts.isEmpty) return null;
    final major = int.tryParse(parts[0]);
    if (major == null) return null;
    final minor = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    final patch = parts.length > 2 ? int.tryParse(parts[2]) ?? 0 : 0;
    return [major, minor, patch];
  }
}
