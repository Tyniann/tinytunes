import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Reads the installed APK’s signing-certificate SHA-1 (MSAL Base64 form).
///
/// Purpose: Compare against the official release SHA-1 without a third-party
/// package. Usage Context: [isOfficialApkProvider].
abstract class InstalledSigningHashSource {
  /// Base64 SHA-1 of the current signer, or `null` when unavailable.
  Future<String?> sha1Base64();
}

/// Android [InstalledSigningHashSource] via a narrow MethodChannel.
class AndroidInstalledSigningHashSource implements InstalledSigningHashSource {
  /// Creates a source using the default package-identity channel.
  AndroidInstalledSigningHashSource({MethodChannel? channel})
    : _channel =
          channel ??
          const MethodChannel('at.blumenlaube.tinytunes/package_identity');

  final MethodChannel _channel;

  @override
  Future<String?> sha1Base64() async {
    try {
      return await _channel.invokeMethod<String>('sha1Base64');
    } on Object catch (error, stack) {
      debugPrint('Installed signing hash failed: $error\n$stack');
      return null;
    }
  }
}

/// Always-null source for tests and non-Android hosts.
class NullInstalledSigningHashSource implements InstalledSigningHashSource {
  /// Creates a source that never reports a signing hash.
  const NullInstalledSigningHashSource();

  @override
  Future<String?> sha1Base64() async => null;
}
