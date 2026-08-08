import 'package:tinytunes/core/cloud/google_drive/google_drive_auth.dart';

/// In-memory [GoogleDriveAuth] for unit tests (no Play Services).
class FakeGoogleDriveAuth implements GoogleDriveAuth {
  /// Creates a fake with optional [account] and injectable failures.
  FakeGoogleDriveAuth({
    this.account,
    this.signInAccount = const GoogleDriveAccount(
      stableAccountKey: 'gid-user',
      email: 'user@example.com',
      displayName: 'Example User',
    ),
    this.accessToken = 'fake-token',
    this.signInError,
    this.tokenError,
  });

  /// Mutable account used by [currentAccount].
  GoogleDriveAccount? account;

  /// Account returned by a successful [signIn].
  GoogleDriveAccount signInAccount;

  /// Token returned by [accessTokenForDriveReadonly].
  String accessToken;

  /// When set, [signIn] throws this object.
  Object? signInError;

  /// When set, [accessTokenForDriveReadonly] throws this object.
  Object? tokenError;

  /// How many times [signIn] was called.
  int signInCalls = 0;

  /// How many times [signOut] was called.
  int signOutCalls = 0;

  /// How many times [restoreSession] was called.
  int restoreCalls = 0;

  /// How many times [accessTokenForDriveReadonly] was called.
  int tokenCalls = 0;

  @override
  GoogleDriveAccount? get currentAccount => account;

  @override
  Future<GoogleDriveAccount> signIn() async {
    signInCalls++;
    final error = signInError;
    if (error != null) throw error;
    account = signInAccount;
    return account!;
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;
    account = null;
  }

  @override
  Future<GoogleDriveAccount?> restoreSession() async {
    restoreCalls++;
    return account;
  }

  @override
  Future<String> accessTokenForDriveReadonly() async {
    tokenCalls++;
    final error = tokenError;
    if (error != null) throw error;
    if (account == null) {
      throw StateError('Not signed in');
    }
    return accessToken;
  }
}
