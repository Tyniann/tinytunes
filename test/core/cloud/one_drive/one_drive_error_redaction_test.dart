import 'package:flutter_test/flutter_test.dart';
import 'package:tinytunes/core/cloud/one_drive/one_drive_error_redaction.dart';

void main() {
  test('redacts bearer tokens and emails from auth errors', () {
    final raw =
        'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.payload.sig '
        'failed for user@outlook.com access_token=supersecrettokenvalue';
    final redacted = redactOneDriveAuthError(raw);
    expect(redacted, isNot(contains('eyJ')));
    expect(redacted, isNot(contains('user@outlook.com')));
    expect(redacted, isNot(contains('supersecrettokenvalue')));
    expect(redacted, contains('[redacted-token]'));
    expect(redacted, contains('[redacted-email]'));
  });

  test('leaves non-sensitive messages intact', () {
    const raw = 'MsalUiRequiredException: interaction required';
    expect(redactOneDriveAuthError(raw), raw);
  });
}
