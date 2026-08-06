import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinytunes/core/database/database_providers.dart';
import 'package:tinytunes/core/library/artwork_cache_store.dart';

/// On-device artwork cache (capped JPEGs under application support).
///
/// Purpose: Shared write/delete path for ingest, play-path enrich, and
/// Forget / cloud-cache cleanup. Tests may override with a temp-rooted store.
final artworkCacheStoreProvider = Provider<ArtworkCacheStore>((ref) {
  return ArtworkCacheStore(db: ref.watch(appDatabaseProvider));
});
