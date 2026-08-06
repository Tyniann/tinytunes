import 'package:shared_preferences/shared_preferences.dart';
import 'package:tinytunes/core/cloud/cloud_cache_budget.dart';

/// Prefs access for the cloud cache size budget.
///
/// Purpose: Isolate the prefs key and clamp/snap rules from Riverpod/UI.
/// Usage Context: Settings slider and playback download eviction.
class CloudCacheBudgetPreferences {
  /// Creates prefs helpers backed by [prefs].
  const CloudCacheBudgetPreferences(this.prefs);

  /// Prefs key for budget bytes.
  static const String budgetBytesKey = 'cloud.cache.budgetBytes';

  /// Injected [SharedPreferences] instance (sync after bootstrap).
  final SharedPreferences prefs;

  /// Reads the stored budget; missing/invalid → [CloudCacheBudget.defaultBytes].
  int readBytes() {
    final raw = prefs.getInt(budgetBytesKey);
    if (raw == null) return CloudCacheBudget.defaultBytes;
    return CloudCacheBudget.clampAndSnap(raw);
  }

  /// Persists [bytes] (clamped/snapped) for the next cold start.
  Future<void> writeBytes(int bytes) {
    return prefs.setInt(
      budgetBytesKey,
      CloudCacheBudget.clampAndSnap(bytes),
    );
  }
}
