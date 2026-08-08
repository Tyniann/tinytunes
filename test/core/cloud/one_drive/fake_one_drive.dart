import 'package:tinytunes/core/cloud/one_drive/one_drive_auth.dart';

/// In-memory [OneDriveAuth] for unit tests (no native MSAL).
class FakeOneDriveAuth implements OneDriveAuth {
  /// Creates a fake with optional [account] and injectable failures.
  FakeOneDriveAuth({
    this.account,
    this.signInAccount = const OneDriveAccount(
      stableAccountKey: 'oid-example',
      email: 'user@outlook.com',
      displayName: 'Example User',
    ),
    this.accessToken = 'fake-graph-token',
    this.signInError,
    this.tokenError,
    this.restoreError,
  });

  /// Mutable account used by [currentAccount].
  OneDriveAccount? account;

  /// Account returned by a successful [signIn].
  OneDriveAccount signInAccount;

  /// Token returned by [accessTokenForGraphReadonly].
  String accessToken;

  /// When set, [signIn] throws this object.
  Object? signInError;

  /// When set, [accessTokenForGraphReadonly] throws this object.
  Object? tokenError;

  /// When set, [restoreSession] throws this object.
  Object? restoreError;

  /// How many times [signIn] was called.
  int signInCalls = 0;

  /// How many times [signOut] was called.
  int signOutCalls = 0;

  /// How many times [restoreSession] was called.
  int restoreCalls = 0;

  /// How many times [accessTokenForGraphReadonly] was called.
  int tokenCalls = 0;

  @override
  OneDriveAccount? get currentAccount => account;

  @override
  Future<OneDriveAccount> signIn() async {
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
  Future<OneDriveAccount?> restoreSession() async {
    restoreCalls++;
    final error = restoreError;
    if (error != null) throw error;
    return account;
  }

  @override
  Future<String> accessTokenForGraphReadonly() async {
    tokenCalls++;
    final error = tokenError;
    if (error != null) throw error;
    if (account == null) {
      throw const OneDriveAuthUiRequiredException('Not signed in');
    }
    return accessToken;
  }
}
