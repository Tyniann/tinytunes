import 'package:flutter/foundation.dart';

/// Public Microsoft Entra identifiers for personal OneDrive (Android).
///
/// Purpose: Hold the Application (client) ID and Android redirect URIs without
/// shipping a client secret.
/// Usage Context: [MsalOneDriveAuth] initialization only.
///
/// **BYO OAuth:** Forks must create their own Entra registration and replace
/// [clientId] plus the signature-hash redirect URIs. See
/// `docs/legal/android-signing-and-oauth.md`.
abstract final class OneDriveOAuthConfig {
  /// Entra Application (client) ID for maintainer builds (public).
  static const clientId = 'c2ed77e3-5443-4251-94c2-b6e1916d084d';

  /// Android package name registered in Entra.
  static const androidPackageName = 'at.blumenlaube.tinytunes';

  /// Debug signing-certificate signature hash (Base64 of SHA-1).
  static const debugSignatureHash = 'kNrKEKVATPOALWoi2IiGqfnphGM=';

  /// Release signing-certificate signature hash (Base64 of SHA-1).
  static const releaseSignatureHash = 'yA+8T1x4a9pYEu1mYe58Quq7f5Y=';

  /// Asset path for the Android MSAL JSON config (no client id / redirect).
  static const androidConfigAssetPath = 'assets/msal_config.json';

  /// Microsoft Graph delegated scopes for personal OneDrive read + identity.
  ///
  /// Do **not** request `offline_access` explicitly: personal-account tokens
  /// decline that scope and `msal_auth` fails the whole acquire with
  /// [MsalDeclinedScopeException]. MSAL still caches tokens for silent renew
  /// after a successful interactive grant of the scopes below.
  static const graphScopes = <String>[
    'https://graph.microsoft.com/Files.Read',
    'https://graph.microsoft.com/User.Read',
    'openid',
    'profile',
  ];

  /// Redirect URI for the current build type (debug vs release signature).
  static String get androidRedirectUri {
    final hash = kReleaseMode ? releaseSignatureHash : debugSignatureHash;
    return 'msauth://$androidPackageName/${Uri.encodeComponent(hash)}';
  }

  /// Manifest path segment (`/` + raw Base64 hash) for [BrowserTabActivity].
  static String get androidManifestSignaturePath {
    final hash = kReleaseMode ? releaseSignatureHash : debugSignatureHash;
    return '/$hash';
  }
}
