import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tinytunes/core/cloud/android/android_free_space_source.dart';
import 'package:tinytunes/core/cloud/cloud_cache_budget.dart';
import 'package:tinytunes/core/cloud/cloud_cache_budget_preferences.dart';
import 'package:tinytunes/core/cloud/cloud_cache_store.dart';
import 'package:tinytunes/core/cloud/cloud_library_source.dart';
import 'package:tinytunes/core/cloud/drive_remote.dart';
import 'package:tinytunes/core/cloud/free_space_source.dart';
import 'package:tinytunes/core/cloud/google_api_drive_remote.dart';
import 'package:tinytunes/core/cloud/google_drive_auth.dart';
import 'package:tinytunes/core/cloud/google_drive_cloud_library_source.dart';
import 'package:tinytunes/core/cloud/google_drive_probe.dart';
import 'package:tinytunes/core/database/catalog_dao.dart';
import 'package:tinytunes/core/database/database_providers.dart';
import 'package:tinytunes/core/library/artwork_providers.dart';
import 'package:tinytunes/core/theme/theme_providers.dart';

part 'cloud_providers.g.dart';

/// Session state for Google Drive sign-in (Settings).
///
/// Purpose: Hold the signed-in account without coupling widgets to
/// `google_sign_in` types.
@immutable
class GoogleDriveSessionState {
  /// Creates a session snapshot.
  const GoogleDriveSessionState({
    this.account,
    this.rootEntries = const [],
    this.lastError,
    this.busy = false,
  });

  /// Signed-out idle state.
  static const signedOut = GoogleDriveSessionState();

  /// Current account, or `null` when signed out.
  final GoogleDriveAccount? account;

  /// Last successful My Drive root listing (debug / legacy spike).
  final List<DriveProbeEntry> rootEntries;

  /// Last user-visible error message from sign-in / list / sign-out.
  final String? lastError;

  /// Whether an auth or probe call is in flight.
  final bool busy;

  /// Whether a Google account is signed in.
  bool get isSignedIn => account != null;

  /// Copies this state with optional field overrides.
  GoogleDriveSessionState copyWith({
    GoogleDriveAccount? account,
    bool clearAccount = false,
    List<DriveProbeEntry>? rootEntries,
    String? lastError,
    bool clearError = false,
    bool? busy,
  }) {
    return GoogleDriveSessionState(
      account: clearAccount ? null : (account ?? this.account),
      rootEntries: rootEntries ?? this.rootEntries,
      lastError: clearError ? null : (lastError ?? this.lastError),
      busy: busy ?? this.busy,
    );
  }
}

/// Production [GoogleDriveAuth]. Tests override [googleDriveAuthProvider].
@Riverpod(keepAlive: true)
GoogleDriveAuth googleDriveAuth(Ref ref) {
  return GoogleSignInDriveAuth();
}

/// Production [DriveRemote]. Tests override with a fake.
@Riverpod(keepAlive: true)
DriveRemote driveRemote(Ref ref) {
  return GoogleApiDriveRemote(ref.watch(googleDriveAuthProvider));
}

/// Free-space checks for cloud downloads (Android StatFs; unlimited elsewhere).
@Riverpod(keepAlive: true)
FreeSpaceSource freeSpaceSource(Ref ref) {
  if (defaultTargetPlatform == TargetPlatform.android) {
    return AndroidFreeSpaceSource();
  }
  return const UnlimitedFreeSpaceSource();
}

/// Root directory for Drive cache files under application support.
@Riverpod(keepAlive: true)
Future<Directory> cloudCacheDirectory(Ref ref) async {
  final support = await getApplicationSupportDirectory();
  final dir = Directory(p.join(support.path, 'cloud_cache'));
  await dir.create(recursive: true);
  return dir;
}

/// Production Google Drive [CloudLibrarySource] once the cache directory exists.
@Riverpod(keepAlive: true)
Future<CloudLibrarySource> cloudLibrarySource(Ref ref) async {
  final dir = await ref.watch(cloudCacheDirectoryProvider.future);
  return GoogleDriveCloudLibrarySource(
    remote: ref.watch(driveRemoteProvider),
    cacheRootDirectory: dir,
    freeSpace: ref.watch(freeSpaceSourceProvider),
  );
}

/// [CloudCacheStore] bound to the app database (deletes artwork with audio).
@Riverpod(keepAlive: true)
CloudCacheStore cloudCacheStore(Ref ref) {
  return CloudCacheStore(
    db: ref.watch(appDatabaseProvider),
    artwork: ref.watch(artworkCacheStoreProvider),
  );
}

/// Prefs wrapper for the cloud cache budget.
@Riverpod(keepAlive: true)
CloudCacheBudgetPreferences cloudCacheBudgetPreferences(Ref ref) {
  return CloudCacheBudgetPreferences(ref.watch(sharedPreferencesProvider));
}

