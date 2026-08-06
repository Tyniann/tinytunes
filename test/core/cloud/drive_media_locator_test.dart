import 'package:flutter_test/flutter_test.dart';
import 'package:tinytunes/core/cloud/drive_media_locator.dart';
import 'package:tinytunes/core/library/media_locator.dart';

void main() {
  group('DriveMediaLocator', () {
    test('encode wraps a Drive file id with the gdrive prefix', () {
      expect(
        DriveMediaLocator.encode('1abcXYZ'),
        const MediaLocator('gdrive:1abcXYZ'),
      );
    });

    test('decode returns the Drive file id from a gdrive locator', () {
      expect(
        DriveMediaLocator.decode(const MediaLocator('gdrive:1abcXYZ')),
        '1abcXYZ',
      );
    });

    test('decode throws when the locator is not a gdrive token', () {
      expect(
        () => DriveMediaLocator.decode(
          const MediaLocator('content://tree/music'),
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('isDriveLocator is true only for the gdrive prefix', () {
      expect(
        DriveMediaLocator.isDriveLocator(const MediaLocator('gdrive:x')),
        isTrue,
      );
      expect(
        DriveMediaLocator.isDriveLocator(
          const MediaLocator('content://tree/x'),
        ),
        isFalse,
      );
    });

    test('encode rejects empty Drive file ids', () {
      expect(() => DriveMediaLocator.encode(''), throwsArgumentError);
      expect(() => DriveMediaLocator.encode('  '), throwsArgumentError);
    });
  });
}
