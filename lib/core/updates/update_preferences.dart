import 'package:shared_preferences/shared_preferences.dart';
import 'package:tinytunes/core/updates/app_semver.dart';

/// Prefs for update-check interval and dismissed release tags.
///
/// Purpose: Avoid nagging every launch and skip GitHub when the 24h window
/// has not elapsed. Usage Context: [UpdateCheckController] after prefs inject.
class UpdatePreferences {
  /// Creates prefs helpers backed by [prefs].
  const UpdatePreferences(this.prefs);

  /// Milliseconds since epoch of the last successful GitHub fetch.
  static const String lastCheckedAtKey = 'updates.lastCheckedAtMs';

  /// Normalized core version the user dismissed (`1.3.0`, not `v1.3.0`).
  static const String dismissedVersionKey = 'updates.dismissedVersion';

  /// Injected [SharedPreferences] instance (sync after bootstrap).
  final SharedPreferences prefs;

  /// Last successful check time, or `null` if never checked.
  DateTime? readLastCheckedAt() {
    final ms = prefs.getInt(lastCheckedAtKey);
    if (ms == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
  }

  /// Records a successful GitHub fetch at [at] (stored as UTC millis).
  Future<void> writeLastCheckedAt(DateTime at) {
    return prefs.setInt(lastCheckedAtKey, at.toUtc().millisecondsSinceEpoch);
  }

  /// Normalized dismissed tag, or `null`.
  String? readDismissedVersion() => prefs.getString(dismissedVersionKey);

  /// Persists a normalized form of [tag] so `v1.3.0` and `1.3.0` match.
  Future<void> writeDismissedTag(String tag) async {
    final normalized = AppSemver.normalize(tag);
    if (normalized == null) return;
    await prefs.setString(dismissedVersionKey, normalized);
  }
}
