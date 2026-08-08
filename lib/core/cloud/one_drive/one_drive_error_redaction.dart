import 'package:flutter/foundation.dart';

/// Redacts tokens and common PII fragments from auth error strings.
///
/// Purpose: Keep Settings / debugPrint output free of bearer tokens and emails
/// when MSAL or Graph failures are surfaced.
/// Usage Context: [MsalOneDriveAuth] and [OneDriveSessionController] error paths.
String redactOneDriveAuthError(Object error) {
  var text = error.toString();
  // Long JWT / opaque tokens.
  text = text.replaceAllMapped(
    RegExp(r'(eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9._-]{10,})'),
    (_) => '[redacted-token]',
  );
  text = text.replaceAllMapped(
    RegExp(
      r'(Bearer\s+)[A-Za-z0-9\-._~+/]+=*',
      caseSensitive: false,
    ),
    (m) => '${m[1]}[redacted-token]',
  );
  text = text.replaceAllMapped(
    RegExp(r'(access[_-]?token["\s:=]+)[^\s,"}]+', caseSensitive: false),
    (m) => '${m[1]}[redacted-token]',
  );
  text = text.replaceAllMapped(
    RegExp(r'(refresh[_-]?token["\s:=]+)[^\s,"}]+', caseSensitive: false),
    (m) => '${m[1]}[redacted-token]',
  );
  // Email-shaped fragments.
  text = text.replaceAllMapped(
    RegExp(r'[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}', caseSensitive: false),
    (_) => '[redacted-email]',
  );
  return text;
}

/// Logs a redacted OneDrive auth failure once.
void debugPrintOneDriveAuthError(String context, Object error, StackTrace stack) {
  debugPrint(
    'OneDrive $context failed: ${redactOneDriveAuthError(error)}\n$stack',
  );
}
