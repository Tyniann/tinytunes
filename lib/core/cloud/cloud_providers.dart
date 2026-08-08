import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tinytunes/core/cloud/android/android_free_space_source.dart';
import 'package:tinytunes/core/cloud/cloud_account_ownership.dart';
import 'package:tinytunes/core/cloud/cloud_cache_budget.dart';
import 'package:tinytunes/core/cloud/cloud_cache_budget_preferences.dart';
import 'package:tinytunes/core/cloud/cloud_cache_store.dart';
import 'package:tinytunes/core/cloud/cloud_library_source.dart';
import 'package:tinytunes/core/cloud/cloud_provider_id.dart';
import 'package:tinytunes/core/cloud/delegating_cloud_library_source.dart';
import 'package:tinytunes/core/cloud/free_space_source.dart';
import 'package:tinytunes/core/cloud/google_drive/google_api_drive_remote.dart';
import 'package:tinytunes/core/cloud/google_drive/google_drive_auth.dart';
import 'package:tinytunes/core/cloud/google_drive/google_drive_cloud_library_source.dart';
import 'package:tinytunes/core/cloud/google_drive/google_drive_remote.dart';
import 'package:tinytunes/core/cloud/one_drive/one_drive_auth.dart';
import 'package:tinytunes/core/cloud/one_drive/one_drive_cloud_library_source.dart';
import 'package:tinytunes/core/cloud/one_drive/one_drive_error_redaction.dart';
import 'package:tinytunes/core/cloud/one_drive/one_drive_graph_remote.dart';
import 'package:tinytunes/core/cloud/one_drive/one_drive_remote.dart';
import 'package:tinytunes/core/database/catalog_dao.dart';
import 'package:tinytunes/core/database/database_providers.dart';
import 'package:tinytunes/core/library/artwork_providers.dart';
import 'package:tinytunes/core/theme/theme_providers.dart';

part 'cloud_providers.g.dart';

/// Session state for Google Drive sign-in (Settings).
///
/// Purpose: Hold the signed-in account and optional pending account-change
/// confirmation without coupling widgets to `google_sign_in` types.
@immutable
class GoogleDriveSessionState {
  /// Creates a session snapshot.
  const GoogleDriveSessionState({
    this.account,
    this.pendingAccount,
    this.previousAccountEmail,
    this.lastError,
    this.busy = false,
  });

  /// Signed-out idle state.
  static const signedOut = GoogleDriveSessionState();

  /// Accepted account, or `null` when signed out / pending replacement.
  final GoogleDriveAccount? account;

  /// Newly authenticated account waiting for replacement confirmation.
  final GoogleDriveAccount? pendingAccount;

  /// Display email of the previous owning account (prefs / last known).
  final String? previousAccountEmail;

  /// Last user-visible error message from sign-in / list / sign-out.
  final String? lastError;

  /// Whether an auth or session call is in flight.
  final bool busy;

  /// Whether a Google account is accepted for provider operations.
  bool get isSignedIn => account != null && pendingAccount == null;

  /// Whether the user must confirm replacing another account’s roots.
  bool get accountChangeRequired => pendingAccount != null;

  /// Whether provider list/ingest operations may proceed.
  bool get canUseProvider => isSignedIn && !busy;