/// Persisted cloud cache budget with write + eviction on lower limits.
///
/// Purpose: Settings slider and playback download path share one budget value.
/// Usage Context: Settings Cloud cache limit; [PlaybackUriResolver] budget.
@Riverpod(keepAlive: true)
class CloudCacheBudgetController extends _$CloudCacheBudgetController {
  @override
  int build() => ref.watch(cloudCacheBudgetPreferencesProvider).readBytes();

  /// Persists [bytes] (clamped/snapped) and evicts if the store is over budget.
  Future<void> setBudgetBytes(int bytes) async {
    final snapped = CloudCacheBudget.clampAndSnap(bytes);
    await ref.read(cloudCacheBudgetPreferencesProvider).writeBytes(snapped);
    state = snapped;

    final db = ref.read(appDatabaseProvider);
    final store = ref.read(cloudCacheStoreProvider);
    final queued = await db.queuedTrackIds();
    final playback = await db.getPlaybackState();
    final currentEntry = playback.currentQueueEntryId;
    final protect = currentEntry == null
        ? null
        : await db.trackIdForQueueEntry(currentEntry);
    await store.enforceBudget(
      budgetBytes: snapped,
      protectTrackId: protect,
      queuedTrackIds: queued,
    );
  }
}

/// Production [GoogleDriveProbe] for diagnostics / tests.
@Riverpod(keepAlive: true)
GoogleDriveProbe googleDriveProbe(Ref ref) {
  return GoogleDriveProbe(ref.watch(googleDriveAuthProvider));
}

/// Controllers Google Drive sign-in / sign-out for Settings.
///
/// Purpose: Drive Settings buttons through a testable seam; wipe cache on
/// sign-out; restore a lightweight session on first build.
/// Usage Context: Eagerly read from `main` so a prior Google session returns
/// without opening Settings; also used by the Settings Google Drive section.
@Riverpod(keepAlive: true)
class GoogleDriveSessionController extends _$GoogleDriveSessionController {
  @override
  GoogleDriveSessionState build() {
    unawaited(_restoreSession());
    return GoogleDriveSessionState.signedOut;
  }

  Future<void> _restoreSession() async {
    try {
      final account =
          await ref.read(googleDriveAuthProvider).restoreSession();
      if (account == null) return;
      if (state.isSignedIn || state.busy) return;
      state = GoogleDriveSessionState(account: account);
    } on Object catch (error, stack) {
      debugPrint('Google Drive session restore failed: $error\n$stack');
    }
  }

  /// Interactive sign-in.
  Future<void> signIn() async {
    if (state.busy) return;
    state = state.copyWith(busy: true, clearError: true);
    try {
      final account = await ref.read(googleDriveAuthProvider).signIn();
      state = GoogleDriveSessionState(account: account);
    } on Object catch (error, stack) {
      debugPrint('Google Drive sign-in failed: $error\n$stack');
      state = state.copyWith(busy: false, lastError: error.toString());
    }
  }

  /// Signs out, wipes all cloud cache files/rows, and clears session UI.
  Future<void> signOut() async {
    if (state.busy) return;
    state = state.copyWith(busy: true, clearError: true);
    try {
      await ref.read(cloudCacheStoreProvider).clearAll();
      await ref.read(googleDriveAuthProvider).signOut();
      state = GoogleDriveSessionState.signedOut;
    } on Object catch (error, stack) {
      debugPrint('Google Drive sign-out failed: $error\n$stack');
      state = state.copyWith(busy: false, lastError: error.toString());
    }
  }

  /// Deletes all cloud cache files and Drift rows (catalog/queue untouched).
  Future<void> clearCloudCache() async {
    if (state.busy) return;
    state = state.copyWith(busy: true, clearError: true);
    try {
      await ref.read(cloudCacheStoreProvider).clearAll();
      state = state.copyWith(busy: false);
    } on Object catch (error, stack) {
      debugPrint('Clear cloud cache failed: $error\n$stack');
      state = state.copyWith(busy: false, lastError: error.toString());
    }
  }

  /// Lists My Drive root children (requires signed-in account).
  Future<void> listMyDriveRoot() async {
    if (state.busy) return;
    if (!state.isSignedIn) {
      state = state.copyWith(lastError: 'Sign in first');
      return;
    }
    state = state.copyWith(busy: true, clearError: true);
    try {
      final entries =
          await ref.read(googleDriveProbeProvider).listMyDriveRoot();
      state = state.copyWith(rootEntries: entries, busy: false);
    } on Object catch (error, stack) {
      debugPrint('Google Drive list failed: $error\n$stack');
      state = state.copyWith(busy: false, lastError: error.toString());
    }
  }
}
