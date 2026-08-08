import 'package:flutter/foundation.dart';
import 'package:msal_auth/msal_auth.dart';
import 'package:tinytunes/core/cloud/one_drive/one_drive_error_redaction.dart';
import 'package:tinytunes/core/cloud/one_drive/one_drive_oauth_config.dart';

/// Signed-in personal Microsoft account snapshot for OneDrive.
///
/// Purpose: Expose stable ownership identity + display email without leaking
/// MSAL plugin types into feature widgets.
/// Usage Context: Returned by [OneDriveAuth.currentAccount].
@immutable
class OneDriveAccount {
  /// Creates an account with [stableAccountKey] and display [email].
  const OneDriveAccount({
    required this.stableAccountKey,
    required this.email,
    this.displayName,
  });

  /// Stable provider account id (MSAL home OID). Never use email as ownership.
  final String stableAccountKey;

  /// Preferred username / email for Settings display.
  final String email;

  /// Optional display name from the Microsoft profile.
  final String? displayName;
}

/// Thrown when the user cancels the interactive Microsoft sign-in UI.
class OneDriveAuthCancelledException implements Exception {
  /// Creates a cancellation error.
  const OneDriveAuthCancelledException();

  @override
  String toString() => 'OneDriveAuthCancelledException';
}

/// Thrown when silent token acquisition requires interactive UI.
class OneDriveAuthUiRequiredException implements Exception {
  /// Creates a UI-required error with a safe [message].
  const OneDriveAuthUiRequiredException(this.message);

  /// Redacted user-visible reason.
  final String message;

  @override
  String toString() => 'OneDriveAuthUiRequiredException($message)';
}

/// Read-only personal Microsoft authentication for OneDrive / Graph.
///
/// Purpose: Isolate `msal_auth` so tests can fake sign-in without native MSAL.
/// Usage Context: Settings OneDrive section and Graph remote clients.
abstract class OneDriveAuth {
  /// Currently signed-in account, or `null` when signed out.
  OneDriveAccount? get currentAccount;

  /// Interactive sign-in; returns the account after consent.
  Future<OneDriveAccount> signIn();

  /// Clears the local MSAL session only (no catalog/cache mutation).
  Future<void> signOut();

  /// Restores a prior MSAL session without interactive UI when possible.
  Future<OneDriveAccount?> restoreSession();

  /// Returns a Graph access token for [OneDriveOAuthConfig.graphScopes].
  ///
  /// Prefers silent acquisition; throws [OneDriveAuthUiRequiredException] when
  /// interactive consent is required again.
  Future<String> accessTokenForGraphReadonly();
}

/// Production [OneDriveAuth] backed by [SingleAccountPca] (Android).
///
/// Purpose: Settings OneDrive sign-in and Graph token acquisition.
/// Usage Context: Wired via Riverpod; Android-only for this rollout.
class MsalOneDriveAuth implements OneDriveAuth {
  /// Creates auth; [pcaFactory] is injectable for unit tests.
  MsalOneDriveAuth({
    Future<SingleAccountPca> Function()? pcaFactory,
  }) : _pcaFactory = pcaFactory ?? _defaultPcaFactory;

  final Future<SingleAccountPca> Function() _pcaFactory;
  SingleAccountPca? _pca;
  OneDriveAccount? _account;

  static Future<SingleAccountPca> _defaultPcaFactory() {
    if (defaultTargetPlatform != TargetPlatform.android) {
      throw UnsupportedError(
        'OneDrive MSAL auth is Android-only in this rollout',
      );
    }
    return SingleAccountPca.create(
      clientId: OneDriveOAuthConfig.clientId,
      androidConfig: AndroidConfig(
        configFilePath: OneDriveOAuthConfig.androidConfigAssetPath,
        redirectUri: OneDriveOAuthConfig.androidRedirectUri,
      ),
    );
  }

  @override
  OneDriveAccount? get currentAccount => _account;

  Future<SingleAccountPca> _ensurePca() async {
    final existing = _pca;
    if (existing != null) return existing;
    final created = await _pcaFactory();
    _pca = created;
    return created;
  }

  @override
  Future<OneDriveAccount> signIn() async {
    final pca = await _ensurePca();
    try {
      final result = await pca.acquireToken(
        scopes: OneDriveOAuthConfig.graphScopes,
        prompt: Prompt.whenRequired,
      );
      final account = _mapAccount(result.account, fallbackUsername: null);
      _account = account;
      return account;
    } on MsalUserCancelException {
      throw const OneDriveAuthCancelledException();
    } on MsalException catch (error, stack) {
      debugPrintOneDriveAuthError('signIn', error, stack);
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    final pca = await _ensurePca();
    try {
      await pca.signOut();
    } on MsalNoCurrentAccountException {
      // Already signed out in the native cache.
    } on MsalException catch (error, stack) {
      debugPrintOneDriveAuthError('signOut', error, stack);
      rethrow;
    } finally {
      _account = null;
    }
  }

  @override
  Future<OneDriveAccount?> restoreSession() async {
    try {
      final pca = await _ensurePca();
      try {
        final current = await pca.currentAccount;
        final account = _mapAccount(current, fallbackUsername: null);
        // Prove a silent token works while restoring.
        await pca.acquireTokenSilent(scopes: OneDriveOAuthConfig.graphScopes);
        _account = account;
        return account;
      } on MsalNoCurrentAccountException {
        _account = null;
        return null;
      } on MsalUiRequiredException catch (error, stack) {
        debugPrintOneDriveAuthError('restoreSession.uiRequired', error, stack);
        _account = null;
        return null;
      }
    } on Object catch (error, stack) {
      debugPrintOneDriveAuthError('restoreSession', error, stack);
      return null;
    }
  }

  @override
  Future<String> accessTokenForGraphReadonly() async {
    final pca = await _ensurePca();
    try {
      if (_account == null) {
        await restoreSession();
      }
      final result = await pca.acquireTokenSilent(
        scopes: OneDriveOAuthConfig.graphScopes,
      );
      _account = _mapAccount(result.account, fallbackUsername: _account?.email);
      final token = result.accessToken;
      if (token.isEmpty) {
        throw StateError('Graph access token was empty after silent acquire');
      }
      return token;
    } on MsalUiRequiredException catch (error, stack) {
      debugPrintOneDriveAuthError('accessToken.uiRequired', error, stack);
      throw OneDriveAuthUiRequiredException(redactOneDriveAuthError(error));
    } on MsalNoCurrentAccountException catch (error, stack) {
      debugPrintOneDriveAuthError('accessToken.noAccount', error, stack);
      throw OneDriveAuthUiRequiredException(redactOneDriveAuthError(error));
    } on MsalException catch (error, stack) {
      debugPrintOneDriveAuthError('accessToken', error, stack);
      rethrow;
    }
  }

  static OneDriveAccount _mapAccount(
    Account account, {
    required String? fallbackUsername,
  }) {
    final id = account.id.trim();
    if (id.isEmpty) {
      throw StateError('MSAL account is missing a stable id');
    }
    final username = (account.username ?? fallbackUsername)?.trim();
    if (username == null || username.isEmpty) {
      throw StateError('MSAL account is missing a username/email');
    }
    final name = account.name?.trim();
    return OneDriveAccount(
      stableAccountKey: id,
      email: username,
      displayName: (name == null || name.isEmpty) ? null : name,
    );
  }
}