  /// Copies this state with optional field overrides.
  GoogleDriveSessionState copyWith({
    GoogleDriveAccount? account,
    bool clearAccount = false,
    GoogleDriveAccount? pendingAccount,
    bool clearPending = false,
    String? previousAccountEmail,
    bool clearPreviousEmail = false,
    String? lastError,
    bool clearError = false,
    bool? busy,
  }) {
    return GoogleDriveSessionState(
      account: clearAccount ? null : (account ?? this.account),
      pendingAccount:
          clearPending ? null : (pendingAccount ?? this.pendingAccount),
      previousAccountEmail: clearPreviousEmail
          ? null
          : (previousAccountEmail ?? this.previousAccountEmail),
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

/// Production Google Drive [CloudLibrarySource] (provider subdirectory layout).
@Riverpod(keepAlive: true)
Future<CloudLibrarySource> googleDriveCloudLibrarySource(Ref ref) async {
  final dir = await ref.watch(cloudCacheDirectoryProvider.future);
  return GoogleDriveCloudLibrarySource(
    remote: ref.watch(driveRemoteProvider),
    cacheRootDirectory: dir,
    freeSpace: ref.watch(freeSpaceSourceProvider),
  );
}

/// Production OneDrive [OneDriveRemote] (Graph HTTP).
@Riverpod(keepAlive: true)
OneDriveRemote oneDriveRemote(Ref ref) {
  final remote = OneDriveGraphRemote(ref.watch(oneDriveAuthProvider));
  ref.onDispose(remote.close);
  return remote;
}

/// Production OneDrive [CloudLibrarySource] (provider subdirectory layout).
@Riverpod(keepAlive: true)
Future<CloudLibrarySource> oneDriveCloudLibrarySource(Ref ref) async {
  final dir = await ref.watch(cloudCacheDirectoryProvider.future);
  return OneDriveCloudLibrarySource(
    remote: ref.watch(oneDriveRemoteProvider),
    cacheRootDirectory: dir,
    freeSpace: ref.watch(freeSpaceSourceProvider),
  );
}

/// Delegating [CloudLibrarySource] routing by locator prefix.
@Riverpod(keepAlive: true)
Future<CloudLibrarySource> cloudLibrarySource(Ref ref) async {
  final google = await ref.watch(googleDriveCloudLibrarySourceProvider.future);
  final oneDrive = await ref.watch(oneDriveCloudLibrarySourceProvider.future);
  return DelegatingCloudLibrarySource({
    CloudProviderId.googleDrive: google,
    CloudProviderId.oneDrive: oneDrive,
  });
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

/// Controllers Google Drive sign-in / sign-out for Settings.
///
/// Purpose: Drive Settings through a testable seam; bind/replace root ownership;
/// wipe **Google** cache on normal sign-out; restore on first build.
/// Usage Context: Eagerly read from `main`; Settings Google Drive section.
@Riverpod(keepAlive: true)
class GoogleDriveSessionController extends _$GoogleDriveSessionController {
  static final _provider = CloudProviderId.googleDrive;

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
      if (state.isSignedIn || state.accountChangeRequired || state.busy) {
        return;
      }
      await _acceptOrPending(account);
    } on Object catch (error, stack) {
      debugPrint('Google Drive session restore failed: $error\n$stack');
    }
  }

  /// Interactive sign-in (may enter [GoogleDriveSessionState.accountChangeRequired]).
  Future<void> signIn() async {
    if (state.busy || state.accountChangeRequired) return;
    state = state.copyWith(busy: true, clearError: true);
    try {
      final account = await ref.read(googleDriveAuthProvider).signIn();
      await _acceptOrPending(account);
    } on Object catch (error, stack) {
      debugPrint('Google Drive sign-in failed: $error\n$stack');
      state = state.copyWith(busy: false, lastError: error.toString());
    }
  }

  Future<void> _acceptOrPending(GoogleDriveAccount account) async {
    final db = ref.read(appDatabaseProvider);
    final prefs = ref.read(sharedPreferencesProvider);
    final previousEmail = prefs.getString(
      CloudAccountOwnership.displayEmailPrefsKey(_provider),
    );
    final conflict = await CloudAccountOwnership.hasConflictingOwnedRoots(
      db: db,
      provider: _provider,
      accountKey: account.stableAccountKey,
    );
    if (conflict) {
      state = GoogleDriveSessionState(
        pendingAccount: account,
        previousAccountEmail: previousEmail,
        busy: false,
      );
      return;
    }
    await CloudAccountOwnership.bindUnboundIfNoForeignOwners(
      db: db,
      provider: _provider,
      accountKey: account.stableAccountKey,
    );
    await prefs.setString(
      CloudAccountOwnership.displayEmailPrefsKey(_provider),
      account.email,
    );
    state = GoogleDriveSessionState(account: account);
  }

  /// Confirms replacement: forgets foreign/unbound Google roots, accepts pending.
  Future<void> confirmAccountReplacement() async {
    final pending = state.pendingAccount;
    if (pending == null || state.busy) return;
    state = state.copyWith(busy: true, clearError: true);
    try {
      final db = ref.read(appDatabaseProvider);
      await CloudAccountOwnership.forgetRootsNotOwnedBy(
        db: db,
        cache: ref.read(cloudCacheStoreProvider),
        artwork: ref.read(artworkCacheStoreProvider),
        provider: _provider,
        keepAccountKey: pending.stableAccountKey,
      );
      await CloudAccountOwnership.bindUnboundIfNoForeignOwners(
        db: db,
        provider: _provider,
        accountKey: pending.stableAccountKey,
      );
      await ref.read(sharedPreferencesProvider).setString(
        CloudAccountOwnership.displayEmailPrefsKey(_provider),
        pending.email,
      );
      state = GoogleDriveSessionState(account: pending);
    } on Object catch (error, stack) {
      debugPrint('Google Drive confirm replacement failed: $error\n$stack');
      state = state.copyWith(busy: false, lastError: error.toString());
    }
  }

  /// Cancels replacement: auth-only sign-out of the pending session.
  Future<void> cancelAccountReplacement() async {
    if (state.pendingAccount == null || state.busy) return;
    state = state.copyWith(busy: true, clearError: true);
    try {
      await ref.read(googleDriveAuthProvider).signOut();
      state = GoogleDriveSessionState.signedOut;
    } on Object catch (error, stack) {
      debugPrint('Google Drive cancel replacement failed: $error\n$stack');
      state = state.copyWith(busy: false, lastError: error.toString());
    }
  }

  /// Signs out and wipes only Google Drive cache files/rows (catalog stays).
  Future<void> signOut() async {
    if (state.busy) return;
    if (state.accountChangeRequired) {
      await cancelAccountReplacement();
      return;
    }
    state = state.copyWith(busy: true, clearError: true);
    try {
      await ref
          .read(cloudCacheStoreProvider)
          .clearForProvider(CloudProviderId.googleDrive);
      await ref.read(googleDriveAuthProvider).signOut();
      state = GoogleDriveSessionState.signedOut;
    } on Object catch (error, stack) {
      debugPrint('Google Drive sign-out failed: $error\n$stack');
      state = state.copyWith(busy: false, lastError: error.toString());
    }
  }
}

/// Session state for personal OneDrive sign-in (Settings).
///
/// Purpose: Hold the signed-in Microsoft account and optional pending
/// account-change confirmation without coupling widgets to `msal_auth` types.
@immutable
class OneDriveSessionState {
  /// Creates a session snapshot.
  const OneDriveSessionState({
    this.account,
    this.pendingAccount,
    this.previousAccountEmail,
    this.lastError,
    this.busy = false,
  });

  /// Signed-out idle state.
  static const signedOut = OneDriveSessionState();

  /// Accepted account, or `null` when signed out / pending replacement.
  final OneDriveAccount? account;

  /// Newly authenticated account waiting for replacement confirmation.
  final OneDriveAccount? pendingAccount;

  /// Display email of the previous owning account (prefs / last known).
  final String? previousAccountEmail;

  /// Last user-visible error message from sign-in / list / sign-out.
  final String? lastError;

  /// Whether an auth or session call is in flight.
  final bool busy;

  /// Whether a Microsoft account is accepted for provider operations.
  bool get isSignedIn => account != null && pendingAccount == null;

  /// Whether the user must confirm replacing another account’s roots.
  bool get accountChangeRequired => pendingAccount != null;

  /// Whether provider list/ingest operations may proceed.
  bool get canUseProvider => isSignedIn && !busy;

  /// Copies this state with optional field overrides.
  OneDriveSessionState copyWith({
    OneDriveAccount? account,
    bool clearAccount = false,
    OneDriveAccount? pendingAccount,
    bool clearPending = false,
    String? previousAccountEmail,
    bool clearPreviousEmail = false,
    String? lastError,
    bool clearError = false,
    bool? busy,
  }) {
    return OneDriveSessionState(
      account: clearAccount ? null : (account ?? this.account),
      pendingAccount:
          clearPending ? null : (pendingAccount ?? this.pendingAccount),
      previousAccountEmail: clearPreviousEmail
          ? null
          : (previousAccountEmail ?? this.previousAccountEmail),
      lastError: clearError ? null : (lastError ?? this.lastError),
      busy: busy ?? this.busy,
    );
  }
}

/// Production [OneDriveAuth]. Tests override [oneDriveAuthProvider].
@Riverpod(keepAlive: true)
OneDriveAuth oneDriveAuth(Ref ref) {
  return MsalOneDriveAuth();
}

/// Controllers OneDrive sign-in / sign-out for Settings.
///
/// Purpose: Drive Settings through a testable seam; bind/replace root ownership;
/// wipe **OneDrive** cache on normal sign-out; restore on first build.
/// Usage Context: Eagerly read from `main`; Settings OneDrive section.
@Riverpod(keepAlive: true)
class OneDriveSessionController extends _$OneDriveSessionController {
  static final _provider = CloudProviderId.oneDrive;

  @override
  OneDriveSessionState build() {
    unawaited(_restoreSession());
    return OneDriveSessionState.signedOut;
  }

  Future<void> _restoreSession() async {
    try {
      final account = await ref.read(oneDriveAuthProvider).restoreSession();
      if (account == null) return;
      if (state.isSignedIn || state.accountChangeRequired || state.busy) {
        return;
      }
      await _acceptOrPending(account);
    } on Object catch (error, stack) {
      debugPrintOneDriveAuthError('session restore', error, stack);
    }
  }

  /// Interactive Microsoft sign-in (may require account-change confirmation).
  Future<void> signIn() async {
    if (state.busy || state.accountChangeRequired) return;
    state = state.copyWith(busy: true, clearError: true);
    try {
      final account = await ref.read(oneDriveAuthProvider).signIn();
      await _acceptOrPending(account);
    } on OneDriveAuthCancelledException {
      state = state.copyWith(busy: false, clearError: true);
    } on Object catch (error, stack) {
      debugPrintOneDriveAuthError('sign-in', error, stack);
      state = state.copyWith(
        busy: false,
        lastError: redactOneDriveAuthError(error),
      );
    }
  }

  Future<void> _acceptOrPending(OneDriveAccount account) async {
    final db = ref.read(appDatabaseProvider);
    final prefs = ref.read(sharedPreferencesProvider);
    final previousEmail = prefs.getString(
      CloudAccountOwnership.displayEmailPrefsKey(_provider),
    );
    final conflict = await CloudAccountOwnership.hasConflictingOwnedRoots(
      db: db,
      provider: _provider,
      accountKey: account.stableAccountKey,
    );
    if (conflict) {
      state = OneDriveSessionState(
        pendingAccount: account,
        previousAccountEmail: previousEmail,
        busy: false,
      );
      return;
    }
    await CloudAccountOwnership.bindUnboundIfNoForeignOwners(
      db: db,
      provider: _provider,
      accountKey: account.stableAccountKey,
    );
    await prefs.setString(
      CloudAccountOwnership.displayEmailPrefsKey(_provider),
      account.email,
    );
    state = OneDriveSessionState(account: account);
  }

  /// Confirms replacement: forgets foreign/unbound OneDrive roots, accepts pending.
  Future<void> confirmAccountReplacement() async {
    final pending = state.pendingAccount;
    if (pending == null || state.busy) return;
    state = state.copyWith(busy: true, clearError: true);
    try {
      final db = ref.read(appDatabaseProvider);
      await CloudAccountOwnership.forgetRootsNotOwnedBy(
        db: db,
        cache: ref.read(cloudCacheStoreProvider),
        artwork: ref.read(artworkCacheStoreProvider),
        provider: _provider,
        keepAccountKey: pending.stableAccountKey,
      );
      await CloudAccountOwnership.bindUnboundIfNoForeignOwners(
        db: db,
        provider: _provider,
        accountKey: pending.stableAccountKey,
      );
      await ref.read(sharedPreferencesProvider).setString(
        CloudAccountOwnership.displayEmailPrefsKey(_provider),
        pending.email,
      );
      state = OneDriveSessionState(account: pending);
    } on Object catch (error, stack) {
      debugPrintOneDriveAuthError('confirm replacement', error, stack);
      state = state.copyWith(
        busy: false,
        lastError: redactOneDriveAuthError(error),
      );
    }
  }

  /// Cancels replacement: auth-only MSAL sign-out of the pending session.
  Future<void> cancelAccountReplacement() async {
    if (state.pendingAccount == null || state.busy) return;
    state = state.copyWith(busy: true, clearError: true);
    try {
      await ref.read(oneDriveAuthProvider).signOut();
      state = OneDriveSessionState.signedOut;
    } on Object catch (error, stack) {
      debugPrintOneDriveAuthError('cancel replacement', error, stack);
      state = state.copyWith(
        busy: false,
        lastError: redactOneDriveAuthError(error),
      );
    }
  }

  /// Signs out and wipes only OneDrive cache files/rows (catalog stays).
  Future<void> signOut() async {
    if (state.busy) return;
    if (state.accountChangeRequired) {
      await cancelAccountReplacement();
      return;
    }
    state = state.copyWith(busy: true, clearError: true);
    try {
      await ref
          .read(cloudCacheStoreProvider)
          .clearForProvider(CloudProviderId.oneDrive);
      await ref.read(oneDriveAuthProvider).signOut();
      state = OneDriveSessionState.signedOut;
    } on Object catch (error, stack) {
      debugPrintOneDriveAuthError('sign-out', error, stack);
      state = state.copyWith(
        busy: false,
        lastError: redactOneDriveAuthError(error),
      );
    }
  }
}

