import 'package:tinytunes/core/cloud/cloud_provider_id.dart';
import 'package:tinytunes/core/database/app_database.dart';
import 'package:tinytunes/core/database/catalog_dao.dart';
import 'package:tinytunes/core/library/artwork_cache_store.dart';
import 'package:tinytunes/core/cloud/cloud_cache_store.dart';

/// Shared cloud root ownership helpers for session controllers.
///
/// Purpose: Decide account-change conflicts and cascade-forget provider roots
/// without duplicating Google/OneDrive session logic.
/// Usage Context: [GoogleDriveSessionController] / [OneDriveSessionController].
abstract final class CloudAccountOwnership {
  /// Prefs key for the last successfully accepted display email per provider.
  static String displayEmailPrefsKey(CloudProviderId provider) =>
      'cloud_account_display_${provider.token}';

  /// Whether [accountKey] conflicts with existing owned roots for [provider].
  ///
  /// Unbound (null-key) roots alone do not conflict — they bind to the first
  /// successful account. A different non-null key does conflict.
  static Future<bool> hasConflictingOwnedRoots({
    required AppDatabase db,
    required CloudProviderId provider,
    required String accountKey,
  }) async {
    final keys = await db.distinctCloudAccountKeys(provider.token);
    if (keys.isEmpty) return false;
    return keys.any((k) => k != accountKey);
  }

  /// Binds unbound roots for [provider] to [accountKey] when safe.
  static Future<void> bindUnboundIfNoForeignOwners({
    required AppDatabase db,
    required CloudProviderId provider,
    required String accountKey,
  }) async {
    final conflict = await hasConflictingOwnedRoots(
      db: db,
      provider: provider,
      accountKey: accountKey,
    );
    if (conflict) return;
    await db.bindUnboundCloudRoots(
      providerToken: provider.token,
      accountKey: accountKey,
    );
  }

  /// Forgets every cloud root for [provider] not owned by [keepAccountKey].
  ///
  /// Includes unbound roots and foreign account keys. Uses the normal
  /// artwork → cache → cascade path.
  static Future<void> forgetRootsNotOwnedBy({
    required AppDatabase db,
    required CloudCacheStore cache,
    required ArtworkCacheStore artwork,
    required CloudProviderId provider,
    required String keepAccountKey,
  }) async {
    final roots = await db.cloudRootsForProvider(provider.token);
    for (final root in roots) {
      final key = root.cloudAccountKey;
      if (key == keepAccountKey) continue;
      await artwork.deleteForRoot(root.id);
      await cache.deleteForRoot(root.id);
      await db.deleteRootCascade(root.id);
    }
  }
}
