import 'package:flutter_test/flutter_test.dart';
import 'package:tinytunes/core/cloud/cloud_media_locator.dart';
import 'package:tinytunes/core/cloud/cloud_provider_id.dart';
import 'package:tinytunes/core/cloud/google_drive/google_drive_media_locator.dart';
import 'package:tinytunes/core/cloud/one_drive/one_drive_media_locator.dart';
import 'package:tinytunes/core/library/media_locator.dart';

void main() {
  group('CloudMediaLocator', () {
    test('providerOf maps gdrive and onedrive prefixes', () {
      expect(
        CloudMediaLocator.providerOf(DriveMediaLocator.encode('abc')),
        CloudProviderId.googleDrive,
      );
      expect(
        CloudMediaLocator.providerOf(
          OneDriveMediaLocator.encode(driveId: 'd1', itemId: 'i1'),
        ),
        CloudProviderId.oneDrive,
      );
    });

    test('providerOf rejects unknown and empty payloads', () {
      expect(
        () => CloudMediaLocator.providerOf(const MediaLocator('dropbox:x')),
        throwsFormatException,
      );
      expect(
        () => CloudMediaLocator.providerOf(const MediaLocator('gdrive:')),
        throwsFormatException,
      );
    });
  });

  group('OneDriveMediaLocator', () {
    test('round-trips escaped drive and item ids', () {
      final locator = OneDriveMediaLocator.encode(
        driveId: 'drive/with:chars',
        itemId: 'item/with:chars',
      );
      expect(locator.value, startsWith('onedrive:'));
      final decoded = OneDriveMediaLocator.decode(locator);
      expect(decoded.driveId, 'drive/with:chars');
      expect(decoded.itemId, 'item/with:chars');
    });

    test('rejects personal-root sentinel for persistence decode', () {
      expect(OneDriveMediaLocator.isPersonalRoot(OneDriveMediaLocator.personalRoot), isTrue);
      expect(
        () => OneDriveMediaLocator.decode(OneDriveMediaLocator.personalRoot),
        throwsFormatException,
      );
    });

    test('rejects malformed payloads', () {
      expect(
        () => OneDriveMediaLocator.decode(const MediaLocator('onedrive:onlydrive')),
        throwsFormatException,
      );
      expect(
        () => OneDriveMediaLocator.decode(const MediaLocator('gdrive:x')),
        throwsFormatException,
      );
    });
  });
}
