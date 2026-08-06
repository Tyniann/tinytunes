import 'package:flutter_test/flutter_test.dart';
import 'package:tinytunes/core/cloud/drive_media_locator.dart';
import 'package:tinytunes/core/cloud/google_drive_auth.dart';
import 'package:tinytunes/core/cloud/google_drive_probe.dart';
import 'package:tinytunes/core/library/media_locator.dart';

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

  test('FakeGoogleDriveProbe returns injected Drive entries', () async {
    final auth = FakeGoogleDriveAuth()
      ..account = const GoogleDriveAccount(email: 'user@example.com');
    final folder = DriveProbeEntry(
      locator: DriveMediaLocator.encode('folder1'),
      name: 'Music',
      isDirectory: true,
    );
    final probe = FakeGoogleDriveProbe(auth, entries: [folder]);

    final listed = await probe.listMyDriveRoot();
    expect(listed, hasLength(1));
    expect(listed.single.name, 'Music');
    expect(listed.single.locator, const MediaLocator('gdrive:folder1'));
    expect(listed.single.isDirectory, isTrue);
  });
}
