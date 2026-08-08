import 'package:flutter_test/flutter_test.dart';

import 'fake_google_drive.dart';

void main() {
  test('FakeGoogleDriveAuth sign-in then sign-out clears account', () async {
    final auth = FakeGoogleDriveAuth();
    expect(auth.currentAccount, isNull);

    final account = await auth.signIn();
    expect(account.email, 'user@example.com');
    expect(auth.currentAccount?.email, 'user@example.com');
    expect(await auth.accessTokenForDriveReadonly(), 'fake-token');

    await auth.signOut();
    expect(auth.currentAccount, isNull);
    expect(auth.signOutCalls, 1);
  });
}
