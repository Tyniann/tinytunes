import 'package:drift/drift.dart';

/// Indexed local library folder retained via opaque locator.
///
/// Purpose: Persist SAF (or later platform) roots separately from the queue.
class LibraryRoots extends Table {
  /// Auto-increment primary key.
  IntColumn get id => integer().autoIncrement()();

  /// Opaque root [MediaLocator] string (tree URI on Android); unique.
  TextColumn get locator => text().unique()();

  /// Best-effort folder label (decoded URI segment).
  TextColumn get displayName => text()();

  /// Catalog source kind; Phase 2 always writes `local`.
  TextColumn get sourceKind => text().withDefault(const Constant('local'))();

  /// Cloud provider token (`gdrive` / `onedrive`); null for local roots.
  TextColumn get cloudProvider => text().nullable()();

  /// Stable provider account id owning this root; null until first bind.
  TextColumn get cloudAccountKey => text().nullable()();

  /// When the root was first added.
  DateTimeColumn get addedAt => dateTime()();
}

/// Catalog track indexed under a [LibraryRoots] row.
///
/// Purpose: Durable library identity separate from queue membership/order.
class Tracks extends Table {
  /// Auto-increment primary key.
  IntColumn get id => integer().autoIncrement()();

  /// Owning library root; cascade-deletes with the root.
  IntColumn get rootId => integer().references(
        LibraryRoots,
        #id,
        onDelete: KeyAction.cascade,
      )();

  /// Stable item id within the root (`MediaLocator.value` in Phase 2).
  TextColumn get sourceItemId => text()();

  /// Opaque item locator (same as [sourceItemId] in Phase 2).
  TextColumn get locator => text()();

  /// File display name from the platform listing.
  TextColumn get displayName => text()();

  /// Reserved; always null in Phase 2 (SAF listing has no size).
  IntColumn get sizeBytes => integer().nullable()();

  /// Reserved; always null in Phase 2 (SAF listing has no mtime).
  DateTimeColumn get modifiedAt => dateTime().nullable()();

  /// Optional tag title.
  TextColumn get title => text().nullable()();

  /// Optional tag artist.
  TextColumn get artist => text().nullable()();

  /// Optional tag album.
  TextColumn get album => text().nullable()();

  /// Absolute path to capped on-device cover JPEG (`artwork/<trackId>.jpg`).
  TextColumn get artworkCacheRef => text().nullable()();

  /// Catalog source kind; Phase 2 always writes `local`.
  TextColumn get sourceKind => text().withDefault(const Constant('local'))();

  /// Display name of the folder this file sits in (root or nested).
  ///
  /// Purpose: Sticky queue section headers show CD / chapter folders without
  /// parsing opaque locators. Null on rows ingested before schema v4 until
  /// the next Add / Re-scan.
  TextColumn get parentFolderName => text().nullable()();

  @override
  List<Set<Column<Object>>>? get uniqueKeys => [
        {rootId, sourceItemId},
      ];
}

/// Ordered Winamp-style queue row linking to a catalog [Tracks] id.
///
/// Purpose: Own playback order without mutating catalog tracks.
class QueueEntries extends Table {
  /// Auto-increment primary key.
  IntColumn get id => integer().autoIncrement()();

  /// Catalog track; unique so a track appears at most once in the queue.
  IntColumn get trackId => integer().unique().references(
        Tracks,
        #id,
        onDelete: KeyAction.cascade,
      )();

  /// Canonical queue order (append at max+1).
  IntColumn get sortIndex => integer()();
}

/// Singleton playback resume/mode row for Phase 3–4.
///
/// Purpose: Reserve schema so playback can persist without a migration.
/// Usage Context: Seeded with `id = 1`; unused for UX in Phase 2.
class PlaybackState extends Table {
  /// Singleton primary key; always `1`.
  IntColumn get id => integer()();

  /// Current queue entry; cleared when that entry is deleted.
  IntColumn get currentQueueEntryId => integer().nullable().references(
        QueueEntries,
        #id,
        onDelete: KeyAction.setNull,
      )();

  /// Resume position in milliseconds.
  IntColumn get positionMs => integer().withDefault(const Constant(0))();

  /// Whether shuffle is on (`true`) or off (`false`).
  ///
  /// Purpose: Persist the transport toggle across process death; permutation /
  /// history stay in-memory only.
  BoolColumn get shuffleEnabled =>
      boolean().withDefault(const Constant(false))();

  /// Repeat cycle value: `off` / `one` / `all`.
  ///
  /// Purpose: Persist the transport toggle; unknown stored values fall back to
  /// `off` when read by the player layer.
  TextColumn get repeatMode => text().withDefault(const Constant('off'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Local on-disk cache row for a cloud catalog [Tracks] id.
///
/// Purpose: Track downloaded Drive files for playback, LRU eviction, and
/// Forget / Clear / queue-remove cleanup without mutating remote content.
class CloudCacheEntries extends Table {
  /// Catalog track this cache file belongs to.
  IntColumn get trackId => integer().references(
        Tracks,
        #id,
        onDelete: KeyAction.cascade,
      )();

  /// Remote `gdrive:` [MediaLocator] string for the cached item.
  TextColumn get remoteLocator => text().unique()();

  /// Absolute local filesystem path of the cached file.
  TextColumn get localPath => text()();

  /// Cached file size in bytes.
  IntColumn get sizeBytes => integer()();

  /// Last play / download access time (UTC) for LRU eviction.
  DateTimeColumn get lastAccessedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {trackId};
}
