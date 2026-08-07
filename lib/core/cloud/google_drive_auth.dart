import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tinytunes/core/cloud/google_oauth_config.dart';

/// Signed-in Google account snapshot for Drive access.
///
/// Purpose: Expose only what Settings / cloud ingest need without leaking
/// plugin types into feature widgets.
/// Usage Context: Returned by [GoogleDriveAuth.currentAccount].
@immutable
class GoogleDriveAccount {
  /// Creates an account row with [email] and optional [displayName].
  const GoogleDriveAccount({required this.email, this.displayName});

  /// Primary email from Google Sign-In.
  final String email;

  /// Optional display name from the Google profile.
  final String? displayName;
}

/// Read-only Google authentication and Drive scope authorization.
///
/// Purpose: Isolate `google_sign_in` so tests can fake sign-in without Play
/// Services, and production can obtain a Drive access token.
/// Usage Context: Settings cloud section; Drive API clients.
abstract class GoogleDriveAuth {
  /// Currently signed-in account, or `null` when signed out.
  GoogleDriveAccount? get currentAccount;

  /// Signs the user in (interactive) and returns the account.
  Future<GoogleDriveAccount> signIn();

  /// Clears the local Google session.
  Future<void> signOut();

  /// Restores a prior platform session without interactive UI when possible.
  Future<GoogleDriveAccount?> restoreSession();

  /// Returns a Drive access token for [GoogleOAuthConfig.driveReadonlyScope].
  ///
  /// May show a consent UI when scopes were not previously granted.
  Future<String> accessTokenForDriveReadonly();
}

/// Production [GoogleDriveAuth] backed by [GoogleSignIn].
///
/// Purpose: Android Phase 7 OAuth spike and later Settings sign-in.
/// Usage Context: Wired via Riverpod; call [ensureInitialized] once before use.
class GoogleSignInDriveAuth implements GoogleDriveAuth {
  /// Creates auth using the process-wide [GoogleSignIn.instance].
  GoogleSignInDriveAuth({GoogleSignIn? signIn})
    : _signIn = signIn ?? GoogleSignIn.instance;

  final GoogleSignIn _signIn;
  GoogleSignInAccount? _user;
  bool _initialized = false;

  static const _scopes = <String>[GoogleOAuthConfig.driveReadonlyScope];

  @override
  GoogleDriveAccount? get currentAccount {
    final user = _user;
    if (user == null) return null;
    return GoogleDriveAccount(email: user.email, displayName: user.displayName);
  }

  /// Initializes the plugin with [GoogleOAuthConfig.serverClientId] once.
  Future<void> ensureInitialized() async {
    if (_initialized) return;
    await _signIn.initialize(serverClientId: GoogleOAuthConfig.serverClientId);
    _initialized = true;
  }

  @override
  Future<GoogleDriveAccount> signIn() async {
    await ensureInitialized();
    _user = await _signIn.authenticate(scopeHint: _scopes);
    return currentAccount!;
  }

  @override
  Future<void> signOut() async {
    await ensureInitialized();
    await _signIn.signOut();
    _user = null;
  }

  @override
  Future<GoogleDriveAccount?> restoreSession() => attemptLightweightSignIn();

  @override
  Future<String> accessTokenForDriveReadonly() async {
    await ensureInitialized();
    var user = _user;
    if (user == null) {
      // Prefer silent restore so cold-start cloud play does not force UI.
      await attemptLightweightSignIn();
      user = _user;
    }
    if (user == null) {
      user = await _signIn.authenticate(scopeHint: _scopes);
      _user = user;
    }
    var authorization = await user.authorizationClient.authorizationForScopes(
      _scopes,
    );
    authorization ??= await user.authorizationClient.authorizeScopes(_scopes);
    final token = authorization.accessToken;
    if (token.isEmpty) {
      throw StateError('Drive access token was empty after authorization');
    }
    return token;
  }

  /// Restores a lightweight session if the platform still has a signed-in user.
  Future<GoogleDriveAccount?> attemptLightweightSignIn() async {
    await ensureInitialized();
    try {
      final pending = _signIn.attemptLightweightAuthentication();
      if (pending == null) return null;
      final user = await pending;
      if (user == null) return null;
      _user = user;
      return currentAccount;
    } on Object catch (error, stack) {
      debugPrint('lightweight Google sign-in failed: $error\n$stack');
      return null;
    }
  }
}
