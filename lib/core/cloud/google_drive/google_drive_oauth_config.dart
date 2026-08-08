/// Public Google OAuth identifiers for TinyTunes Drive access.
///
/// Purpose: Hold the Web application Client ID used as `serverClientId` on
/// Android without shipping a client secret or Firebase config.
/// Usage Context: [GoogleSignInDriveAuth] initialization only.
///
/// **BYO OAuth:** Forks and self-built APKs must create their own Google Cloud
/// OAuth clients and replace [serverClientId]. The value below is for
/// maintainer builds only — not a verified public multi-user OAuth app.
/// See `docs/legal/android-signing-and-oauth.md` and the project README.
///
/// The Android OAuth client (package + SHA-1) stays Console-only — Play Services
/// matches the installed APK; do not embed that client id here.
abstract final class GoogleOAuthConfig {
  /// Web OAuth Client ID (`serverClientId` for `google_sign_in` on Android).
  ///
  /// Replace with your own Web client ID when forking or shipping your own APK.
  static const serverClientId =
      '603107338638-gc0kmt8iq6enerqd9qtipcqvencsgq15.apps.googleusercontent.com';

  /// Read-only Drive scope requested after authentication.
  static const driveReadonlyScope =
      'https://www.googleapis.com/auth/drive.readonly';
}
